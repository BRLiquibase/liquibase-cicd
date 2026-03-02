--liquibase formatted sql

--changeset benriley:001-planets-create-table labels: v1.0 context: Dev,test
-- Initial table creation
CREATE TABLE planets_demo (
    id         BIGSERIAL PRIMARY KEY,
    name       TEXT NOT NULL,  
    email      TEXT,
    firstname  TEXT,
    lastname   TEXT, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

--rollback DROP TABLE IF EXISTS planets_demo;

--changeset james.bennett:002 labels: v1.0 context: Dev
-- Add a few columns + a uniqueness rule
ALTER TABLE planets_demo
    ADD COLUMN discovered_by TEXT,
    ADD COLUMN first_observed DATE,
    ADD CONSTRAINT uq_planets_demo_name UNIQUE (name);
--rollback ALTER TABLE planets_demo DROP CONSTRAINT IF EXISTS uq_planets_demo_name;
--rollback ALTER TABLE planets_demo DROP COLUMN IF EXISTS first_observed, DROP COLUMN IF EXISTS discovered_by;

--changeset james.bennett:003 labels: v1.0 context: Dev
-- Create related table with FK to planets_demo
CREATE TABLE moons_demo (
    id         BIGSERIAL PRIMARY KEY,
    planet_id  BIGINT NOT NULL,
    name       TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_moons_demo_planet
        FOREIGN KEY (planet_id) 
        REFERENCES planets_demo(id) 
        ON DELETE CASCADE
);

--rollback DROP TABLE IF EXISTS moons_demo;

--changeset ben.riley:004 labels: v1.0 context: Dev
CREATE INDEX IF NOT EXISTS idx_moons_demo_planet_id ON moons_demo (planet_id);
CREATE INDEX IF NOT EXISTS idx_planets_demo_name ON planets_demo (name);
--rollback DROP INDEX IF EXISTS idx_moons_demo_planet_id;
--rollback DROP INDEX IF EXISTS idx_planets_demo_name;

--changeset ben.riley:005-alteringplanets labels: v1.1 context: Dev
-- Example ALTER TYPE tightening (works well in demos)
ALTER TABLE planets_demo
    ALTER COLUMN name TYPE VARCHAR(50);
--rollback ALTER TABLE planets_demo
--rollback     ALTER COLUMN name TYPE TEXT;


--changeset ben.riley:006-alteringplanets labels: v1.1 context: Dev
-- Example ALTER TYPE tightening (works well in demos)
ALTER TABLE planets_demo
    ALTER COLUMN email TYPE VARCHAR(255);
--rollback ALTER TABLE planets_demo
--rollback     ALTER COLUMN email TYPE TEXT;


--changeset ben.riley:007-insertdata labels: v1.1 context: Dev
INSERT INTO planets_demo (name, email, firstname, lastname, discovered_by, first_observed) VALUES
('Mercury', '', 'Mercury', '', 'Ancient Astronomers', 'Prehistory'),
('Venus', '', 'Venus', '', 'Ancient Astronomers', 'Prehistory'),
('Earth', '', 'Earth', '', 'Ancient Astronomers', 'Prehistory'),
('Mars', '', 'Mars', '', 'Ancient Astronomers', 'Prehistory'),
('Jupiter', '', 'Jupiter', '', 'Ancient Astronomers', 'Prehistory'),
('Saturn', '', 'Saturn', '', 'Ancient Astronomers', 'Prehistory'),
('Uranus', '', 'Uranus', '', 'William Herschel', '1781-03-13'),
('Neptune', '', 'Neptune', '', 'Urbain Le Verrier & Johann Galle', '1846-09-23');
--rollback DELETE FROM planets_demo WHERE name IN ('Mercury', 'Venus', 'Earth', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune');

--changeset ben.riley:008-insertmoons labels: v1.1 context: Dev
INSERT INTO moons_demo (planet_id, name) VALUES
((SELECT id FROM planets_demo WHERE name = 'Earth'), 'Moon'),
((SELECT id FROM planets_demo WHERE name = 'Mars'), 'Phobos'),
((SELECT id FROM planets_demo WHERE name = 'Mars'), 'Deimos'),
((SELECT id FROM planets_demo WHERE name = 'Jupiter'), 'Io'),
((SELECT id FROM planets_demo WHERE name = 'Jupiter'), 'Europa'),
((SELECT id FROM planets_demo WHERE name = 'Jupiter'), 'Ganymede'),
((SELECT id FROM planets_demo WHERE name = 'Jupiter'), 'Callisto'),
((SELECT id FROM planets_demo WHERE name = 'Saturn'), 'Titan'),
((SELECT id FROM planets_demo WHERE name = 'Saturn'), 'Enceladus'),
((SELECT id FROM planets_demo WHERE name = 'Saturn'), 'Mimas'),
((SELECT id FROM planets_demo WHERE name = 'Uranus'), 'Titania'),
((SELECT id FROM planets_demo WHERE name = 'Uranus'), 'Oberon'),
((SELECT id FROM planets_demo WHERE name = 'Uranus'), 'Umbriel'),
((SELECT id FROM planets_demo WHERE name = 'Uranus'), 'Ariel'),
((SELECT id FROM planets_demo WHERE name = 'Neptune'), 'Triton');

drop table if exists planets_demo;