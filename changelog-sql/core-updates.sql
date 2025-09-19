--liquibase formatted sql

--changeset briley:001
-- no comment on purpose (ChangesetCommentCheck)
-- no context on purpose (ChangesetContextCheck)
-- no labels on purpose (ChangesetLabelCheck)
-- no rollback on purpose (RollbackRequired)
CREATE TABLE customers (
    id          BIGSERIAL PRIMARY KEY,
    first_name  TEXT,
    last_name   TEXT,
    email       TEXT,      -- PII (GDPRCHECKER)
    ssn         TEXT,      -- PII (GDPRCHECKER)
    dob         DATE       -- PII (GDPRCHECKER)
);

--changeset jbennett:002
-- no comment/context/labels; wide table to exceed TableColumnLimit; no rollback
CREATE TABLE wide_table1 (
    id BIGSERIAL PRIMARY KEY,
    c001 INT, c002 INT, c003 INT, c004 INT, c005 INT, c006 INT, c007 INT, c008 INT, c009 INT, c010 INT,
    c011 INT, c012 INT, c013 INT, c014 INT, c015 INT, c016 INT, c017 INT, c018 INT, c019 INT, c020 INT,
    c021 INT, c022 INT, c023 INT, c024 INT, c025 INT, c026 INT, c027 INT, c028 INT, c029 INT, c030 INT,
    c031 INT, c032 INT, c033 INT, c034 INT, c035 INT, c036 INT, c037 INT, c038 INT, c039 INT, c040 INT,
    c041 INT, c042 INT, c043 INT, c044 INT, c045 INT, c046 INT, c047 INT, c048 INT, c049 INT, c050 INT,
    c051 INT, c052 INT, c053 INT, c054 INT, c055 INT, c056 INT, c057 INT, c058 INT, c059 INT, c060 INT
);

--changeset mikeo:003 context:dev
--comment: Intentionally packs multiple changes in one changeset (OneChangePerChangeset)
-- no labels; no rollback
ALTER TABLE customers ADD COLUMN extra_col1 INT;
ALTER TABLE customers ADD COLUMN extra_col2 INT;

--changeset briley:004
-- no comment/context/labels; wide table #2 to exceed TableColumnLimit; no rollback
CREATE TABLE wide_table2 (
    id BIGSERIAL PRIMARY KEY,
    w001 INT, w002 INT, w003 INT, w004 INT, w005 INT, w006 INT, w007 INT, w008 INT, w009 INT, w010 INT,
    w011 INT, w012 INT, w013 INT, w014 INT, w015 INT, w016 INT, w017 INT, w018 INT, w019 INT, w020 INT,
    w021 INT, w022 INT, w023 INT, w024 INT, w025 INT, w026 INT, w027 INT, w028 INT, w029 INT, w030 INT,
    w031 INT, w032 INT, w033 INT, w034 INT, w035 INT, w036 INT, w037 INT, w038 INT, w039 INT, w040 INT,
    w041 INT, w042 INT, w043 INT, w044 INT, w045 INT, w046 INT, w047 INT, w048 INT, w049 INT, w050 INT,
    w051 INT, w052 INT, w053 INT, w054 INT, w055 INT
);

--changeset jbennett:005 context:dev
--comment: Small app log table (this one is “well-formed”)
-- no labels
CREATE TABLE app_log (
    id        BIGSERIAL PRIMARY KEY,
    at        TIMESTAMP NOT NULL DEFAULT NOW(),
    level     TEXT NOT NULL,
    message   TEXT
);
--rollback DROP TABLE IF EXISTS app_log;

--changeset mikeo:006
--comment: Analytics events table (no context)
-- no labels
CREATE TABLE analytics_event (
    id           BIGSERIAL PRIMARY KEY,
    occurred_at  TIMESTAMP NOT NULL,
    actor_id     BIGINT,
    event_type   TEXT,
    details      JSONB
);
--rollback DROP TABLE IF EXISTS analytics_event;

--changeset briley:007 context:test
--comment: Index for app_log timestamp
-- no labels
CREATE INDEX IF NOT EXISTS app_log_at_idx ON app_log(at);
--rollback DROP INDEX IF EXISTS app_log_at_idx;

--changeset jbennett:008
--comment: Rename a column (no context)
-- no labels
ALTER TABLE app_log RENAME COLUMN message TO message_text;
--rollback ALTER TABLE app_log RENAME COLUMN message_text TO message;

--changeset mikeo:009
-- no comment/context/labels (to trip comment/context/label checks again)
CREATE TABLE temp_no_comment (
    id BIGSERIAL PRIMARY KEY,
    note TEXT
);
--rollback DROP TABLE IF EXISTS temp_no_comment;

--changeset briley:010 context:prod
--comment: Harmless lookup table (has context & rollback but still no labels)
CREATE TABLE status_lookup (
    code TEXT PRIMARY KEY,
    description TEXT NOT NULL
);
--rollback DROP TABLE IF EXISTS status_lookup;
