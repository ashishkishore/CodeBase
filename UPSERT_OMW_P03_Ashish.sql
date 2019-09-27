DECLARE


/*
*********************************************************************UPSERT-QUERY************************************************************************
DEVELOPED BY:   ASHISH KUMAR    VERSION    1.0     DATE: 25/09/2019 08:26 PM     PURPOSE: This will generate the SOAP Payload for particular Siebel Order 
*********************************************************************************************************************************************************
*/


 m_siebel_order_row_id 		VARCHAR2(100)	:= '1-1C8D4A8S';
 m_header_id 				NUMBER			:= NULL;
 m_copy_from_line_id 		VARCHAR2(50) 	:= '';
 m_ctr 						NUMBER 			:= 1;
 m_ns 						VARCHAR2(50) 	:= 'asi';
 v_final 					CLOB;

TYPE t1 IS RECORD(
 BackOfficeProcess 			VARCHAR2(4000),
 HeaderId 					VARCHAR2(4000),
 ora_order_number         	VARCHAR2(4000),
 Hdr_CurrencyCode        	VARCHAR2(4000),
 EAISyncDate       			VARCHAR2(4000),
 Freight         			VARCHAR2(4000),
 Hdr_HoldFlag         		VARCHAR2(4000),
 Id         				VARCHAR2(4000),
 Status        				VARCHAR2(4000),
 Hdr_TaxAmount        		VARCHAR2(4000),
 StatusContext        		VARCHAR2(4000),
 BasePrice        			VARCHAR2(4000),
 ChangeReason        		VARCHAR2(4000),
 PackageName        		VARCHAR2(4000),
 FulfillmentSet        		VARCHAR2(4000),
 OverrideUpperTolerance     VARCHAR2(4000),
 OverrideLowerTolerance     VARCHAR2(4000),
 QuantityShipped        	VARCHAR2(4000),
 OracleLineStatus        	VARCHAR2(4000),
 AccountingRule        		VARCHAR2(4000),
 OntimeShippingTracker      VARCHAR2(4000),
 FreightTerms        		VARCHAR2(4000),
 freight_terms_code        	VARCHAR2(4000),
 IncoTerms        			VARCHAR2(4000),
 CarrierCode        		VARCHAR2(4000),
 Line_CurrencyCode        	VARCHAR2(4000),
 ExtendedQuantity        	VARCHAR2(4000),
 FreightAmount        		VARCHAR2(4000),
 LineType        			VARCHAR2(4000),
 OracleLineNumber        	VARCHAR2(4000),
 OracleLineId        		VARCHAR2(4000),
 SEBL_VALUE        			VARCHAR2(4000),
 OracleParentLineId        	VARCHAR2(4000),
 NetPrice        			VARCHAR2(4000),
 Qty        				VARCHAR2(4000),
 SourceInventoryLocation   	VARCHAR2(4000),
 Line_TaxAmount        		VARCHAR2(4000),
 lfsc        				VARCHAR2(4000),
 UnitPrice        			VARCHAR2(4000),
 UnitofMeasure        		VARCHAR2(4000),
 ScheduledShipDate        	VARCHAR2(4000),
 Line_HoldFlag        		VARCHAR2(4000),
 ora_request_date        	VARCHAR2(4000),
 Line_Row_id        		VARCHAR2(4000),
 Line_Status        		VARCHAR2(4000),
 ConversionFactor        	VARCHAR2(4000),
 ExtendedUOMQty        		VARCHAR2(4000),
 QuantityRequested        	VARCHAR2(4000));
 
TYPE t2 IS TABLE OF t1;
 
crec t2;
 
v0 CLOB:='With 
SOL as(select ROW_ID Line_Row_id,X_ZEB_UOM_FACTOR from SIEBEL.S_ORDER_ITEM@AIA_TO_CRM
where row_id in(';

v1 CLOB;

main_cur SYS_REFCURSOR;

CURSOR c1(p1 number) IS
SELECT 'select '''||(SELECT value FROM otc_xref.xref_data
                     WHERE xref_table_name ='oramds:/apps/AIAMetaData/xref/SALESORDER_LINEID.xref'
                     AND   xref_column_name='SEBL_01'
                     AND row_number=(SELECT row_number FROM otc_xref.xref_data
                     WHERE xref_table_name ='oramds:/apps/AIAMetaData/xref/SALESORDER_LINEID.xref'
                     AND   xref_column_name='EBIZ_01'
                     AND  value=to_char(OV.LINE_ID)))||''' from dual@aia_to_crm union ' as sebl_value
FROM apps.zeb_otc_order_synch_v@aia_to_erp  OV
WHERE OV.HEADER_ID= p1;

v2 CLOB:=Q'[)),
   header_line as(select /*+DRIVING_SITE(apps.zeb_otc_order_synch_v)*/
  'Created in Back Office'    BackOfficeProcess,
  OV.HEADER_ID                HeaderId,
  OV.ORDER_NUMBER             ora_order_number,
  OV.HEADER_CURRENCY_CODE     Hdr_CurrencyCode,   
  to_char(sysdate,'MM/DD/YYYY HH24:MI:SS') EAISyncDate,
  OV.HEADER_FREIGHT           Freight,   
  OV.HEADER_HOLD_FLAG         Hdr_HoldFlag,']';
  
v3 CLOB:=Q'['               Id,
  (select LOVH.DESC_TEXT  from     SIEBEL.S_LST_OF_VAL@AIA_TO_CRM   LOVH
  where   LOVH.TYPE='ZEB_AIA_ORDER_STATUS'
  AND   LOVH.NAME =OV.HEADER_STATUS_CODE ) Status,
  OV.HEADER_TAX               Hdr_TaxAmount, 
  ''                          StatusContext,
  decode(OV.LINE_FLOW_STATUS_CODE,'CANCELLED',0,null) BasePrice,
  decode(OV.CHANGE_REASON,
         'Administrative or procedural error','Admin or procedural error',
         'Release Accounting Cancellation','Release Acct Cancellation',
         'Internal requisition initiated change','Internal req initiated change',
         OV.CHANGE_REASON)    ChangeReason,
  OV.SHIP_SET                 PackageName,
  OV.FULFILLMENT_SET          FulfillmentSet,
  OV.SHIP_TOLERANCE_ABOVE     OverrideUpperTolerance,
  OV.SHIP_TOLERANCE_BELOW     OverrideLowerTolerance,
  round(OV.SHIPPED_QUANTITY,0)          QuantityShipped,
  OV.LINE_FLOW_STATUS_MEANING  OracleLineStatus,
  OV.ACCOUNTING_RULE_ID        AccountingRule,
  to_char(OV.SCHEDULE_SHIP_DATE,'DD-MON-YYYY')||'-'||CHANGE_REASON  OntimeShippingTracker,
  nvl(OV.FREIGHT_TERMS,(select f.meaning
                        from apps.FND_LOOKUP_VALUES_VL@aia_to_erp f
                        where f.lookup_type = 'FREIGHT_TERMS'
                        and f.enabled_flag = 'Y'
                        and f.lookup_code = oelb.freight_terms_code))  FreightTerms,
  oelb.freight_terms_code,                            
  nvl(OV.INCOTERMS,oelb.TP_ATTRIBUTE7)                 IncoTerms,
  OV.SHIP_METHOD               CarrierCode,
  OV.HEADER_CURRENCY_CODE      Line_CurrencyCode,
  round(OV.ORDERED_QUANTITY,0)          ExtendedQuantity,
  OV.LINE_FREIGHT              FreightAmount,
  OV.LINE_TYPE                 LineType,
  OV.LINE_NUMBER               OracleLineNumber,
  OV.LINE_ID                   OracleLineId,
  (select value from otc_xref.xref_data
                     where xref_table_name ='oramds:/apps/AIAMetaData/xref/SALESORDER_LINEID.xref'
                     AND   xref_column_name='SEBL_01'
                     and row_number=(select row_number from otc_xref.xref_data
                     where xref_table_name ='oramds:/apps/AIAMetaData/xref/SALESORDER_LINEID.xref'
                     AND   xref_column_name='EBIZ_01'
                     and  value=to_char(OV.LINE_ID))) SEBL_VALUE,
  OV.TOP_MODEL_LINE_ID         OracleParentLineId,
  decode(OV.LINE_FLOW_STATUS_CODE,'CANCELLED',0,null) NetPrice,
  round(OV.ORDERED_QUANTITY,0)          Qty,
  OV.INVENTORY_ORG             SourceInventoryLocation,
  OV.LINE_TAX                  Line_TaxAmount,
  OV.LINE_FLOW_STATUS_CODE  lfsc,
  decode(OV.LINE_FLOW_STATUS_CODE,'CANCELLED',0,null) UnitPrice,
  OV.UNIT_OF_MEASURE             UnitofMeasure,
  decode(OV.SCHEDULE_SHIP_DATE,null,'',to_char(OV.SCHEDULE_SHIP_DATE,'MM/DD/YYYY')||' 09:00:00')  ScheduledShipDate,
  OV.LINE_HOLD_FLAG            Line_HoldFlag,
  decode(OV.REQUEST_DATE,null,'',to_char(OV.REQUEST_DATE,'MM/DD/YYYY')) ora_request_date             
 from
    apps.zeb_otc_order_synch_v@aia_to_erp  OV,
    apps.oe_order_lines_all@aia_to_erp oelb
 where  OV.HEADER_ID=]';

v4 CLOB:=Q'[ and   OV.top_model_line_id = oelb.line_id(+)),
  AIA_to_CRM as(
  select /*+DRIVING_SITE(SIEBEL.S_LST_OF_VAL)*/
  hl.*,
  SOL.Line_Row_id,
  LOVL.DESC_TEXT Line_Status,
  SOL.X_ZEB_UOM_FACTOR ConversionFactor,
  (hl.Qty * SOL.X_ZEB_UOM_FACTOR )    ExtendedUOMQty,
  (hl.Qty * SOL.X_ZEB_UOM_FACTOR )    QuantityRequested
  from 
      header_line hl left join sol on hl.sebl_value=sol.line_row_id
      left join SIEBEL.S_LST_OF_VAL@AIA_TO_CRM  LOVL on LOVL.NAME =decode(hl.lfsc,'INVOICE_HOLD','INVOICED',hl.lfsc)
      where 
      LOVL.TYPE='ZEB_AIA_ORDER_STATUS'
   )
  select * from aia_to_crm]';

  PROCEDURE log_msg (p_msg IN VARCHAR2)
  IS
  BEGIN
     dbms_output.put_line(p_msg);
  END;
 
  PROCEDURE log_msg (p_tag IN VARCHAR2, p_msg IN VARCHAR2)
  IS
  BEGIN
       log_msg ('<'||m_ns||':'||p_tag||'>'||replace(p_msg,chr(38),chr(38)||'amp;')||'</'||m_ns||':'||p_tag||'>');
  END;
 
  PROCEDURE log_msg (p_tag IN VARCHAR2, p_msg IN VARCHAR2, p_ignore_null IN VARCHAR2)
  IS
  BEGIN
    IF p_msg IS NOT NULL
    THEN
       log_msg (p_tag,p_msg);
    END IF;
  END;
  
BEGIN

  SELECT to_number(a.value)  INTO m_header_id
  FROM  otc_xref.xref_data A,
        otc_xref.xref_data B
  WHERE A.xref_table_name ='oramds:/apps/AIAMetaData/xref/SALESORDER_ID.xref'
  AND   A.xref_column_name='EBIZ_01'
  AND   A.row_number = B.row_number 
  AND   B.xref_table_name ='oramds:/apps/AIAMetaData/xref/SALESORDER_ID.xref'
  AND   B.xref_column_name='SEBL_01'
  and   B.VALUE = m_siebel_order_row_id;
  
 FOR i IN c1(m_header_id) 
	LOOP
	v1:=v1||i.sebl_value||chr(13);
	END LOOP;
	
 v1:=substr(v1,1,length(v1)-7);

 v_final:=v0||v1||v2||m_siebel_order_row_id||v3||m_header_id||v4;

 OPEN main_cur FOR v_final;
 
	FETCH main_cur BULK COLLECT INTO crec; 
		
		FOR i IN crec.first..crec.last LOOP
			if m_ctr = 1
				then
				log_msg ('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:asi="http://siebel.com/asi" xmlns:data="http://siebel.com/OrderManagement/Order/Data">');
				log_msg ('<soapenv:Header/>');
				log_msg ('<soapenv:Body>');
				log_msg ('  ');
				log_msg ('<asi:SWIOrderUpsert_Input>');
				log_msg ('<asi:ListOfSWIOrderIO xmlns:sbldata="http://siebel.com/OrderManagement/Order/Data">');
				log_msg ('  ');
				log_msg ('<asi:SWIOrder>');
				log_msg ('BackOfficeProcessStatus',crec(i).BackOfficeProcess);
				log_msg ('CurrencyCode',crec(i).Hdr_CurrencyCode);
				log_msg ('EAISyncDate',crec(i).EAISyncDate);
				log_msg ('HoldFlag',crec(i).Hdr_HoldFlag);
				log_msg ('Id',crec(i).Id);
				log_msg ('SubmitLockFlag','N');
				log_msg ('Status',crec(i).Status,'Y');
				log_msg ('TaxAmount',crec(i).Hdr_TaxAmount);
				log_msg ('StatusContext',crec(i).StatusContext);
				log_msg ('<asi:ListOfSWIOrderItem>');
			end if;
			
				m_ctr := m_ctr + 1;
				
				log_msg ('  ');
				log_msg ('<asi:SWIOrderItem>');
				if nvl(m_copy_from_line_id,'x') != crec(i).Line_Row_id
					then
					log_msg('BasePrice',crec(i).BasePrice,'Y');
				end if;
					
				log_msg('ChangeReason',crec(i).ChangeReason);
				log_msg('PackageName',crec(i).PackageName);
				log_msg('FulfillmentSet',crec(i).FulfillmentSet);
				log_msg('OverrideUpperTolerance',crec(i).OverrideUpperTolerance);
				log_msg('OverrideLowerTolerance',crec(i).OverrideLowerTolerance);
				log_msg('QuantityShipped',crec(i).QuantityShipped);
				log_msg('OracleLineStatus',crec(i).OracleLineStatus);
				log_msg('AccountingRule',crec(i).AccountingRule);
				log_msg('OntimeShippingTracker',crec(i).OntimeShippingTracker);
				log_msg('FreightTerms',crec(i).FreightTerms);
				log_msg('IncoTerms',crec(i).IncoTerms);
				log_msg('CarrierCode',crec(i).CarrierCode,'Y');
				log_msg('CurrencyCode',crec(i).Line_CurrencyCode);
				log_msg('ExtendedQuantity',crec(i).ExtendedQuantity);
				log_msg('FreightAmount',crec(i).FreightAmount);
				log_msg('Id',crec(i).Line_Row_id);
				log_msg('LineType',crec(i).LineType);
				log_msg('OracleLineNumber',crec(i).OracleLineNumber);
				log_msg('OracleLineId',crec(i).OracleLineId);
				log_msg('OracleParentLineId',crec(i).OracleParentLineId);
				
				if nvl(m_copy_from_line_id,'x') != crec(i).Line_Row_id
					then
					log_msg('NetPrice',crec(i).NetPrice,'Y');
				end if;
			
				log_msg('Qty',crec(i).Qty);
				log_msg('SourceInventoryLocation',crec(i).SourceInventoryLocation,'Y');
				log_msg('Status',crec(i). Line_Status);
				log_msg('TaxAmount',crec(i).Line_TaxAmount);
				
				if nvl(m_copy_from_line_id,'x') != crec(i).Line_Row_id
					then
					log_msg('UnitPrice',crec(i).UnitPrice,'Y');
				end if;
			
				log_msg('UnitofMeasure',crec(i).UnitofMeasure);
				log_msg('ScheduledShipDate',crec(i).ScheduledShipDate);
				log_msg('HoldFlag',crec(i).Line_HoldFlag);
				log_msg('ConversionFactor',crec(i).ConversionFactor);
				log_msg('ExtendedUOMQty',crec(i).ExtendedUOMQty);
				log_msg('QuantityRequested',crec(i).QuantityRequested);
				
				if nvl(m_copy_from_line_id,'x') = crec(i).Line_Row_id
					then
					log_msg (' ');
					log_msg('DueDate',crec(i).ora_request_date);
					
					for copyrec in (select
								X_ZEB_UOM_FACTOR,
								BASE_UNIT_PRI,
								UNIT_PRI,
								X_ZEB_OVERRIDE_REASON,
								X_ZEB_RESTOCK_FEE,
								X_ZEB_PC_ID,
								PROMOTION_ID,
								X_ZEB_FULFILLMENT_SET,
								X_ZEB_UPPER_TOLR,
								X_ZEB_LOWER_TOLR,
								X_ZEB_RETURN_LN_ID,
								X_ZEB_REFORDERLINEID,
								X_ZEB_FINAL_DESTINATION,
								X_PORT_OF_LOADING,
								X_ZEB_PORTOFDESTINATION,
								X_ZEB_BLIND_PAPERWORK,
								X_ZEB_CUST_SUPPLIED_PAPERWORK,
								X_ZEB_FOB,
								FRGHT_TERMS_CD,
								X_ZEB_FOB_INCOTERMS,
								ITEM_GROUP_NAME,
								X_ZEB_UOM,
								ADJ_UNIT_PRI,
								X_ZEB_NET_PRICE,
								NET_PRI,
								PROD_ID,
								SHIP_OU_ID,
								SHIP_ADDR_ID
							from siebel.s_order_item@aia_to_crm
							where row_id = m_copy_from_line_id)
					loop
			
					log_msg('ProductId',copyrec.PROD_ID);
					log_msg('ShipToAccountId',copyrec.SHIP_OU_ID);
					log_msg('ShipToAddressId',copyrec.SHIP_ADDR_ID);
					log_msg('BasePrice',   copyrec.BASE_UNIT_PRI,'Y');
					log_msg('UnitPrice',   copyrec.UNIT_PRI,'Y');
					log_msg('NetPrice',   copyrec.NET_PRI,'Y');
					log_msg('OverrideReason', copyrec.X_ZEB_OVERRIDE_REASON);
					log_msg('RestockFee',copyrec.X_ZEB_RESTOCK_FEE);
					log_msg('PCLineId',copyrec.X_ZEB_PC_ID);
					log_msg('ProdPromId',copyrec.PROMOTION_ID);
					log_msg('FinalDestination',copyrec.X_ZEB_FINAL_DESTINATION);
					log_msg('PortofLoading',copyrec.X_PORT_OF_LOADING);
					log_msg('PortofDestination',copyrec.X_ZEB_PORTOFDESTINATION);
					log_msg('BlindPaperwork',copyrec.X_ZEB_BLIND_PAPERWORK);
					log_msg('CustomerSuppliedPaperwork',copyrec.X_ZEB_CUST_SUPPLIED_PAPERWORK);
					log_msg('FOB',copyrec.X_ZEB_FOB);
					log_msg('AdjustedListPrice',copyrec.ADJ_UNIT_PRI);
					log_msg('StandardNetPrice',copyrec.X_ZEB_NET_PRICE);
				
					end loop;         
					end if;
			
					log_msg ('</asi:SWIOrderItem>');
				
				end loop;
				log_msg ('  ');
				log_msg('</asi:ListOfSWIOrderItem>');
				log_msg ('</asi:SWIOrder>');
				log_msg ('</asi:ListOfSWIOrderIO>');
				log_msg ('</asi:SWIOrderUpsert_Input>');
				log_msg ('  ');
				log_msg ('</soapenv:Body>');
				log_msg ('</soapenv:Envelope>');
 
CLOSE main_cur;

END;
