--Section 4:
--Employee Management System - Aggregation Functions:
-- TASK 1: Basic Aggregation:
--(a)Total number of employees in each department
SELECT d.name AS department_name, COUNT(e.emp_id) AS total_employees
FROM job_department d
LEFT JOIN employee e ON d.job_id = e.job_id
GROUP BY d.name;

--(b)Min, max, average salary (amount) across all salary records
SELECT MIN(amount) AS min_salary, MAX(amount) AS max_salary, AVG(amount) AS avg_salary
FROM salary_bonus;

--(c)Total bonus paid out across the entire company
SELECT SUM(bonus) AS total_bonus_paid
FROM salary_bonus;
--------------------------------
-- TASK 2: GROUP BY with HAVING:
--(a)Departments where average employee age exceeds 30
SELECT d.name AS department_name, AVG(e.age) AS avg_age
FROM job_department d
JOIN employee e ON d.job_id = e.job_id
GROUP BY d.name
HAVING AVG(e.age) > 30;

--(b)Job titles (qualification position) shared by more than 2 employees
SELECT q.position, COUNT(q.emp_id) AS employee_count
FROM qualification q
GROUP BY q.position
HAVING COUNT(q.emp_id) > 2;

--(c)Months (from PAYROLL.pay_date) where total payroll exceeds 20,000
SELECT TO_CHAR(p.pay_date, 'YYYY-MM') AS pay_month, SUM(p.total_amount) AS month_total
FROM payroll p
GROUP BY TO_CHAR(p.pay_date, 'YYYY-MM')
HAVING SUM(p.total_amount) > 20000;
---------------------------------
--TASK 3: Aggregation with Multiple Functions:
--Department summary report
SELECT
    d.name                              AS department_name,
    COUNT(DISTINCT e.emp_id)            AS total_employees,
    SUM(p.total_amount)                 AS total_payroll_paid,
    AVG(sb.amount)                      AS avg_salary,
    MAX(sb.amount)                      AS highest_salary,
    MIN(sb.amount)                      AS lowest_salary
FROM job_department d
LEFT JOIN employee e   ON d.job_id = e.job_id
LEFT JOIN salary_bonus sb ON e.emp_id = sb.emp_id
LEFT JOIN payroll p    ON d.job_id = p.job_id
GROUP BY d.name
ORDER BY total_payroll_paid DESC;

--TASK 4: Filtered Aggregation - HAVING with Multiple Conditions:
--(a)Departments where total payroll > 15,000 AND average salary > 3,000
SELECT
    d.name AS department_name,
    SUM(p.total_amount) AS total_payroll,
    AVG(sb.amount) AS avg_salary
FROM job_department d
JOIN employee e ON d.job_id = e.job_id
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
JOIN payroll p ON d.job_id = p.job_id
GROUP BY d.name
HAVING SUM(p.total_amount) > 15000 AND AVG(sb.amount) > 3000;

--(b)Qualification positions held by more than 2 employees AND avg age > 28
SELECT
    q.position,
    COUNT(q.emp_id) AS employee_count,
    AVG(e.age) AS avg_age
FROM qualification q
JOIN employee e ON q.emp_id = e.emp_id
GROUP BY q.position
HAVING COUNT(q.emp_id) > 2 AND AVG(e.age) > 28;

--(c)Employees with more than 1 leave record - full name, department, leave count
SELECT
    e.fname || ' ' || e.lname AS full_name,
    d.name AS department_name,
    COUNT(l.leave_id) AS leave_count
FROM employee e
JOIN job_department d ON e.job_id = d.job_id
JOIN leave_record l ON e.emp_id = l.emp_id
GROUP BY e.fname, e.lname, d.name
HAVING COUNT(l.leave_id) > 1;
----------------------------------
-- TASK 5: Aggregation Across the Full Schema:
--(a)Per department: employees, total bonus, MAX-MIN salary spread
--(only departments with at least 2 employees)
SELECT
    d.name AS department_name,
    COUNT(DISTINCT e.emp_id) AS total_employees,
    SUM(sb.bonus) AS total_bonus_paid,
    MAX(sb.amount) - MIN(sb.amount) AS salary_spread
FROM job_department d
JOIN employee e ON d.job_id = e.job_id
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
GROUP BY d.name
HAVING COUNT(DISTINCT e.emp_id) >= 2;

--(b)Employee with the highest total payroll amount across all their records
--(GROUP BY + ORDER BY, no window functions)
SELECT *
FROM (
    SELECT
        e.emp_id,
        e.fname || ' ' || e.lname AS full_name,
        d.name AS department_name,
        SUM(p.total_amount) AS total_payroll
    FROM employee e
    JOIN job_department d ON e.job_id = d.job_id
    JOIN payroll p ON e.emp_id = p.emp_id
    GROUP BY e.emp_id, e.fname, e.lname, d.name
    ORDER BY total_payroll DESC
)
WHERE ROWNUM = 1;

--(c)Leave summary per department: total leave records, avg leave per employee,
--ranked with the highest-leave department first
SELECT
    d.name AS department_name,
    COUNT(l.leave_id) AS total_leave_records,
    COUNT(l.leave_id) / COUNT(DISTINCT e.emp_id) AS avg_leave_per_employee
FROM job_department d
JOIN employee e ON d.job_id = e.job_id
LEFT JOIN leave_record l ON e.emp_id = l.emp_id
GROUP BY d.name
ORDER BY total_leave_records DESC;