# 복구 가이드

## 개요

backup-utils를 사용한 복구 가이드

## 복구 전 체크리스트

### 1. 복구대상 인스턴스

백업 대상 서버는 기존 인스턴스에 수행할 수 없습니다.

반드시 새로 생성된 Github Enterprise Server여야 하며, Management Console에서 생성시 New Instance로 생성해야 합니다.

&nbsp;

### 2. 메인터넌스 모드

복구를 실행하기 전에 복구 대상 Github Enterprise Server가 메인터넌스 모드여야 합니다.

```bash
# Maintenance 상태 확인
ghe-maintenance -q

# Maintenance 모드 활성화
ghe-maintenance -s
```

&nbsp;

### 3. Actions S3 설정

(복구 스냅샷에 S3 Actions data 포함되어 있는 경우) 복구 대상 Github Enterprise 서버에 접속한 후 Actions S3 기능을 미리 활성화 해야합니다.

```bash
# Actions S3 관련 설정
ghe-config secrets.actions.storage.blob-provider "s3"

ghe-config secrets.actions.storage.s3.bucket-name "<BUCKET_NAME>"
ghe-config secrets.actions.storage.s3.service-url "https://s3.ap-northeast-2.amazonaws.com"
ghe-config secrets.actions.storage.s3.access-key-id "<KEY_ID>"
ghe-config secrets.actions.storage.s3.access-secret "..."

ghe-config app.actions.enabled true

# Actions S3 설정 적용
ghe-config-apply
```

Github Enterprise Server의 Actions S3 설정 방법은 아래 2개 문서를 참고합니다.

- [Backup and restore with GitHub Actions enabled](https://github.com/github/backup-utils/blob/master/docs/usage.md#backup-and-restore-with-github-actions-enabled)
- [Restoring a backup of GitHub Enterprise Server when GitHub Actions is enabled](https://docs.github.com/en/enterprise-server@3.11/admin/managing-github-actions-for-your-enterprise/advanced-configuration-and-troubleshooting/backing-up-and-restoring-github-enterprise-server-with-github-actions-enabled#restoring-a-backup-of-github-enterprise-server-when-github-actions-is-enabled)

## 복구 실행

1. 복구를 하기 위한 Github Enterprise Server 인스턴스를 새롭게 생성합니다.
2. `github-restore-bastion` 파드를 [YAML](../github-restore-bastion.yaml)을 사용하여 생성합니다.
3. 파드에 접속한 후 복구 데이터를 주입할 Github Enterprise 서버로 접근 가능 여부를 `ghe-host-check`로 확인합니다.
4. 복구 명령어인 `ghe-restore`을 실행합니다.

> [!TIP]
> `ghe-host-check`와 `ghe-restore` 명령어를 실행할 때 `GHE_BACKUP_CONFIG` 환경변수를 통해 backup-utils의 설정파일 경로를 직접 지정할 수 있습니다.

```console
$ GHE_BACKUP_CONFIG=/root/.ssh/backup.config /backup-utils/bin/ghe-host-check <TARGET_SERVER_IP>
Connect 10.11.11.11:122 OK (v3.11.2)
```

> [!WARNING]
> `ghe-host-check` 명령어에서 실패한다면 복구를 수행할 대상 Github Enterprise 서버의 `/home/admin/.ssh/authorized_keys` 파일에 정상적으로 공개키가 들어가 있는지 확인합니다.

```console
$ GHE_BACKUP_CONFIG=/root/.ssh/backup.config /backup-utils/bin/ghe-restore -v -c -s 240704T142322 <TARGET_SERVER_IP>
```
