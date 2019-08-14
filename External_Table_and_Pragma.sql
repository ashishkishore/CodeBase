create table ext_tst(id number,name varchar2(20),salary number,dept_id number)
organization EXTERNAL
(TYPE ORACLE_LOADER
 DEFAULT DIRECTORY ORA_DATA
 ACCESS PARAMETERS
 (
  RECORDS DELIMITED BY NEWLINE
  FIELDS TERMINATED BY "," 
  missing field values are null
 )
 LOCATION ('EMPLOYEE.CSV')
)
REJECT LIMIT UNLIMITED
/
select * from ext_tst;

drop table ext_tst;

select * from all_tables;

select * from graphics_table;


desc test_emp;
/


begin
insert into test_emp values(999,'sahil');
pragma_tst(998,'rehan');
rollback;
end;
/

select * from test_emp;

truncate table test_emp;


create or replace procedure pragma_tst(id number,name varchar2) as 
pragma autonomous_transaction;
begin
insert into test_emp values(id,name);
commit;
end;
/

drop procedure prc1;

