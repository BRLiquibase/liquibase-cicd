--liquibase formatted sql

-- ============================================================
--  002_add_indexes.sql
--  Performance indexes on high-query columns
-- ============================================================


-- ------------------------------------------------------------
--  Index: orders by customer
-- ------------------------------------------------------------
--changeset ben.riley:002-01 labels:v1.0 context:dev,uat,prod
--comment: Index on orders.customer_id for join performance
CREATE NONCLUSTERED INDEX ix_orders_customer_id
    ON orders (customer_id ASC);
--rollback DROP INDEX ix_orders_customer_id ON orders;


-- ------------------------------------------------------------
--  Index: orders by status
-- ------------------------------------------------------------
--changeset ben.riley:002-02 labels:v1.0 context:dev,uat,prod
--comment: Index on orders.status to support status filtering
CREATE NONCLUSTERED INDEX ix_orders_status
    ON orders (status ASC)
    INCLUDE (order_date, total_amount);
--rollback DROP INDEX ix_orders_status ON orders;


-- ------------------------------------------------------------
--  Index: order_items by order
-- ------------------------------------------------------------
--changeset ben.riley:002-03 labels:v1.0 context:dev,uat,prod
--comment: Index on order_items.order_id for line item lookups
CREATE NONCLUSTERED INDEX ix_order_items_order_id
    ON order_items (order_id ASC);
--rollback DROP INDEX ix_order_items_order_id ON order_items;