# System Administration & Configuration

# System Administration & Configuration Module

## Purpose
Provides endpoints for system monitoring, log access, role-based access control, and dynamic configuration management. Enables administrators to view system status, retrieve logs, manage user roles, and adjust runtime settings.

## Key Components

### Admin API Endpoints
- **`logs.py`**: `/logs` endpoint returns redacted system log entries. Reads log file, parses JSON lines, applies sensitive data redaction.
- **`status.py`**: `/system-info` endpoint returns static system metadata: version, OS, database type.

### System API Endpoints
- **`config.py`**: 
  - `GET /`: Returns all system settings as key-value pairs.
  - `GET /{key}`: Returns specific setting value. For `system.default_bearer_token`, syncs from `.token` file if DB value differs.
  - `PUT /{key}`: Updates setting value. For `system.default_bearer_token`, writes to `.token` file.
- **`health.py`**: `/health` endpoint checks database connectivity via `SELECT 1`.

### Core Models
- **`Role`** (`admin/models/role/role.py`): Defines RBAC roles. Links to users via association table.
- **`SystemSetting`** (`system/models/system_setting.py`): Stores settings as JSON in `settings` column. Unique `key` constraint.
- **`TraceEntry`** (`admin/models/trace/trace_entry.py`): Logs function performance traces (module, function, duration).
- **`TraceConfiguration`** (`admin/models/trace/trace_configuration.py`): *Deprecated*. Use `SystemSetting` for tracing config (`tracing.{service}`).

### Utilities & Services
- **`redactor.py`**: `redact_sensitive_data()` recursively replaces values for keys in `SENSITIVE_KEYS` (password, token, etc.) with `[REDACTED]`.
- **`setting_service.py`**: 
  - `get_setting()`: Fetches setting by key.
  - `set_setting()`: Creates or updates setting.
  - `sync_token_to_file()`: Writes bearer token to `.token` file.
  - `get_all_settings()`: Returns all settings as dict.

## Authentication & Authorization
All admin endpoints require `get_admin_user` dependency (from `app.api.v1.deps`), which validates:
1. Valid authentication token (Bearer or cookie)
2. User possesses `admin` role (via `Role` model)

## Configuration Flow
### Getting Bearer Token
1. Client requests `GET /api/v1/system/config/system.default_bearer_token`
2. Endpoint checks DB value via `get_setting()`
3. If key matches `system.default_bearer_token`:
   - Reads `.token` file if exists
   - Updates DB with file token if different
   - Returns (potentially updated) token value
4. For other keys: returns DB value directly

### Updating Bearer Token
1. Client requests `PUT /api/v1/system/config/system.default_bearer_token` with `{ "value": "new_token" }`
2. Endpoint:
   - Updates DB via `set_setting()`
   - Calls `sync_token_to_file()` to write token to `.token` file
3. Returns success response

## Health Check
- Executes `SELECT 1` via SQLAlchemy
- Returns `{"status": "ok", "database": "ok"}` on success
- Throws 503 error on database failure

## Log Retrieval
1. Client requests `GET /api/v1/admin/logs`
2. Endpoint:
   - Verifies admin privileges
   - Reads log file (`settings.LOG_FILE_PATH`)
   - Parses last `tail` lines as JSON
   - Applies `redact_sensitive_data()` to each entry
3. Returns `{"logs": [redacted_entries]}`

## Database Integration
- Uses `get_db` dependency for session management
- `SystemSetting` and `Role` models mapped via SQLAlchemy ORM
- All modifications committed via `db.session.commit()`

## Tracing Configuration (Deprecated)
- Legacy `TraceConfiguration` model replaced by `SystemSetting`
- Tracing enabled via `system.tracing.{service}` setting (e.g., `system.tracing.admin`)
- Value format: `{"enabled": true}`

## Frontend Integration
- **AdminStatus.vue**: 
  - Displays system info (`/api/v1/admin/system-info`)
  - Shows tracing status (`/api/v1/system/config/tracing.admin`)
  - Toggles tracing via PUT to same endpoint
  - Fetches logs (`/api/v1/admin/logs`)
- **SettingsView.vue**: 
  - Lists all settings (`/api/v1/system/config/`)
  - Updates individual settings via PUT
- **LogsView.vue**: 
  - Displays raw log entries (`/api/v1/admin/logs`)

## Security Considerations
- Log redaction prevents leakage of credentials in log outputs
- Admin endpoints strictly require authenticated admin users
- Bearer token synchronization ensures consistency between DB and file-based auth systems
- Input validation on config endpoints (requires `value` field in PUT payload)