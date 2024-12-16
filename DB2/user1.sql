


.










































































































































































































































































































create table Attendance(
    id NUMBER PRIMARY KEY not NULL,
    employee_id NUMBER,
    CONSTRAINT emp_id_const FOREIGN KEY( employee_id) REFERENCES Employees(id), 
    date_attend DATE, 
    in_time VARCHAR2(20) , 
    out_time VARCHAR2(20) , 
    total_hours number DEFAULT 0 NOT NULL check(total_hours>=0)
);

create table Employees(
    id NUMBER PRIMARY KEY ,
    name VARCHAR2(50), 
    position VARCHAR2(50), 
    department VARCHAR2(50), 
    salary NUMBER , 
    status number check (status in (0,1))
);

GRANT REFERENCES ON Employees TO manager with GRANT OPTION;
GRANT SELECT ON user_1.Employees TO manager;
GRANT SELECT ON user_1.Attendance TO manager;
grant execute on raise_salary to user_2;
drop table Attendance;
drop table Employees;
--------------------------------------------------------------------------------
--(10) blocker_waiting


set autocommit off;
set serveroutput on;

declare
    result number;
BEGIN
    
    dbms_output.put_line('User 1: Raising salary by 10%');
        result := manager.raise_salary('IS');
    dbms_output.put_line('User 1: salary updated'); 
 
-- commit;
END;
--------------------------------------------------------------------------------

--(12) deadlock
-- User 1

--set SERVEROUTPUT on;
--DECLARE
--    result NUMBER;
--BEGIN
--    dbms_output.put_line('User  1: Raising salary by 10%');
--    result := manager.raise_salary('IS');
--    dbms_output.put_line('User  1: Salary updated in Marketing');
--    
--    EXCEPTION WHEN others then
--         dbms_output.put_line('User  1: rolling back');
--         rollback;
--
--END;
--                                          
--DECLARE
--    result NUMBER;
--BEGIN 
--
--    dbms_output.put_line('User  1: Raising salary by 10%');
--    result := manager.raise_salary('AI');
--    dbms_output.put_line('User  1: Raising salary updated');
--
--    EXCEPTION WHEN others then
--         dbms_output.put_line('User  1: rolling back');
--         rollback;
--END;
--------------------------------------------------------------------------------

SET SERVEROUTPUT ON;
DECLARE
result number  := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('User 1: Locking IS department');
    result := manager.raise_salary('IS');

    DBMS_OUTPUT.PUT_LINE('User 1: IS updated. Waiting to lock AI department...');
    DBMS_LOCK.SLEEP(10); 
    
    result := manager.raise_salary('AI');
    DBMS_OUTPUT.PUT_LINE('User 1: AI updated');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('User 1: Rolling back due to deadlock');
        ROLLBACK;
END;



