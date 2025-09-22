--liquibase formatted sql

--changeset james.bennett:001
-- no comment/context/labels; NO ROLLBACK  -> RollbackRequired
CREATE TABLE customers (
    id          BIGSERIAL PRIMARY KEY,
    first_name  TEXT,
    last_name   TEXT,
    email       TEXT,      -- PII-ish
    ssn         TEXT,      -- PII-ish
    dob         DATE       -- PII-ish
);

--changeset james.bennett:002
-- NO ROLLBACK; very wide table -> TableColumnLimit
CREATE TABLE way_too_wide (
    id BIGSERIAL PRIMARY KEY,
    c001 INT, c002 INT, c003 INT, c004 INT, c005 INT, c006 INT, c007 INT, c008 INT, c009 INT, c010 INT,
    c011 INT, c012 INT, c013 INT, c014 INT, c015 INT, c016 INT, c017 INT, c018 INT, c019 INT, c020 INT,
    c021 INT, c022 INT, c023 INT, c024 INT, c025 INT, c026 INT, c027 INT, c028 INT, c029 INT, c030 INT,
    c031 INT, c032 INT, c033 INT, c034 INT, c035 INT, c036 INT, c037 INT, c038 INT, c039 INT, c040 INT,
    c041 INT, c042 INT, c043 INT, c044 INT, c045 INT, c046 INT, c047 INT, c048 INT, c049 INT, c050 INT,
    c051 INT, c052 INT, c053 INT, c054 INT, c055 INT, c056 INT, c057 INT, c058 INT, c059 INT, c060 INT
);

--changeset james.bennett:003
-- multiple statements in one set; NO ROLLBACK
-- ChangeDropColumnWarn (drop column)
ALTER TABLE customers ADD COLUMN temp_col TEXT;
ALTER TABLE customers DROP COLUMN temp_col;

--changeset james.bennett:004
-- NO ROLLBACK -> ChangeDropTableWarn
DROP TABLE IF EXISTS way_too_wide;

--changeset ben.riley:005
-- NO ROLLBACK -> ChangeTruncateTableWarn
CREATE TABLE scratch (id BIGSERIAL PRIMARY KEY, note TEXT);
TRUNCATE TABLE scratch;

--changeset ben.riley:006
-- NO ROLLBACK -> ModifyDataTypeWarn
ALTER TABLE customers
    ALTER COLUMN first_name TYPE VARCHAR(10),
    ALTER COLUMN last_name  TYPE VARCHAR(10);

--changeset ben.riley:007
-- GRANT patterns -> SqlGrantWarn / SqlGrantOptionWarn / SqlGrantAdminWarn
-- NO ROLLBACK
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_writer') THEN
        CREATE ROLE app_writer LOGIN PASSWORD 'badpassword';
    END IF;
END $$;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_writer WITH GRANT OPTION;  -- grant option
GRANT app_writer TO postgres WITH ADMIN OPTION;                                              -- admin option

--changeset ben.riley:008
-- REVOKE pattern -> SqlRevokeWarn
-- NO ROLLBACK
REVOKE ALL ON SCHEMA public FROM PUBLIC;

--changeset ben.riley:009
-- SELECT * pattern -> SqlSelectStarWarn
-- NO ROLLBACK
-- (Liquibase will run it as a raw SQL change; it’s intentionally useless)
SELECT * FROM customers;

--changeset ben.riley:010 runInTransaction:false
-- Explicitly disabling transactions -> CheckRunInTransactionValue (warn)
-- NO ROLLBACK
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_customers_email ON customers (email);
