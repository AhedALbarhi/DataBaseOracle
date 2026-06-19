-- Section 7:
-- Employee Management System - Views
-- TASK 1: Simple Read-Only View:
CREATE OR REPLACE VIEW vw_employee_summary AS
SELECT
    e.emp_id,
    e.fname || ' ' || e.lname AS full_name,
    e.gender,
    e.age,
    d.name AS department_name,
    q.position AS job_title
FROM employee e
JOIN job_department d ON e.job_id = d.job_id
LEFT JOIN qualification q ON e.emp_id = q.emp_id;

--to know which schema
SELECT USER FROM DUAL;

--(a)Query the view for female employees over 30
SELECT * FROM vw_employee_summary
WHERE gender = 'F' AND age > 30;

--(b)Attempt to INSERT through the view
INSERT INTO vw_employee_summary (emp_id, full_name, gender, age, department_name, job_title)
VALUES (999, 'Test User', 'M', 28, 'Engineering', 'Tester');
/*
Expected Oracle error:
ORA-01779: cannot modify a column which maps to a non key-preserved table
This occurs because the view is built from a join across multiple tables
(EMPLOYEE, JOB_DEPARTMENT, QUALIFICATION) and computed expressions
(full_name concatenation), so Oracle cannot determine which base table
each inserted value belongs to.
*/
------------------
-- TASK 2: Payroll Dashboard View:
CREATE OR REPLACE VIEW vw_payroll_dashboard AS
SELECT
    p.payroll_id,
    e.fname || ' ' || e.lname AS full_name,
    d.name AS department_name,
    sb.amount AS salary_amount,
    sb.bonus,
    l.reason AS leave_reason,
    p.pay_date,
    p.total_amount
FROM payroll p
JOIN employee e
    ON p.emp_id = e.emp_id
JOIN job_department d
    ON p.job_id = d.job_id
JOIN salary_bonus sb
    ON p.salary_id = sb.salary_id
LEFT JOIN (
    SELECT
        lr.emp_id,
        lr.reason,
        lr.leave_date
    FROM leave_record lr
    WHERE lr.leave_date = (
        SELECT MAX(lr2.leave_date)
        FROM leave_record lr2
        WHERE lr2.emp_id = lr.emp_id
    )
) l
    ON e.emp_id = l.emp_id;
-- Top 5 payroll records by total_amount
SELECT *
FROM (
    SELECT * FROM vw_payroll_dashboard ORDER BY total_amount DESC
)
WHERE ROWNUM <= 5;
------------------
-- TASK 3: Updatable View with CHECK OPTION:
CREATE OR REPLACE VIEW vw_active_employees AS
SELECT emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id, salary_id
FROM employee
WHERE age >= 18
WITH CHECK OPTION;

--(a)Attempt to insert an employee with age = 15 (should fail)
INSERT INTO vw_active_employees (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Young', 'Person', 'M', 15, 'young.person@ems.com', 'pass123', 1);
/*
Expected Oracle error:
ORA-01402: view WITH CHECK OPTION where-clause violation
This happens because age = 15 violates the view's WHERE age >= 18
condition, and WITH CHECK OPTION blocks any DML that would produce a
row the view itself could not subsequently see.
*/

--(b)Successfully insert an employee with age = 25
INSERT INTO vw_active_employees (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Adult', 'Person', 'F', 25, 'adult.person@ems.com', 'pass123', 1);

SELECT * FROM employee WHERE fname = 'Adult';

--(c)Update an employee's contact address through...
-- NOTE: contact_add lives in EMP_ADDRESS (separate table after 1NF fix),
-- not in EMPLOYEE, so it is not part of this view. Demonstrating the
-- equivalent update directly against EMP_ADDRESS instead:
UPDATE emp_address
SET contact_add = '123 New Street, Capital City'
WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Adult');

SELECT * FROM emp_address
WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Adult');

COMMIT;
---------------------------
-- TASK 4: Aggregation View
CREATE OR REPLACE VIEW vw_dept_stats AS
SELECT
    d.name AS department_name,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    AVG(sb.amount) AS avg_salary,
    SUM(sb.bonus) AS total_bonus,
    SUM(p.total_amount) AS total_payroll_amount
FROM job_department d
LEFT JOIN employee e ON d.job_id = e.job_id
LEFT JOIN salary_bonus sb ON e.emp_id = sb.emp_id
LEFT JOIN payroll p ON d.job_id = p.job_id
GROUP BY d.name;

--(a)Departments where average salary > 3000
SELECT * FROM vw_dept_stats WHERE avg_salary > 3000;

--(b)Attempt to DROP the base table while the view exists
DROP TABLE job_department;
/*
Expected Oracle error:
ORA-02449: unique/primary keys in table referenced by foreign keys
(if FK constraints from EMPLOYEE/PAYROLL reference it), OR if those did
not block it, the DROP would still succeed at the table level since
Oracle views do NOT prevent DROP TABLE by default - but any SELECT
against the view afterward would fail with:
ORA-04068 / ORA-08103: object no longer exists,
because the view's underlying table is gone.
In our schema specifically, EMPLOYEE.job_id and PAYROLL.job_id hold FK
constraints to JOB_DEPARTMENT, so the DROP TABLE fails with ORA-02449
(or ORA-02266) before the view is even affected.
*/

--(c)Modify the view to also include max and min salary
CREATE OR REPLACE VIEW vw_dept_stats AS
SELECT
    d.name AS department_name,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    AVG(sb.amount) AS avg_salary,
    SUM(sb.bonus) AS total_bonus,
    SUM(p.total_amount) AS total_payroll_amount,
    MAX(sb.amount) AS max_salary,
    MIN(sb.amount) AS min_salary
FROM job_department d
LEFT JOIN employee e ON d.job_id = e.job_id
LEFT JOIN salary_bonus sb ON e.emp_id = sb.emp_id
LEFT JOIN payroll p ON d.job_id = p.job_id
GROUP BY d.name;
---------------------
-- TASK 5: Materialized View with Refresh:
CREATE MATERIALIZED VIEW mvw_monthly_payroll
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    EXTRACT(YEAR FROM p.pay_date) AS pay_year,
    EXTRACT(MONTH FROM p.pay_date) AS pay_month,
    d.name AS department_name,
    SUM(p.total_amount) AS total_monthly_payroll,
    COUNT(DISTINCT p.emp_id) AS employee_count
FROM payroll p
JOIN job_department d ON p.job_id = d.job_id
GROUP BY EXTRACT(YEAR FROM p.pay_date), EXTRACT(MONTH FROM p.pay_date), d.name;

--(a)Compare Q1 (Jan-Mar) vs Q2 (Apr-Jun) totals per department
SELECT
    department_name,
    SUM(CASE WHEN pay_month IN (1,2,3) THEN total_monthly_payroll ELSE 0 END) AS q1_total,
    SUM(CASE WHEN pay_month IN (4,5,6) THEN total_monthly_payroll ELSE 0 END) AS q2_total
FROM mvw_monthly_payroll
GROUP BY department_name;

-- (b) Insert new payroll records, then manually refresh
INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, DATE '2025-06-30', 'June payroll', 5300, 2, 2, 2);
COMMIT;

BEGIN
    DBMS_MVIEW.REFRESH('MVW_MONTHLY_PAYROLL', 'C');
END;
/
---------------
--(c)Verify the materialized view reflects the new data
SELECT * FROM mvw_monthly_payroll
WHERE pay_month = 6;