--liquibase formatted sql

-- ============================================================
--  001_create_tables.sql
--  Initial schema -- core application tables (PostgreSQL)
-- ============================================================


-- ------------------------------------------------------------
--  employees
-- ------------------------------------------------------------
--changeset ben.riley:001-01 labels:v1.0 context:dev,uat,prod
--comment: Create employees table
CREATE TABLE employees (
    employee_id   SERIAL          NOT NULL,
    first_name    VARCHAR(100)    NOT NULL,
    last_name     VARCHAR(100)    NOT NULL,
    email         VARCHAR(255)    NOT NULL,
    created_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_employees PRIMARY KEY (employee_id),
    CONSTRAINT uq_employees_email UNIQUE (email)
);
--rollback DROP TABLE employees;


-- ------------------------------------------------------------
--  projects
-- ------------------------------------------------------------
--changeset ben.riley:001-02 labels:v1.0 context:dev,uat,prod
--comment: Create projects table
CREATE TABLE projects (
    project_id    SERIAL          NOT NULL,
    employee_id   INT             NOT NULL,
    start_date    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    status        VARCHAR(50)     NOT NULL DEFAULT 'PENDING',
    budget        NUMERIC(18,2)   NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_projects PRIMARY KEY (project_id),
    CONSTRAINT fk_projects_employee FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id)
);
--rollback DROP TABLE projects;


-- ------------------------------------------------------------
--  project_tasks
-- ------------------------------------------------------------
--changeset ben.riley:001-03 labels:v1.0 context:dev,uat,prod
--comment: Create project_tasks table
CREATE TABLE project_tasks (
    task_id       SERIAL          NOT NULL,
    project_id    INT             NOT NULL,
    task_code     VARCHAR(50)     NOT NULL,
    quantity      INT             NOT NULL DEFAULT 1,
    unit_cost     NUMERIC(18,2)   NOT NULL,
    CONSTRAINT pk_project_tasks PRIMARY KEY (task_id),
    CONSTRAINT fk_project_tasks_project FOREIGN KEY (project_id)
        REFERENCES projects (project_id)
);
--rollback DROP TABLE project_tasks;