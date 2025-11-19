--liquibase formatted sql
--changeset james.bennett:001CreatePlanetsTable
-- Initial table creation
CREATE TABLE planets_demo (
    id    BIGSERIAL PRIMARY KEY,
    name  TEXT NOT NULL,  
    email TEXT,
    firstname TEXT,
    lastname TEXT, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

);

--rollback DROP TABLE IF EXISTS planets_demo;

--changeset james.bennett:002AddColumns
-- Add a few columns + a uniqueness rule
ALTER TABLE planets_demo
    ADD COLUMN discovered_by TEXT,
    ADD COLUMN first_observed DATE;
ALTER TABLE planets_demo
    ADD CONSTRAINT uq_planets_demo_name UNIQUE (name);
--rollback ALTER TABLE planets_demo DROP CONSTRAINT IF EXISTS uq_planets_demo_name;
--rollback ALTER TABLE planets_demo DROP COLUMN IF EXISTS first_observed;
--rollback ALTER TABLE planets_demo DROP COLUMN IF EXISTS discovered_by;

-- [DB2] ALTER TABLE planets_demo ADD COLUMN discovered_by VARCHAR(255);
-- [DB2] ALTER TABLE planets_demo ADD COLUMN first_observed DATE;
-- [DB2] ALTER TABLE planets_demo ADD CONSTRAINT uq_planets_demo_name UNIQUE (name);

--changeset james.bennett:003CreateMoonsTable
-- Create related table with FK to planets_demo
CREATE TABLE moons_demo (
    id          BIGSERIAL PRIMARY KEY,
    planet_id   BIGINT NOT NULL,
    name        TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_moons_demo_planet
      FOREIGN KEY (planet_id) REFERENCES planets_demo(id) ON DELETE CASCADE
);

drop table addresses;
--rollback DROP TABLE IF EXISTS moons_demo;

--changeset ben.riley:004
-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_moons_demo_planet_id ON moons_demo (planet_id);
CREATE INDEX IF NOT EXISTS idx_planets_demo_name ON planets_demo (name);
--rollback DROP INDEX IF EXISTS idx_moons_demo_planet_id;
--rollback DROP INDEX IF EXISTS idx_planets_demo_name;

--changeset ben.riley:005
-- Example ALTER TYPE tightening (works well in demos)
ALTER TABLE planets_demo
    ALTER COLUMN name TYPE VARCHAR(50);
--rollback ALTER TABLE planets_demo
--rollback     ALTER COLUMN name TYPE TEXT;
