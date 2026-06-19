-- Section 9:
-- Employee Management System - Triggers
-- TASK 1: BEFORE INSERT - Auto-Assign emp_ID
CREATE OR REPLACE TRIGGER trg_emp_id
BEFORE INSERT ON employee
FOR EACH ROW 
WHEN(NEW.emp_id IS NULL)
BEGIN
  :NEW.emp_id := employee_seq.NEXTVAL;
END;
/

-- Test: insert an employee without specifying emp_ID
INSERT INTO employee (fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES ('Auto', 'Assigned', 'F', 26, 'auto.assigned@ems.com', 'pass123', 2);

SELECT emp_id, fname, lname FROM employee WHERE fname = 'Auto';
-- Expected: emp_id is populated automatically from EMPLOYEE_SEQ
-------------------------
-- TASK 2: AFTER INSERT - Welcome Log
CREATE TABLE employee_log (
    log_id        NUMBER          NOT NULL,
    emp_id        NUMBER,
    action        VARCHAR2(50)    NOT NULL,
    log_timestamp DATE            DEFAULT SYSDATE,
    CONSTRAINT pk_employee_log PRIMARY KEY (log_id)
);

CREATE SEQUENCE employee_log_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_emp_welcome_log
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
    VALUES (employee_log_seq.NEXTVAL, :NEW.emp_id, 'NEW HIRE', SYSDATE);
END;
/
-- Test: insert 2 employees and query EMPLOYEE_LOG
INSERT INTO employee (fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES ('Hire', 'One', 'M', 30, 'hire.one@ems.com', 'pass123', 3);

INSERT INTO employee (fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES ('Hire', 'Two', 'F', 31, 'hire.two@ems.com', 'pass123', 3);

SELECT * FROM employee_log WHERE action = 'NEW HIRE';
---------------
-- TASK 2: AFTER INSERT - Welcome Log "no  need to create agine since its exit before"
CREATE TABLE employee_log (
    log_id        NUMBER          NOT NULL,
    emp_id        NUMBER,
    action        VARCHAR2(50)    NOT NULL,
    log_timestamp DATE            DEFAULT SYSDATE,
    CONSTRAINT pk_employee_log PRIMARY KEY (log_id)
);

SELECT * FROM employee_log;
DESC employee_log;

CREATE OR REPLACE TRIGGER trg_emp_welcome_log
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
    VALUES (employee_log_seq.NEXTVAL, :NEW.emp_id, 'NEW HIRE', SYSDATE);
END;
/

-- Test: insert 2 employees and query EMPLOYEE_LOG
INSERT INTO employee (fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES ('Hire', 'One', 'M', 30, 'hire.oraclePer@ems.com', 'pass123', 3);

INSERT INTO employee (fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES ('Hire', 'Two', 'F', 31, 'hire.oracleOne@ems.com', 'pass123', 3);

SELECT * FROM employee_log WHERE action = 'NEW HIRE';
------------------
-- TASK 3: BEFORE UPDATE - Prevent Salary Decrease
CREATE OR REPLACE TRIGGER trg_prevent_salary_cut
BEFORE UPDATE ON salary_bonus
FOR EACH ROW
BEGIN
    IF :NEW.amount < :OLD.amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary decrease is not allowed.');
    END IF;
END;
/

-- Test (a): try to lower a salary - should fail and roll back
UPDATE salary_bonus SET amount = amount - 500 WHERE salary_id = 1;
-- Expected: ORA-20001: Salary decrease is not allowed.

-- Confirm the value is unchanged after the failed attempt
SELECT salary_id, amount FROM salary_bonus WHERE salary_id = 1;

-- Test (b): raise a salary - should succeed
UPDATE salary_bonus SET amount = amount + 500 WHERE salary_id = 1;
COMMIT;

SELECT salary_id, amount FROM salary_bonus WHERE salary_id = 1;
-----------------
-- TASK 4: AFTER DELETE - Archive Deleted Employees
CREATE TABLE employee_archive (
    emp_id        NUMBER,
    fname         VARCHAR2(50),
    lname         VARCHAR2(50),
    gender        CHAR(1),
    age           NUMBER(3),
    emp_email     VARCHAR2(100),
    emp_pass      VARCHAR2(100),
    job_id        NUMBER,
    salary_id     NUMBER,
    manager_id    NUMBER,
    archived_at   DATE            DEFAULT SYSDATE,
    archived_by   VARCHAR2(50)
);

CREATE OR REPLACE TRIGGER trg_archive_employee
AFTER DELETE ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_archive (
        emp_id, fname, lname, gender, age, emp_email, emp_pass,
        job_id, salary_id, manager_id, archived_at, archived_by
    )
    VALUES (
        :OLD.emp_id, :OLD.fname, :OLD.lname, :OLD.gender, :OLD.age,
        :OLD.emp_email, :OLD.emp_pass, :OLD.job_id, :OLD.salary_id,
        :OLD.manager_id, SYSDATE, USER
    );
END;
/

-- Test: delete one employee and verify the archive
-- (using the 'Auto Assigned' test employee from Task 1, after clearing
--  any dependent rows first to satisfy FK constraints)
DELETE FROM payroll WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Auto' AND lname = 'Assigned');
DELETE FROM leave_record WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Auto' AND lname = 'Assigned');
DELETE FROM qualification WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Auto' AND lname = 'Assigned');
DELETE FROM salary_bonus WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Auto' AND lname = 'Assigned');
DELETE FROM employee WHERE fname = 'Auto' AND lname = 'Assigned';
COMMIT;

SELECT * FROM employee_archive;
-----------------
-- TASK 5: Compound Trigger - Payroll Validation & Audit
CREATE OR REPLACE TRIGGER trg_payroll_compound
FOR INSERT ON payroll
COMPOUND TRIGGER

    v_row_count NUMBER := 0;

    BEFORE STATEMENT IS
    BEGIN
        INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
        VALUES (employee_log_seq.NEXTVAL, NULL, 'PAYROLL_BULK_START', SYSDATE);
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
        v_existing_count NUMBER;
    BEGIN
        IF :NEW.total_amount <= 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Payroll total_amount must be greater than 0.');
        END IF;

        SELECT COUNT(*) INTO v_existing_count
        FROM payroll
        WHERE emp_id = :NEW.emp_id
          AND TO_CHAR(pay_date, 'YYYY-MM') = TO_CHAR(:NEW.pay_date, 'YYYY-MM');

        IF v_existing_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Employee already has a payroll entry for this month.');
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        INSERT INTO salary_audit (audit_id, emp_id, old_amount, new_amount, changed_by, changed_at)
        VALUES (salary_audit_seq.NEXTVAL, :NEW.emp_id, 0, :NEW.total_amount, USER, SYSDATE);

        v_row_count := v_row_count + 1;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
        VALUES (employee_log_seq.NEXTVAL, NULL, 'PAYROLL_BULK_END: ' || v_row_count || ' rows', SYSDATE);
    END AFTER STATEMENT;

END trg_payroll_compound;
/

-- Test: valid payroll insert
INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, DATE '2025-07-31', 'July payroll', 4700, 5, 4, 5);
COMMIT;

-- Test: invalid payroll insert (negative amount, should fail BEFORE EACH ROW check)
INSERT INTO payroll (payroll_id, pay_date, report, total_amount, emp_id, job_id, salary_id)
VALUES (payroll_seq.NEXTVAL, DATE '2025-07-31', 'Bad July payroll', -100, 5, 4, 5);
-- Expected: ORA-20002: Payroll total_amount must be greater than 0.

SELECT * FROM employee_log WHERE action LIKE 'PAYROLL%';
SELECT * FROM salary_audit;