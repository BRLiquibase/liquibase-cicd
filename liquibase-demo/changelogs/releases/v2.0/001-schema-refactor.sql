--liquibase formatted sql

--changeset architect:v2.0-001 labels:v2.0,ddl,refactor context:prod,uat,dev
--comment: Add customer address table for shipping functionality
CREATE TABLE app.customer_addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES app.customers(customer_id),
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('billing', 'shipping')),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(2) NOT NULL DEFAULT 'US',
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_default_address UNIQUE (customer_id, address_type, is_default) 
        DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX idx_addresses_customer_id ON app.customer_addresses(customer_id);
COMMENT ON TABLE app.customer_addresses IS 'Customer shipping and billing addresses';
--rollback DROP TABLE IF EXISTS app.customer_addresses CASCADE;

--changeset architect:v2.0-002 labels:v2.0,ddl,refactor context:prod,uat,dev
--comment: Add shipping address reference to orders
ALTER TABLE app.orders 
    ADD COLUMN shipping_address_id INTEGER REFERENCES app.customer_addresses(address_id);

CREATE INDEX idx_orders_shipping_address ON app.orders(shipping_address_id);
--rollback ALTER TABLE app.orders DROP COLUMN shipping_address_id;
