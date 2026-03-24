DO $$
DECLARE
    my_user     TEXT := 'username';
    my_schema   TEXT := 'schema_name';
    my_password TEXT := 'password';
    my_access   TEXT := 'RO';  -- 'RO' for Read Only, 'RW' for Read Write
BEGIN
    -- =========================
    -- Create User
    -- =========================
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = my_user
    ) THEN
        EXECUTE format('CREATE USER %I WITH PASSWORD %L', my_user, my_password);
        RAISE NOTICE 'User % created successfully', my_user;
    ELSE
        RAISE NOTICE 'User % already exists, skipping', my_user;
    END IF;

    -- =========================
    -- Grant Schema Access
    -- =========================
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO %I', my_schema, my_user);

    IF my_access = 'RO' THEN
        -- =========================
        -- READ ONLY
        -- =========================
        EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO %I', my_schema, my_user);
        EXECUTE format('GRANT SELECT ON ALL SEQUENCES IN SCHEMA %I TO %I', my_schema, my_user);
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT ON TABLES TO %I',
            my_schema, my_user
        );
    EXECUTE format(
            'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT ON SEQUENCES TO %I',
            my_schema, my_user
        );
        RAISE NOTICE 'READ ONLY permissions granted on schema % to user %', my_schema, my_user;

    ELSIF my_access = 'RW' THEN
        -- =========================
        -- READ WRITE
        -- =========================
    EXECUTE format('GRANT ALL ON SCHEMA %I TO %I', my_schema, my_user);
        EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO %I', my_schema, my_user);
        EXECUTE format('GRANT ALL ON ALL SEQUENCES IN SCHEMA %I TO %I', my_schema, my_user);
        EXECUTE format('GRANT ALL ON ALL PROCEDURES IN SCHEMA %I TO %I', my_schema, my_user);        
        -- Default privileges (future objects)
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON TABLES TO %I',
            my_schema, my_user
        );
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON SEQUENCES TO %I',
            my_schema, my_user
        );
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT EXECUTE ON FUNCTIONS TO %I',
            my_schema, my_user
        );
        RAISE NOTICE 'READ WRITE permissions granted on schema % to user %', my_schema, my_user;

    ELSE
        RAISE EXCEPTION 'Invalid access type: %. Use RO or RW.', my_access;
    END IF;

END
$$;
