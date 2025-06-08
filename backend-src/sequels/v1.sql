DO
$do$
    BEGIN
        IF EXISTS (
            SELECT FROM pg_catalog.pg_roles
            WHERE  rolname = 'f2') THEN

            RAISE NOTICE 'Role "f2" already exists. Skipping.';
        ELSE
            CREATE ROLE f2 LOGIN PASSWORD 'f2123!'; --- change this for production
        END IF;
    END
$do$;

DO
$do$
    BEGIN
        IF EXISTS (SELECT FROM pg_database WHERE datname = 'f2') THEN
            RAISE NOTICE 'Database already exists';  -- optional
        ELSE
            PERFORM dblink_exec('dbname=' || current_database()  -- current db
                , 'CREATE DATABASE f2 WITH OWNER f2 ENCODING ''UTF8''');
        END IF;
    END
$do$;

create table if not exists f2.users
(
    id     uuid primary key,
    handle text not null unique,
    email  text not null unique
);
