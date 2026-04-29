--liquibase formatted sql

-- ============================================================
--  002_add_indexes.sql
--  Performance indexes (PostgreSQL)
-- ============================================================


--changeset ben.riley:002-01 labels:v1.0 context:dev,uat,prod
--comment: Index on projects.employee_id for join performance
CREATE INDEX ix_projects_employee_id ON projects (employee_id);
--rollback DROP INDEX ix_projects_employee_id;


--changeset ben.riley:002-02 labels:v1.0 context:dev,uat,prod
--comment: Index on projects.status to support status filtering
CREATE INDEX ix_projects_status ON projects (status);
--rollback DROP INDEX ix_projects_status;


--changeset ben.riley:002-03 labels:v1.0 context:dev,uat,prod
--comment: Index on project_tasks.project_id for task lookups
CREATE INDEX ix_project_tasks_project_id ON project_tasks (project_id);
--rollback DROP INDEX ix_project_tasks_project_id;