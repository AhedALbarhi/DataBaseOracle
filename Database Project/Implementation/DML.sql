----Section 3:
--TASK 1: Populate All Tables with Seed Data
--insert 5 departments:
INSERT INTO job_department (job_id, job_dept, name, description, salary_range)
VALUES (job_department_seq.NEXTVAL, 'ENG', 'Engineering', 'Software and systems engineering', '3000-8000');

INSERT INTO job_department (job_id, job_dept, name, description, salary_range)
VALUES (job_department_seq.NEXTVAL, 'HR', 'Human Resources', 'Recruitment and employee relations', '2500-6000');

INSERT INTO job_department (job_id, job_dept, name, description, salary_range)
VALUES (job_department_seq.NEXTVAL, 'FIN', 'Finance', 'Accounting and financial planning', '3000-7000');

INSERT INTO job_department (job_id, job_dept, name, description, salary_range)
VALUES (job_department_seq.NEXTVAL, 'MNT', 'Maintenance', 'Facilities and equipment upkeep', '2000-4500');

INSERT INTO job_department (job_id, job_dept, name, description, salary_range)
VALUES (job_department_seq.NEXTVAL, 'SAL', 'Sales', 'Client acquisition and account management', '2800-6500');

COMMIT;
--insert 10 employees (job_id values 1-5 assigned round robin):
INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'John', 'Smith', 'M', 34, 'john.smith@ems.com', 'pass123', 1);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Mary', 'Jones', 'F', 29, 'mary.jones@ems.com', 'pass123', 2);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Ali', 'Hassan', 'M', 41, 'ali.hassan@ems.com', 'pass123', 1);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Sara', 'Khan', 'F', 26, 'sara.khan@ems.com', 'pass123', 3);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'David', 'Brown', 'M', 38, 'david.brown@ems.com', 'pass123', 4);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Linda', 'Garcia', 'F', 31, 'linda.garcia@ems.com', 'pass123', 5);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Omar', 'Said', 'M', 45, 'omar.said@ems.com', 'pass123', 1);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Emma', 'Wilson', 'F', 27, 'emma.wilson@ems.com', 'pass123', 2);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Noah', 'Davis', 'M', 33, 'noah.davis@ems.com', 'pass123', 3);

INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Layla', 'Ahmed', 'F', 24, 'layla.ahmed@ems.com', 'pass123', 4);

COMMIT;
---- 5 salary/bonus records (linked 1:1 to first 5 employees):
INSERT INTO salary_bonus (salary_id, amount, bonus, annual, emp_id)
VALUES (salary_bonus_seq.NEXTVAL, 5000, 500, 60000, 1);

INSERT INTO salary_bonus (salary_id, amount, bonus, annual, emp_id)
VALUES (salary_bonus_seq.NEXTVAL, 4200, 300, 50400, 2);

INSERT INTO salary_bonus (salary_id, amount, bonus, annual, emp_id)
VALUES (salary_bonus_seq.NEXTVAL, 5500, 700, 66000, 3);

INSERT INTO salary_bonus (salary_id, amount, bonus, annual, emp_id)
VALUES (salary_bonus_seq.NEXTVAL, 4800, 400, 57600, 4);

INSERT INTO salary_bonus (salary_id, amount, bonus, annual, emp_id)
VALUES (salary_bonus_seq.NEXTVAL, 3200, 200, 38400, 5);

COMMIT;
-- Link employees back to their salary record (1:1 relationship):
UPDATE employee SET salary_id = 1 WHERE emp_id = 1;
UPDATE employee SET salary_id = 2 WHERE emp_id = 2;
UPDATE employee SET salary_id = 3 WHERE emp_id = 3;
UPDATE employee SET salary_id = 4 WHERE emp_id = 4;
UPDATE employee SET salary_id = 5 WHERE emp_id = 5;
COMMIT;
-- 5 leave records:
INSERT INTO leave_record (leave_id, emp_id, leave_date, reason)
VALUES (leave_seq.NEXTVAL, 1, DATE '2025-03-10', 'Sick leave - flu');

INSERT INTO leave_record (leave_id, emp_id, leave_date, reason)
VALUES (leave_seq.NEXTVAL, 2, DATE '2025-04-02', 'Annual vacation');

INSERT INTO leave_record (leave_id, emp_id, leave_date, reason)
VALUES (leave_seq.NEXTVAL, 3, DATE '2025-05-15', 'Sick leave - migraine');

INSERT INTO leave_record (leave_id, emp_id, leave_date, reason)
VALUES (leave_seq.NEXTVAL, 1, DATE '2025-06-01', 'Family emergency');

INSERT INTO leave_record (leave_id, emp_id, leave_date, reason)
VALUES (leave_seq.NEXTVAL, 4, DATE '2025-02-20', 'Personal leave');

COMMIT;
-- 5 qualification records:
INSERT INTO qualification (qual_id, emp_id, position, date_in)
VALUES (qualification_seq.NEXTVAL, 1, 'Senior Developer', DATE '2020-01-15');

INSERT INTO qualification (qual_id, emp_id, position, date_in)
VALUES (qualification_seq.NEXTVAL, 2, 'HR Officer', DATE '2021-03-10');

INSERT INTO qualification (qual_id, emp_id, position, date_in)
VALUES (qualification_seq.NEXTVAL, 3, 'Team Lead', DATE '2019-07-22');

INSERT INTO qualification (qual_id, emp_id, position, date_in)
VALUES (qualification_seq.NEXTVAL, 4, 'Accountant', DATE '2022-02-01');

INSERT INTO qualification (qual_id, emp_id, position, date_in)
VALUES (qualification_seq.NEXTVAL, 6, 'Sales Executive', DATE '2023-01-10');

COMMIT;
-- 8 payroll records (leave_id/leave_emp_id only set where a matching leave exists)
INSERT INTO payroll (payroll_id, pay_date, report, total_amount, job_id, salary_id, emp_id)
VALUES (payroll_seq.NEXTVAL, TO_DATE('2026-05-25', 'YYYY-MM-DD'), 'May Payroll - Regular', 1350.00, 3, 4, 4);

INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, TO_DATE('2025-06-28', 'YYYY-MM-DD'), 'February payroll', 4500, 2, 2, 2);

INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, TO_DATE ('2025-03-31', 'YYYY-MM-DD'), 'March payroll', 6200, 3, 1, 3);

INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, TO_DATE ('2025-04-30','YYYY-MM-DD'), 'April payroll', 5200, 4, 3, 4);

INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, TO_DATE ('2025-05-31','YYYY-MM-DD'), 'May payroll', 3400, 5, 4, 5);

INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, TO_DATE ('2025-01-31','YYYY-MM-DD'), 'January payroll', 5400, 1, 1, 1);

INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, TO_DATE ('2025-02-28','YYYY-MM-DD'), 'February payroll', 6100, 3, 1, 3);

INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, TO_DATE ('2025-03-31','YYYY-MM-DD'), 'March payroll', 4900, 4, 3, 4);

COMMIT;
--------------------------------------------------------------------------
-- TASK 2: Conditional SELECT Queries
-- (a)Employees aged 25-40, ordered by last name ascending:
SELECT emp_id, fname, lname, age
FROM employee
WHERE age BETWEEN 25 AND 40
ORDER BY lname ASC;

-- (b)Payroll records where total_amount exceeds 5000, with employee name and department
SELECT p.payroll_id, e.fname || ' ' || e.lname AS employee_name,
       d.name AS department_name, p.total_amount
FROM payroll p
JOIN employee e ON p.emp_id = e.emp_id
JOIN job_department d ON p.job_id = d.job_id
WHERE p.total_amount > 5000;

-- (c)Employees who took leave with reason containing 'sick' (case-insensitive)
SELECT DISTINCT e.emp_id, e.fname, e.lname, l.reason
FROM employee e
JOIN leave_record l ON e.emp_id = l.emp_id
WHERE LOWER(l.reason) LIKE '%sick%';

-- (d)Departments with no employees assigned (using NOT EXISTS)
SELECT d.job_id, d.name
FROM job_department d
WHERE NOT EXISTS (
    SELECT 1 FROM employee e WHERE e.job_id = d.job_id
);
---------------------------------------------------------------
-- TASK 3: Bulk UPDATE Scenarios
--(a)10% salary increase for all employees in Engineering
UPDATE salary_bonus sb
SET amount = amount * 1.10
WHERE sb.emp_id IN (
    SELECT e.emp_id
    FROM employee e
    JOIN job_department d ON e.job_id = d.job_id
    WHERE d.name = 'Engineering'
);

--(b)Lowercase all emp_email values
UPDATE employee
SET emp_email = LOWER(emp_email);

--(c)Set salary_range to 'REVISED' where avg total payroll exceeds 8000
UPDATE job_department d
SET d.salary_range = 'REVISED'
WHERE d.job_id IN (
    SELECT p.job_id
    FROM payroll p
    GROUP BY p.job_id
    HAVING AVG(p.total_amount) > 8000
);
COMMIT;
---------------------------------------------------------------
-- TASK 4:Controlled DELETE with Safety Checks
--(a)Delete LEAVE records older than 2 years from today
DELETE FROM leave_record
WHERE leave_date < ADD_MONTHS(SYSDATE, -24);

SELECT COUNT(*) AS leave_count_after_delete FROM leave_record;

--(b)Preview (run BEFORE the delete) - qualification rows whose employee no longer exists
SELECT q.qual_id, q.emp_id, q.position
FROM qualification q
WHERE NOT EXISTS (
    SELECT 1 FROM employee e WHERE e.emp_id = q.emp_id
);

--Now perform the delete
DELETE FROM qualification q
WHERE NOT EXISTS (
    SELECT 1 FROM employee e WHERE e.emp_id = q.emp_id
);

SELECT COUNT(*) AS qualification_count_after_delete FROM qualification;

COMMIT;
------------------------------------------------------
-- TASK 5: Transaction Management & SAVEPOINT
-- Step 1: Insert a new employee and their first payroll record
INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (employee_seq.NEXTVAL, 'Karim', 'Nasser', 'M', 30, 'karim.nasser@ems.com', 'pass123', 1);

-- Capture the emp_id just inserted for reuse in this block
-- (employee_seq.CURRVAL gives the last value used in this session)
SELECT employee_seq.CURRVAL AS new_emp_id FROM dual;

INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, SYSDATE, 'Initial payroll', 5000, employee_seq.CURRVAL, 1, 1);

--Verify state after step 1
SELECT * FROM employee WHERE emp_id = employee_seq.CURRVAL;
SELECT * FROM payroll WHERE emp_id = employee_seq.CURRVAL;
----------------------------------------------------------------