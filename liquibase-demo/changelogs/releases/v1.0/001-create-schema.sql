--liquibase formatted sql

--changeset devops:v1.0-001 labels:v1.0,schema,initial context:prod,uat,dev
--comment: Create application schema for e-commerce platform
CREATE SCHEMA IF NOT EXISTS app;
COMMENT ON SCHEMA app IS 'Main application schema for e-commerce platform';
--rollback DROP SCHEMA IF EXISTS app CASCADE;
