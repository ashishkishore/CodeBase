create type subject_list is table of varchar2(20);
/
create table dept_nested_subjects(dept_name varchar2(20),hod_name varchar2(20),course_offered subject_list)
NESTED TABLE course_offered STORE AS SYS_GEN_TBL;
/

select * from DEPT_NESTED_SUBJECTS;

insert into DEPT_NESTED_SUBJECTS values('Arts','H.N.P',subject_list('history','geography','economics','plitical_sc'));

select * from DEPT_NESTED_SUBJECTS d,table(D.COURSE_OFFERED) s;
/

DECLARE
subjects subject_list;
begin
select name bulk collect into subjects from TEST_UPDATE_RELATION;
for i in subjects.first..subjects.last loop
dbms_output.put_line(subjects(i));
end loop;
end;