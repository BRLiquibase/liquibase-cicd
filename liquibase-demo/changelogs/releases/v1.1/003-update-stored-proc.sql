--liquibase formatted sql

--changeset dbateam:v1.1-003 labels:v1.1,ddl,functions runOnChange:true context:prod,uat,dev splitStatements:false
--comment: Create function to calculate customer lifetime value with order totals
CREATE OR REPLACE FUNCTION app.get_customer_lifetime_value(p_customer_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total
    FROM app.orders
    WHERE customer_id = p_customer_id
      AND status = 'completed'
      AND deleted_at IS NULL;
    
    RETURN v_total;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION app.get_customer_lifetime_value IS 'Calculate total completed order value for customer';
--rollback DROP FUNCTION IF EXISTS app.get_customer_lifetime_value(INTEGER);