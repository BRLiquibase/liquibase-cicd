#!/usr/bin/env python3
"""
Liquibase Demo Project Generator
Creates a complete Liquibase demo structure with PostgreSQL examples
"""

import os
from pathlib import Path

def create_demo_structure(base_path="."):
    """Create the complete Liquibase demo project structure"""
    
    base = Path(base_path) / "liquibase-demo"
    
    # Define directory structure
    directories = [
        "changelogs/releases/v1.0/rollback",
        "changelogs/releases/v1.1",
        "changelogs/releases/v2.0",
        "changelogs/hotfix",
    ]
    
    # Define files and their content
    files = {
        "liquibase.properties": """changeLogFile=changelogs/master.root.xml
url=jdbc:postgresql://localhost:5432/demo_db
username=postgres
password=postgres
driver=org.postgresql.Driver
liquibase.hub.mode=off
""",
        
        "changelogs/master.root.xml": """<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">

    <!-- Release 1.0 - Initial Application Schema -->
    <include file="releases/v1.0/release-v1.0.xml" relativeToChangelogFile="true"/>
    
    <!-- Release 1.1 - Audit and Performance Enhancements -->
    <include file="releases/v1.1/release-v1.1.xml" relativeToChangelogFile="true"/>
    
    <!-- Release 2.0 - Customer Portal and Data Migration -->
    <include file="releases/v2.0/release-v2.0.xml" relativeToChangelogFile="true"/>
    
    <!-- Hotfixes -->
    <include file="hotfix/hotfix-2024-01.xml" relativeToChangelogFile="true"/>

</databaseChangeLog>
""",
        
        "changelogs/releases/v1.0/release-v1.0.xml": """<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">

    <include file="001-create-schema.sql" relativeToChangelogFile="true"/>
    <include file="002-create-tables.sql" relativeToChangelogFile="true"/>
    <include file="003-seed-data.sql" relativeToChangelogFile="true"/>

</databaseChangeLog>
""",
        
        "changelogs/releases/v1.0/001-create-schema.sql": """--liquibase formatted sql

--changeset devops:v1.0-001 labels:v1.0,schema,initial context:prod,uat,dev
--comment: Create application schema for e-commerce platform
CREATE SCHEMA IF NOT EXISTS app;
COMMENT ON SCHEMA app IS 'Main application schema for e-commerce platform';
--rollback DROP SCHEMA IF EXISTS app CASCADE;
""",
        
        "changelogs/releases/v1.0/002-create-tables.sql": """--liquibase formatted sql

--changeset devops:v1.0-002 labels:v1.0,ddl,tables context:prod,uat,dev
--comment: Create core tables: customers, products, orders, order_items
CREATE TABLE app.customers (
    customer_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

CREATE TABLE app.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES app.orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES app.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE app.customers IS 'Customer master data';
COMMENT ON TABLE app.products IS 'Product catalog';
COMMENT ON TABLE app.orders IS 'Customer orders';
COMMENT ON TABLE app.order_items IS 'Order line items';
--rollback DROP TABLE IF EXISTS app.order_items CASCADE;
--rollback DROP TABLE IF EXISTS app.orders CASCADE;
--rollback DROP TABLE IF EXISTS app.products CASCADE;
--rollback DROP TABLE IF EXISTS app.customers CASCADE;
""",
        
        "changelogs/releases/v1.0/003-seed-data.sql": """--liquibase formatted sql

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
""",
        
        "changelogs/releases/v1.1/release-v1.1.xml": """<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">

    <include file="001-add-audit-columns.sql" relativeToChangelogFile="true"/>
    <include file="002-create-indexes.sql" relativeToChangelogFile="true"/>
    <include file="003-update-stored-proc.sql" relativeToChangelogFile="true"/>

</databaseChangeLog>
""",
        
        "changelogs/releases/v1.1/001-add-audit-columns.sql": """--liquibase formatted sql

--changeset dbateam:v1.1-001 labels:v1.1,ddl,audit context:prod,uat,dev
--comment: Add audit tracking columns for compliance (SOC2, GDPR)
ALTER TABLE app.customers 
    ADD COLUMN created_by VARCHAR(100),
    ADD COLUMN updated_by VARCHAR(100),
    ADD COLUMN deleted_at TIMESTAMP,
    ADD COLUMN deleted_by VARCHAR(100);

ALTER TABLE app.orders 
    ADD COLUMN created_by VARCHAR(100),
    ADD COLUMN updated_by VARCHAR(100);

COMMENT ON COLUMN app.customers.deleted_at IS 'Soft delete timestamp for GDPR compliance';
COMMENT ON COLUMN app.customers.created_by IS 'User who created the record';
--rollback ALTER TABLE app.orders DROP COLUMN created_by, DROP COLUMN updated_by;
--rollback ALTER TABLE app.customers DROP COLUMN created_by, DROP COLUMN updated_by, DROP COLUMN deleted_at, DROP COLUMN deleted_by;
""",
        
        "changelogs/releases/v1.1/002-create-indexes.sql": """--liquibase formatted sql

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
""",
        
        "changelogs/releases/v1.1/003-update-stored-proc.sql": """--liquibase formatted sql

--changeset dbateam:v1.1-003 labels:v1.1,ddl,functions runOnChange:true context:prod,uat,dev
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
""",
        
        "changelogs/releases/v2.0/release-v2.0.xml": """<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">

    <include file="001-schema-refactor.sql" relativeToChangelogFile="true"/>
    <include file="002-data-migration.sql" relativeToChangelogFile="true"/>

</databaseChangeLog>
""",
        
        "changelogs/releases/v2.0/001-schema-refactor.sql": """--liquibase formatted sql

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
""",
        
        "changelogs/releases/v2.0/002-data-migration.sql": """--liquibase formatted sql

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
""",
        
        "changelogs/hotfix/hotfix-2024-01.xml": """<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">

    <include file="001-fix-order-status-constraint.sql" relativeToChangelogFile="true"/>

</databaseChangeLog>
""",
        
        "changelogs/hotfix/001-fix-order-status-constraint.sql": """--liquibase formatted sql

--changeset hotfix-team:hotfix-2024-01-001 labels:hotfix,production-issue context:prod,uat,dev
--comment: HOTFIX - Add missing order status values for new fulfillment process
--preconditions onFail:MARK_RAN
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM pg_constraint WHERE conname = 'orders_status_check'

ALTER TABLE app.orders DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE app.orders 
    ADD CONSTRAINT orders_status_check 
    CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'));

COMMENT ON CONSTRAINT orders_status_check ON app.orders IS 'Valid order status values including fulfillment states';
--rollback ALTER TABLE app.orders DROP CONSTRAINT IF EXISTS orders_status_check;
--rollback ALTER TABLE app.orders ADD CONSTRAINT orders_status_check CHECK (status IN ('pending', 'processing', 'completed', 'cancelled'));
""",
    }
    
    # Create base directory
    print(f"Creating Liquibase demo project at: {base.absolute()}")
    base.mkdir(exist_ok=True)
    
    # Create all directories
    for directory in directories:
        dir_path = base / directory
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"  ✓ Created directory: {directory}")
    
    # Create all files
    for file_path, content in files.items():
        full_path = base / file_path
        full_path.parent.mkdir(parents=True, exist_ok=True)
        full_path.write_text(content)
        print(f"  ✓ Created file: {file_path}")
    
    print(f"\n✅ Demo project created successfully!")
    print(f"\nNext steps:")
    print(f"  1. cd {base}")
    print(f"  2. Update liquibase.properties with your database credentials")
    print(f"  3. Run: liquibase update")
    print(f"\nDemo features:")
    print(f"  - v1.0: Initial schema, tables, seed data")
    print(f"  - v1.1: Audit columns, indexes, stored procedures")
    print(f"  - v2.0: Schema refactoring, data migration")
    print(f"  - Hotfix: Production constraint fix with preconditions")
    print(f"  - All changesets have: proper IDs, labels, contexts, comments, rollbacks")
    
    return base

if __name__ == "__main__":
    import sys
    
    # Allow custom base path as argument
    base_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    try:
        create_demo_structure(base_path)
    except Exception as e:
        print(f"❌ Error creating demo structure: {e}")
        sys.exit(1)