create or replace PROCEDURE cims_transaction_set (p_env_code IN VARCHAR2, p_payload IN CLOB) IS
  v_extract XMLType;
  v_ns VARCHAR2(500);
  v_work XMLTYPE;
  v_meter XMLTYPE;
  v_node XMLTYPE;
  v_txn_id VARCHAR2(2);
  v_effective_ts TIMESTAMP WITH LOCAL TIME ZONE := NULL;
  v_meter_number VARCHAR2(11) := NULL;
  v_module_id VARCHAR2(10) := NULL;
  v_premise_Number VARCHAR2(20) := NULL;
  v_service_point_number VARCHAR2(20) := NULL;
  v_meter_point_number  VARCHAR2(20) := NULL;  
  v_effective_old TIMESTAMP WITH LOCAL TIME ZONE;
BEGIN
  dbms_output.put_line('Start');
  v_extract := XMLType(p_payload);
  v_ns := 'xmlns:msg="http://www.exeloncorp.com/Utility/Work/Message"
  xmlns:cbo="http://www.exeloncorp.com/services/WorkManagement/ConstructionAndDesign/UtilityWork.xsd"
  xmlns:iec="http://iec.ch/TC57/2011/schema/message"';
  v_work := v_extract.extract('/msg:UtilityWorkReqMsg/msg:Payload/cbo:UtilityWork/cbo:Work[1]', v_ns);
  --v_work := EXTRACTVALUE(p_payload, '/msg:UtilityWorkReqMsg/msg:Payload/cbo:UtilityWork/cbo:Work[1]', v_n);
  IF v_work IS NOT NULL
  THEN
    -- CIMS Transaction Code (i.e. AR or RA)
    v_node := v_work.extract('cbo:Work/cbo:type/text()', v_ns);
	
    IF v_node IS NOT NULL
    THEN
      v_txn_id := v_node.getStringVal();
      dbms_output.put_line('v_txn_id = '||v_txn_id);
    END IF;
    IF v_txn_id IN ('AR','RA')
    THEN
      v_node := v_work.extract('cbo:Work/cbo:requestDateTime/text()', v_ns);
      IF v_node IS NOT NULL
      THEN
        v_effective_ts := CAST(to_timestamp_tz(TRIM(v_node.getStringVal()),'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM') AS TIMESTAMP WITH LOCAL TIME ZONE);
        dbms_output.put_line('v_effective_ts = '||v_effective_ts);
      END IF;
      v_meter := v_work.extract('cbo:Work/cbo:ServiceLocations/cbo:ServiceLocation[1]/cbo:UsagePoints/cbo:UsagePoint[1]/cbo:Meters/cbo:Meter[cbo:status[cbo:name="action"]/cbo:value="info"]', v_ns);
      IF v_meter IS NOT NULL
	        THEN
         v_node := v_meter.extract('cbo:Meter/cbo:ProprietaryParameters/cbo:ProprietaryParameter[cbo:parameterName="badgeNumber"]/cbo:stringParameterValue/text()', v_ns);
         IF v_node IS NOT NULL
         THEN
           v_meter_number := v_node.getStringVal();
           dbms_output.put_line('v_meter_number = '||v_meter_number);
         END IF;
         v_node := v_meter.extract('cbo:Meter/cbo:ProprietaryParameters/cbo:ProprietaryParameter[cbo:parameterName="module"]/cbo:stringParameterValue/text()', v_ns);
         IF v_node IS NOT NULL
         THEN
           v_module_id := v_node.getStringVal();
           dbms_output.put_line('v_module_id = '||v_module_id);
         END IF;
                                v_node := v_work.extract('cbo:Work/cbo:ServiceLocations/cbo:ServiceLocation[1]/cbo:mRID/text()', v_ns);
         IF v_node IS NOT NULL
         THEN
           v_premise_number := v_node.getStringVal();
           dbms_output.put_line('v_premise_number = '||v_premise_number);
         END IF;
         v_node := v_work.extract('cbo:Work/cbo:ServiceLocations/cbo:ServiceLocation[1]/cbo:UsagePoints/cbo:UsagePoint[1]/cbo:mRID/text()', v_ns);
                                  IF v_node IS NOT NULL
         THEN
           v_service_point_number := v_node.getStringVal();
           dbms_output.put_line('v_service_point_number = '||v_service_point_number);
         END IF;
                                v_node := v_work.extract('cbo:Work/cbo:ServiceLocations/cbo:ServiceLocation[1]/cbo:UsagePoints/cbo:UsagePoint[1]/cbo:Meters/cbo:Meter/cbo:mRID/text()', v_ns);
         IF v_node IS NOT NULL
         THEN
           v_meter_point_number := v_node.getStringVal();
           dbms_output.put_line('v_meter_point_number = '||v_meter_point_number);
         END IF;
         -- Need to find the elemnt where premise number being populated and capture it to v_premise_number
         -- Create or Update the record
        BEGIN
        INSERT INTO cims_transaction (env_code, meter_number, txn_id, module_id, effective_ts, payload,premise_Number,service_point_Number,meter_point_number)
          VALUES (p_env_code, v_meter_number, v_txn_id, v_module_id, v_effective_ts, p_payload,v_premise_number,v_service_point_number,v_meter_point_number);
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
           SELECT effective_ts INTO v_effective_old
          FROM cims_transaction
           WHERE env_code = p_env_code AND meter_number = v_meter_number;
           IF v_effective_old IS NULL OR v_effective_old < v_effective_ts
           THEN -- Always replace with newer transactions
             UPDATE cims_transaction
            SET txn_id = v_txn_id, module_id = v_module_id, effective_ts = v_effective_ts, payload = p_payload,premise_number = v_premise_number,
                 status_flg = 'P', updated = SYSTIMESTAMP
             WHERE env_code = p_env_code AND meter_number = v_meter_number;
           END IF;
         END;
      END IF;
    END IF;
  END IF;
  --dbms_output.put_line('End');
END;
