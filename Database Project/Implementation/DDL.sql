--Section 1:DDL
--job_department table:
CREATE TABLE job_department (
    job_id NUMBER(9) PRIMARY KEY,
    job_dept VARCHAR2(50) NOT NULL,
    name VARCHAR2(100) NOT NULL,
    description  VARCHAR2(225),
    salary_range  VARCHAR2(50)
);

--show
SELECT * FROM job_department;
--sequence automatically generates numbers.
CREATE SEQUENCE job_department_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
------------------------------------------------------
--EMPLOYEE table:
CREATE TABLE EMPLOYEE (
    emp_id NUMBER(9) PRIMARY KEY,
    fname VARCHAR2(50) NOT NULL,
    lname VARCHAR2(50) NOT NULL,
    Gender CHAR(1) NOT NULL,
    age   NUMBER(3),
    emp_email VARCHAR2(100) NOT NULL,
    emp_pass VARCHAR2(100) NOT NULL,
     job_id        NUMBER          NOT NULL,
    CONSTRAINT fk_employee_job FOREIGN KEY (job_id)
        REFERENCES job_department (job_id),
    CONSTRAINT chk_employee_gender CHECK (gender IN ('M', 'F')),
    CONSTRAINT uq_emp_email UNIQUE (emp_email)
);
--show
SELECT * FROM EMPLOYEE;
--sequence automatically generates numbers.
CREATE SEQUENCE employee_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
----------
-- Add the column "salary_id" to employee
ALTER TABLE employee
ADD salary_id NUMBER(9);
-- After SALARY_BONUS table created, add the FK on EMPLOYEE
ALTER TABLE employee
    ADD CONSTRAINT fk_employee_salary FOREIGN KEY (salary_id)
        REFERENCES salary_bonus (salary_id);
--Verify the column exists
DESC employee;
-------------------------------------------------------
--SALARY_BONUS table:
CREATE TABLE salary_bonus (
    salary_id NUMBER(9) PRIMARY KEY,
    amount NUMBER(10,2) NOT NULL,
    bonus NUMBER(10,2) NOT NULL,
    annual NUMBER(12,2),
    emp_id  NUMBER(9) NOT NULL,
    CONSTRAINT fk_salary_employee FOREIGN KEY (emp_id)
        REFERENCES employee (emp_id),
    CONSTRAINT chk_salary_amount CHECK (amount > 0)
);
--show
SELECT * FROM salary_bonus;
--sequence automatically generates numbers.
CREATE SEQUENCE salary_bonus_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
-------------------------------------------------------
--EMP_ADDRESS table:
CREATE TABLE emp_address (
    address_id    NUMBER          NOT NULL,
    emp_id        NUMBER          NOT NULL,
    contact_add   VARCHAR2(150)   NOT NULL,
    CONSTRAINT pk_emp_address PRIMARY KEY (address_id, emp_id),
    CONSTRAINT fk_address_employee FOREIGN KEY (emp_id)
        REFERENCES employee (emp_id)
);
--show
SELECT * FROM emp_address;
--sequence automatically generates numbers.
CREATE SEQUENCE emp_address_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
-------------------------------------------------------
--qualification table:
CREATE TABLE qualification (
    qual_id  NUMBER  NOT NULL,
    emp_id   NUMBER  NOT NULL,
    position  VARCHAR2(100) NOT NULL,
    date_in  DATE  DEFAULT SYSDATE,
    CONSTRAINT pk_qualification PRIMARY KEY (qual_id),
    CONSTRAINT fk_qualification_employee FOREIGN KEY (emp_id)
        REFERENCES employee (emp_id)
);
--show
SELECT * FROM qualification;
--sequence automatically generates numbers.
CREATE SEQUENCE qualification_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--drop
DROP TABLE qualification;
DROP SEQUENCE  qualification_seq;
-------------------------------------------------------
--requrements_q table:
CREATE TABLE requirements_q (
    qual_id  NUMBER NOT NULL,
    requirement   VARCHAR2(150)   NOT NULL,
    CONSTRAINT pk_requirements_q PRIMARY KEY (qual_id, requirement),
    CONSTRAINT fk_requirement_qualification FOREIGN KEY (qual_id)
        REFERENCES qualification (qual_id)
);
--show
SELECT * FROM requirements_q;
------------------------------------------------------
--leave table:
CREATE TABLE leave_record (
    leave_id  NUMBER  NOT NULL,
    emp_id   NUMBER  NOT NULL,
    leave_date  DATE  NOT NULL,
    reason  VARCHAR2(255),
   CONSTRAINT pk_leave_record PRIMARY KEY (leave_id, emp_id),
    CONSTRAINT fk_leave_employee FOREIGN KEY (emp_id)
        REFERENCES employee (emp_id)
);
--show
SELECT * FROM leave_record;
--sequence automatically generates numbers.
CREATE SEQUENCE leave_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
--drop
DROP TABLE leave_record;
DROP SEQUENCE  leave_seq;
------------------------------------------------------
--payroll table:
CREATE TABLE payroll (
    payroll_id    NUMBER,
    pay_date      DATE NOT NULL,
    report        VARCHAR2(250),
    total_amount  NUMBER(10, 2) NOT NULL,
    job_id        NUMBER,
    salary_id     NUMBER,
    emp_id        NUMBER,
    CONSTRAINT pk_payroll PRIMARY KEY (payroll_id),
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_id)
        REFERENCES job_department(job_id),
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_id)
        REFERENCES salary_bonus(salary_id),
    CONSTRAINT fk_payroll_employee FOREIGN KEY (emp_id)
        REFERENCES employee(emp_id)
);

CREATE SEQUENCE payroll_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
    
--show
SELECT * FROM payroll;