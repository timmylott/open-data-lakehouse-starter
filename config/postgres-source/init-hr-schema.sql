-- ============================================================================
-- HR System Database Schema
-- ============================================================================
-- This schema represents a typical HR system with:
-- - Departments
-- - Employees
-- - Job History (tracking role changes, promotions, transfers)
-- ============================================================================

-- Create schema
CREATE SCHEMA IF NOT EXISTS hr;

-- ============================================================================
-- DEPARTMENTS
-- ============================================================================
CREATE TABLE hr.departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    manager_id INTEGER,  -- Will be FK to employees after that table is created
    location VARCHAR(100),
    budget DECIMAL(15, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE hr.departments IS 'Company departments and organizational units';

-- ============================================================================
-- EMPLOYEES
-- ============================================================================
CREATE TABLE hr.employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    termination_date DATE,
    department_id INTEGER REFERENCES hr.departments(department_id),
    job_title VARCHAR(100) NOT NULL,
    employment_status VARCHAR(20) DEFAULT 'active' CHECK (employment_status IN ('active', 'on_leave', 'terminated')),
    employee_type VARCHAR(20) DEFAULT 'full_time' CHECK (employee_type IN ('full_time', 'part_time', 'contractor', 'intern')),
    manager_id INTEGER REFERENCES hr.employees(employee_id),
    salary DECIMAL(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE hr.employees IS 'Employee master data';

-- Add manager FK to departments now that employees table exists
ALTER TABLE hr.departments 
ADD CONSTRAINT fk_department_manager 
FOREIGN KEY (manager_id) REFERENCES hr.employees(employee_id);

-- ============================================================================
-- JOB HISTORY
-- ============================================================================
CREATE TABLE hr.job_history (
    history_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES hr.employees(employee_id),
    department_id INTEGER REFERENCES hr.departments(department_id),
    job_title VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    salary DECIMAL(12, 2),
    change_reason VARCHAR(50) CHECK (change_reason IN ('promotion', 'transfer', 'role_change', 'salary_adjustment', 'demotion', 'initial_hire')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_date_order CHECK (end_date IS NULL OR end_date >= start_date)
);

COMMENT ON TABLE hr.job_history IS 'Historical record of employee job changes, promotions, and transfers';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Employees indexes
CREATE INDEX idx_employees_department ON hr.employees(department_id);
CREATE INDEX idx_employees_manager ON hr.employees(manager_id);
CREATE INDEX idx_employees_status ON hr.employees(employment_status);
CREATE INDEX idx_employees_email ON hr.employees(email);
CREATE INDEX idx_employees_hire_date ON hr.employees(hire_date);

-- Job history indexes
CREATE INDEX idx_job_history_employee ON hr.job_history(employee_id);
CREATE INDEX idx_job_history_department ON hr.job_history(department_id);
CREATE INDEX idx_job_history_dates ON hr.job_history(start_date, end_date);

-- ============================================================================
-- TRIGGERS FOR updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION hr.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_departments_updated_at
    BEFORE UPDATE ON hr.departments
    FOR EACH ROW
    EXECUTE FUNCTION hr.update_updated_at_column();

CREATE TRIGGER update_employees_updated_at
    BEFORE UPDATE ON hr.employees
    FOR EACH ROW
    EXECUTE FUNCTION hr.update_updated_at_column();

-- ============================================================================
-- SAMPLE DATA
-- ============================================================================

-- Insert Departments
INSERT INTO hr.departments (department_name, location, budget) VALUES
('Engineering', 'San Francisco', 5000000.00),
('Product', 'San Francisco', 2000000.00),
('Sales', 'New York', 3000000.00),
('Marketing', 'Austin', 1500000.00),
('Human Resources', 'Remote', 800000.00),
('Finance', 'New York', 1200000.00),
('Customer Success', 'Remote', 1000000.00),
('Data & Analytics', 'San Francisco', 1800000.00);

-- Insert Employees (Engineering Department)
INSERT INTO hr.employees (first_name, last_name, email, phone, hire_date, department_id, job_title, employment_status, employee_type, salary) VALUES
('Sarah', 'Chen', 'sarah.chen@company.com', '415-555-0101', '2020-01-15', 1, 'VP of Engineering', 'active', 'full_time', 185000.00),
('Marcus', 'Johnson', 'marcus.johnson@company.com', '415-555-0102', '2020-03-20', 1, 'Senior Software Engineer', 'active', 'full_time', 145000.00),
('Emily', 'Rodriguez', 'emily.rodriguez@company.com', '415-555-0103', '2021-06-10', 1, 'Software Engineer', 'active', 'full_time', 120000.00),
('David', 'Kim', 'david.kim@company.com', '415-555-0104', '2022-02-01', 1, 'Junior Software Engineer', 'active', 'full_time', 95000.00),
('Lisa', 'Wang', 'lisa.wang@company.com', '415-555-0105', '2021-09-15', 1, 'Engineering Manager', 'active', 'full_time', 160000.00);

-- Insert Employees (Product Department)
INSERT INTO hr.employees (first_name, last_name, email, phone, hire_date, department_id, job_title, employment_status, employee_type, salary) VALUES
('Michael', 'Brown', 'michael.brown@company.com', '415-555-0201', '2019-11-01', 2, 'VP of Product', 'active', 'full_time', 175000.00),
('Jennifer', 'Taylor', 'jennifer.taylor@company.com', '415-555-0202', '2021-01-20', 2, 'Senior Product Manager', 'active', 'full_time', 140000.00),
('Alex', 'Martinez', 'alex.martinez@company.com', '415-555-0203', '2022-04-15', 2, 'Product Manager', 'active', 'full_time', 125000.00);

-- Insert Employees (Sales Department)
INSERT INTO hr.employees (first_name, last_name, email, phone, hire_date, department_id, job_title, employment_status, employee_type, salary) VALUES
('Robert', 'Anderson', 'robert.anderson@company.com', '212-555-0301', '2020-05-10', 3, 'VP of Sales', 'active', 'full_time', 180000.00),
('Amanda', 'Wilson', 'amanda.wilson@company.com', '212-555-0302', '2021-08-15', 3, 'Senior Account Executive', 'active', 'full_time', 135000.00),
('James', 'Thompson', 'james.thompson@company.com', '212-555-0303', '2022-01-10', 3, 'Account Executive', 'active', 'full_time', 110000.00);

-- Insert Employees (Marketing Department)
INSERT INTO hr.employees (first_name, last_name, email, phone, hire_date, department_id, job_title, employment_status, employee_type, salary) VALUES
('Jessica', 'Garcia', 'jessica.garcia@company.com', '512-555-0401', '2020-07-20', 4, 'VP of Marketing', 'active', 'full_time', 165000.00),
('Daniel', 'Lee', 'daniel.lee@company.com', '512-555-0402', '2021-11-05', 4, 'Marketing Manager', 'active', 'full_time', 115000.00);

-- Insert Employees (HR Department)
INSERT INTO hr.employees (first_name, last_name, email, phone, hire_date, department_id, job_title, employment_status, employee_type, salary) VALUES
('Patricia', 'Moore', 'patricia.moore@company.com', '555-555-0501', '2019-09-01', 5, 'VP of Human Resources', 'active', 'full_time', 155000.00),
('Kevin', 'White', 'kevin.white@company.com', '555-555-0502', '2021-03-15', 5, 'HR Business Partner', 'active', 'full_time', 105000.00);

-- Insert Employees (Finance Department)
INSERT INTO hr.employees (first_name, last_name, email, phone, hire_date, department_id, job_title, employment_status, employee_type, salary) VALUES
('Laura', 'Harris', 'laura.harris@company.com', '212-555-0601', '2020-02-10', 6, 'VP of Finance', 'active', 'full_time', 170000.00),
('Christopher', 'Martin', 'christopher.martin@company.com', '212-555-0602', '2021-07-20', 6, 'Finance Manager', 'active', 'full_time', 120000.00);

-- Insert Employees (Data & Analytics)
INSERT INTO hr.employees (first_name, last_name, email, phone, hire_date, department_id, job_title, employment_status, employee_type, salary) VALUES
('Rachel', 'Davis', 'rachel.davis@company.com', '415-555-0801', '2020-10-15', 8, 'Director of Data', 'active', 'full_time', 165000.00),
('Thomas', 'Miller', 'thomas.miller@company.com', '415-555-0802', '2021-12-01', 8, 'Senior Data Engineer', 'active', 'full_time', 145000.00),
('Sophia', 'Wilson', 'sophia.wilson@company.com', '415-555-0803', '2022-05-20', 8, 'Data Analyst', 'active', 'full_time', 105000.00);

-- Update department managers
UPDATE hr.departments SET manager_id = 1 WHERE department_name = 'Engineering';
UPDATE hr.departments SET manager_id = 6 WHERE department_name = 'Product';
UPDATE hr.departments SET manager_id = 9 WHERE department_name = 'Sales';
UPDATE hr.departments SET manager_id = 12 WHERE department_name = 'Marketing';
UPDATE hr.departments SET manager_id = 14 WHERE department_name = 'Human Resources';
UPDATE hr.departments SET manager_id = 16 WHERE department_name = 'Finance';
UPDATE hr.departments SET manager_id = 18 WHERE department_name = 'Data & Analytics';

-- Update employee managers
UPDATE hr.employees SET manager_id = 1 WHERE employee_id IN (2, 3, 4, 5);  -- Engineering reports to Sarah
UPDATE hr.employees SET manager_id = 6 WHERE employee_id IN (7, 8);  -- Product reports to Michael
UPDATE hr.employees SET manager_id = 9 WHERE employee_id IN (10, 11);  -- Sales reports to Robert
UPDATE hr.employees SET manager_id = 12 WHERE employee_id = 13;  -- Marketing reports to Jessica
UPDATE hr.employees SET manager_id = 14 WHERE employee_id = 15;  -- HR reports to Patricia
UPDATE hr.employees SET manager_id = 16 WHERE employee_id = 17;  -- Finance reports to Laura
UPDATE hr.employees SET manager_id = 18 WHERE employee_id IN (19, 20);  -- Data reports to Rachel

-- Insert Job History (Initial hires and some promotions)
INSERT INTO hr.job_history (employee_id, department_id, job_title, start_date, end_date, salary, change_reason, notes) VALUES
-- Sarah's history (VP of Engineering)
(1, 1, 'Senior Engineering Manager', '2020-01-15', '2022-06-01', 145000.00, 'initial_hire', 'Started as Senior Engineering Manager'),
(1, 1, 'VP of Engineering', '2022-06-01', NULL, 185000.00, 'promotion', 'Promoted to VP of Engineering'),

-- Marcus's history (promoted from Mid-level to Senior)
(2, 1, 'Software Engineer', '2020-03-20', '2022-01-15', 120000.00, 'initial_hire', 'Initial hire as Software Engineer'),
(2, 1, 'Senior Software Engineer', '2022-01-15', NULL, 145000.00, 'promotion', 'Promoted to Senior Software Engineer'),

-- Emily's history (no changes yet)
(3, 1, 'Software Engineer', '2021-06-10', NULL, 120000.00, 'initial_hire', 'Initial hire'),

-- Lisa's history (transferred from Product to Engineering)
(5, 2, 'Product Manager', '2021-09-15', '2023-03-01', 135000.00, 'initial_hire', 'Started in Product'),
(5, 1, 'Engineering Manager', '2023-03-01', NULL, 160000.00, 'transfer', 'Transferred to Engineering as EM');

-- Add a terminated employee example
INSERT INTO hr.employees (first_name, last_name, email, phone, hire_date, termination_date, department_id, job_title, employment_status, employee_type, manager_id, salary) VALUES
('John', 'Smith', 'john.smith@company.com', '415-555-0999', '2021-01-10', '2023-12-15', 1, 'Software Engineer', 'terminated', 'full_time', 1, 115000.00);

-- Add job history for terminated employee
INSERT INTO hr.job_history (employee_id, department_id, job_title, start_date, end_date, salary, change_reason, notes) VALUES
(21, 1, 'Software Engineer', '2021-01-10', '2023-12-15', 115000.00, 'initial_hire', 'Terminated after 3 years');

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT USAGE ON SCHEMA hr TO hr_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA hr TO hr_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA hr TO hr_user;

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

CREATE OR REPLACE VIEW hr.current_employees AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.phone,
    e.hire_date,
    e.job_title,
    e.employment_status,
    e.employee_type,
    e.salary,
    d.department_name,
    d.location,
    m.first_name || ' ' || m.last_name AS manager_name,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_of_service
FROM hr.employees e
LEFT JOIN hr.departments d ON e.department_id = d.department_id
LEFT JOIN hr.employees m ON e.manager_id = m.employee_id
WHERE e.employment_status = 'active';

COMMENT ON VIEW hr.current_employees IS 'Active employees with department and manager information';

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'HR System Database Initialized';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Departments: %', (SELECT COUNT(*) FROM hr.departments);
    RAISE NOTICE 'Employees: %', (SELECT COUNT(*) FROM hr.employees);
    RAISE NOTICE 'Job History Records: %', (SELECT COUNT(*) FROM hr.job_history);
    RAISE NOTICE '========================================';
END $$;
