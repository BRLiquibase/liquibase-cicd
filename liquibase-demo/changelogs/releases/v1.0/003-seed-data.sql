--liquibase formatted sql

--changeset devops:v1.0-003 labels:v1.0,dml,seed-data context:dev,uat runOnChange:false
--comment: Insert initial reference data for development and testing
INSERT INTO app.customers (email, first_name, last_name, phone) VALUES
('john.doe@example.com', 'John', 'Doe', '555-0101'),
('jane.smith@example.com', 'Jane', 'Smith', '555-0102'),
('bob.johnson@example.com', 'Bob', 'Johnson', '555-0103');

INSERT INTO app.products (sku, name, description, price, stock_quantity) VALUES
('WIDGET-001', 'Premium Widget', 'High-quality widget for industrial use', 99.99, 100),
('GADGET-001', 'Smart Gadget', 'IoT-enabled smart gadget', 149.99, 50),
('TOOL-001', 'Professional Tool', 'Professional-grade tool', 249.99, 25);

INSERT INTO app.orders (customer_id, order_number, total_amount, status) VALUES
(1, 'ORD-2024-001', 99.99, 'completed'),
(2, 'ORD-2024-002', 399.98, 'pending');

INSERT INTO app.order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 99.99, 99.99),
(2, 2, 2, 149.99, 299.98),
(2, 1, 1, 99.99, 99.99);
--rollback DELETE FROM app.order_items;
--rollback DELETE FROM app.orders;
--rollback DELETE FROM app.products;
--rollback DELETE FROM app.customers;
