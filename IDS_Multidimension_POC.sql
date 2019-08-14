create or replace package ComED_Mangd_IDS as
type val_list is table of varchar2(50);
type cus_rec is record (name varchar2(50),value val_list);
type rec is record ( RequestID varchar2(100),
RequestType varchar2(100),
RequestStartDTTM varchar2(100),
IBStartDT varchar2(100),
IBEndDT varchar2(100),
Consumer varchar2(100),
SubscriberID varchar2(100),
IntervalDataQuality varchar2(100),
CustomField cus_rec);
 procedure insert_ids_data(p1 rec);
 end;
 /
 
create or replace package body ComED_Mangd_IDS as
procedure insert_ids_data(p1 rec)
as
begin
for j in p1.CustomField.value.first..p1.CustomField.value.last loop
insert into ids values (
p1.RequestID,
p1.RequestType ,
p1.RequestStartDTTM ,
p1.IBStartDT ,
p1.IBEndDT ,
p1.Consumer ,
p1.SubscriberID ,
p1.IntervalDataQuality ,
to_clob('Ashish'), 
p1.CustomField.name ,
p1.CustomField.value(j));
end loop;

end insert_ids_data;
end ComED_Mangd_IDS;
/

declare
inp1 ComED_Mangd_IDS.rec;
v1 ComED_Mangd_IDS.val_list:=ComED_Mangd_IDS.val_list();
v2 ComED_Mangd_IDS.cus_rec;
begin
select salary bulk collect into v1 from employees where rownum<5;
v2.name:='RATE';
v2.value:=v1;
inp1.RequestID:='777';
inp1.RequestType :='777';
inp1.RequestStartDTTM :='777';
inp1.IBStartDT :='777';
inp1.IBEndDT :='777';
inp1.Consumer :='777';
inp1.SubscriberID :='777';
inp1.IntervalDataQuality :='777';
inp1.CustomField:=v2;
ComED_Mangd_IDS.insert_ids_data(inp1);
dbms_output.put_line('Bingo!!!');
end;
