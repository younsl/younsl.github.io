---
title: "backstage no popup signin"
date: 2026-02-25T19:30:00+09:00
lastmod: 2026-02-25T19:30:00+09:00
tags: ["backstage", "keycloak", "oidc", "authentication"]
---

## Overview

By default, [Backstage](https://backstage.io/) opens a popup window for OAuth2/OIDC login. This can be blocked by popup blockers and is a poor user experience. This post covers how to switch to in-window redirect flow using the enableExperimentalRedirectFlow config.

When enabled, unauthenticated users visiting backstage.example.com are automatically redirected to the Keycloak login page without any additional action — no sign-in page, no button click required.

> Tested on a custom Backstage 1.48.1 container image with Keycloak OIDC provider.

## Problem

Backstage's SignInPage triggers OAuthRequestDialog which calls window.open() for authentication. Users see a popup window for Keycloak login instead of being redirected within the same browser tab.

## Solution

Add enableExperimentalRedirectFlow to the [root level](https://backstage.io/docs/auth/#sign-in-configuration) of app-config.yaml. Introduced in [Backstage v1.13.0](https://backstage.io/docs/releases/v1.13.0-changelog/), this setting makes the auto sign-in path use in-window redirect instead of a popup.

### Configuration

For the [official Backstage Helm chart](https://github.com/backstage/charts), configure as follows:

```yaml
# charts/backstage/values.yaml
backstage:
  appConfig:
    # Required: Must be at the root level of appConfig, not under auth.
    enableExperimentalRedirectFlow: true

    auth:
      environment: production
      providers:
        oidc:
          production:
            clientId: ${KEYCLOAK_CLIENT_ID}
            clientSecret: ${KEYCLOAK_CLIENT_SECRET}
            metadataUrl: ${KEYCLOAK_METADATA_URL}
            prompt: auto
            signIn:
              resolvers:
                - resolver: emailLocalPartMatchingUserEntityName
                  dangerouslyAllowSignInWithoutUserInCatalog: true
```

> ⚠️ `enableExperimentalRedirectFlow` must be placed at the **root level** of appConfig, not under `auth:`.

### Frontend

No code changes needed. Use the standard SignInPage with auto prop:

```tsx
// packages/app/src/App.tsx
const CustomSignInPage = (props: any) => (
  <SignInPage
    {...props}
    auto
    providers={[
      {
        id: 'keycloak',
        title: 'Keycloak',
        message: 'Sign in using Keycloak',
        apiRef: keycloakOIDCAuthApiRef,
      },
    ]}
  />
);
```

The auto prop triggers login on page load, and enableExperimentalRedirectFlow switches that path from popup to redirect. Combined, an unauthenticated user is immediately redirected to Keycloak on first visit:

**Flow:** backstage.example.com → Keycloak login → Backstage home

## Scope

enableExperimentalRedirectFlow applies to both the auto sign-in path and the manual button click path. When enabled, all authentication flows use in-window redirect instead of popup.

| Trigger | Redirect applied | Behavior |
|---------|:----------------:|----------|
| auto prop (page load) | Yes | Redirect |
| Sign in button click (fallback) | Yes | Redirect |

In practice, users rarely see the sign-in button since auto fires immediately on page load. The button only appears when auto sign-in fails (e.g., Keycloak outage), and in that case clicking the sign-in button also redirects to Keycloak without a popup.

## Alternatives considered

### ProxiedSignInPage

```tsx
<ProxiedSignInPage {...props} provider="oidc" />
```

Designed for proxy-based auth (header/cookie). Does not work with standard OIDC provider and returns 400 error.

### Custom redirect

```tsx
React.useEffect(() => {
  window.location.replace(
    `${baseUrl}/api/auth/oidc/start?env=${env}&flow=redirect`,
  );
}, []);
```

Works for all cases but risks infinite redirect loops on Keycloak outage and bypasses Backstage's official auth flow.

### Comparison

| Approach | Redirect scope | Official | On failure |
|----------|---------------|:--------:|------------|
| `enableExperimentalRedirectFlow` | All | Yes | Button fallback (redirect) |
| `ProxiedSignInPage` | All | Yes | 400 error (OIDC incompatible) |
| Custom redirect | All | No | Infinite redirect loop risk |

enableExperimentalRedirectFlow is the recommended approach as it's officially supported and provides safe fallback behavior.

## Conclusion

Backstage's default popup-based login is disruptive to developers — popup blockers interfere with sign-in and the extra window breaks workflow. By enabling `enableExperimentalRedirectFlow` with an OIDC provider like Keycloak, developers are seamlessly redirected to the login page within the same tab, eliminating the popup entirely. This small configuration change significantly improves the developer experience for teams using Backstage as their internal developer portal.

## References

- [Backstage Auth documentation](https://backstage.io/docs/auth/)
- [Backstage v1.13.0 Changelog](https://backstage.io/docs/releases/v1.13.0-changelog/)
- [Backstage OAuth and OpenID Connect](https://backstage.io/docs/auth/oauth/)
