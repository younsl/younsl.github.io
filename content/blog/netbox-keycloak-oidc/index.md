---
title: "netbox keycloak oidc"
date: 2025-12-20T00:00:00+09:00
lastmod: 2025-12-20T00:00:00+09:00
description: "How to integrate NetBox with Keycloak OIDC for group-based permission mapping"
keywords: []
tags: ["netbox", "keycloak", "oidc", "kubernetes", "sso"]
---

## Overview

This guide explains how to integrate NetBox with Keycloak OIDC for SSO authentication in a Kubernetes environment using the [netbox-chart](https://github.com/netbox-community/netbox-chart).

Key features:

- Auto user creation on first login
- Auto permission assignment based on Keycloak groups:
  - `administrator` group → Superuser + Staff
  - `developer` group → Staff
  - Others → Regular user

## NetBox Permission Model

| Role | Description |
|------|-------------|
| **Superuser** | Full admin access. Can manage all objects, users, and system settings |
| **Staff** | Can access Django admin panel. Permissions controlled by assigned groups |
| **Regular user** | No admin access. Can only view/edit objects based on assigned permissions |

## Why Custom Pipeline?

NetBox uses [python-social-auth](https://python-social-auth.readthedocs.io/) for OAuth/OIDC authentication.

NetBox's built-in `groupSyncEnabled` and `superuserGroups` only work with HTTP header-based authentication (e.g., Apache mod_auth_openidc). For python-social-auth (direct OAuth), NetBox does not automatically read the groups claim from tokens. A custom pipeline is required to map Keycloak groups to NetBox permissions.

References:

- [python-social-auth](https://python-social-auth.readthedocs.io/)
- [python-social-auth Keycloak Backend](https://python-social-auth.readthedocs.io/en/latest/backends/keycloak.html)
- [social-core keycloak.py](https://github.com/python-social-auth/social-core/blob/master/social_core/backends/keycloak.py)
- [NetBox SSO Group Sync Discussion](https://github.com/netbox-community/netbox/discussions/9635) - Community discussion about group synchronization limitations with SSO

## Prerequisites

- Kubernetes cluster
- NetBox Community v4.4.8-Docker-3.4.2 deployed via [netbox-chart](https://github.com/netbox-community/netbox-chart)
- Keycloak with a realm configured

## Keycloak Configuration

### Create Client

| Setting | Value |
|---------|-------|
| Client ID | `netbox` |
| Client Protocol | `openid-connect` |
| Access Type | `confidential` |

### Add Mappers

Go to Clients → netbox → Client Scopes → netbox-dedicated → Mappers.

**Audience Mapper:**

| Field | Value |
|-------|-------|
| Mapper Type | Audience |
| Included Client Audience | `netbox` |
| Add to access token | ON |

**Groups Mapper:**

| Field | Value |
|-------|-------|
| Mapper Type | Group Membership |
| Token Claim Name | `groups` |
| Full group path | OFF |
| Add to access token | ON |

### Get Public Key

```bash
curl -s https://<keycloak>/realms/<realm> | jq -r '.public_key'
```

You can also get the public key from Keycloak Admin Console: Realm settings → Keys → RS256 → Public key button.

## Values Configuration

Configure netbox's helm chart values file to enable Keycloak OIDC authentication with custom pipeline.

The custom pipeline script is deployed as a ConfigMap via netbox subchart's `extraDeploy` and mounted to the netbox-app pod at `/opt/netbox/netbox/netbox/sso_pipeline.py`. This allows NetBox to import and execute it as a Python module (`netbox.sso_pipeline.set_superuser`) during the authentication process.

```yaml
netbox-operator:
  netbox:
    extraConfig:
      - values:
          SOCIAL_AUTH_PIPELINE:
            # ... omitted for brevity ...
            - netbox.sso_pipeline.set_superuser
```

The group names in the script (`administrator`, `developer`) must match your Keycloak group names exactly (case-sensitive).

```yaml
netbox-operator:
  netbox:
    enabled: true

    ## Keycloak OIDC SSO settings
    remoteAuth:
      enabled: true
      backends:
        - social_core.backends.keycloak.KeycloakOAuth2
      autoCreateUser: true
      autoCreateGroups: true
      defaultGroups: []
      defaultPermissions: {}
      # NOTE: groupSyncEnabled, superuserGroups, staffGroups only work with
      # HTTP header-based auth (e.g., Apache mod_auth_openidc).
      # For python-social-auth, use custom pipeline instead.
      groupSyncEnabled: true
      superuserGroups:
        - administrator
      superusers: []
      staffGroups:
        - developer
      staffUsers: []

    extraConfig:
      - values:
          SOCIAL_AUTH_KEYCLOAK_KEY: "netbox"
          SOCIAL_AUTH_KEYCLOAK_SECRET: "<client-secret>"
          SOCIAL_AUTH_KEYCLOAK_PUBLIC_KEY: "<public-key>"
          SOCIAL_AUTH_KEYCLOAK_AUTHORIZATION_URL: "https://<keycloak>/realms/<realm>/protocol/openid-connect/auth"
          SOCIAL_AUTH_KEYCLOAK_ACCESS_TOKEN_URL: "https://<keycloak>/realms/<realm>/protocol/openid-connect/token"
          SOCIAL_AUTH_KEYCLOAK_SCOPE:
            - openid
            - email
            - profile
          SOCIAL_AUTH_KEYCLOAK_ID_KEY: "email"
          LOGIN_REQUIRED: true
          # Authentication pipeline - executed in order during login
          SOCIAL_AUTH_PIPELINE:
            - social_core.pipeline.social_auth.social_details   # Extract user details from OAuth response
            - social_core.pipeline.social_auth.social_uid       # Get user's unique ID
            - social_core.pipeline.social_auth.auth_allowed     # Check if authentication is allowed
            - social_core.pipeline.social_auth.social_user      # Find existing social account
            - social_core.pipeline.user.get_username            # Generate username
            - social_core.pipeline.user.create_user             # Create new user if needed
            - social_core.pipeline.social_auth.associate_user   # Link social account to user
            - social_core.pipeline.social_auth.load_extra_data  # Load extra data (groups, etc.)
            - social_core.pipeline.user.user_details            # Update user details
            - netbox.sso_pipeline.set_superuser                 # Custom: Map Keycloak groups to NetBox permissions

    # Mount custom pipeline to netbox-app pod
    extraVolumes:
      - name: sso-pipeline
        configMap:
          name: netbox-sso-pipeline

    extraVolumeMounts:
      - name: sso-pipeline
        mountPath: /opt/netbox/netbox/netbox/sso_pipeline.py
        subPath: sso_pipeline.py

    # Custom pipeline ConfigMap
    extraDeploy:
      - apiVersion: v1
        kind: ConfigMap
        metadata:
          name: netbox-sso-pipeline
        data:
          sso_pipeline.py: |
            def set_superuser(backend, user, response, *args, **kwargs):
                groups = response.get('groups', [])
                normalized = [g.lstrip('/') for g in groups]

                if 'administrator' in normalized:
                    user.is_superuser = True
                    user.is_staff = True
                elif 'developer' in normalized:
                    user.is_staff = True
                else:
                    user.is_superuser = False
                    user.is_staff = False

                user.save()
```

Note: `groupSyncEnabled`, `superuserGroups`, `staffGroups` settings are included but only work with HTTP header-based authentication. For python-social-auth (direct OAuth), the custom pipeline handles group mapping.

## Group Mapping

| Keycloak Group | NetBox Permission |
|----------------|-------------------|
| `administrator` | superuser + staff |
| `developer` | staff only |
| others | regular user |

## Troubleshooting

### InvalidAudienceError

Missing audience mapper in Keycloak client configuration.

Add Audience mapper in Keycloak: Clients → netbox → Client Scopes → netbox-dedicated → Mappers → Add Audience mapper.

### sequence item 1: NoneType

Missing groups claim or user name fields in the token.

Add Groups mapper in Keycloak and ensure the user has first/last name set in their Keycloak profile.

### Login works but no superuser

NetBox's built-in `groupSyncEnabled` and `superuserGroups` only work with HTTP header-based authentication. For python-social-auth (direct OAuth), a custom pipeline is required to read groups from the token and assign permissions.

The custom pipeline must be mounted at `/opt/netbox/netbox/netbox/sso_pipeline.py`. Check extraVolumeMounts path and verify the ConfigMap is created in the correct namespace. You can verify the file is mounted by exec into the netbox pod and checking the file exists.

## Conclusion

Automatically creating users and mapping Keycloak groups to NetBox permissions (Staff/Superuser) is not straightforward. NetBox's built-in group sync only supports HTTP header-based authentication, not direct OAuth.

Solution:

1. Create a custom python-social-auth pipeline that reads groups claim from token
2. Deploy it as a ConfigMap via extraDeploy
3. Mount it to netbox-app pod via extraVolumes/extraVolumeMounts
4. Add the custom function to SOCIAL_AUTH_PIPELINE

This approach was inspired by [NetBox with Okta SSO using OAuth](https://blog.networktocode.com/post/netbox-with-okta-sso-oauth/), which demonstrates custom pipeline implementation for similar OAuth providers.
