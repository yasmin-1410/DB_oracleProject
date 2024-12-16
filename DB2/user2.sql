create sequence seq start with 1 increment by 1;

insert into user_1.Employees (id, name, position, department, salary, status)
values (seq.nextval,'ahmed','manager','IS',30000,1);

insert into user_1.Employees (id, name, position, department, salary, status)
values (seq.nextval,'mohamed','employee','CS',20000,1);

insert into user_1.Employees (id, name, position, department, salary, status)
values (seq.nextval,'omar','HR','AI',10000,1);

insert into user_1.Employees (id, name, position, department, salary, status)
values (seq.nextval,'hassan','manager','CS',30000,0);

insert into user_1.Employees (id, name, position, department, salary, status)
values (seq.nextval,'khaled','HR','AI',15000,0);
commit;


create sequence a_seq start with 1 increment by 1;


INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES (a_seq.NEXTVAL,1,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'10:00:00','14:00:00');
INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES(a_seq.nextval,2,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'09:00:00','15:00:00');
INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES(a_seq.nextval,3,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'11:00:00','14:00:00');
INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES(a_seq.nextval,4,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'10:00:00','15:00:00');
INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES(a_seq.nextval,5,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'09:00:00','15:00:00');
commit;
--------------------------------------------------------------------------------
--(10) blocker_waiting 
declare
    result number;
BEGIN
    
    dbms_output.put_line('User 2: Raising salary by 10%');
        result := manager.raise_salary('IS');
    dbms_output.put_line('User 2: salary updated'); 
        Dbms_LOCK.SLEEP(20); 
 commit;
END;
--------------------------------------------------------------------------------
--(12) deadlock
-- User 2

--set serveroutput on;
--DECLARE
--    result NUMBER;
--BEGIN
--    dbms_output.put_line('User  2: Raising salary by 10%');
--    result := manager.raise_salary('AI');
--    dbms_output.put_line('User  2: Raising salary updated');
--    
--    EXCEPTION WHEN others then
--         dbms_output.put_line('User  2: rolling back');
--         rollback;
--
--END;
--
--DECLARE
--    result NUMBER;
--BEGIN
--
--    dbms_output.put_line('User  2: Raising salary by 10%');
--    result := manager.raise_salary('IS');
--    dbms_output.put_line('User  2: Raising salary updated');
--    EXCEPTION WHEN others then
--         dbms_output.put_line('User  2: rolling back');
--         rollback;
--END;

--------------------------------------------------------------------------------

SET SERVEROUTPUT ON;
DECLARE
result number := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('User 2: Locking AI department');
    result := manager.raise_salary('AI');

    DBMS_OUTPUT.PUT_LINE('User 2: AI updated. Waiting to lock IS department...');
    DBMS_LOCK.SLEEP(10); 

    result := manager.raise_salary('IS'); 
    DBMS_OUTPUT.PUT_LINE('User 2: IS updated');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('User 2: Rolling back due to deadlock');
        ROLLBACK;
END;

