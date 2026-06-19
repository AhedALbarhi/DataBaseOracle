--Section 6:
-- Employee Management System - Subqueries:
-- TASK 1: Single-Row Subquery
--(a)Employees whose salary is greater than the company average
SELECT e.emp_id, e.fname, e.lname, sb.amount
FROM employee e
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
WHERE sb.amount > (SELECT AVG(amount) FROM salary_bonus);

--(b)Department with the highest total payroll amount
SELECT d.name, payroll_totals.total_payroll
FROM job_department d
JOIN (
    SELECT job_id, SUM(total_amount) AS total_payroll
    FROM payroll
    GROUP BY job_id
) payroll_totals ON d.job_id = payroll_totals.job_id
WHERE payroll_totals.total_payroll = (
    SELECT MAX(dept_total)
    FROM (
        SELECT SUM(total_amount) AS dept_total
        FROM payroll
        GROUP BY job_id
    )
);
--------------------------
-- TASK 2: Multi-Row Subquery with IN / ANY / ALL
--(a)Employees in departments with at least one salary record with bonus > 500 (IN)
SELECT e.emp_id, e.fname, e.lname, e.job_id
FROM employee e
WHERE e.job_id IN (
    SELECT emp.job_id
    FROM employee emp
    JOIN salary_bonus sb ON emp.emp_id = sb.emp_id
    WHERE sb.bonus > 500
);

--(b)Employees with salary greater than ALL salaries in the Maintenance department
SELECT e.emp_id, e.fname, e.lname, sb.amount
FROM employee e
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
WHERE sb.amount > ALL (
    SELECT sb2.amount
    FROM salary_bonus sb2
    JOIN employee e2 ON sb2.emp_id = e2.emp_id
    JOIN job_department d2 ON e2.job_id = d2.job_id
    WHERE d2.name = 'Maintenance'
);

--(c)Employees with salary greater than ANY salary in the HR department
SELECT e.emp_id, e.fname, e.lname, sb.amount
FROM employee e
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
WHERE sb.amount > ANY (
    SELECT sb2.amount
    FROM salary_bonus sb2
    JOIN employee e2 ON sb2.emp_id = e2.emp_id
    JOIN job_department d2 ON e2.job_id = d2.job_id
    WHERE d2.name = 'Human Resources'
);

-- TASK 3: Correlated Subquery
--(a)Employee name + number of payroll records, without a JOIN
SELECT
    e.emp_id,
    e.fname || ' ' || e.lname AS full_name,
    (SELECT COUNT(*) FROM payroll p WHERE p.emp_id = e.emp_id) AS payroll_record_count
FROM employee e;

--(b)Employees who have taken more leave days than the average leave count
SELECT e.emp_id, e.fname, e.lname
FROM employee e
WHERE (SELECT COUNT(*) FROM leave_record l WHERE l.emp_id = e.emp_id) >
      (SELECT AVG(leave_count)
       FROM (
           SELECT COUNT(*) AS leave_count
           FROM leave_record
           GROUP BY emp_id
       ));
-------------------------------
-- TASK 4: EXISTS and NOT EXISTS
--(a)Departments with at least one payroll record where total_amount > 10,000
SELECT d.job_id, d.name
FROM job_department d
WHERE EXISTS (
    SELECT 1 FROM payroll p WHERE p.job_id = d.job_id AND p.total_amount > 10000
);

--(b)Employees with NOT EXISTS any qualification record
SELECT e.emp_id, e.fname, e.lname
FROM employee e
WHERE NOT EXISTS (
    SELECT 1 FROM qualification q WHERE q.emp_id = e.emp_id
);

--(c)Compare EXISTS vs IN performance plans for query (b)
-- Version using NOT EXISTS (above)
EXPLAIN PLAN FOR
SELECT e.emp_id, e.fname, e.lname
FROM employee e
WHERE NOT EXISTS (
    SELECT 1 FROM qualification q WHERE q.emp_id = e.emp_id
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Version using NOT IN
EXPLAIN PLAN FOR
SELECT e.emp_id, e.fname, e.lname
FROM employee e
WHERE e.emp_id NOT IN (
    SELECT q.emp_id FROM qualification q WHERE q.emp_id IS NOT NULL
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*
Sample EXPLAIN PLAN output (paste actual output from your Oracle instance
here after running both blocks above):

NOT EXISTS plan typically shows a HASH JOIN ANTI or FILTER operation -
Oracle can stop scanning the inner table as soon as one match is found per
outer row, which tends to perform well even if qualification.emp_id is
NULL-able.

NOT IN plan can show a similar HASH JOIN ANTI NA (null-aware anti-join) in
modern Oracle versions, but historically NOT IN had to fully materialize
the subquery first and is more sensitive to NULL values in the subquery's
column - if even one row has a NULL emp_id, NOT IN can return zero rows
unexpectedly, whereas NOT EXISTS is unaffected by NULLs in the subquery.

Conclusion: NOT EXISTS is generally the safer and equally fast (or faster)
choice for "no matching child row" queries.
*/
------------------------------------------------------
-- TASK 5: Inline Views & WITH Clause (CTE)
--(a)Top 3 highest-paid employees per department (inline view)
SELECT *
FROM (
    SELECT
        e.emp_id,
        e.fname || ' ' || e.lname AS full_name,
        d.name AS department_name,
        sb.amount,
        RANK() OVER (PARTITION BY d.job_id ORDER BY sb.amount DESC) AS salary_rank
    FROM employee e
    JOIN job_department d ON e.job_id = d.job_id
    JOIN salary_bonus sb ON e.emp_id = sb.emp_id
)
WHERE salary_rank <= 3;

--(b)Same query rewritten using a WITH clause (CTE)
WITH ranked_salaries AS (
    SELECT
        e.emp_id,
        e.fname || ' ' || e.lname AS full_name,
        d.name AS department_name,
        sb.amount,
        RANK() OVER (PARTITION BY d.job_id ORDER BY sb.amount DESC) AS salary_rank
    FROM employee e
    JOIN job_department d ON e.job_id = d.job_id
    JOIN salary_bonus sb ON e.emp_id = sb.emp_id
)
SELECT *
FROM ranked_salaries
WHERE salary_rank <= 3;

--(c)Chained CTEs: department totals -> ranked departments -> top 2
WITH dept_totals AS (
    SELECT
        d.job_id,
        d.name AS department_name,
        SUM(p.total_amount) AS total_payroll
    FROM job_department d
    JOIN payroll p ON d.job_id = p.job_id
    GROUP BY d.job_id, d.name
),
ranked_departments AS (
    SELECT
        department_name,
        total_payroll,
        RANK() OVER (ORDER BY total_payroll DESC) AS dept_rank
    FROM dept_totals
)
SELECT department_name, total_payroll
FROM ranked_departments
WHERE dept_rank <= 2;