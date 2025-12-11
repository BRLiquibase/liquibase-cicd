--liquibase formatted sql

--changeset architect:v2.0-003 labels:v2.0,dml,migration context:prod,uat,dev
--comment: Migrate existing customer data to new address structure
INSERT INTO app.customer_addresses (customer_id, address_type, address_line1, city, state, postal_code, is_default)
SELECT 
    customer_id,
    'billing',
    '123 Default Street',
    'San Francisco',
    'CA',
    '94105',
    true
FROM app.customers
WHERE NOT EXISTS (
    SELECT 1 FROM app.customer_addresses 
    WHERE customer_addresses.customer_id = customers.customer_id
);
--rollback DELETE FROM app.customer_addresses WHERE address_line1 = '123 Default Street';
