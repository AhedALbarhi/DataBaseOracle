--Section 5:
-- Employee Management System - Joins:
-- TASK 1: INNER JOIN - Employee Full Profile
SELECT
    e.emp_id,
    e.fname || ' ' || e.lname AS full_name,
    d.name AS department_name,
    q.position AS job_title,
    sb.amount AS salary_amount,
    MAX(l.leave_date) AS latest_leave_date
FROM employee e
INNER JOIN job_department d ON e.job_id = d.job_id
INNER JOIN salary_bonus sb ON e.emp_id = sb.emp_id
INNER JOIN qualification q ON e.emp_id = q.emp_id
INNER JOIN payroll p ON e.emp_id = p.emp_id
LEFT JOIN leave_record l ON e.emp_id = l.emp_id
GROUP BY e.emp_id, e.fname, e.lname, d.name, q.position, sb.amount;
--------------------------
-- TASK 2: LEFT OUTER JOIN - Missing Records
--(a)Employees who have never taken any leave
SELECT e.emp_id, e.fname, e.lname
FROM employee e
LEFT OUTER JOIN leave_record l ON e.emp_id = l.emp_id
WHERE l.leave_id IS NULL;

--(b)Departments with no salary/bonus records associated
SELECT d.job_id, d.name
FROM job_department d
LEFT OUTER JOIN employee e ON d.job_id = e.job_id
LEFT OUTER JOIN salary_bonus sb ON e.emp_id = sb.emp_id
WHERE sb.salary_id IS NULL;
----------------------------
-- TASK 3: Multi-Table JOIN - Payroll Report
SELECT
    p.payroll_id,
    e.fname || ' ' || e.lname AS full_name,
    d.name AS department_name,
    q.position,
    sb.amount AS salary_amount,
    sb.bonus,
    l.reason AS leave_reason,
    p.total_amount
FROM employee e
JOIN payroll p
    ON p.emp_id = e.emp_id
    AND p.pay_date = (
        SELECT MAX(p2.pay_date)
        FROM payroll p2
        WHERE p2.emp_id = e.emp_id
    )
JOIN job_department d ON p.job_id = d.job_id
JOIN salary_bonus sb ON p.salary_id = sb.salary_id
LEFT JOIN qualification q
    ON e.emp_id = q.emp_id
    AND q.date_in = (
        SELECT MAX(q2.date_in)
        FROM qualification q2
        WHERE q2.emp_id = e.emp_id
    )
LEFT JOIN leave_record l
    ON e.emp_id = l.emp_id
    AND l.leave_date = (
        SELECT MAX(l2.leave_date)
        FROM leave_record l2
        WHERE l2.emp_id = e.emp_id
    )
ORDER BY d.name, p.total_amount DESC;
--------------------------------------
-- TASK 4: SELF JOIN - Employee Hierarchy
ALTER TABLE employee ADD (manager_id NUMBER REFERENCES employee(emp_id));

--(a)Assign managers to at least 5 employees
UPDATE employee SET manager_id = 1 WHERE emp_id IN (3, 7);
UPDATE employee SET manager_id = 2 WHERE emp_id IN (8);
UPDATE employee SET manager_id = 4 WHERE emp_id IN (9, 10);
COMMIT;

--(b)SELF JOIN listing each employee alongside their manager's full name
SELECT
    e.emp_id,
    e.fname || ' ' || e.lname AS employee_name,
    m.fname || ' ' || m.lname AS manager_name
FROM employee e
LEFT JOIN employee m ON e.manager_id = m.emp_id;

--(c)Employees who are themselves managers
SELECT DISTINCT m.emp_id, m.fname, m.lname
FROM employee e
JOIN employee m ON e.manager_id = m.emp_id;
---------------------------------------------
-- TASK 5: CROSS JOIN & Set Operations
--(a)CROSS JOIN of employees and departments, excluding the employee's
--current department, limited to 20 rows
SELECT *
FROM (
    SELECT e.emp_id, e.fname, e.lname, d.job_id, d.name AS department_name
    FROM employee e
    CROSS JOIN job_department d
    WHERE e.job_id != d.job_id
)
WHERE ROWNUM <= 20;
---------------------------
--(b)Set operations
--UNION: employees who appear in either PAYROLL or LEAVE (or both)
SELECT emp_id FROM payroll
UNION
SELECT emp_id FROM leave_record;
-- Business meaning: every employee who has any payroll activity or any
-- leave history recorded - i.e. the full set of "active" employees
-- tracked by either process.

-- INTERSECT: employees who appear in BOTH PAYROLL and LEAVE
SELECT emp_id FROM payroll
INTERSECT
SELECT emp_id FROM leave_record;
-- Business meaning: employees who have taken leave AND been paid through
-- payroll - useful for verifying that leave deductions were applied
-- correctly to their payroll calculation.

-- MINUS: employees who appear in PAYROLL but have NO LEAVE record
SELECT emp_id FROM payroll
MINUS
SELECT emp_id FROM leave_record;
-- Business meaning: employees who have been paid but have never taken
-- leave - useful for identifying employees who may be due for a leave
-- balance review or who simply haven't used any leave yet.