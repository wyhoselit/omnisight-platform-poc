# Authentication & User Management

# Authentication & User Management Module

## Overview

This module handles user authentication, registration, session management, and role-based access control. It spans both backend (FastAPI) and frontend (Vue 3 + Pinia) with JWT-based authentication stored in HttpOnly cookies.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Frontend (Vue 3)                         │
├─────────────────────────────────────────────────────────────────┤
│  LoginForm.vue / RegistrationForm.vue                           │
│         │                                                       │
│         ▼                                                       │
│  useAuthStore (Pinia)                                           │
│         │                                                       │
│         ▼                                                       │
│  authService (API calls)                                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                    HTTP + Cookies
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Backend (FastAPI)                        │
├─────────────────────────────────────────────────────────────────┤
│  POST /api/v1/auth/register  →  User model + hash_password      │
│  POST /api/v1/auth/login     →  verify_password + create_token  │
│  GET  /api/v1/users/me       →  extract_token + verify_token    │
│  GET  /api/v1/users          →  admin only (get_admin_user)     │
└─────────────────────────────────────────────────────────────────┘
```

## Backend Components

### User Model (`backend/app/modules/user/user.py`)

```python
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    roles = relationship("Role", secondary=user_roles, back_populates="users")
```

- **email**: Unique, indexed, required
- **hashed_password**: Bcrypt hash (never plaintext)
- **roles**: Many-to-many with `Role` via `user_roles` association table

### Auth Endpoints (`backend/app/modules/user/api/auth.py`)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/register` | POST | Create user, hash password, return user ID + email |
| `/login` | POST | Verify credentials, issue JWT, set HttpOnly cookie |

**Registration flow:**
1. Validate email + password present
2. Check email uniqueness
3. Hash password with `hash_password()` (bcrypt)
4. Create User, commit to DB
5. Return `{id, email}`

**Login flow:**
1. Validate email + password present
2. Find user by email
3. Verify password with `verify_password()` (bcrypt)
4. Create JWT via `create_access_token({"sub": str(user.id)})`
5. Set cookie: `access_token`, HttpOnly, SameSite=strict, max_age=900s (15 min)
6. Return `{message: "Login successful"}`

### User Endpoints (`backend/app/modules/user/api/users.py`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/me` | GET | Required | Current user profile + roles |
| `/` | GET | Admin | List all users with roles |

**Dependency chain:**
```
get_me → get_current_user → extract_token_from_request → verify_token
get_users → get_admin_user → get_current_user → extract_token_from_request → verify_token
```

### Exceptions (`backend/app/modules/core/exceptions.py`)

- `EmailAlreadyExistsError` → 409, `error_code: "EMAIL_ALREADY_EXISTS"`
- `InvalidCredentialsError` → 401, `error_code: "INVALID_CREDENTIALS"`

## Frontend Components

### Auth Service (`frontend/src/modules/user/services/auth.ts`)

```typescript
login(credentials) → POST /api/v1/auth/login → GET /api/v1/users/me → User
register(credentials) → POST /api/v1/auth/register → User
logout() → POST /api/v1/auth/logout
getCurrentUser() → GET /api/v1/users/me → User
```

**Error handling:** Catches axios errors, extracts `error.response.data` (contains `detail` + `error_code`), throws normalized error object.

### Auth Store (`frontend/src/modules/user/stores/auth.ts`)

Pinia store with:
- **State**: `user`, `loading`, `error`, `errorCode`, `isAuthenticated`
- **Actions**:
  - `login()` → calls service, fetches current user, returns redirect path (`/chat`)
  - `register()` → calls service, no auto-login
  - `logout()` → calls service, clears user
  - `fetchCurrentUser()` → hydrates session on app load

**Note:** Duplicate store exists at `frontend/src/stores/auth.ts` (Options API style). The module-specific store (`user/stores/auth.ts`) is the active one used by views.

### Views

- **LoginForm.vue**: Email/password fields, validation, error display, submit → `authStore.login()` → redirect to `/chat`
- **RegistrationForm.vue**: Email/password, validation, error display, submit → `authStore.register()` → redirect to `/login`
- **AuthLayout.vue**: Minimal centered container, no app chrome

## Security Details

| Aspect | Implementation |
|--------|----------------|
| Password hashing | bcrypt via `hash_password()` / `verify_password()` |
| Token type | JWT (HS256) |
| Token payload | `{"sub": "<user_id>"}` |
| Token expiry | 15 minutes (cookie `max_age`) |
| Cookie flags | `HttpOnly`, `SameSite=strict`, `Secure=False` (dev) |
| Token transport | HttpOnly cookie (not localStorage) |
| Role enforcement | `get_admin_user` dependency checks `user.roles` for "admin" |

## Testing

`backend/app/modules/user/tests/test_users.py` covers:
- `test_auth_register` - successful registration
- `test_auth_register_duplicate` - 409 on duplicate email
- `test_auth_login_invalid` - 401 on wrong password
- `test_users_me` - authenticated `/me` returns user
- `test_users_me_unauthorized` - 401 without token
- `test_users_list` - admin can list all users

Helper `create_admin_client()` creates admin user + role, logs in, sets cookie.

## Integration Points

| Component | Depends On |
|-----------|------------|
| `register` | `get_db`, `hash_password`, `User` model |
| `login` | `get_db`, `verify_password`, `create_access_token` |
| `get_me` | `get_current_user` → `extract_token_from_request` → `verify_token` |
| `get_users` | `get_admin_user` → `get_current_user` → ... |
| Frontend `authService` | Axios instance (`@/shared/api`) with baseURL |
| Frontend `authStore` | `authService`, router for redirects |

## Configuration

Token expiry controlled in `auth.py`:
```python
max_age=15 * 60  # 15 minutes
```

Cookie `secure=False` for local dev; must be `True` in production (HTTPS).

## Common Issues

1. **Cookie not sent** - Frontend must use `credentials: 'include'` (configured in axios instance)
2. **CORS** - Backend must allow credentials: `allow_credentials=True` in CORS middleware
3. **Token expiry** - 15 min is short; consider refresh token flow for production
4. **Duplicate stores** - `frontend/src/stores/auth.ts` vs `frontend/src/modules/user/stores/auth.ts` - consolidate

## File Map

```
backend/app/modules/user/
├── user.py                    # User SQLAlchemy model
├── api/
│   ├── auth.py               # register, login endpoints
│   ├── users.py              # /me, / (admin) endpoints
│   └── health.py             # health check
└── tests/
    ├── test_users.py         # Auth + user endpoint tests
    └── test_api_errors.py    # Error handler tests

frontend/src/modules/user/
├── services/auth.ts          # API calls
├── stores/auth.ts            # Pinia auth store (active)
├── views/
│   ├── LoginForm.vue
│   └── RegistrationForm.vue
└── layouts/AuthLayout.vue    # Minimal auth page layout
```