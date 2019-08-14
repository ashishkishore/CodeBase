--REVERSE A STRING WITH THE USE OF COLLECTION

DECLARE
TYPE ABC IS TABLE OF VARCHAR2(1 BYTE);
ABCD ABC;
NM VARCHAR2(20);
CNT NUMBER;
BEGIN
ABCD:=ABC();
CNT:=LENGTH('ASHISH')+1;
FOR I IN 1..LENGTH('ASHISH SINHA')  LOOP
ABCD.EXTEND();
ABCD(I):=SUBSTR('ASHISH',I,1);
DBMS_OUTPUT.PUT_LINE(ABCD(I));
END LOOP;
FOR I IN 1..6 LOOP
CNT:=CNT-1;
NM:=CONCAT(NM,ABCD(CNT));
END LOOP;
DBMS_OUTPUT.PUT_LINE(NM);
END;


create or replace function rev(str varchar2)
return varchar2
is
type mytype is varray(100) of varchar2(1);
mt mytype;
nm varchar2(20);
nm1 varchar2(20);
cnt number:=length(str);
begin 
mt:=mytype();
for i in 1..length(str) loop
mt.extend;
mt(i):=substr(str,i,1);
nm:=concat(nm,mt(i));
end loop;
--dbms_output.put_line(nm);
for i in 1..length(str) loop
nm1:=concat(nm1,mt(cnt));
cnt:=cnt-1;
end loop;
--dbms_output.put_line(nm1||'=>'||nm);
return nm1;
end;

--Find first non-repeating character in the string
select * from (select lit,cnt,dense_rank() over(order by cnt) rnk from(
select substr('abcdeabc',level,1) lit,regexp_count('abcdeabc',substr('abcdeabc',level,1)) cnt from dual connect by level<9))
where rnk=1 and rownum<2;

--find whether a mathematical expression is balanced in terms of parenthesis
declare 
str varchar2(10):='(1+2)';
par varchar2(5);
cnt1 number:=0;
cnt2 number:=0;
begin
for i in 1..length(str) loop
par:=substr(str,i,1);
if par='(' then cnt1:=cnt1+1;
elsif par=')' then cnt2:=cnt2+1;
end if;
end loop;
if cnt1=cnt2 then
dbms_output.put_line('Balanced');
else
dbms_output.put_line('Not Balanced');
end if;
end;

--Implement power function n^m
declare 
n number:=3;
m number:=3;
res number;
begin
res:=n;
for i in 1..m-1 loop
res:=res*n;
end loop;
dbms_output.put_line(res);
end;

