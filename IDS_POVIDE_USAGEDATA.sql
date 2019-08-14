create or replace procedure IDS_Provide_UsageData
(CacheFunctionality boolean default TRUE,
CacheQueueTable_valid boolean,
CacheQueueTable_hiulookup_data ref cursor default null,
DataHubSchemaNm varchar2(100) default NULL,
DataHubSourceNm varchar2(100) default NULL,
requestid varchar2(30),
requesttype varchar2(30),
requeststartdttm timestamp,
requestenddttm timestamp,
subscriberid varchar2(30),
consumer varchar2(50),
includepiidataflag varchar2(5),
ibstartdt date,
ibenddt date,
intervaldataquality varchar2(30),
frequency varchar2(30),
amimeterflag varchar2(5),
ptsenrolledflag varchar2(5))
is
inRootComplexRef ref cursor;
inSubRootRef ref cursor;
Environment_Variables_TransactionID varchar2(30):=nvl(request_id,'N/A');
Environment_Variables_LookUp_Data ref cursor;
var_Environment_Variables_LookUp_Data Environment_Variables_LookUp_Data%rowtype;
begin

logMessage(Environment_Variables_TransactionID,'SOAP request received for RequestType : '
		|| RequestType,flowLogLevel,'INFO');

IF CacheFunctionality = TRUE THEN		
	if CacheQueueTable_valid is null or CacheQueueTable_hiulookup_data is null ten
	open CacheQueueTable_hiulookup_data for select * from Database.VALIDATION_IDS;
	CacheQueueTable.valid := TRUE;
	else 
	open CacheQueueTable_hiulookup_data for select * from Database.VALIDATION_IDS;
end if;

IF requesttype is null or requesttype is '' then
raise_application_error(-3010,'A SOAP fault occured. Fault Message : RequestType is Missing in the SOAP message');
else
open Environment_Variables_LookUp_Data for select * from Database.VALIDATION_IDS v where v.requesttype=requesttype;
end if;

logMessage(Environment_Variables_TransactionID,'Inserting data in MW Operational metrics table'
		|| RequestType,flowLogLevel,'INFO');
		
INSERT INTO OPR_CTRL_RES_IDS
		(REQ_KEY,
		RQST_ID,
		SUBSCRIBER_ID,
		CONSUMER,
		RQST_TYPE,
		RQST_DTTM,
		MSG_GET_DTTM,
		PII_FLAG,
		REQ_STATUS)
		VALUES
	(seq.nextval,
	Environment_Variables_TransactionID,
		NVL(SubscriberID,'NA'),
		NVL(Consumer,'NA'),
		NVL(RequestType, 'NA'),
		requestStartDTTM,
		CURRENT_TIMESTAMP,
		IncludePIIDataFlag,
		'RECEIVED'
	);	
	commit;
	
logMessage(Environment_Variables_TransactionID,'Validating input message against lookup table - Start Loop',
		flowLogLevel,'INFO');

loop
fetch Environment_Variables_LookUp_Data	into var_Environment_Variables_LookUp_Data;
exit when Environment_Variables_LookUp_Data%notfound;
vfieldName:=CAST(var_Environment_Variables_LookUp_Data.FIELDNAME AS CHARACTER);

logMessage(Environment_Variables_TransactionID,'Validating input message for field - ' || var_Environment_Variables_LookUp_Data.FIELDNAME,
		flowLogLevel,'DEBUG');

if var_Environment_Variables_LookUp_Data.iscomplex='Yes' then
rootXpath:=substr(var_Environment_Variables_LookUp_Data.xpath,1,(instr(var_Environment_Variables_Liikup_data.xpath,'.',1)-1));
		
