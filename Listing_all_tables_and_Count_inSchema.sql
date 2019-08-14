create or replace procedure get_count(table_name varchar2) as
cnt number:=0;
begin
execute immediate 'select count(*) from '||table_name into cnt;
dbms_output.put_line(rpad(upper(table_name),20,' ')||': '||cnt);
end;
/

declare
cursor c1 is
select distinct table_name from all_tab_columns where owner='HR' order by 1;
begin
for i in c1 loop
get_count(i.table_name);
end loop;
end;
/
