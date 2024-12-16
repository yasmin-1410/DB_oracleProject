
alter SESSION set "_oracle_script"=true;
-- admin hear create user manager and role manager_role
create user manager identified by 123;
create or manager_roles;

-- this condetion in case of we already created manager_role before
set role manager_roles;
--------------------------------------
-- admin give privilage to manager_role (with admin option)

grant create session, create user, create table, drop user, alter user,
      select any table, insert any table, delete any table, update any table,
      create any trigger, drop any trigger, create procedure, create sequence,
      insert any table
      to manager_roles with admin option;
      
-- manager give privilage to user manager 

grant manager_roles to manager with admin option;
grant create procedure, create sequence, create any trigger, drop any trigger,
      update any table, execute on dbms_lock 
      to manager with admin option;
      
-- give quota to users
alter user manager quota 100m on Users;
alter user user_1 quota 100m on Users;

grant select on user_1.employees to manager;
--------------------------------------------------------------------------------
-- manager 

-- create user 1 and user 2
alter SESSION set "_oracle_script"=true;
create user user_1 identified by 123;
create user user_2 identified by 456;

-- privilage to user 1 and user 2
grant create session, create table, create sequence, insert any table, update any table, select any table, execute on dbms_lock to user_1;
grant create session, create sequence, insert any table, update any table, execute on dbms_lock to user_2;

------------------------------------
-- privilage from user 1 to manger

grant references on employees to manager with grant option, 
      select on user_1.employees to manager, 
      select on user_1.attendance to manager, 
      execute on raise_salary to user_2;

--------------------------------------------------------------------------------
-- tables created in manager 

create table Payroll(
    id NUMBER PRIMARY KEY ,
    employee_id NUMBER not null,
    CONSTRAINT emp_id_const FOREIGN KEY( employee_id) REFERENCES user_1.Employees(id), 
    month NUMBER check(month>=1 and month<=12),
    total_hours_worked number check(total_hours_worked>=0),
    deductions number check(deductions>=0), 
    bonuses number DEFAULT 0 NOT NULL check(bonuses>=0), 
    net_salary number check(net_salary>=0)
);

create table LeaveRequests(
    id NUMBER PRIMARY KEY NOT NULL,
    employee_id NUMBER ,
    CONSTRAINT emp_id_const2 FOREIGN KEY( employee_id) REFERENCES user_1.Employees(id), 
    leave_date date , 
    reason VARCHAR2(255), 
    approval_status VARCHAR2(50) check (approval_status in ('approved','unapproved','Pending'))
);


create table AuditTrail(
    id NUMBER PRIMARY KEY NOT NULL,
    table_name VARCHAR2(50), 
    operation VARCHAR2(50) check(operation in ('insert','update','delete')), 
    old_data clob, 
    new_data clob, 
    timestamp timestamp 
);

create table Deductions(
    id NUMBER PRIMARY KEY,
    employee_id NUMBER not null,
    CONSTRAINT emp_id_const3 FOREIGN KEY( employee_id) REFERENCES user_1.Employees(id), 
    deduction_reason VARCHAR2(255), 
    amount NUMBER DEFAULT 0 NOT NULL check( amount >=0), 
    deduction_date date
);
--(1) nadeen
create TABLE SuspendedAttendanceAttempts(
    employee_id NUMBER not null,
    CONSTRAINT emp_id_const4 FOREIGN KEY( employee_id) REFERENCES user_1.Employees(id)
);

--(7)
create table MonthlyAttendanceSummary(
    month varchar(10) ,
    employee_id NUMBER not null,
    CONSTRAINT emp_id_const5 FOREIGN KEY( employee_id) REFERENCES user_1.Employees(id),
    total_days_worked numeric,
    avg_time_worked numeric,
    total_lates numeric  
);

--(8)

create table AdjustmentAudit(
    employee_id NUMBER not null,
    CONSTRAINT emp_id_const6 FOREIGN KEY( employee_id) REFERENCES user_1.Employees(id), 
    department VARCHAR(50), 
    adjustment_amount NUMBEr ,
    processor VARCHAR(100)
);

--------------------------------------------------------------------------------
-- tales in user 1

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

--------------------------------------------------------------------------------
-- insertion on user 2

-- Employees table 

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

-- Attendance 

create sequence a_seq start with 1 increment by 1;


INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES (a_seq.NEXTVAL,1,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'10:00:00','14:00:00');
INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES(a_seq.nextval,2,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'09:00:00','15:00:00');
INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES(a_seq.nextval,3,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'11:00:00','14:00:00');
INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES(a_seq.nextval,4,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'10:00:00','15:00:00');
INSERT INTO user_1.Attendance (id, employee_id, date_attend, in_time, out_time) VALUES(a_seq.nextval,5,TO_DATE('12-12-2024', 'DD-MM-YYYY'),'09:00:00','15:00:00');
commit;
--------------------------------------------------------------------------------

-- requirments steps -> 1, 2, 4, 6, 3, 8, 5, 7, 10, 11, 12

-----------------------------------------------------------
--(1) 
-- trigger is for before inserting in attendance table check is the emp is (active , suspended)
-- add suspended emps in new table named SuspendedAttendanceAttempts

drop trigger Attendance_Validation;
CREATE OR REPLACE TRIGGER Attendance_Validation
BEFORE INSERT OR UPDATE ON user_1.Attendance
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    employee_status number(1);
BEGIN

    BEGIN
        SELECT status INTO employee_status
        FROM user_1.Employees
        WHERE id = :NEW.employee_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Employee not found in Employees table!');
    END;

    IF employee_status = 0 THEN
        INSERT INTO SuspendedAttendanceAttempts (employee_id)
        VALUES (:NEW.employee_id);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Attendance attempt rejected for Employee ' || :NEW.employee_id || '. Employee is suspended.');
        RAISE_APPLICATION_ERROR(-20001, 'Attendance cannot be recorded for suspended employees!');
        
    END IF;
END Attendance_Validation;

--------------------------------------------------------------------------------
-- (2)

-- split the in_time and out_time for employee into hours and minutes to calculate total hours
-- every employee must record thier attendance in 09:00:00 and just 5mins delay is allowed 
-- if employee in_time for him is bigger than 5min then insert in deduction table and the reason is stored as 'late' in deduction table
-- update total_hours worked in table attendance

CREATE OR REPLACE FUNCTION CalculateWorkHours(in_time IN VARCHAR2, out_time IN VARCHAR2, emp_id IN NUMBER) 
    RETURN VARCHAR2 IS
        const_in_time CONSTANT VARCHAR2(50) := '09:00:00';  
        TotalHours NUMBER;
        actual_in_time NUMBER;
        in_minute NUMBER;
        out_minute NUMBER;
        grace_minute NUMBER := 5; 
        in_timestamp TIMESTAMP;
        out_timestamp TIMESTAMP;
        hours NUMBER;
        minutes NUMBER;
        hour_char VARCHAR2(50);
        standard_in_minute NUMBER;
        standard_out_minute NUMBER;
        standard_in_timestamp TIMESTAMP;
        standard_out_timestamp TIMESTAMP; 
        time TIMESTAMP;
        
BEGIN
    in_timestamp := TO_TIMESTAMP(in_time, 'HH24:MI:SS');
    out_timestamp := TO_TIMESTAMP(out_time , 'HH24:MI:SS');


    in_minute := EXTRACT(HOUR FROM in_timestamp) * 60 + EXTRACT(MINUTE FROM in_timestamp);
    out_minute := EXTRACT(HOUR FROM out_timestamp) * 60 + EXTRACT(MINUTE FROM out_timestamp);
    
    standard_in_timestamp := TO_TIMESTAMP(const_in_time, 'HH24:MI:SS');

    standard_in_minute := EXTRACT(HOUR FROM standard_in_timestamp) * 60 + EXTRACT(MINUTE FROM standard_in_timestamp);

    IF in_minute = standard_in_minute THEN 
        actual_in_time := standard_in_minute; 
    ELSIF in_minute > standard_in_minute AND in_minute <= (standard_in_minute + grace_minute) THEN
        actual_in_time := in_minute; 
    ELSE 
        actual_in_time := in_minute; 
        
        insert into Deductions (id, employee_id, deduction_reason, deduction_date) values (id_seq.nextval,emp_id,'late',SYSTIMESTAMP );
    END IF;

    TotalHours := (out_minute - actual_in_time) / 60.00;

    hours := FLOOR(TotalHours); 
    minutes := ROUND((TotalHours - hours) * 60);        
    time := TO_TIMESTAMP(TO_CHAR(hours) || ':' || TO_CHAR(minutes) || ':00', 'HH24:MI:SS');
    
    hour_char := TO_CHAR(time, 'HH24:MI:SS');

    UPDATE user_1.Attendance SET total_hours = TotalHours WHERE employee_id = emp_id;
    commit;

    RETURN hour_char; 

END CalculateWorkHours;
set serveroutput on;
DECLARE
    in_time_variable VARCHAR2(50)  ;
    out_time_variable VARCHAR2(50) ;
    EmployeeId NUMBER := 1; 
    hour VARCHAR2(50);
BEGIN
    select in_time into in_time_variable from user_1.Attendance where employee_id =EmployeeId;
    select out_time into out_time_variable from user_1.Attendance where employee_id =EmployeeId;
    hour := CalculateWorkHours(in_time_variable, out_time_variable, EmployeeId); 
    DBMS_OUTPUT.PUT_LINE('Calculated Time: ' || hour); 

END;

--------------------------------------------------------------------------------
--(4)

-- okay here we created two triggers one for one is for BEFORE INSERT and the other is for AFTER UPDATE
-- the two trigger either updating or inserting it sould be in table AuditTrail
-- AuditTrail should Include details such as employee_id, leave_date, approval_status, and the timestamp of the change.

create or replace TRIGGER  BEFORE_INSERT
BEFORE INSERT ON LeaveRequests
REFERENCING NEW AS n
FOR EACH ROW

DECLARE
    
begin 
    insert into AuditTrail (id, table_name, operation,old_data ,new_data, timestamp) 
    values(id_seq.nextval,'LeaveRequests','insert',null,'employee_id ' || :n.employee_id  || ', leave date ' || :n.leave_date || ',approval status ' || :n.approval_status , SYSTIMESTAMP );
    

end BEFORE_INSERT;

create or replace TRIGGER  AFTER_UPDATE
AFTER UPDATE ON LeaveRequests
REFERENCING NEW AS n 
FOR EACH ROW
    
DECLARE

begin 

    insert into AuditTrail (id, table_name, operation, old_data, new_data, timestamp) 
    values(id_seq.nextval,'LeaveRequests','update','employee_id :' || :old.employee_id || 'leave date: ' || :old.leave_date || 'approval status: ' || :old.approval_status, 'employee_id :' || :n.employee_id || ' ,leave date: ' || :n.leave_date || ', approval status :' || :n.approval_status ,SYSTIMESTAMP );
end AFTER_UPDATE;

INSERT INTO LeaveRequests (id,employee_id, leave_date, reason, approval_status)
VALUES (id_seq.NEXTVAL,1, TO_DATE('2023-10-15', 'YYYY-MM-DD'), 'Medical Leave', 'Pending');


update LeaveRequests set approval_status ='unapproved' where employee_id = 1;

--------------------------------------------------------------------------------
-- in this part we use :
-- first 6 -> deduction and update in payroll
-- second 3 -> for insert in payroll and caculate the net_salary (real_salary + bounes - deduction)
-- third 8 -> add bounes and update net_salary
--------------------------------------------------------------------------------

-- (6)

-- create two cursor to fetch on the procedure one for unapproved_cur from LeaveRequests table
-- and the other one is for late_cur that from deduction table to fetch on late employees
-- insert in table deduction if it unapproved and amount of deduct = 100
-- update in table payroll in deduction column the amount of deduct = 200

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ProcessLeaveDeductions
IS
    CURSOR unapproved_cur IS
        SELECT lr.employee_id, lr.leave_date, lr.reason
        FROM manager.LeaveRequests lr
        WHERE lr.approval_status = 'unapproved';

    CURSOR late_cur IS
        SELECT d.employee_id, d.amount
        FROM Deductions d
        WHERE d.deduction_reason = 'late';

    total_deduction NUMBER := 0;  
    new_amount NUMBER := 200;     
    default_deduction NUMBER := 100; 

BEGIN
  
    for unapproved_rec in unapproved_cur loop

        insert into Deductions (id, employee_id, deduction_reason, amount, deduction_date)
        values (id_deduct_seq.NEXTVAL, unapproved_rec.employee_id, unapproved_rec.reason, default_deduction, unapproved_rec.leave_date);

        select NVL(sum(amount), 0)
        into total_deduction
        from Deductions
        where employee_id = unapproved_rec.employee_id;

        update manager.Payroll
        set deductions = total_deduction
        where employee_id = unapproved_rec.employee_id;

        DBMS_OUTPUT.PUT_LINE('Inserted Deduction for Employee ID: ' || unapproved_rec.employee_id || 
                             ', Reason: ' || unapproved_rec.reason || ', Deduction Amount: ' || default_deduction);
    end loop;

    for late_rec IN late_cur loop
        UPDATE Deductions
        SET amount = new_amount
        WHERE employee_id = late_rec.employee_id AND deduction_reason = 'late';

        SELECT NVL(SUM(amount), 0)
        INTO total_deduction
        FROM Deductions
        WHERE employee_id = late_rec.employee_id;

        UPDATE manager.Payroll
        SET deductions = total_deduction
        WHERE employee_id = late_rec.employee_id;

        DBMS_OUTPUT.PUT_LINE('Updated Deduction for Employee ID: ' || late_rec.employee_id || 
                             ', New Deduction Amount: ' || new_amount);
    END LOOP;

    COMMIT;

END ProcessLeaveDeductions;
set serveroutput on;
exec ProcessLeaveDeductions;
--------------------------------------------------------------------------------
-- (3)

-- loop all emp and calculate all total hours worked for the form select in and out time from attendance table 
-- and calculate deduction amount and bounes and add the result in ne_salary
-- inseart all this actions in payroll table
create sequence id_seq1 start with 1 increment by 1;

--drop SEQUENCE id_seq1;
CREATE OR REPLACE PROCEDURE Generate(pmonth IN NUMBER)
IS
    total_h NUMBER := 0;  
    base_s NUMBER := 0;  
    net_s NUMBER := 0;  
    bonuse NUMBER := 0;  
    deduction NUMBER := 0; 
BEGIN
    DELETE FROM Payroll;
    for emp_id in (select id from user_1.Employees where status = 1) loop
        total_h := 0;
        base_s := 0;
        net_s := 0;
        bonuse := 0;
        deduction := 0;

        select NVL(SUM(total_hours), 0)into total_h from user_1.Attendance where employee_id = emp_id.id and EXTRACT(MONTH FROM date_attend) = pmonth;

        select salary INTO base_s from user_1.Employees where id = emp_id.id;

        select NVL(SUM(amount), 0) into deduction from Deductions where employee_id = emp_id.id and EXTRACT(MONTH FROM deduction_date) = pmonth;

        select NVL(SUM(bonuses), 0) into bonuse from Payroll where employee_id = emp_id.id and month = pmonth;

        net_s := base_s + bonuse - deduction;
        insert into Payroll (id, employee_id, month, total_hours_worked, bonuses, deductions, net_salary)
        values (id_seq1.NEXTVAL, emp_id.id, pmonth, total_h, bonuse, deduction, net_s);

    end loop;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found');
END Generate;

DECLARE
    pay_month NUMBER := 12;  
BEGIN
    Generate(pay_month);
END;
--------------------------------------------------------------------------------

--(8)

-- add bounse for specific department and month then update in the payroll table
--  update net_salary from payroll table 
-- rollback in case of failures
-- new table AdjustmentAudit have (employee_id, department, adjustment_amount, processor)
SET SERVEROUTPUT ON;

DECLARE
    bounse NUMBER := 200;
    temp_depart VARCHAR2(20) := 'IS';
    sal_bon NUMBER := 0;
    month_in VARCHAR(20) := '12';
    processor VARCHAR(20) := 'manager';
    i user_1.Attendance%ROWTYPE;
    row_count NUMBER := 0;  
BEGIN
    FOR i IN (SELECT p.employee_id, p.bonuses, p.month, e.department ,p.net_salary 
              FROM Payroll p 
              JOIN user_1.Employees e ON e.id = p.employee_id 
              WHERE e.department = temp_depart AND p.month = month_in) 
    LOOP
        row_count := row_count + 1;
        sal_bon := bounse + i.net_salary;

        UPDATE Payroll 
        SET bonuses = bounse, net_salary = sal_bon
        WHERE employee_id = i.employee_id;

        DBMS_OUTPUT.PUT_LINE('employee_id :' || i.employee_id ||
                             ', department: ' || temp_depart ||
                             ', adjustment_amount: ' || sal_bon ||
                             ', processor: ' || processor);

        INSERT INTO AdjustmentAudit (employee_id, department, adjustment_amount, processor)
        VALUES (i.employee_id, temp_depart, sal_bon, processor);
    END LOOP;

    IF row_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No rows found for department: ' || temp_depart || ', rolling back...');
        ROLLBACK; 
    ELSE
        COMMIT;
    END IF;

EXCEPTION 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('Rolling back transaction due to error: ' || SQLERRM);
        ROLLBACK;
END;

--------------------------------------------------------------------------------
-- (5)

-- create cursor  
-- Fetch each employee's total hours worked, approved leaves, and late arrivals for approved and late
-- arranged desc to take the max total hours worked from attendance table to specify if the top performing or lower performing
-- print the result for each emp

CREATE OR REPLACE PROCEDURE GeneratePerformanceReport
IS
    CURSOR emp_cursor IS
        SELECT e.id AS employee_id,SUM(a.total_hours) AS total_hours_worked,COUNT(l.id) AS approved_leaves,COUNT(d.id) AS late
        FROM user_1.Employees e
             LEFT JOIN user_1.Attendance a ON e.id = a.employee_id
             LEFT JOIN LeaveRequests l ON e.id = l.employee_id AND l.approval_status = 'approved'
             LEFT JOIN Deductions d ON e.id = d.employee_id AND d.deduction_reason = 'late'
        WHERE e.status = 1 GROUP BY e.id ORDER BY SUM(a.total_hours) DESC NULLS LAST;

    id number;
    total_hours NUMBER;
    approved_leaves NUMBER;
    late_arrivals NUMBER;
    performance VARCHAR2(20);

    first_employee BOOLEAN := TRUE;

BEGIN
    OPEN emp_cursor;

    LOOP
        FETCH emp_cursor INTO id, total_hours, approved_leaves, late_arrivals;
        EXIT WHEN emp_cursor%NOTFOUND;

        IF first_employee THEN
            performance := 'Top Performance';
            first_employee := FALSE; 
        ELSE
            performance := 'Lowest Performance';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'Employee ID: ' || id || ', Total Hours Worked: ' || total_hours ||', Approved Leaves: ' || approved_leaves ||', Late Arrivals: ' || late_arrivals ||', Performance Rating: ' || performance);
    END LOOP;

    CLOSE emp_cursor;
END GeneratePerformanceReport;
execute GeneratePerformanceReport;
--------------------------------------------------------------------------------

-- (7)

-- summary attendanc (day works, days late, avg daily hours) for each emp in specified month
-- save in new table MonthlyAttendanceSummary

set SERVEROUTPUT on;

DECLARE
    i user_1.Attendance%ROWTYPE;
    j user_1.Attendance%ROWTYPE;
    total_days_worked NUMBER; --
    total_lates NUMBER; --
    id_temp NUMBER := NULL; --
    month_temp varchar2(10); --
    work_time constant varchar2(20) := '09:00:00';
    hour_w Number :=0; --intime
    minute_w NUMBER :=0; --intime
    hour_w2 NUMBER :=0; --
    minute_w2 NUMBER :=0; --
    avg_hours_worked NUMERIC :=0; --
    total_hours_worked NUMBER :=0; --
BEGIN 
        for j in (select to_char(date_attend, 'MM') as month
              from user_1.Attendance
              group by to_char(date_attend, 'MM')
              order by month)loop
              
        month_temp := j.month;

        for i in (select employee_id, total_hours, in_time
                  from user_1.Attendance
                  where to_char(date_attend, 'MM') = month_temp
                  ORDER BY employee_id)
        loop
            if id_temp is NULL or id_temp != i.employee_id then

                if id_temp is not null then
                    avg_hours_worked := total_hours_worked / total_days_worked;

            dbms_output.put_line('Month: ' || month_temp ||
                                 ', Employee ID: ' || id_temp ||
                                 ', Total Days Worked: ' || total_days_worked ||
                                 ', Avg Hours Worked: ' || TO_CHAR(avg_hours_worked, '90.99') ||
                                 ', Total Lates: ' || total_lates);

              Insert into MonthlyAttendanceSummary(month, employee_id, total_days_worked, avg_time_worked, total_lates)
              values (month_temp, id_temp, total_days_worked, avg_hours_worked, total_lates);
                end if;

                id_temp := i.employee_id;
                total_days_worked := 0;
                total_hours_worked := 0;
                total_lates := 0;
            end if;

            total_days_worked := total_days_worked + 1;
            total_hours_worked := total_hours_worked + i.total_hours;

            hour_w := to_number(to_char(to_date(i.in_time, 'HH24:MI:SS'), 'HH24'));
            minute_w := to_number(to_char(to_date(i.in_time, 'HH24:MI:SS'), 'MI'));
            
            hour_w2 := to_number(to_char(to_date(work_time, 'HH24:MI:SS'), 'HH24'));
            minute_w2 := to_number(to_char(to_date(work_time, 'HH24:MI:SS'), 'MI'));

            if hour_w > hour_w2 or (hour_w = hour_w2 and minute_w > minute_w2) then
                  total_lates := total_lates + ((hour_w - hour_w2) * 60) + (minute_w - minute_w2);
            end if;

        end loop;

        if id_temp is not null then
            avg_hours_worked := total_hours_worked / total_days_worked;

            dbms_output.put_line('Month: ' || month_temp ||
                                 ', Employee ID: ' || id_temp ||
                                 ', Total Days Worked: ' || total_days_worked ||
                                 ', Avg Hours Worked: ' || TO_CHAR(avg_hours_worked, '90.99') ||
                                 ', Total Lates: ' || total_lates);

              Insert into MonthlyAttendanceSummary(month, employee_id, total_days_worked, avg_time_worked, total_lates)
              values (month_temp, id_temp, total_days_worked, avg_hours_worked, total_lates);
              
        end if;
            commit;
        id_temp := null;
    end loop;
end;

--------------------------------------------------------------------------------

-- (10)

-- block_waiting for user 1 and user 2 
-- first makeing a function named raise_salary in manager accroding to specific department then give privilage to user1 and user2 to call this function
-- then make and run pl/sql in user 2 that call function with department for example 'IS' and before commit add locksleep for 10 sec
-- in this period run pl/sql in user 1 that call function with the same department 
-- user1 transaction will waiting and for make sure go run select query in point (10) until user 2 commit the user1 well work

-- function

create or replace function raise_salary(depart in VARCHAR2) 
return Number is
    updated_salary NUMBER;
    BEGIN
    UPDATe user_1.Employees 
    set salary = salary *1.10
    Where department = depart;

    RETURN updated_salary;
END;


grant execute on raise_salary to user_1;
grant execute on raise_salary to user_2;


--user 1

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

-- user 2

declare
    result number;
BEGIN
    
    dbms_output.put_line('User 2: Raising salary by 10%');
        result := manager.raise_salary('IS');
    dbms_output.put_line('User 2: salary updated'); 
        Dbms_LOCK.SLEEP(20); 
 commit;
END;

-- (11)
--Identify the sessions in the blocker-waiting situation using SID and SERIAL# for both the blocker and waiting sessions.

select
w.sid "Wating Session", w.serial# "Wating Serial Id",
w.blocking_session "Blocker session id",
w.seconds_in_wait "Wating Session Period",
v.sql_fulltext "wating session sql statment"
FROM
    v$session w
JOIN
    v$sql v ON w.sql_id = v.sql_id
AND w.blocking_session IS NOT NULL;

--------------------------------------------------------------------------------
--(12)

-- again from the previous function we should doing deadlock setuation for two senarios

-- user1 will locks the IS department 
-- user2 locks the AI department causing a deadlock for two transactions 
-- Oracle detects the deadlock and raises an exception
-- The EXCEPTION block catches the error, and both users perform a ROLLBACK, undoing their changes
-- no updates in payroll table

-- user 1 

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

-- user 2

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

