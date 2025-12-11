--liquibase formatted sql

--changeset hotfix-team:hotfix-2024-01-001 labels:hotfix,production-issue context:prod,uat,dev
--comment: HOTFIX - Add missing order status values for new fulfillment process
--preconditions onFail:MARK_RAN
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM pg_constraint WHERE conname = 'orders_status_check'

ALTER TABLE app.orders DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE app.orders 
    ADD CONSTRAINT orders_status_check 
    CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'completed', 'cancelled', 'refunded'));

COMMENT ON CONSTRAINT orders_status_check ON app.orders IS 'Valid order status values including fulfillment states';
--rollback ALTER TABLE app.orders DROP CONSTRAINT IF EXISTS orders_status_check;
--rollback ALTER TABLE app.orders ADD CONSTRAINT orders_status_check CHECK (status IN ('pending', 'processing', 'completed', 'cancelled'));