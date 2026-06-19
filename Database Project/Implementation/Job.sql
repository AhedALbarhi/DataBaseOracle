--Section 10:
-- Employee Management System - Oracle Scheduler Jobs
-- TASK 1: Simple One-Time Scheduler Job
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_GREET_EMPLOYEES',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN
                                DBMS_OUTPUT.PUT_LINE(''Payroll System Initialized'');
                                INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
                                VALUES (employee_log_seq.NEXTVAL, NULL, ''SYSTEM_INIT'', SYSDATE);
                                COMMIT;
                             END;',
        start_date      => SYSTIMESTAMP + INTERVAL '2' MINUTE,
        enabled         => TRUE
    );
END;
/

-- After the job runs (wait ~2 minutes), confirm execution status
SELECT job_name, status, log_date
FROM user_scheduler_job_log
WHERE job_name = 'JOB_GREET_EMPLOYEES'
ORDER BY log_date DESC;
--check
SELECT column_name
FROM user_tab_columns
WHERE table_name = 'USER_SCHEDULER_JOB_LOG';

DESC user_scheduler_job_log;
---------------------
-- TASK 2: Recurring Job - Daily Leave Report
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_DAILY_LEAVE_REPORT',
        job_type        => 'PLSQL_BLOCK',
        job_action       => 'BEGIN
                                INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
                                SELECT employee_log_seq.NEXTVAL, NULL,
                                       ''DAILY_LEAVE_COUNT: '' || COUNT(*),
                                       SYSDATE
                                FROM leave_record
                                WHERE TRUNC(leave_date) = TRUNC(SYSDATE);
                                COMMIT;
                              END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=7; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE
    );
END;
/

-- Show the job definition
SELECT job_name, repeat_interval, state, next_run_date
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_DAILY_LEAVE_REPORT';
----------------------
-- TASK 3: Job with Program & Schedule Objects
-- (a) Program pointing to SP_PROCESS_PAYROLL
BEGIN
    DBMS_SCHEDULER.CREATE_PROGRAM(
        program_name   => 'PROG_MONTHLY_PAYROLL',
        program_type    => 'STORED_PROCEDURE',
        program_action  => 'SP_PROCESS_PAYROLL',
        number_of_arguments => 2,
        enabled         => FALSE
    );

    DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
        program_name      => 'PROG_MONTHLY_PAYROLL',
        argument_position => 1,
        argument_type      => 'NUMBER'
    );

    DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
        program_name      => 'PROG_MONTHLY_PAYROLL',
        argument_position => 2,
        argument_type      => 'DATE'
    );

    DBMS_SCHEDULER.ENABLE('PROG_MONTHLY_PAYROLL');
END;
/

--(b)Schedule for the first of every month
BEGIN
    DBMS_SCHEDULER.CREATE_SCHEDULE(
        schedule_name   => 'SCH_FIRST_OF_MONTH',
        repeat_interval => 'FREQ=MONTHLY; BYMONTHDAY=1; BYHOUR=6',
        comments        => 'Runs on the 1st of every month at 6 AM'
    );
END;
/

-- (c) Job combining the program and schedule
BEGIN
DBMS_SCHEDULER.CREATE_JOB(
job_name => 'JOB_MONTHLY_PAYROLL',
program_name => 'PROG_MONTHLY_PAYROLL',
schedule_name => 'SCH_FIRST_OF_MONTH',
enabled => FALSE);
DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(
job_name => 'JOB_MONTHLY_PAYROLL',
argument_position => 1,
argument_value => 1);
DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(
job_name => 'JOB_MONTHLY_PAYROLL',
argument_position => 2,
argument_value => SYSDATE);
DBMS_SCHEDULER.ENABLE('JOB_MONTHLY_PAYROLL');
END;
/

--check
BEGIN
DBMS_SCHEDULER.CREATE_JOB(
job_name => 'JOB_MONTHLY_PAYROLL',
program_name => 'PROG_MONTHLY_PAYROLL',
schedule_name => 'SCH_FIRST_OF_MONTH',
enabled => FALSE
);
END;
/

BEGIN
DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(
job_name => 'JOB_MONTHLY_PAYROLL',
argument_position => 1,
argument_value => 1
);
DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(
job_name => 'JOB_MONTHLY_PAYROLL',
argument_position => 2,
argument_value => SYSDATE
);
DBMS_SCHEDULER.ENABLE('JOB_MONTHLY_PAYROLL');
END;
/

-- Query all three objects
SELECT program_name, program_type, program_action, enabled FROM USER_SCHEDULER_PROGRAMS;
SELECT schedule_name, repeat_interval FROM USER_SCHEDULER_SCHEDULES;
SELECT job_name, program_name, schedule_name, enabled FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_MONTHLY_PAYROLL';
------------------------------------------------------------------------
