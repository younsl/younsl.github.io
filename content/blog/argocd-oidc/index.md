---
title: "argocd oidc"
date: 2024-11-26T00:44:30+09:00
lastmod: 2024-11-26T00:44:35+09:00
slug: ""
description: "argocd oidc"
keywords: []
tags: ["kubernetes", "argocd", "oidc"]
---

## 개요

이 문서에서는 `argocd`와 Google 그룹을 연동하여 권한 관리를 설정하는 방법을 설명합니다. OpenID Connect(OIDC) 프로토콜을 활용하여 Google Groups의 멤버십 정보를 기반으로 RBAC(Role-Based Access Control)를 구성하는 방법을 다룹니다.

&nbsp;

`dex`는 ArgoCD의 인증 및 권한 부여를 담당하는 컴포넌트로, 다양한 인증 프로토콜을 지원합니다. 예를 들어, OpenID Connect, OAuth2, SAML 등이 있습니다. Google Groups와의 통합을 통해 사용자 정보를 안전하게 관리하고, RBAC 설정을 통해 세밀한 권한 제어를 가능하게 합니다.

&nbsp;

## 환경

- `argocd` 버전: v2.9.5 (차트 버전 5.53.12)
- Helm install
- `dex` 버전: v2.38.0

&nbsp;

## 배경지식

### ArgoCD와 Google Workspace 사용자 연동

Argo CD 로그인을 Google Workspace 사용자와 통합하는 방법에는 세 가지가 있습니다. 일반적으로 OpenID Connect(OIDC) 방법은 이 통합을 수행하는 데 권장되는 방법이지만(그리고 더 쉽습니다...), 필요에 따라 다른 옵션을 선택할 수 있습니다.

| 방법 | 그룹메일 지원 | 상태 |
|-----|-----------|------|
| OpenID Connect using Dex | X | Recommended |
| SAML App Auth using Dex | X | Deprecated |
| OpenID Connect plus Google Groups | O | Recommended |

> ⚠️ Google 그룹메일(Google Groups)을 사용해서 ArgoCD 권한 관리가 필요한 경우, 반드시 `OpenID Connect plus Google Groups using Dex` 방법으로 연동해야 합니다.

1. **OpenID Connect using Dex** (권장): 사용자가 속한 그룹에 대한 정보가 필요하지 않은 경우 추천되는 로그인 방법입니다. Google은 OIDC를 통해 그룹 클레임을 노출하지 않기 때문에 Google Groups의 멤버십 정보를 RBAC에 사용할 수 없다는 단점이 있습니다.
2. **SAML App Auth using Dex** (권장하지 않음): Dex는 이 방법을 권장하지 않습니다. 또한, 이 방법을 사용하면 Google Groups 멤버십 정보를 가져올 수 없습니다. [Dex 공식문서](https://dexidp.io/docs/connectors/saml/#warning)에 따르면 SAML 방식은 안전하지 않은 것으로 간주되며, Dex에서는 해당 모듈을 더 이상 지원하지 않을 계획입니다. 자세한 사항은 [dex의 #1884](https://github.com/dexidp/dex/discussions/1884) 이슈를 확인합니다.
3. **OpenID Connect plus Google Groups using Dex** (권장): Google Groups 멤버십 정보를 RBAC 설정에 사용해야 하는 경우 추천되는 방법입니다. `dex` 서버가 파드에 마운트된 service account를 사용해 Google Admin API에 접근한 후, 그룹메일 정보를 가져오는 방법입니다.

> ⚠️ SAML App Auth using Dex는 유지보수가 중단되었으며, [인증 우회 취약점](https://github.com/synacktiv/CVE-2024-45409)에 노출될 가능성이 높습니다. 이 방법은 보안상의 이유로 권장되지 않으며, 향후 `dex` 커넥터에서 제외될 가능성이 있습니다. SAML 방식 대신 OpenID Connect, OAuth2 또는 LDAP와 같은 더 안전하고 현대적인 프로토콜을 사용하는 것을 권장합니다.

&nbsp;

## 설정하기

**OpenID Connect plus Google Groups using Dex** 방식에서 `dex` 서버는 다음과 같이 Google Groups에 연동됩니다.

![dex의 Google Groups 권한획득 구조](./0.png)

&nbsp;

### 1. 서비스 계정 만들기

도메인 전체 위임(Domain-wide Delegation)을 사용하여 서비스 계정(service account)을 만들려면 Google 공식문서 [액세스 사용자 인증 정보 만들기](https://developers.google.com/admin-sdk/directory/v1/guides/delegation)를 참고합니다.

serviceAccount에 API scope를 할당할 때는 `https://www.googleapis.com/auth/admin.directory.group.readonly` scope만 할당하고 다른 것은 할당하지 마세요. 다른 scope를 할당하면 API에서 정보를 가져올 수 없습니다. 이 권한은 `dex` 서버가 service account를 사용해 Google Admin API에 접근하기 위해 필요합니다. Google Groups의 그룹메일 정보를 가져오기 위해서는 반드시 이 scope를 할당해야 합니다.

&nbsp;

아래는 Google Workspace Console에서 `dex` 서버가 사용할 서비스 계정에 [도메인 전체 위임(domain-wide delegation)](https://support.google.com/a/answer/162106?hl=ko)을 설정하는 화면입니다.

도메인 전체 위임은 클라이언트 애플리케이션(이 경우 `dex` 서버)에 사용자의 동의 없이도 Workspace 사용자 데이터에 대한 액세스 권한을 부여할 수 있는 강력한 기능입니다. 이 기능을 통해 `dex` 서버는 Google Admin API에 접근하여 필요한 그룹 정보를 효율적으로 조회할 수 있습니다.

> Google Workspace 어드민 권한을 가진 사용자 계정으로 로그인해야 이 작업을 진행할 수 있습니다.

![Google Workspace Console](./1.png)

Client ID에는 `dex` 서버가 사용할 서비스 계정의 클라이언트 ID를 입력합니다. 범위(scope)에는 `https://www.googleapis.com/auth/admin.directory.group.readonly` scope만 할당합니다.

이후 GCP 프로젝트에서 [Google Admin API](https://console.developers.google.com/apis/library/admin.googleapis.com/)를 활성화합니다. 이 Google Admin API의 일부인 [Directory API](https://developers.google.com/admin-sdk/directory/v1/guides?hl=ko)를 사용하면 `dex` 파드가 service account를 사용해 Google Groups의 그룹메일 정보를 조회할 수 있습니다.

&nbsp;

### 2. 서비스 계정 키 생성

IAM 서비스 계정 키를 JSON 형식으로 자격 증명을 생성한 후 안전한 곳에 보관합니다.

GCP 콘솔에서 다운로드 받은 serviceAccount 키 파일 이름을 식별하기 쉽도록 `dex-google-groups-sa.json`으로 변경합니다.

```bash
mv example-f75ef679f225.json dex-google-groups-sa.json
```

&nbsp;

`dex-google-groups-sa.json` 파일의 내용은 아래와 같습니다.

```json
{
  "type": "service_account",
  "project_id": "<PROJECT_NAME>",
  "private_key_id": "XXXX",
  "private_key": "-----BEGIN PRIVATE KEY-----\nXXXX\n-----END PRIVATE KEY-----\n",
  "client_email": "XXXX@<PROJECT_NAME>.iam.gserviceaccount.com",
  "client_id": "XXXX",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metabeta/x509/XXXX%40<PROJECT_NAME>.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
```

GCP `serviceAccount`의 JSON 포맷 키를 쿠버네티스 시크릿으로 생성한 후 `dex` 컨테이너에 볼륨 마운트해서 사용할 예정입니다.

&nbsp;

### 3. Kubernetes Secret 생성

`dex-google-groups-sa.json` 파일을 `dex` 컨테이너에 마운트할 수 있도록 Kubernetes Secret으로 생성합니다. `argocd`의 `dex` 컨테이너에 마운트할 예정이므로 `argocd` 네임스페이스에 생성합니다.

```bash
kubectl create secret generic argocd-google-groups-json \
  -n argocd \
  --from-file googleAuth.json=dex-google-groups-sa.json
```

```bash
secret/argocd-google-groups-json created
```

&nbsp;

쿠버네티스 시크릿을 만들게 되면 `googleAuth.json` 파일의 내용이 base64 인코딩된 형태로 Secret에 저장됩니다. 아래는 `argocd-google-groups-json` Secret의 YAML 형식입니다.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: argocd-google-groups-json
  namespace: argocd
data:
  googleAuth.json: <JSON_FILE_BASE64_ENCODED>
```

&nbsp;

생성한 `argocd-google-groups-json` Secret을 확인합니다.

```bash
kubectl get secret -n argocd argocd-google-groups-json
```

```bash
NAME                        TYPE     beta   AGE
argocd-google-groups-json   Opaque   1      28s
```

&nbsp;

### 4. values.yaml 파일 설정

`dex` 컨테이너에 마운트할 수 있도록 `dex` 차트의 `values.yaml` 파일에 설정합니다.

```yaml
# charts/argocd/values.yaml
dex:
  # -- Additional volumeMounts to the dex main container
  volumeMounts:
    - name: google-json
      mountPath: /tmp/oidc
      readOnly: true

  # -- Additional volumes to the dex pod
  volumes:
    - name: google-json
      secret:
        defaultMode: 420
        secretName: argocd-google-groups-json
```

`dex` 파드 안에 `/tmp/oidc/googleAuth.json` 경로에 JSON 파일이 마운트됩니다. `googleAuth.json` 파일의 목적은 `dex` 서버가 service account를 사용해 Google Admin API에 접근하기 위해 필요합니다.

&nbsp;

### 5. dex 설정

`dex` 컨테이너에 마운트한 JSON 파일의 내용을 사용하여 `dex` 컨테이너에 설정합니다.

```yaml
# charts/argocd/values.yaml
configs:
  cm:
    dex.config: |
      connectors:
      - config:
          redirectURI: https://argocd.example.com/api/dex/callback
          clientID: XXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com
          clientSecret: XXXXXX-XXX-X-XXXXXXXXXXXXXXXXXXXXXX
          serviceAccountFilePath: /tmp/oidc/googleAuth.json
          adminEmail: workspace-admin@example.com
          fetchTransitiveGroupMembership: True
        type: google
        id: google
        name: Google
  rbac:
    scopes: ['groups']
```

- `redirectURI`는 `argocd` 서버의 도메인에 `/api/dex/callback`을 붙여서 설정합니다.
- `clientID`와 `clientSecret`은 [OpenID Connect using Dex 페이지](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/google/#openid-connect-using-dex)를 참고하여 새롭게 만든 OAuth 2.0 클라이언트 자격 증명을 사용합니다.
- `adminEmail`값은 `dex` 파드가 Google Admin API에 접근하기 위해 필요한 Google Workspace의 관리자 계정 이메일 주소입니다. 이 계정은 Dex가 사용자 정보를 가져오기 위해 임시로 가장(impersonate)하는 역할을 하며, 그룹 정보 조회와 같은 API 호출을 수행할 수 있는 권한을 가져야 합니다.
- 연동 과정에서 그룹메일을 사용해야 하기 때문에 `type` 값이 `oidc`가 아닌 `google`로 설정되어야 합니다.
- `fetchTransitiveGroupMembership` 값은 `dex` 서버 버전이 2.31.0 이상인 경우 사용할 수 있습니다. 즉, 사용자가 직접 속한 그룹뿐만 아니라, 그 그룹이 속한 다른 그룹까지도 권한을 상속받는 설정입니다. 이렇게 하면 권한 관리가 더 간편해지지만, 복잡해질 수 있으니 주의해야 합니다.

&nbsp;

### 6. ArgoCD RBAC 설정

그룹메일(Google Groups)을 사용해서 ArgoCD 권한 관리를 하기 위해서는 `type: oidc`가 아닌 `type: google`로 설정해야 합니다.

Google Groups를 사용해서 OIDC를 연동하고, 그룹메일 기반으로 ArgoCD 권한 관리를 하는 설정은 아래와 같습니다.

```yaml
# charts/argocd/values.yaml
configs:
  cm:
    dex.config: |
      connectors:
      - config:
          redirectURI: https://argocd.example.com/api/dex/callback
          clientID: XXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com
          clientSecret: XXXXXX-XXX-X-XXXXXXXXXXXXXXXXXXXXXX
          serviceAccountFilePath: /tmp/oidc/googleAuth.json
          adminEmail: workspace-admin@example.com
          fetchTransitiveGroupMembership: True
        type: google
        id: google
        name: Google
  
  rbac:
    # -- Create the argocd-rbac-cm configmap with ([Argo CD RBAC policy]) definitions.
    # If false, it is expected the configmap will be created by something else.
    # Argo CD will not work if there is no configmap created with the name above.
    create: true

    # -- Annotations to be added to argocd-rbac-cm configmap
    annotations: {}

    # -- The name of the default role which Argo CD will falls back to, when authorizing API requests (optional).
    # If omitted or empty, users may be still be able to login, but will see no apps, projects, etc...
    policy.default: role:readonly

    # -- File containing user-defined policies and role definitions.
    # @default -- `''` (See [values.yaml])
    policy.csv: |
      ## `role:admin` and `role:readonly` are predefined roles in argocd
      p, role:image-updater, applications, get, */*, allow
      p, role:image-updater, applications, update, */*, allow
      g, image-updater, role:image-updater

      p, role:team_beta, applications, get, beta/*, allow
      p, role:team_beta, applications, get, ingress/beta-internal-ingress, allow
      p, role:team_beta, certificates, get, *, allow
      p, role:team_beta, clusters, get, *, allow
      p, role:team_beta, repositories, get, *, allow
      p, role:team_beta, projects, get, beta, allow
      p, role:team_beta, projects, get, ingress, allow
      p, role:team_beta, accounts, get, *, allow
      p, role:team_beta, gpgkeys, get, *, allow
      p, role:team_beta, logs, get, beta/*, allow
      p, role:team_beta, exec, create, beta/*, allow

      p, role:team_gamma, applications, get, gamma/*, allow
      p, role:team_gamma, applications, get, ingress/beta-internal-ingress, allow
      p, role:team_gamma, applications, sync, gamma/*, allow
      p, role:team_gamma, certificates, get, *, allow
      p, role:team_gamma, clusters, get, *, allow
      p, role:team_gamma, repositories, get, *, allow
      p, role:team_gamma, projects, get, gamma, allow
      p, role:team_gamma, projects, get, ingress, allow
      p, role:team_gamma, accounts, get, *, allow
      p, role:team_gamma, gpgkeys, get, *, allow
      p, role:team_gamma, logs, get, gamma/*, allow
      p, role:team_gamma, exec, create, gamma/*, allow

      # [group-mail] admin
      g, team_admin@example.com, role:admin

      # [group-mail] beta team
      g, team_beta@example.com, role:team_beta

      # [group-mail] gamma team
      g, team_gamma@example.com, role:team_gamma

    # -- OIDC scopes to examine during rbac enforcement (in addition to `sub` scope).
    # The scope value can be a string, or a list of strings.
    scopes: "[groups]"

    # -- Matcher function for Casbin, `glob` for glob matcher and `regex` for regex matcher.
    policy.matchMode: "glob"
```

Argo CD에는 두 가지 미리 정의된 역할이 있으며, RBAC 구성에서는 역할과 그룹을 정의할 수 있습니다(아래 참조).

- `role:readonly`: 모든 리소스에 대한 읽기 전용 접근
- `role:admin`: 모든 리소스에 대한 무제한 접근

ArgoCD에 기본 내장된 Role의 세부 권한은 [builtin-policy.csv](https://github.com/argoproj/argo-cd/blob/master/assets/builtin-policy.csv)를 참고합니다.

&nbsp;

`policy.default`는 ArgoCD에서 기본적으로 사용되는 역할을 설정하는 부분입니다. 이 설정은 사용자가 특정 역할을 명시적으로 할당받지 않았을 때, 어떤 역할이 자동으로 적용될지를 결정합니다.

ArgoCD에서 `role:readonly`을 기본 역할로 설정하는 방법은 아래와 같습니다.

```yaml
# charts/argocd/values.yaml
configs:
  rbac:
    policy.default: role:readonly
```

&nbsp;

#### 선택사항: 웹 기반 터미널 기능

웹 기반 터미널 기능은 선택사항입니다. ArgoCD 웹(Argo UI)에서 터미널 기능을 사용하기 위해서는 configMap의 `exec.enabled` 값을 `true`로 설정해야 합니다.

```yaml
# charts/argocd/values.yaml
configs:
  cm:
    # -- Enable exec feature in Argo UI
    ## Ref: https://argo-cd.readthedocs.io/en/latest/operator-manual/rbac/#exec-resource
    exec.enabled: true
```

&nbsp;

Application Project 단위에 속하는(application-specific) `applications`, `applicationsets`, `logs` 및 `exec` 리소스에 대한 접근 권한을 부여하기 위해서는 아래와 같은 형식을 사용합니다.

이 값은 `policy.csv` 파일에서 사용되는 형식입니다.

```bash
p, <role/user/group>, <resource>, <action>, <appproject>/<object>, allow
```

> ArgoCD 권한 관리에서는 `deny` 규칙을 지원하지 않습니다. 이러한 이유로 기본 정책을 통해 최소 필요한 권한을 부여하고, 필요에 따라 개별 역할에 권한을 부여하는 방법을 사용합니다.

&nbsp;

`action` 권한은 [Argo CD 저장소에 정의된 기본 제공 리소스 사용자 지정](https://github.com/argoproj/argo-cd/tree/master/resource_customizations) 또는 사용자가 정의한 사용자 지정 리소스 작업에 해당합니다. action 경로는 `action/<api-group>/<Kind>/<action-name>` 형식입니다.

아래는 `action` 권한을 사용해 특정 어플리케이션에 포함된 Deployment, Rollout, StatefulSet 리소스의 재시작 권한을 부여하는 예제입니다.

```yaml
# charts/argocd/values.yaml
configs:
  rbac:
    policy.csv: |
      # StatefulSet 리소스 재시작 권한을 부여하는 예제입니다.
      p, role:team_beta, applications, action/app/StatefulSet/restart, beta/app-backend, allow
      p, role:team_beta, applications, action/app/StatefulSet/restart, beta/app-frontend, allow

      # Rollout 리소스 재시작 권한을 부여하는 예제입니다.
      p, role:team_beta, applications, action/argoproj.io/Rollout/restart, beta/app-backend, allow
      p, role:team_beta, applications, action/argoproj.io/Rollout/restart, beta/app-frontend, allow

      # Deployment 리소스 재시작 권한을 부여하는 예제입니다.
      p, role:team_beta, applications, action/app/Deployment/restart, beta/app-backend, allow
      p, role:team_beta, applications, action/app/Deployment/restart, beta/app-frontend, allow

      g, team_beta@example.com, role:team_beta
```

자세한 사항은 [argoproj/argo-cd#2401](https://github.com/argoproj/argo-cd/issues/2401) 이슈와 [Argo CD RBAC Configuration](https://argo-cd.readthedocs.io/en/release-2.9/operator-manual/rbac/#application-resources) 공식 문서를 참고합니다.

&nbsp;

`role:team_beta`에 대해 `beta` 프로젝트의 모든 파드에 대해 터미널 접속 권한을 부여하기 위해서는 아래와 같은 설정을 `policy.csv` 파일에 추가합니다.

```yaml
# charts/argocd/values.yaml
configs:
  cm:
    policy.default: role:readonly
    policy.csv: |
      p, role:team_beta, exec, create, beta/*, allow
      g, team_beta@example.com, role:team_beta
```

&nbsp;

#### 주의사항: 업데이트/삭제 작업에 대한 세분화된 권한

ArgoCD v2.9에서는 `rollout`, `pod`와 같은 프로젝트의 하위 쿠버네티스 리소스에 대한 권한은 세부적으로 관리할 수 없는 한계점이 있습니다. 따라서 Applications에 대한 삭제 권한을 부여하면 해당 애플리케이션이 배포한 모든 쿠버네티스 리소스에 대한 삭제 권한을 부여해야만 하는 한계점이 있습니다.

아래는 ArgoCD RBAC Configuration 공식문서의 [Application resources](https://argo-cd.readthedocs.io/en/release-2.9/operator-manual/rbac/#application-resources) 섹션 내용 일부입니다.

> Delete access to **sub-resources of a project, such as a rollout or a pod, cannot be managed granularly**. `<project-name>/<application-name>` grants access to all subresources of an application.

예를 들어, 아래 RBAC 설정은 `beta` 프로젝트의 `important-backend-api` 애플리케이션이 배포한 모든 쿠버네티스 리소스(pod, deployment, configMap, secret, etc.)에 대한 삭제(`delete`) 권한을 같이 부여합니다.

```yaml
# charts/argocd/values.yaml
# argocd v2.9
configs:
  cm:
    policy.csv: |
      p, role:team_beta, applications, delete, beta/important-backend-api, allow
      g, team_beta@example.com, role:team_beta
```

이는 어쩔 수 없이 발생하는 구 버전 ArgoCD의 한계점입니다. 네임스페이스 및 리소스 단위의 세부 권한 제어 기능인 [Fine-grained Permissions for update/delete action](https://argo-cd.readthedocs.io/en/release-2.12/operator-manual/rbac/#fine-grained-permissions-for-updatedelete-action)를 사용하려면 ArgoCD v2.12 이상 버전으로 업그레이드해야 합니다.

&nbsp;

변경된 설정을 적용하기 위해 `dex` 파드를 재시작합니다.

```bash
kubectl rollout restart deployment -n argocd dex-server
```

&nbsp;

### 7. 그룹 정보 확인

`dex` 파드에서 `Failed to authenticate: google: could not retrieve groups: could not list groups` 에러가 발생하는 경우, OAuth와 Google Admin API 권한 부족으로 인해 발생할 수 있습니다.

- Google Admin API에 접근하기 위해서는 반드시 Google Workspace 어드민 권한을 가진 사용자의 메일을 `dex`의 `adminEmail` 값으로 설정해야 합니다. 그룹메일은 Google Admin API에 접근할 수 없습니다.
- Google Admin API에 접근하기 위해서는 반드시 `https://www.googleapis.com/auth/admin.directory.group.readonly` scope를 service account에 할당해야 합니다.
- GCP 프로젝트에서 Google Admin API가 활성화된 상태인지 확인해야 합니다. API가 활성화되어 있지 않으면 Google Admin API에 접근할 수 없습니다.

&nbsp;

아래는 `dex` 파드 로그에서 확인한 `401 Unauthorized` 에러 메시지입니다:

```bash
dex-server time="2024-11-25T05:28:20Z" level=error msg="Failed to authenticate: google: could not retrieve groups: could not list groups: Get \"https://admin.googleapis.com/admin/directory/v1/groups?alt=json&pageToken=&prettyPrint=false&userKey=alice%40example.com\": oauth2: cannot fetch token: 401 Unauthorized\nResponse: {\n  \"error\": \"unauthorized_client\",\n  \"error_description\": \"Client is unauthorized to retrieve access tokens using this method, or client not authorized for any of the scopes requested.\"\n}"
dex-server time="2024-11-25T05:28:22Z" level=error msg="Failed to authenticate: google: could not retrieve groups: could not list groups: Get \"https://admin.googleapis.com/admin/directory/v1/groups?alt=json&pageToken=&prettyPrint=false&userKey=bob%40example.com\": oauth2: cannot fetch token: 401 Unauthorized\nResponse: {\n  \"error\": \"unauthorized_client\",\n  \"error_description\": \"Client is unauthorized to retrieve access tokens using this method, or client not authorized for any of the scopes requested.\"\n}"
```

&nbsp;

제 경우는 `adminEmail` 값이 Google Workspace 어드민 권한을 가진 사용자의 메일이 아닌, 그룹메일로 설정된 경우 위 에러가 발생했습니다.

```yaml
# charts/argocd/values.yaml
configs:
  dex.config: |
    connectors:
    - config:
        adminEmail: team_admin@example.com
```

&nbsp;

이 권한 문제를 해결하기 위해서는 실제 Google Workspace 어드민 권한을 가진 사용자의 메일 주소를 `adminEmail` 값으로 설정하면 됩니다.

```yaml
# charts/argocd/values.yaml
configs:
  dex.config: |
    connectors:
    - config:
        adminEmail: workspace-admin@example.com
```

&nbsp;

변경된 dex connector 설정을 적용하기 위해 `dex` 파드를 재시작합니다.

```bash
kubectl rollout restart deployment -n argocd dex-server
```

&nbsp;

정상적으로 dex와 Google Groups가 연동되면, ArgoCD 로그인한 후 그룹메일 기반으로 권한 관리가 적용됩니다.

ArgoCD 사용자는 로그인 후 `https://<ARGOCD_DOMAIN>/user-info` 페이지에서 사용자 이메일 주소가 속한 그룹 메일의 모든 멤버십을 확인할 수 있습니다. `fetchTransitiveGroupMembership` 값이 `true`로 설정된 경우, 사용자가 직접 속한 그룹뿐만 아니라, 그 그룹이 속한 다른 그룹까지도 권한을 상속받는 설정입니다.

![ArgoCD Login](./2.png)

그룹메일 주소를 사용자 메일 주소와 동일하게 표시되는 경우, `dex`와 Google Groups의 연동이 정상적으로 수행되지 않은 것입니다.

&nbsp;

## 참고자료

- [OpenID Connect plus Google Groups using Dex](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/google/#openid-connect-plus-google-groups-using-dex)
- [선택사항: 서비스 계정(service account)에 도메인 전체 위임 설정](https://developers.google.com/workspace/guides/create-credentials?hl=ko#optional_set_up_domain-wide_delegation_for_a_service_account)
