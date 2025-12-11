--liquibase formatted sql

--changeset devops:v1.0-002-customers labels:v1.0,ddl,tables context:prod,uat,dev
--comment: Create customers table for customer master data
CREATE TABLE app.customers (
    customer_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE app.customers IS 'Customer master data';
--rollback DROP TABLE IF EXISTS app.customers CASCADE;

--changeset devops:v1.0-002-products labels:v1.0,ddl,tables context:prod,uat,dev
--comment: Create products table for product catalog
CREATE TABLE app.products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE app.products IS 'Product catalog';
--rollback DROP TABLE IF EXISTS app.products CASCADE;

--changeset devops:v1.0-002-orders labels:v1.0,ddl,tables context:prod,uat,dev
--comment: Create orders table for customer orders
CREATE TABLE app.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES app.customers(customer_id),
    order_number VARCHAR(50) NOT NULL UNIQUE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE app.orders IS 'Customer orders';
--rollback DROP TABLE IF EXISTS app.orders CASCADE;

--changeset devops:v1.0-002-order-items labels:v1.0,ddl,tables context:prod,uat,dev
--comment: Create order_items table for order line items
CREATE TABLE app.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES app.orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES app.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE app.order_items IS 'Order line items';
--rollback DROP TABLE IF EXISTS app.order_items CASCADE;