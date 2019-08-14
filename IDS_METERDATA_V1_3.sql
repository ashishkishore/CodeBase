CREATE OR REPLACE PROCEDURE IDS_METERDATA(
p_PayLoad CLOB,
p_Status OUT VARCHAR2,
p_Message OUT VARCHAR2)
AS
/*
* File Name: IDS_METERDATA.sql
* Purpose: This Procedure is used for handling request received from Consumers and inserting a Record in IDS/CDW DataHub
*******************************************VERSIONING****************************************************************************
Sno.    Date       Version No.    Author          Comments
---------------------------------------------------------------------------------------------------------------------------------
1.    2018-09-07   1.0            Ashish Kumar     -- 
2.    2018-09-12   1.1            Ashish Kumar     Removed OP-Metric Table for Logging. Now sending p_Status to log in CLEH.
3.    2018-10-01   1.2            Ashish Kumar     Removed Group By while parsing the XML.OSB is passing Comma seperated Value with Count Tag.
4.    2018-10-03   1.3            Ashish Kumar     Incorporated Input Data Validation. 
*/
VALIDATION_STATUS varchar2(1000):='';
SUCCESS_CNT number:=0;
FAIL_CNT number:=0;
F_MESSAGE varchar2(4000);
			CURSOR C1 IS	WITH VALIDATION AS 
			(select 'SP' RequestType,'ACCOUNT' Name, 200 MaxOccur from dual
				union
				select 'AB' RequestType,'ACCOUNT' Name, 1000 MaxOccur from dual
				union
				select 'SP' RequestType,'METER' Name, 10000 MaxOccur from dual
				union
				select 'AB' RequestType,'METER' Name, 50000 MaxOccur from dual
				union
				select 'SP' RequestType,'ZIPCODE' Name, 400 MaxOccur from dual
				union
				select 'AB' RequestType,'ZIPCODE' Name, 400 MaxOccur from dual
				union
				select 'SP' RequestType,'RATE' Name, 1000 MaxOccur from dual
				union
				select 'AB' RequestType,'RATE' Name, 1000 MaxOccur from dual
				union
				select 'SP' RequestType,'Revenue Class' Name, 300 MaxOccur from dual
				union
				select 'AB' RequestType,'Revenue Class' Name, 300 MaxOccur from dual),
				DATA as (SELECT 
				RequestID,
				Consumer,
				TO_DATE(SUBSTR(RequestStartDTTM,1,INSTR(RequestStartDTTM,'T',1)-1),'yyyy-mm-dd') RequestStartDTTM,
				IBStartDT,
				IBEndDT,
				RequestType,
				SubscriberID,
				IncludePIIDataFlag,
				IntervalDataQuality,
				Frequency,
				TO_DATE(SUBSTR(RequestEndDTTM,1,INSTR(RequestEndDTTM,'T',1)-1),'yyyy-mm-dd') RequestEndDTTM,
				AMIMeterFlag,
				PTSEnrolledFlag,
				name value_type,
				value value_clob,
				Count value_count	
			FROM 
				xmltable('IDS_Request_MeterDataRequest/UsageDataRequest' passing xmltype(p_PayLoad)
				columns
				RequestID VARCHAR2(100 BYTE) path 'RequestID',
				Consumer VARCHAR2(100 BYTE) path 'Consumer',
				RequestStartDTTM varchar2(35 BYTE) path 'RequestStartDTTM',
				IBStartDT DATE path 'IBStartDT',
				IBEndDT DATE path 'IBEndDT',
				RequestType VARCHAR2(50 BYTE) path 'RequestType',
				SubscriberID VARCHAR2(100 BYTE) path 'SubscriberID',
				IncludePIIDataFlag VARCHAR2(1 BYTE) path 'IncludePIIDataFlag',
				IntervalDataQuality VARCHAR2(2 BYTE) path 'IntervalDataQuality',
				Frequency VARCHAR2(20 BYTE) path 'Frequency',
				RequestEndDTTM varchar2(35 BYTE) path 'RequestEndDTTM',
				AMIMeterFlag VARCHAR2(1 BYTE)	path 'AMIMeterFlag',
				PTSEnrolledFlag VARCHAR2(1 BYTE) path 'PTSEnrolledFlag'	,
				CustomField xmltype path 'CustomField') a,
					xmltable('CustomField' passing a.CustomField columns
					Name varchar2(50) path '/CustomField/Name',
					Value clob path '/CustomField/Value',
					Count number path '/CustomField/Count'))
         SELECT 
				RequestID,
				Consumer,
				RequestStartDTTM,
				IBStartDT,
				IBEndDT,
				DATA.RequestType,
				SubscriberID,
				IncludePIIDataFlag,
				IntervalDataQuality,
				Frequency,
				RequestEndDTTM,
				AMIMeterFlag,
				PTSEnrolledFlag,
				name value_type,
				value_clob,
				value_count,
				VALIDATION.RequestType val_RequestType,
				Name Name,
				MaxOccur
			FROM DATA INNER JOIN VALIDATION
         ON DATA.value_type=VALIDATION.name and DATA.RequestType=VALIDATION.RequestType;
    BEGIN
      FOR I IN C1 LOOP
        IF i.value_count>i.MaxOccur THEN
         VALIDATION_STATUS:=VALIDATION_STATUS||','||I.VALUE_TYPE;
		 FAIL_CNT:=FAIL_CNT+1;
		ELSE
		 BEGIN
			INSERT 	INTO CDM.DFL_RQST_CNTL_HDR
			(REQUEST_ID,
			CONSUMER,
			REQUEST_DATE,
			IB_START_DATE,
			IB_END_DATE,
			REQUEST_TYPE,
			SUBSCRIBER_ID,
			PII_FLAG,
			BA_OR_BL,
			FREQUENCY,
			REQST_END_DT,
			REV_CLASS,
			TARIFF_RATE_TYP,
			AMI_FLAG,
			PTS_ENROLLED_FLAG,
			VALUE_CLOB,
			VALUE_TYPE,
			VALUE_COUNT)
			VALUES
			( 
			I.RequestID,
			I.Consumer,
		    I.RequestStartDTTM,
		    I.IBStartDT,
		    I.IBEndDT,
		    I.RequestType,
		    I.SubscriberID,
		    I.IncludePIIDataFlag,
		    I.IntervalDataQuality,
		    I.Frequency,
		    I.RequestEndDTTM,
			case when I.value_type='Revenue Class' then I.value_clob else null end ,
			case when I.value_type='RATE' then I.value_clob else null end ,
		    I.AMIMeterFlag,
		    I.PTSEnrolledFlag,
		    case when I.value_type in ('ACCOUNT','METER','ZIPCODE') then I.value_clob else null end ,
			case when I.value_type in ('ACCOUNT','METER','ZIPCODE') then I.value_type else null end ,
		    case when I.value_type in ('ACCOUNT','METER','ZIPCODE') then I.value_count else null end 
			);
			
			COMMIT;
			
			SUCCESS_CNT:=SUCCESS_CNT+1;
      
				
			EXCEPTION
				WHEN OTHERS THEN
				FAIL_CNT:=FAIL_CNT+1;
				F_MESSAGE:=F_MESSAGE||' '||SQLERRM;
				
			END;
         END IF;
        END LOOP; 
		 
		IF SUCCESS_CNT>0 AND FAIL_CNT=0 THEN
		    p_Status:='SUCCESS';
			p_Message:='Record Loaded Successfully';
		ELSIF SUCCESS_CNT=0 AND FAIL_CNT>0 THEN
			p_Status:='FAILED';
			p_Message:=f_Message;
		ELSE 
			p_Status:='PARTIAL SUCCESS :'||'Field violated Validation rule for either Min occurence Or Max Occurence.FieldName - '||substr(VALIDATION_STATUS,2) ;
			p_Message:='PARTIAL SUCCESS';
		END IF;		
		 
        
    END;
    
    grant execute on ids_meterdata to mw;