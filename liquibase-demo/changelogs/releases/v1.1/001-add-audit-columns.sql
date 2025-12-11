--liquibase formatted sql

--changeset dbateam:v1.1-001-customers-audit labels:v1.1,ddl,audit context:prod,uat,dev
--comment: Add audit tracking columns to customers table for SOC2 and GDPR compliance
ALTER TABLE app.customers 
    ADD COLUMN created_by VARCHAR(100),
    ADD COLUMN updated_by VARCHAR(100),
    ADD COLUMN deleted_at TIMESTAMP,
    ADD COLUMN deleted_by VARCHAR(100);

COMMENT ON COLUMN app.customers.deleted_at IS 'Soft delete timestamp for GDPR compliance';
COMMENT ON COLUMN app.customers.created_by IS 'User who created the record';
--rollback ALTER TABLE app.customers DROP COLUMN created_by, DROP COLUMN updated_by, DROP COLUMN deleted_at, DROP COLUMN deleted_by;

--changeset dbateam:v1.1-001-orders-audit labels:v1.1,ddl,audit context:prod,uat,dev
--comment: Add audit tracking columns to orders table for compliance
ALTER TABLE app.orders 
    ADD COLUMN created_by VARCHAR(100),
    ADD COLUMN updated_by VARCHAR(100);

COMMENT ON COLUMN app.orders.created_by IS 'User who created the record';
COMMENT ON COLUMN app.orders.updated_by IS 'User who last updated the record';
--rollback ALTER TABLE app.orders DROP COLUMN created_by, DROP COLUMN updated_by;