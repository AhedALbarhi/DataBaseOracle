--Section 8:
-- Employee Management System - Stored Procedures & Functions:
-- TASK 1: Procedure - Add New Employee
CREATE OR REPLACE PROCEDURE sp_add_employee (
    p_fname      IN VARCHAR2,
    p_lname      IN VARCHAR2,
    p_gender     IN CHAR,
    p_age        IN NUMBER,
    p_email      IN VARCHAR2,
    p_pass       IN VARCHAR2,
    p_job_id     IN NUMBER,
    p_salary_id  IN NUMBER DEFAULT NULL
) IS
    v_count NUMBER;
BEGIN
    -- Validate email is not already in use
    SELECT COUNT(*) INTO v_count
    FROM employee
    WHERE LOWER(emp_email) = LOWER(p_email);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Email already in use: ' || p_email);
    END IF;

    INSERT INTO employee (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id, salary_id)
    VALUES (employee_seq.NEXTVAL, p_fname, p_lname, p_gender, p_age, p_email, p_pass, p_job_id, p_salary_id);

    DBMS_OUTPUT.PUT_LINE('Employee added successfully: ' || p_fname || ' ' || p_lname);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_add_employee;
/

-- Test: call twice with same email to confirm the exception fires
BEGIN
    sp_add_employee('Test1', 'User', 'M', 28, 'duplicate.test@ems.com', 'pass123', 1);
END;
/

BEGIN
    sp_add_employee('Test2', 'User', 'F', 29, 'duplicate.test@ems.com', 'pass123', 2);
END;
/
-- Expected: second call raises ORA-20010 (Email already in use)
---------------------
-- TASK 2: Function - Calculate Net Salary:
CREATE OR REPLACE FUNCTION fn_net_salary (
    p_emp_id IN NUMBER
) RETURN NUMBER IS
    v_net_salary NUMBER;
BEGIN
    SELECT amount + bonus INTO v_net_salary
    FROM salary_bonus
    WHERE emp_id = p_emp_id;

    RETURN v_net_salary;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END fn_net_salary;
/

--Use it in a SELECT, highest to lowest
SELECT
    e.emp_id,
    e.fname || ' ' || e.lname AS full_name,
    fn_net_salary(e.emp_id) AS net_salary
FROM employee e
ORDER BY net_salary DESC NULLS LAST;
---------------------------------
--TASK 3: Procedure - Process Monthly Payroll
CREATE OR REPLACE PROCEDURE sp_process_payroll (
    p_job_id    IN NUMBER,
    p_pay_date  IN DATE
) IS
    CURSOR c_employees IS
        SELECT e.emp_id, sb.salary_id, sb.amount, sb.bonus
        FROM employee e
        JOIN salary_bonus sb ON e.emp_id = sb.emp_id
        WHERE e.job_id = p_job_id;

    v_emp_id        employee.emp_id%TYPE;
    v_salary_id     salary_bonus.salary_id%TYPE;
    v_amount        salary_bonus.amount%TYPE;
    v_bonus         salary_bonus.bonus%TYPE;
    v_leave_count   NUMBER;
    v_daily_rate    NUMBER;
    v_total_amount  NUMBER;
    v_inserted_count NUMBER := 0;
BEGIN
    OPEN c_employees;
    LOOP
        FETCH c_employees INTO v_emp_id, v_salary_id, v_amount, v_bonus;
        EXIT WHEN c_employees%NOTFOUND;

        SELECT COUNT(*) INTO v_leave_count
        FROM leave_record
        WHERE emp_id = v_emp_id;

        v_daily_rate := v_amount / 30;
        v_total_amount := v_amount + v_bonus - (v_leave_count * v_daily_rate);

        INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
        VALUES (payroll_seq.NEXTVAL, p_pay_date, 'Auto-generated monthly payroll', v_total_amount, v_emp_id, p_job_id, v_salary_id);

        v_inserted_count := v_inserted_count + 1;
    END LOOP;
    CLOSE c_employees;

    DBMS_OUTPUT.PUT_LINE('Payroll records inserted: ' || v_inserted_count);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF c_employees%ISOPEN THEN
            CLOSE c_employees;
        END IF;
        ROLLBACK;
        RAISE;
END sp_process_payroll;
/
---------------------------
--Check if there is duplicates or not:
SELECT *
FROM EMPLOYEE
WHERE emp_email = 'duplicate.test@ems.com';

DESC payroll;
---------------------------

-- Test
BEGIN
    sp_process_payroll(1, SYSDATE);
END;
/
-----------------------------
-- TASK 4: Procedure - Raise Salary with Audit
CREATE TABLE salary_audit (
    audit_id     NUMBER          NOT NULL,
    emp_id       NUMBER          NOT NULL,
    old_amount   NUMBER(10,2)    NOT NULL,
    new_amount   NUMBER(10,2)    NOT NULL,
    changed_by   VARCHAR2(50),
    changed_at   DATE            DEFAULT SYSDATE,
    CONSTRAINT pk_salary_audit PRIMARY KEY (audit_id)
);

CREATE SEQUENCE salary_audit_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE PROCEDURE sp_raise_salary (
    p_emp_id     IN NUMBER,
    p_percentage IN NUMBER
) IS
    v_old_amount NUMBER;
    v_new_amount NUMBER;
BEGIN
    SELECT sb.amount INTO v_old_amount
    FROM salary_bonus sb
    WHERE sb.emp_id = p_emp_id;
    
    v_new_amount := v_old_amount * (1 + p_percentage / 100);
    
       UPDATE salary_bonus
    SET amount = v_new_amount
    WHERE emp_id = p_emp_id;
    
    INSERT INTO salary_audit (audit_id, emp_id, old_amount, new_amount, changed_by, changed_at)
    VALUES (salary_audit_seq.NEXTVAL, p_emp_id, v_old_amount, v_new_amount, USER, SYSDATE);

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO salary_audit (audit_id, emp_id, old_amount, new_amount, changed_by, changed_at)
        VALUES (salary_audit_seq.NEXTVAL, p_emp_id, 0, 0, USER, SYSDATE);
        COMMIT;
        RAISE_APPLICATION_ERROR(-20011, 'No salary record found for emp_id: ' || p_emp_id);
END sp_raise_salary;
/

-- Test
BEGIN
    sp_raise_salary(1, 10);
END;
/
SELECT * FROM salary_audit
-------------------------------------
-- TASK 5: Package - Employee Management Package
----------------------------------------------------------------------------------