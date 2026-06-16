# HighFive Backend Secret Handling

## Store locally only

Use local environment variables, Xcode scheme environment variables, or CI secret storage.

Never commit:

- Supabase service role key
- Supabase anon key if you consider it environment-specific
- Clerk/Auth0 secrets
- Stripe secret key
- RevenueCat secret key
- Meta/Instagram app secret
- OAuth access tokens
- OAuth refresh tokens
- APNs private key
- analytics write keys

## Client-safe values

Some providers have public client keys. Treat every key as environment-specific and keep placeholders in the repo until a security decision is made.

## Recommended `.gitignore` additions

```gitignore
.env
.env.*
*.xcconfig.local
HighFive/Config/Secrets.swift
```

## App labels when missing secrets

- Local Mode
- Backend Not Connected Yet
- Missing Credentials
- Provider-ready
- Not Connected Yet
