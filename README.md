# user_management_psql_script

A PostgreSQL (`psql`) script for managing database users and their permissions. The script provides a safe, idempotent workflow to:

1. **View existing database users** — lists all users with key attributes such as superuser status, replication rights, and password expiry.
2. **Create a new user** — only creates the role if it does not already exist, avoiding errors on re-runs.
3. **Grant read-only access to a schema** — grants `USAGE` on the schema, `SELECT` on all existing tables and sequences, and sets default privileges so that future tables in the schema are automatically readable by the new user.

---

## Prerequisites

- PostgreSQL client tools (`psql`) installed.
- A database superuser (or a user with sufficient privileges) to run the script.

---

## Configuration

Edit the variables at the top of the script before running it:

| Variable      | Default           | Description                              |
|---------------|-------------------|------------------------------------------|
| `my_user`     | `username`        | Name of the PostgreSQL user to create    |
| `my_schema`   | `public`          | Schema to grant read-only access on      |
| `my_password` | `strong_password` | Password for the new user                |

---

## Usage

```bash
psql -U <superuser> -d <database> -f user_management.sql
```

Replace `<superuser>` with your privileged PostgreSQL user and `<database>` with the target database name.

---

## What the Script Does

### 1. Set Variables

```sql
\set my_user     'username'
\set my_schema   'public'
\set my_password 'strong_password'
```

Defines the `psql` meta-variables used throughout the rest of the script.

### 2. View DB Users

Queries `pg_user` to display all current database users and their properties (user ID, create-DB privilege, superuser flag, replication flag, password expiry).

### 3. Create User

Uses a `DO` block to conditionally create the role only when it does not already exist in `pg_catalog.pg_roles`. The user name and password are injected safely with `format('%I', ...)` / `format('%L', ...)` to prevent SQL injection.

### 4. Grant Read-Only on Schema

Grants the following privileges to the new user on the specified schema:

- `USAGE` on the schema
- `SELECT` on all existing tables
- `SELECT` on all existing sequences
- Default privileges so that `SELECT` is automatically granted on any **future** tables added to the schema

---

## Security Notes

- Replace `strong_password` with a secure, randomly generated password before use.
- Use `ALTER DEFAULT PRIVILEGES` (already included) to ensure the user retains read access as new tables are created.
- The script uses `format('%I', ...)` for identifiers and `format('%L', ...)` for literals, which protects against SQL injection.