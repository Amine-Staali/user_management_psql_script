-- =========================
-- Set Variables
-- =========================
\set my_user     'username'
\set my_schema   'public'
\set my_password 'strong_password'

-- =========================
-- View DB Users
-- =========================
SELECT usename     AS username,
       usesysid    AS user_id,
       usecreatedb AS can_create_db,
       usesuper    AS is_superuser,
       userepl     AS can_replicate,
       valuntil    AS password_expiry
FROM pg_user
ORDER BY usename;

-- =========================
-- Create User
-- =========================
DO $$
DECLARE
    my_user     TEXT := :'my_user';
    my_password TEXT := :'my_password';
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = my_user
    ) THEN
        EXECUTE format('CREATE USER %I WITH PASSWORD %L', my_user, my_password);
    END IF;
END
$$;

-- =========================
-- Grant READ ONLY on Schema
-- =========================
DO $$
DECLARE
    my_user   TEXT := :'my_user';
    my_schema TEXT := :'my_schema';
BEGIN
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO %I', my_schema, my_user);
    EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO %I', my_schema, my_user);
    EXECUTE format('GRANT SELECT ON ALL SEQUENCES IN SCHEMA %I TO %I', my_schema, my_user);
    EXECUTE format(
        'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT ON TABLES TO %I',
        my_schema,
        my_user
    );
END
$$;
