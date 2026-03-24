# user_management_psql_script

A PostgreSQL (`psql`) script for managing database users and their permissions. The script provides a safe, idempotent workflow to:

1. **Create a new user** — only creates the role if it does not already exist, avoiding errors on re-runs.
2. **Grant read-only access to a schema** — grants `USAGE` on the schema, `SELECT` on all existing tables and sequences, and sets default privileges so that future tables in the schema are automatically readable by the new user.
3. **Grant read-write access to a schema**  — grants `ALL` on the schema and all existing tables and sequences, and sets default privileges so that future tables in the schema are automatically readable & editable by the new user.

---

## Prerequisites

- PostgreSQL client tools (`psql`) installed.
- A database superuser (or a user with sufficient privileges) to run the script.

---

## Security Notes

- Replace `strong_password` with a secure, randomly generated password before use.
- The script uses `format('%I', ...)` for identifiers and `format('%L', ...)` for literals, which protects against SQL injection.
