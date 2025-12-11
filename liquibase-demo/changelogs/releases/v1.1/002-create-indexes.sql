--liquibase formatted sql

--changeset dbateam:v1.1-002 labels:v1.1,ddl,performance context:prod,uat,dev
--comment: Add performance indexes for order queries and customer lookups
CREATE INDEX idx_orders_customer_id ON app.orders(customer_id);
CREATE INDEX idx_orders_order_date ON app.orders(order_date);
CREATE INDEX idx_orders_status ON app.orders(status) WHERE status IN ('pending', 'processing');
CREATE INDEX idx_order_items_order_id ON app.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON app.order_items(product_id);
CREATE INDEX idx_customers_email ON app.customers(email);
CREATE INDEX idx_products_sku ON app.products(sku);
--rollback DROP INDEX IF EXISTS app.idx_products_sku;
--rollback DROP INDEX IF EXISTS app.idx_customers_email;
--rollback DROP INDEX IF EXISTS app.idx_order_items_product_id;
--rollback DROP INDEX IF EXISTS app.idx_order_items_order_id;
--rollback DROP INDEX IF EXISTS app.idx_orders_status;
--rollback DROP INDEX IF EXISTS app.idx_orders_order_date;
--rollback DROP INDEX IF EXISTS app.idx_orders_customer_id;
