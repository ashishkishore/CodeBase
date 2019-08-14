File Content:
-------------
1. Writing into Flat file.
2. Reading from Flat file.
3. Exporting table data in Flat file.
4. Storing Images in DB.
5. Getting DDL of a Table.
6. APPLICATION CONTEXT.
7. candidate table for gathering table stat 
8. 15 Days sql learning Code challenge.
9. Fetching substr enclosed within <>
10. Fetching table name having specific column in the schema.
11. ORACLE 12c New Enhancements for SQL and PL/SQL
12. DATABASE File Location
13. Take a backup of control file
14. Performance Tuning Approach
15. External Table
16. Save Exception: Continuing the DML in case of errors and logging the error rows in error table.
17. Mule Soft Key Concepts:
18. GUID()
--*************************************UTL_FILE OPERATION*******************************************--

--DIRECTORY=ORA_DATA 
/*SQL> create directory ORA_DATA as 'D:\ASHISH';

Directory created.

SQL> grant read on directory ORA_DATA to hr;

Grant succeeded.

SQL> grant write on directory ORA_DATA to hr;

Grant succeeded.*/

1.--Writing into flat file..
DECLARE
F1 UTL_FILE.FILE_TYPE;
BEGIN
F1:=UTL_FILE.FOPEN('ORA_DATA','TEST.TXT','W');
UTL_FILE.PUT_LINE(F1,'HI ASHISH..');
UTL_FILE.PUTF(F1,'THIS IS MY FIRST FILE.\NITS AMAZING!!');
UTL_FILE.FCLOSE(F1);
DBMS_OUTPUT.PUT_LINE('FILE GENERATED..');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('OOPS!! '|| SQLERRM);
END;

2.--Reading from Flat file..
DECLARE
V1 VARCHAR2(32767);
F1 UTL_FILE.FILE_TYPE;
BEGIN
F1:=UTL_FILE.FOPEN('ORA_DATA','TEST.TXT','R');
LOOP
BEGIN
UTL_FILE.GET_LINE(F1,V1);
DBMS_OUTPUT.PUT_LINE(V1);
EXCEPTION WHEN NO_DATA_FOUND THEN EXIT;
END;
END LOOP;
UTL_FILE.FCLOSE(F1);
END;

3.--Exporting table data in Flat file..
DECLARE
F1 UTL_FILE.FILE_TYPE;
BEGIN
F1:=UTL_FILE.FOPEN('ORA_DATA','EMPLOYEE.CSV','W');
FOR I IN (SELECT * FROM EMPLOYEES) LOOP
UTL_FILE.PUT_LINE(F1,I.EMPLOYEE_ID||','||I.FIRST_NAME||','||I.LAST_NAME||','||I.SALARY);
END LOOP;
DBMS_OUTPUT.PUT_LINE('FILE COPIED..');
UTL_FILE.FCLOSE(F1);
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('SOMETHING WRONG..'||SQLERRM);
END;

/*===============================================================
 4.******************Storing Images in DB..***********************
===============================================================*/
create table graphics_table (
  bfile_id number,
  bfile_desc varchar2(30),
  bfile_loc bfile,
  bfile_type varchar2(4));
  
  INSERT INTO graphics_table
  VALUES(10,'tea_party',bfilename('ORA_DATA','tea_party.JPG'),'JPEG');
  
  commit;
  
  /*==============================================================
  5.************Getting DDL of a Table******************************
  ==============================================================*/
  select dbms_metadata.get_ddl('TABLE','SMARTVENDORTAG') from dual;
  
  
  6./******************** WHAT IS AN APPLICATION CONTEXT?*******************/
      ====================================================================
 AN APPLICATION CONTEXT IS A SET OF NAME-VALUE PAIRS THAT ORACLE DATABASE STORES IN MEMORY.
 THE APPLICATION CONTEXT HAS A LABEL CALLED A NAMESPACE, FOR EXAMPLE, EMPNO_CTX FOR AN APPLICATION CONTEXT THAT RETRIEVES EMPLOYEE IDS.
 INSIDE THE CONTEXT ARE THE NAME-VALUE PAIRS (AN ASSOCIATIVE ARRAY): 
 THE NAME POINTS TO A LOCATION IN MEMORY THAT HOLDS THE VALUE.
 AN APPLICATION CAN USE THE APPLICATION CONTEXT TO ACCESS SESSION INFORMATION ABOUT A USER,
 SUCH AS THE USER ID OR OTHER USER-SPECIFIC INFORMATION, OR A CLIENT ID, AND THEN SECURELY PASS THIS DATA TO THE DATABASE.
 YOU CAN THEN USE THIS INFORMATION TO EITHER PERMIT OR PREVENT THE USER FROM ACCESSING DATA THROUGH THE APPLICATION. 
 YOU CAN USE APPLICATION CONTEXTS TO AUTHENTICATE BOTH DATABASE AND NONDATABASE USERS.
 
 https://docs.oracle.com/cd/B28359_01/network.111/b28531/app_context.htm#DBSEG98149
 
conn sys as sysdba
Enter password:orcl
Connected.
SQL> GRANT CREATE SESSION, CREATE ANY CONTEXT, CREATE PROCEDURE, CREATE TRIGGER, ADMINISTER DATABASE TRIGGER TO sysadmin_ctx IDENTIFIED BY sysadmin_ctx;

Grant succeeded.

SQL>GRANT SELECT ON HR.EMPLOYEES TO sysadmin_ctx;

Grant succeeded.

SQL>GRANT EXECUTE ON DBMS_SESSION TO sysadmin_ctx;

Grant succeeded.

SQL> GRANT CREATE SESSION TO LOZER IDENTIFIED BY LOZER;

Grant succeeded.

SQL> conn sysadmin_ctx/sysadmin_ctx
Connected.
SQL> CREATE CONTEXT empno_ctx USING set_empno_ctx_pkg;

Context created.

SQL> CREATE OR REPLACE PACKAGE set_empno_ctx_pkg IS
  2     PROCEDURE set_empno;
  3   END;
  4   /

Package created.

SQL>  CREATE OR REPLACE PACKAGE BODY set_empno_ctx_pkg IS
  6     PROCEDURE set_empno
  7    IS
  8      emp_id NUMBER;
  9     BEGIN
  10      SELECT EMPLOYEE_ID INTO emp_id FROM HR.EMPLOYEES
  11         WHERE email = SYS_CONTEXT('USERENV', 'SESSION_USER');
  12     DBMS_SESSION.SET_CONTEXT('empno_ctx', 'employee_id', emp_id);
  13    EXCEPTION
  14     WHEN NO_DATA_FOUND THEN NULL;
  15    END;
  16   END;
  17  /

Package body created.

This package creates a procedure called set_empno that performs the following actions:

Line 8: Declares a variable, emp_id, to store the employee ID for the user who logs on.

Line 10: Performs a SELECT statement to copy the employee ID that is stored in the employee_id column data from the HR.EMPLOYEES table
 into the emp_id variable.

Line 11: Uses a WHERE clause to find all employee IDs that match the email account for the session user.
 The SYS_CONTEXT function uses the predefined USERENV context to retrieve the user session ID,
 which is the same as the email column data. For example, the user ID and email address for Lisa Ozer are both the same: lozer.

Line 12: Uses the DBMS_SESSION.SET_CONTEXT procedure to set the application context:

'empno_ctx': Calls the application context empno_ctx. Enclose empno_ctx in single quotes.

'employee_id': Creates the attribute value of the empno_ctx application context name-value pair,
 by naming it employee_id. Enclose employee_id in single quotes.

emp_id: Sets the value for the employee_id attribute to the value stored in the emp_id variable.
 The emp_id variable was created in Line 8 and the employee ID was retrieved in Lines 10–11.

To summarize, the set_empno_ctx_pkg.set_empno procedure says,
 "Get the session ID of the user and then match it with the employee ID and email address of any user listed in the HR.EMPLOYEES table."

Lines 13–14: Add a WHEN NO_DATA_FOUND system exception to catch any no data found errors that may result from the SELECT statement in Lines 10–11. 
(Without this exception, the package and logon trigger will work fine and set the application context as needed, 
but then any non-system administrator users other than the users listed in the HR.EMPLOYEES table will not be able to log in to the database.
 Other users should be able to log in to the database, assuming they are valid database users. 
 Once the application context information is set, then you can use this session information as a way to control user access to a particular application.)
 
Create a Logon Trigger for the Package
As user sysadmin_ctx, create the following trigger:
 
 SQL> CREATE TRIGGER set_empno_ctx_trig AFTER LOGON ON DATABASE
  2   BEGIN
  3    sysadmin_ctx.set_empno_ctx_pkg.set_empno;
  4   END;
  5  /

Trigger created.

Test the Application Context
Log on as user lozer.

CONNECT lozer
Enter password: password
When user lozer logs on, the empno_ctx application context collects her employee ID. You can check it as follows:

SELECT SYS_CONTEXT('empno_ctx', 'employee_id') emp_id FROM DUAL;
The following output should appear:

EMP_ID
--------------------------------------------------------
168
Log on as user SCOTT.

CONNECT SCOTT
Enter password: password
User SCOTT is not listed as an employee in the HR.EMPLOYEES table, so the empno_ctx application context cannot collect an employee ID for him.

SELECT SYS_CONTEXT('empno_ctx', 'employee_id') emp_id FROM DUAL;
The following output should appear:

EMP_ID
--------------------------------------------------------
From here, the application can use the user session information to determine how much access the user can have in the database.
 You can use Oracle Virtual Private Database to accomplish this.
 
 
 
 **************************************************************************************************************************
 7. To get the candidate table for gathering table stat. Ideally any table having value more than 8 is eligible..
 **************************************************************************************************************************
 select nvl(ROUND ( (DELETES + UPDATES + INSERTS) / NUM_ROWS * 100),0) , a.table_name from all_tab_modifications a , all_tables b
where a.table_name=b.table_name and b.owner='SMARTSTG';

*******************************************
8. --15 Days sql learning Code challenge.
*******************************************
	Julia conducted a  days of learning SQL contest. The start date of the contest was March 01, 2016 and the end date was March 15, 2016.
	Write a query to print total number of unique hackers who made at least  submission each day (starting on the first day of the contest),
	and find the hacker_id and name of the hacker who made maximum number of submissions each day.
	If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. 
	The query should print this information for each day of the contest, sorted by the date.

--CODE	
	select x.submission_date, (select count(distinct ls.hacker_id) from 
                           Submissions ls where x.rn = 
                           (select count(distinct q.submission_date) from Submissions q
                            where q.hacker_id = ls.hacker_id and q.submission_date <= x.submission_date)
                           ) as zz, h.hacker_id, h.name from
(select y.*,rownum as rn from (select submission_date,hacker_id, cnt,dense_rank() 
over(partition by submission_date 
order by cnt desc,hacker_id asc) rnk from(
select distinct submission_date,hacker_id,
count(hacker_id) over(partition by SUBMISSION_DATE,HACKER_ID ) cnt
from submissions
)) y where y.rnk=1) x inner join Hackers h on h.hacker_id = x.hacker_id
order by x.submission_date asc; 

***************************************************
--9. Fetching substr enclosed within <>
***************************************************
select * from test;
ID  ERR_ID 
1	<a>xyz<err:bc>wq
2	<err:a>xyz<bc>wq<err:c>pq
3	<1>x<err:vicky>rs

--Fetching all value within <>
select * from(SELECT distinct id,err_id
     , replace(replace(regexp_substr(err_id,'\<(.*?)\>',1,level,null),'<',''),'>','') err
   FROM test
   connect by level<=REGexp_COUNT(err_id,'>')) where err is not null
   order by 1;
   
ID  ERR_ID                      ERR   
1	<a>xyz<err:bc>wq	        err:bc
1	<a>xyz<err:bc>wq	        a
2	<err:a>xyz<bc>wq<err:c>pq	bc
2	<err:a>xyz<bc>wq<err:c>pq	err:a
2	<err:a>xyz<bc>wq<err:c>pq	err:c
3	<1>x<err:vicky>rs	        1
3	<1>x<err:vicky>rs	        err:vicky

--Fetching value having "err:" within <>
select * from(SELECT distinct id,err_id
     , replace(replace(regexp_substr(err_id,'\<([err].*?)\>',1,level,null),'<',''),'>','') err
   FROM test
   connect by level<=REGexp_COUNT(err_id,'>')) where err is not null
   order by 1; 
   
ID  ERR_ID                      ERR
1	<a>xyz<err:bc>wq	        err:bc
2	<err:a>xyz<bc>wq<err:c>pq	err:a
2	<err:a>xyz<bc>wq<err:c>pq	err:c
3	<1>x<err:vicky>rs	        err:vicky

--Fetching table name having specific column in the schema.
select  * from all_tab_columns where owner='APPS' and column_name like 'BILL_TO_LOCATION%';

--12c New Enhancements for SQL and PL/SQL
https://www.youtube.com/watch?v=PeXMOX1kxSU&t=763s
	a. Top-n Queries
	 SQL> select * from employees order by sal desc fetch first 5 rows only;
	 SQL> select * from employees order by sal desc fetch first 5 rows with ties; 	
	 SQL> select * from employees order by sal desc fetch first 3 percent rows only;
	 SQL> select * from employees order by sal desc offset 3 rows fetch next 5 rows only;
	
	b. Function/Procedure in WITH clause:
	
		with function f1(empid number) return varchar2 as
		name varchar2(25);
		begin
		select first_name into name from employees where employee_id=empid;
		return name;
		exception
		when others then return 'N/A';
		end;
		select f1(108) from dual;
		
--DATABASE File Location:
	select * from v$controlfile;
	select * from v$logfile;
	select * from v$datafile;

--Take a backup of control file	
	alter database backup controlfile to 'D:\Control_file_BKP\CF_20022018.ctl';
	
	
********************************************************************
14. Performance Tuning Approach
********************************************************************

1. Object Level:
	a. Indexes
	b. Partition Tables
	c. Partition Indexes
	d. Statistics Gathering (DBMS_STAT)
	
2. SQL Level:
	a. Explain Plan
	b. Function based Indexes
	c. Re write poor SQLs
	d. Join with precise data set, not the complete data (With Clause or Stage tables)
	e. Joining Order
	f. Correct Order in Filtering the Data (Appropriate sequence in Where Clause)
	g. Analytical functions in place of multiple sub queries.
	
3. PLSQL Level:
	a. Using appropriate DataTypes (pls_integer,binary_integer, binary_float, binary_double)
	b. Loops in Bulk Data Processing (Bulk Collect and Forall)
	c. Constant declaration and refering it at Multiple places.
	d. Efficient Loops: Making initialization outside the loop; Use of UNION ALL, CONNECT BY to get the desired dataset, instead of Looping.
	
************************************************************************
15. External Table
************************************************************************

create table ext_test(employee_id NUMBER,first_name varchar2(20),salary number,department_id number)
ORGANIZATION external(
TYPE oracle_loader
DEFAULT DIRECTORY ORA_DATA--ORA_DATA is my directory.
ACCESS PARAMETERS (
    RECORDS DELIMITED BY newline
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL
  )
LOCATION ('EMPLOYEE.csv')--This is my Flat file having same no of columns and sequence as defined in ext table.
)
PARALLEL 5
REJECT LIMIT UNLIMITED;--reject limit set the number of rejected records a data load can have.

***************************************************************************************************
16. Save Exception: Continuing the DML in case of errors and logging the error rows in error table.
***************************************************************************************************
Scenario: I have a source table "SRC_TAB" as below:
Name Null? Type         
---- ----- ------------ 
NAME       VARCHAR2(20) 
AGE        NUMBER       

Target table "TGT_TAB" as below:
Name Null?    Type         
---- -------- ------------ 
NAME NOT NULL VARCHAR2(20) 
AGE           NUMBER       

We have duplicate records in source table which can not inserted into target table because of Primary key.
I have an Error logging table where i will put this duplicate rows.

declare
    cursor C is select name,age from src_tab;
    type array is table of c%rowtype;
    l_data array;
    dml_errors EXCEPTION;
    PRAGMA exception_init(dml_errors, -24381);
    l_errors number;
    l_idx number;
begin
    open c;
    loop
        fetch c bulk collect into l_data limit 100;
        begin
            forall i in 1 .. l_data.count SAVE EXCEPTIONS
                insert into tgt_tab values l_data(i);
        exception
            when DML_ERRORS then
                l_errors := sql%bulk_exceptions.count;
				for i in 1 .. l_errors
				
                loop
				l_idx   := sql%bulk_exceptions(i).error_index;
                    insert into err_tab values( l_data(l_idx).name,l_data(l_idx).age);
                end loop;
        end;
        exit when c%notfound;
    end loop;
    close c;
end;
/

Alternate way:
---------------

BEGIN
for i in (select * from SRC_TAB) loop
begin
insert into TGT_TAB values(i.name,i.age);
exception
when others then
insert into err_tab values(i.name,i.age);
end;
end loop;
commit;
end;

Note: This can be done through 
exec DBMS_ERRLOG.create_error_log('src_tab');
desc ERR$_SRC_TAB; 
Name            Null? Type           
--------------- ----- -------------- 
ORA_ERR_NUMBER$       NUMBER         
ORA_ERR_MESG$         VARCHAR2(2000) 
ORA_ERR_ROWID$        UROWID         
ORA_ERR_OPTYP$        VARCHAR2(2)    
ORA_ERR_TAG$          VARCHAR2(2000) 
NAME                  VARCHAR2(4000) 
AGE                   VARCHAR2(4000) 

insert into hr.tgt_tab select * from hr.src_tab log errors reject limit unlimited;

UAN:100772448636
PF NO: MH/KND/43209/4173

17. Mule Soft Key Concepts:
***********************

For Each
Batch Process, Batch Size etc
Sctter Gather
Message Enricher
Async
CXF g WSC
Transformers
Ruby, Groovy
Java Component & Java Transformation
Data Weave

18. GUID()
****************************
This will generate GLOBALLY UNIQUE ID .
