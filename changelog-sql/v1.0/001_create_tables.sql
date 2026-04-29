--liquibase formatted sql

-- ============================================================
--  001_create_tables.sql
--  Initial schema -- core application tables
-- ============================================================


-- ------------------------------------------------------------
--  customers
-- ------------------------------------------------------------
--changeset ben.riley:001-01 labels:v1.0 context:dev,uat,prod
--comment: Create customers table
CREATE TABLE customers (
    customer_id   INT             NOT NULL IDENTITY(1,1),
    first_name    NVARCHAR(100)   NOT NULL,
    last_name     NVARCHAR(100)   NOT NULL,
    email         NVARCHAR(255)   NOT NULL,
    created_at    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    updated_at    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    is_active     BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_email UNIQUE (email)
);
--rollback DROP TABLE customers;


-- ------------------------------------------------------------
--  orders
-- ------------------------------------------------------------
--changeset ben.riley:001-02 labels:v1.0 context:dev,uat,prod
--comment: Create orders table
CREATE TABLE orders (
    order_id      INT             NOT NULL IDENTITY(1,1),
    customer_id   INT             NOT NULL,
    order_date    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    status        NVARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    total_amount  DECIMAL(18,2)   NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
);
--rollback DROP TABLE orders;


-- ------------------------------------------------------------
--  order_items
-- ------------------------------------------------------------
--changeset ben.riley:001-03 labels:v1.0 context:dev,uat,prod
--comment: Create order_items table
CREATE TABLE order_items (
    item_id       INT             NOT NULL IDENTITY(1,1),
    order_id      INT             NOT NULL,
    product_code  NVARCHAR(50)    NOT NULL,
    quantity      INT             NOT NULL DEFAULT 1,
    unit_price    DECIMAL(18,2)   NOT NULL,
    CONSTRAINT pk_order_items PRIMARY KEY (item_id),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
);
--rollback DROP TABLE order_items;