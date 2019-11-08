public without sharing class LWCimportFile {
    
	public List<Case_Z> caseZ {get;set;} // in json: case

	public LWCimportFile(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'case') {
						caseZ = arrayOfCase_Z(parser);
					} else {
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Case_Z {
    

        
		public String caseRecordType {get;set;} 
		public String accountACN  {get;set;} 
		public String serials  {get;set;} 
		public String issueName  {get;set;} 
		public String requestType  {get;set;} 
		public String caseCategory {get;set;} 
		public String priority {get;set;} 
		public String fSDispenserType {get;set;} 
		public String issueCategories {get;set;} 
		public String issueDetails {get;set;} 
		public String status {get;set;} 
		public String comment {get;set;} 
		public String subStatus {get;set;} 
		public String projectId {get;set;} 
		public String projectBatchId {get;set;} 
		public String projectBatchDate {get;set;} 

		public Case_Z(JSONParser parser) {
            //Parse the json and store them in respective variables
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Case Record Type') {
							caseRecordType = parser.getText();
						} else if (text == 'Account ACN') {
                            //adding 000 as it will not take leading zeroes in excel by default 
							accountACN  = parser.getText();
                            String zeroes='';
                            Integer acn0stoAdd =10-accountACN.length();
                            for(Integer i=1;i<=acn0stoAdd;i++){
                                zeroes+='0';
                            }
                            accountACN=zeroes+accountACN;
						} else if (text == 'Issue Name') {
							issueName  = parser.getText();
						} else if (text == 'Serials') {
							serials  = parser.getText();
						} else if (text == 'Request Type') {
							requestType  = parser.getText();
						} else if (text == 'Case Type') {
							caseCategory = parser.getText();
						} else if (text == 'Priority') {
							priority = parser.getText();
						} else if (text == 'Sub-Status') {
							subStatus = parser.getText();
						} else if (text == 'FS Dispenser Type') {
							fSDispenserType = parser.getText();
						} else if (text == 'Issue Categories') {
							issueCategories = parser.getText();
						} else if (text == 'Description of issue') {
							issueDetails = parser.getText();
						} else if (text == 'Status') {
							status = parser.getText();
						} else if (text == 'Comment') {
							comment = parser.getText();
						} else if (text == 'Project Id') {
							projectId = parser.getText();
						} else if (text == 'Project Batch ID') {
							projectBatchId = parser.getText();
						} else if (text == 'Project Batch ID Date') {
							projectBatchDate = parser.getText();
						} else {
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
//method is used to get the serial number and outlet dispenser which is used to create caseto outlet dispenser accordingly
public static Map<String,id> createserialnoOdMap(List<String> serialnosACN) {
    Map<string,id> serialnoOdIdmap=new Map<string,id>();
    
        if ( Schema.sObjectType.FS_Outlet_Dispenser__c.fields.FS_Serial_Number__c.isAccessible() &&
            Schema.sObjectType.FS_Outlet_Dispenser__c.fields.FACT_Serial_Number_ACN__c.isAccessible() && Schema.sObjectType.FS_Outlet_Dispenser__c.fields.FS_IsActive__c.isAccessible()){
                List<FS_Outlet_Dispenser__c> odlist= [SELECT Id,FS_Serial_Number__c,FACT_Serial_Number_ACN__c  
                                                      FROM FS_Outlet_Dispenser__c 
                                                      where FACT_Serial_Number_ACN__c in:serialnosACN and FS_IsActive__c =true];
                for(FS_Outlet_Dispenser__c od:odlist){
                    serialnoOdIdmap.put(od.FS_Serial_Number__c, od.id);
                }
            }
      
        return serialnoOdIdmap;
    
}

    //this method is used to recieve the json string from Lightning Web component
@AuraEnabled
    public static String sendJson(String json) {
       
   Boolean errorflag=false;
   List<Case> caserecList=new List<Case>();
   List<id> caserecdelList=new List<id>();
   Map<integer,List<string>> rowFailReportMap=new Map<integer,List<string>>();
   Map<integer,List<string>> rowFailReportdbMap=new Map<integer,List<string>>();
   Map<integer,string> rowReportMap=new Map<integer,string>();
   List<CaseComment> casecs=new List<CaseComment>();
   Group Freestyle=[select Id from Group where Name = 'Freestyle Support' and Type = 'Queue' limit 1];
   Savepoint sp = Database.setSavepoint();
   String message='';
        
   try{
    LWCimportFile obj = parse(json);
    List<String> acnlist=new List<String>();
    List<String> serialacn=new List<String>();
    Map<String,List<String>> mapRowSerial=new Map<String,List<String>>();
    for(integer i=0;i<obj.caseZ.size();i++){
          acnlist.add(obj.CaseZ[i].accountACN);
          String key=String.valueOf(i);
        	//creating a list of serial numbers replacing all special characters with semi colon
          List<String> withcommaSerials = obj.caseZ[i].Serials.replace('\t\r\n', '').replaceAll('[^a-zA-Z0-9\\s+]', ';').replaceAll('\\s+', '').split(';');
          mapRowSerial.put(key, withcommaSerials);
        system.debug('mapRowSerial:'+mapRowSerial);
          for(String serialno:withcommaSerials){
              //concatinating serial numbers with acn in order to get active outlet dispenser
                serialacn.add(serialno.trim()+'-'+obj.CaseZ[i].accountACN);
              
          }
    }
                    
            Map<String,Id> mapserialOd=new Map<String,Id>();
        try{
        	mapserialOd=createserialnoOdMap(serialacn); 
        }
        catch(Exception e){
             Database.rollback(sp);
             message+='Cannot Proceed further.Error: '+e.getMessage();          
        }

    for(integer i=0;i<obj.caseZ.size();i++){
        
        	String rownum=String.valueOf(i);
            List<String> seriallist=mapRowSerial.get(rownum);
            
                try{
                Case caserec=new Case();
                caserec.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(obj.CaseZ[i].caseRecordType).getRecordTypeId();
                caserec.Subject=obj.CaseZ[i].issueName;
                caserec.Issue_Type__c=obj.CaseZ[i].requestType;
                caserec.FACT_Case_Type__c=obj.CaseZ[i].caseCategory;
                caserec.Priority=obj.CaseZ[i].priority;
                caserec.FS_Outlet_Dispenser__c=mapserialOd.get(seriallist[0]);
                caserec.FS_Dispenser_Type__c=obj.CaseZ[i].fSDispenserType;
                caserec.Categories__c=obj.CaseZ[i].issueCategories;
                caserec.Description_of_issue__c=obj.CaseZ[i].issuedetails;
                caserec.Status=obj.CaseZ[i].status;
                caserec.Sub_Status__c=obj.CaseZ[i].subStatus;
                caserec.Project_ID__c=obj.CaseZ[i].projectId;
                caserec.Project_Batch_Id__c=obj.CaseZ[i].projectBatchId;
                    if(obj.CaseZ[i].projectBatchDate != null) {
                    caserec.Project_Batch_ID_Date__c=Date.parse(obj.CaseZ[i].projectBatchDate);
                    }
                caserec.OwnerId=Freestyle.Id;
                caserecList.add(caserec);
             
                    //if serial number is not present in map key,then it is outlet dispenser is not exists
            if(!mapserialOd.containsKey(seriallist[0])){
                errorflag=true;
                //rowFailReportMap is used to track the serial numbers missed
                if(rowFailReportMap.containsKey(Integer.valueOf(rownum))) {
                    List<String> msg = rowFailReportMap.get(Integer.valueOf(rownum));
                    msg.add(String.valueOf(seriallist[0]));
                    rowFailReportMap.put(Integer.valueOf(rownum), msg);
            	} else {
                	rowFailReportMap.put(Integer.valueOf(rownum), new List<String> {String.valueOf(seriallist[0])  });
            	}
            }
            
                    }
                catch(Exception e){
                    Database.rollback(sp);                    
                    message+='Cannot Proceed further.Error in row:'+i+' .Recordtype is invalid.Please check.';
                    return 'Cannot proceed further. ' + e.getMessage()+' in line no.'+e.getLineNumber();
                }
        }
        String successrecs='';
        Database.SaveResult[] results;
        try{
        	results=Database.insert(caserecList,false);
        }
        catch(Exception e){
            Database.rollback(sp);
            message+=e.getMessage();
            return 'Cannot proceed further. ' + e.getMessage()+' in line no.'+e.getLineNumber();
        }
        List<id> allSuccessIdc=new List<id>();
        List<id> allFailedIdc=new List<id>();
        
        
        successrecs=successrecs.removeEnd(', ');
        Map<String,Id> caseODMap=new Map<String,Id>(); 
        Map<String,Id> caseextIdMap=new Map<String,Id>();
      
            
            //for report,pass and failed rec nums
            for(integer i=0;i<obj.caseZ.size();i++){
               Database.SaveResult recresult=results[i];
                if(!recresult.isSuccess()){
                    errorflag=true;
                    //rowFailReportdbMap is used to track validation rules and other system errors
                     for(Database.Error err : recresult.getErrors()) {
                         if(rowFailReportdbMap.containsKey(i)) {
                             List<String> msg = rowFailReportdbMap.get(i);
                             msg.add(err.getMessage());
                             rowFailReportdbMap.put(i, msg);
                         } else {
                             rowFailReportdbMap.put(i, new List<String> {err.getMessage()  });
                         }
       				 }
                }
                else{
                    //rowReportMap is used to track the success records 
                    if(!rowFailReportMap.containsKey(i)){
                    	rowReportMap.put(i, recresult.getId());
                    } 
                    else{
                       caserecdelList.add(recresult.getId());
                    }
       				allSuccessIdc.add(recresult.getId());
                    caseextIdMap.put(String.valueOf(i),caserecList[i].id);
                    caseODMap.put(caserecList[i].id,mapserialOd.get(String.valueOf(i)));
                }
                
            }
            
            
            
            
        List<CaseComment> casecList=new List<CaseComment>();
        //loop through success cases and insert case comments for them based on row numbers
         for(integer i=0;i<allSuccessIdc.size();i++){
             if(obj.CaseZ[i].Comment!=''){
                CaseComment cc=new CaseComment();
                 cc.CommentBody=obj.CaseZ[i].Comment;
                 cc.ParentId=caseextIdMap.get(String.valueOf(i));
                 casecList.add(cc);
             }
         }
            Database.SaveResult[] resultscc;
            try{
       			 resultscc= Database.insert(casecList,false);
            }
            catch(Exception e){
                Database.rollback(sp);
                message+=e.getMessage();    
            }
        List<id> allSuccessIdcc=new List<id>();
        List<id> allFailedIdcc=new List<id>();
        for(database.SaveResult s:resultscc){
            if(s.isSuccess()){
                allSuccessIdcc.add(s.getId());
            }
            else{
                message+=s.errors;    
            }
         }
		
        
            
      
         
            List<CaseToOutletdispenser__c> ctoOdlst=new List<CaseToOutletdispenser__c>();
            for(Integer i=0;i<mapserialOd.keyset().size();i++){
                String rownum=String.valueOf(i);
                List<String> seriallist=mapRowSerial.get(rownum);
                if(seriallist!=null)
                for(Integer j=1;j<seriallist.size();j++){
                    if(mapserialOd.containsKey(seriallist[j])){
                        if(caseextIdMap.containsKey(rownum)){
                            //create casetooutlet dispensers with the use of serial numbers
                            CaseToOutletdispenser__c ctood=new CaseToOutletdispenser__c();
                            ctood.Outlet_Dispenser__c=Id.valueOf(mapserialOd.get(seriallist[j]));
                            ctood.Case__c=caseextIdMap.get(rownum);
                            ctoOdlst.add(ctood);
                        }
                    }
                    else{
                        errorflag=true;
                        if(rowFailReportMap.containsKey(Integer.valueOf(rownum))) {
                            List<String> msg = rowFailReportMap.get(Integer.valueOf(rownum));
                            msg.add(String.valueOf(seriallist[j]));
                            rowFailReportMap.put(Integer.valueOf(rownum), msg);
                        } else {
                            rowFailReportMap.put(Integer.valueOf(rownum), new List<String> {String.valueOf(seriallist[j])  });
                        }
                    }
                }
            }
        Database.SaveResult[] resultsccod;
            try{
        		resultsccod= Database.insert(ctoOdlst,false);
            }
            catch(Exception e){
                Database.rollback(sp);
                message+=e.getMessage();    
            }
        List<id> allSuccessIdccod=new List<id>();
        for(database.SaveResult s:resultsccod){
            if(s.isSuccess()){
                allSuccessIdccod.add(s.getId());
            }
            else{
                message+=s.errors;    
            }
         }
            
            Integer passRecs=rowReportMap.size();
            
            //Prepare CSV report
            string header = 'Row num, Status , Id, Errors \n';
			string finalstr = header ;
            integer failcount=0;
    		for(integer row=0;row<obj.caseZ.size();row++){
                String errmsg='';
                String errmsg1='';
                List<String> errs=new List<String>();
                List<String> errs1=new List<String>();
                if(rowFailReportMap.containsKey(row)){
                    errs=rowFailReportMap.get(row);
                    //if(errs!=null)
                    	errmsg='Serial numbers not found: '+String.join(errs,','); 
                }
                if(rowFailReportdbMap.containsKey(row)){
                    errs1=rowFailReportdbMap.get(row);
                    //if(errs1!=null)
                  		errmsg1=' and Errors: '+String.join(errs1,','); 
                }
                if(errmsg=='')
                    errmsg1=errmsg1.remove(' and ');
                 if(rowFailReportMap.containsKey(row)||rowFailReportdbMap.containsKey(row)){
                     failcount++;
                 string recordString = (row+1)+','+'Fail'+',,'+'"'+errmsg+'"'+errmsg1+'\n';
				 finalstr = finalstr +recordString;
                 }
            }
            for(Integer row:rowReportMap.keyset()){
                String ids=rowReportMap.get(row);
                 string recordString = (row+1)+','+'Pass'+','+ids+'\n';
				 finalstr = finalstr +recordString;
            }
            if(caserecdelList.size()>0){
                try{
                    //Database.rollback(sp);
                    //delete the cases created if they are created without the serial numbers 
            		delete [select id from case where id in:caserecdelList];
                }
                catch(Exception e){
                	message+=e.getMessage();    
                }
        }
            //return the success and failed response from controller to LWC
            return 'Success:'+passRecs+' and failed:'+failcount+'.Please click on below link to download report.'+';'
                +finalstr;
            
			
    }
        catch(Exception e){
                Database.rollback(sp);
            return 'Cannot proceed further. '+message + ' , ' + e.getMessage()+' in line no.'+e.getLineNumber();
        }
    }
    
	public static LWCimportFile parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new LWCimportFile(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	

    private static List<Case_Z> arrayOfCase_Z(System.JSONParser p) {
        List<Case_Z> res = new List<Case_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Case_Z(p));
        }
        return res;
    }




}