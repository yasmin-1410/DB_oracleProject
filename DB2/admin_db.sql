alter SESSION set "_oracle_script"=true;
create user manager identified by 123;
create or manager_roles;

set role manager_roles;

grant create session, create user, create table, drop user, alter user, select any table, insert any table, delete any table to manager_roles WITH ADMIN OPTION; 
grant  manager_roles to manager with admin option;
grant create PROCEDURE to manager with admin option;
alter user manager quota 100M on Users ;
alter user user_1 quota 100M on Users;
grant create any trigger to manager with admin option;
grant drop any trigger to manager with admin option; 
grant update any table to manager with admin option;
GRANT SELECT ON user_1.Employees TO manager;
grant create SEQUENCE to manager with admin option;
--drop manager_roles;
GRANT EXECUTE ON DBMS_LOCK TO manager with grant option;
grant insert any table to manager with admin option;
SELECT * 
FROM USER_ROLE_PRIVS 
WHERE GRANTED_ROLE = 'MANAGER_ROLES';
--------------------------------------------------------------------------------
--(11) not sure

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

    

--SELECT
--    l.session_id AS "blocking_session",
--    s.serial# AS "serial#",
--    o.object_name AS "locked_object",
--    s.sid,
--    s.status,
--    s.machine,
--    s.username
--FROM
--    v$locked_object l
--JOIN
--    dba_objects o ON l.object_id = o.object_id
--JOIN
--    v$session s ON l.session_id = s.sid
--WHERE
--    o.object_name = 'EMPLOYEES';


--ALTER SYSTEM KILL SESSION '197,40129' IMMEDIATE;