# Core Architecture & Infrastructure — docs

# Core Architecture & Infrastructure Docs

Module documents core backend infrastructure components: app settings, error handling, security utilities. Target source definitions reside in `app.modules.core`.

## Structure

```
backend/docs/modules/core/
├── config.md       # Environment, runtime settings
├── exceptions.md   # Domain exception hierarchies
└── security.md     # Passwords, JWT token operations
```

## Documented Submodules

### Configuration (`config.md`)

Documents `app.modules.core.config.Settings`.

Key configuration attributes:
* `DATABASE_URL`: Relational DB connection string.
* `REDIS_URL`: Cache/broker connection string.
* `SECRET_KEY`: Cryptographic signing key.
* `CORS_ORIGINS`: Allowed cross-origin domains.

### Exceptions (`exceptions.md`)

Documents error classes defined in `app.modules.core.exceptions`:

* `AuthException`: Base auth error.
* `EmailAlreadyExistsError`: User registration conflict.
* `InvalidCredentialsError`: Login verification failure.
* `ValidationError`: Input payload failure.
* `TokenExpiredError`: Expired JWT payload.

### Security (`security.md`)

Documents cryptographic functions in `app.modules.core.security`:

* `hash_password`: Passlib/bcrypt password hashing.
* `verify_password`: Cleartext comparison against stored hash.
* `create_access_token`: JWT token encoder with expiry claims.
* `verify_token`: JWT decoder, signature validator.

## Generation Pattern

Uses `mkdocstrings` Python handler. Injects docstrings directly from `app.modules.core` source files at doc build time:

```markdown
::: app.modules.core.<submodule>.<symbol>
    options:
        show_source: true
```