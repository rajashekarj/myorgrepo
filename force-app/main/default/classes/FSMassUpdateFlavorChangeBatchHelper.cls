/*********************************************************************************************************
Name         : FSMassUpdateFlavorChangeBatchHelper 
Created By   : Infosys Limited 
Created Date : 17-Feb-2017
Usage        : Helper for Batch class (FSMassUpdateFlavorChangeBatch) which is used to create flavor change records
  
****************************  *******************************************************************************/
public without sharing class FSMassUpdateFlavorChangeBatchHelper{
    
    private static String recTypeHeadHQChain=Schema.SObjectType.FS_Flavor_Change_Head__c.getRecordTypeInfosByName().get('FS Flavor Change Chain HQ').getRecordTypeId();
    private static String recTypeHeadOutlet=Schema.SObjectType.FS_Flavor_Change_Head__c.getRecordTypeInfosByName().get('FS Flavor Change Outlet').getRecordTypeId();
    private static String recTypeLineHQChain=Schema.SObjectType.FS_Flavor_Change_New__c.getRecordTypeInfosByName().get('FS Flavor Change Chain HQ').getRecordTypeId();
    private static String recTypeLineOutletOD=Schema.SObjectType.FS_Flavor_Change_New__c.getRecordTypeInfosByName().get('FS Flavor Change Outlet').getRecordTypeId();
    private final static Object NULLOBJ = null;
    //validations messages to use in the method later
    private static final String VALUEREQUIREDERRORMESSAGE='Attributes are mandatory if effective date is provided';
    private static List<FS_Outlet_Dispenser__c> ODList{set;get;}
    private static List<FS_Association_Brandset__c> assignedBrandsetList{set;get;}
    private static set<string> dispenserSerialNumberSet{set;get;}
    private static set<String> newBrandsetSet{set;get;}
    private static set<string> outletAcnSet{set;get;}
    private static list<String> outletZIPs{set;get;}
    private static String atleastOneSuccess{get;set;}
    private static Map<string,Id> aCUserMap{get;set;}
   // private static Map<string,Id> pmUserMap{get;set;}
   // private static Map<string,Id> comUserMap{get;set;}
    public static final List<ProfileListFromCustomSettings__c> profileList = ProfileListFromCustomSettings__c.getall().values();
    
  //  private static Map<string,Id> productUserMap{get;set;}

    /* * @MethodName - booleanParser
        * @Description -parse string to Boolean
        * @Return - boolean	
        */
      public static boolean booleanParser(String value){
         boolean bValue=false;
         if(value.containsIgnoreCase('yes')){
             bValue= true;
         } 
          return bValue;
      }
    
       
  /* * @MethodName - validation
        * @Description -Validates the records to to be uploaded 
        * @Return - List<detailFlavorChangeWrapper>
        */
      public static List<detailFlavorChangeWrapper> validation(List<detailFlavorChangeWrapper> DetailFlavorChangesList,Id accountID,
                                                               string accountACN,set<string> dispenserSerialSet,set<String> newBrandSet,
                                                               set<string> outltAcnSet,set<string> platformSet,set<string> aCUserSet){
            
            dispenserSerialNumberSet=new set<string>();
            newBrandsetSet=new set<string>();
            outletAcnSet=new set<string>();
            assignedBrandsetList=new List<FS_Association_Brandset__c>();
            ODList=new List<FS_Outlet_Dispenser__c>();
            outletZIPs=new list<String>();
            atleastOneSuccess='';                                                                   
            //accountID= accountID;
            String acn=accountACN;
            dispenserSerialNumberSet=dispenserSerialSet;
            newBrandsetSet=newBrandSet;
            outletAcnSet=outltAcnSet;
            Set<string> outletAcnList=new Set<string>();
			Set<string> outletcsvAcnList=new Set<string>();
            aCUserMap=new Map<string,Id>();
            Id OdABid=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_OD).getRecordTypeId();                                                       
           // pmUserMap=new Map<string,Id>();
           // comUserMap=new Map<string,Id>();
            List<User> aCuserList=new List<User>();
            //List<User> pmUserList=new List<User>();
            //List<User> comUserList=new List<User>();
           	List<String> acpcList = New List<String> ();
           // List<String> comList = New List<String> (); 
           // List<String> pmAdminList = New List<String> ();  
            // loop to get the required profile wise list
           // acpcList = ProfileListFromCustomSettings__c.getInstance('ACPCProfiles').FS_Profile_Name__c.split(',');
           // comList = ProfileListFromCustomSettings__c.getInstance('COMProfiles').FS_Profile_Name__c.split(',');
           // pmAdminList = ProfileListFromCustomSettings__c.getInstance('PMADMINPMProfiles').FS_Profile_Name__c.split(',');
          
            //Query AC users from the list and put in a map//OCR changes
            aCuserList=[SELECT Id,Name,Email,Profile.Name from user where Email IN:aCUserSet AND IsActive=true];
            
            //Query PM/Admin PM users//OCR changes
          //	pmUserList=[SELECT Id,Name,Email,Profile.Name from user where Email IN:pmUserSet  AND IsActive=true AND Profile.Name IN : pmAdminList];
           
            //Query COM users  //OCR changes                                                    
           // comUserList=[SELECT Id,Name,Email,Profile.Name from user where Email IN:comUserSet AND IsActive=true AND Profile.Name IN : comList];
          
          	//All the od list under the HQ or Chain
			for(detailFlavorChangeWrapper detail:DetailFlavorChangesList){
				String formattedACN=FSUtil.leftPadWithZeroes(detail.outletACN,10);
				outletcsvAcnList.add(formattedACN);
			
			}
            ODList=[SELECT ID,FS_IsActive__c,FS_Serial_Number2__c,FS_Outlet__c,FS_Outlet__r.FS_ACN__c,FS_Outlet__r.ShippingPostalCode,Head_Quarter_ID__c,Chain_ID__c,FS_ACN_NBR__c from FS_Outlet_Dispenser__c where (Head_Quarter_ID__c=:acn OR Chain_ID__c=:acn) AND FS_Serial_Number2__c IN: dispenserSerialNumberSet];
            List<Account> OLList=new List<Account>([SELECT Id,Name,FS_ACN__c from Account where (FS_Headquarters__c=:accountID OR FS_Chain__c=:accountID) AND RecordTypeId=:Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId() AND FS_ACN__c IN: outletcsvAcnList]);
            
            assignedBrandsetList=[SELECT ID,FS_Dispenser_Serial_Number__c,FS_Brandset__c,FS_Brandset__r.name,FS_Brandset__r.FS_Available_for_commercial_use__c FROM FS_Association_Brandset__c WHERE FS_Dispenser_Serial_Number__c=:dispenserSerialNumberSet and FS_Outlet_Dispenser__c!= Null and RecordTypeId =:OdABid];
            
             for(Account outletObj:OLList){
                    outletAcnList.add(outletObj.FS_ACN__c);                                                   
             } 
             if(!aCuserList.isEmpty()){
               for(User usr:aCuserList){
                aCUserMap.put(usr.Email.toUpperCase(UserInfo.getLocale()),usr.Id);                                              
                 }
             }
             system.debug('ac user map'+aCUserMap);
            //OCR changes
           /* if(!pmUserList.isEmpty()){
             for(User usr:pmUserList){
                 pmUserMap.put(usr.Email.toUpperCase(UserInfo.getLocale()),usr.Id);                                              
            }
            }
             system.debug('pm user map'+pmUserMap);
             //OCR changes
             if(!comUserList.isEmpty()){
             for(User usr:comUserList){
                    comUserMap.put(usr.Email.toUpperCase(UserInfo.getLocale()),usr.Id);                                              
             }
             }
             system.debug('com user map'+comUserMap);   
			*/
             
            //Set<string> platformSet=new set<string>();
            
            Set<string> mappedSerialNumberList=new Set<string>();
            Set<string> activeSerialNumberList=new Set<string>();
            Map<string,string> acnSerialNumberMap=new Map<string,string>();
            Map<String,ID> futureBrandNameIdMap=new Map<String,ID>();
            Map<String,Account> acnAccountMap=new Map<String,Account>();                                                  
            for(FS_Outlet_Dispenser__c sampleOD:ODList){
                
                mappedSerialNumberList.add(sampleOD.FS_Serial_Number2__c);
                if(sampleOD.FS_IsActive__c){
                   activeSerialNumberList.add(sampleOD.FS_Serial_Number2__c); 
                }
                outletZIPs.add(sampleOD.FS_Outlet__r.ShippingPostalCode);
            }
            
            List<account> accList=new List<account>();
            accList=[SELECT ID,FS_ACN__c,FS_Requested_Order_Method__c,FS_Requested_Delivery_Method__c,(SELECT Id,FS_Serial_Number2__c from Outlet_Dispensers__r) from account where FS_ACN__c IN :outletAcnList];
            for(account acc:accList){
                for(FS_Outlet_Dispenser__c outletDis:acc.Outlet_Dispensers__r){
                    acnSerialNumberMap.put(outletDis.FS_Serial_Number2__c,acc.FS_ACN__c);
                }
                acnAccountMap.put(acc.FS_ACN__c,acc);
            }
            
          //Below variable contains values from the file upload future brandset section and querying it for matching purposes
          Map<Id,FS_Brandset__c> futureBrandUploadMap=new Map<Id,FS_Brandset__c>([select Id,Name,FS_Available_for_commercial_use__c,FS_Date_Brandset_is_available_for_Select__c,FS_Effective_End_Date__c,Available_for_Selection__c,FS_Platform__c  from FS_Brandset__c WHERE Name IN :newBrandSet]);
          Map<Id,FS_Brandset__c> fsBrandsetMap=new Map<Id,FS_Brandset__c>([select Id,Name,FS_Available_for_commercial_use__c,FS_Date_Brandset_is_available_for_Select__c,FS_Platform__c,Available_for_Selection__c,FS_Effective_End_Date__c from FS_Brandset__c where Available_for_Selection__c=true]);
                                                                                                                          
          for(FS_Brandset__c fcBItem:futureBrandUploadMap.values()){
              futureBrandNameIdMap.put(fcBItem.Name,fcBItem.Id);              
          }
          //this loop fills the records with details of validation succcess or fail and returns that list at the end                                                         
         for(detailFlavorChangeWrapper detail:DetailFlavorChangesList){
             
             detail.validationPassed=true;
             detail.validationErrorMessage='';
             String formattedACN=FSUtil.leftPadWithZeroes(detail.outletACN,10);
             if(!outletAcnList.contains(formattedACN)){
                detail.validationPassed=false;
                if(String.isBlank(detail.outletACN)){
                    detail.validationErrorMessage+='ACN field is Blank;';
                }
                else{
                     detail.validationErrorMessage+='The ACN does not exists under the HQ or chain selected;';
                }
                 
             }
             if(!(detail.validationErrorMessage).containsIgnoreCase('ACN')){
                 if(!mappedSerialNumberList.contains(detail.serialNumber)){
                     detail.validationPassed=false;
                     if(String.isBlank(detail.serialNumber)){
                        detail.validationErrorMessage+='Serial No field is Blank;';
                     }
                     else{
                        detail.validationErrorMessage+='The Serial Number does not exists under the selected outlet;';
                     }
                 }
                 else if(mappedSerialNumberList.contains(detail.serialNumber) && !activeSerialNumberList.contains(detail.serialNumber)){
                         detail.validationErrorMessage+='The Serial number is not active;';
                 }
                 if((acnSerialNumberMap.get(detail.serialNumber)!=null) && !acnSerialNumberMap.get(detail.serialNumber).contains(formattedACN)){
                     detail.validationPassed=false;
                     if(!String.isBlank(detail.serialNumber) && !(detail.validationErrorMessage).contains('The Serial Number does not exists') && !(detail.validationErrorMessage).contains('not active')){
                         detail.validationErrorMessage+='The Serial Number does not exists under the selected outlet;';
                     }
                  }
                  if(!activeSerialNumberList.contains(detail.serialNumber)){
                      detail.validationPassed=false;
                      if(!detail.validationErrorMessage.contains('The Serial Number does not exists') && !detail.validationErrorMessage.contains('Serial No field is Blank') && !detail.validationErrorMessage.contains('not active')){
                           detail.validationErrorMessage+='The Serial Number is not active;'; 
                      }                                 
                  }
             }             
             if(!string.isblank(detail.newBrandset) && string.IsBlank(detail.brandsetEffectiveDate)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='Effective Brandset Date is required if we have New Brandset;';
             }
             if(string.isblank(detail.newBrandset) && !string.isblank(detail.brandsetEffectiveDate)){
                detail.validationPassed=false;
                detail.validationErrorMessage+='New Brandset is required if we have Effective Brandset Date;'; 
             }
             /*
             if(!string.isblank(detail.dasaniData) && string.isblank(detail.dasaniDataEffectvieDate)){
                detail.validationPassed=false;
                detail.validationErrorMessage+='Effective Hide/Show Dasani Date is required if we have value in Hide/Show Dasani;';
                                
             }
             if(string.isblank(detail.dasaniData) && !string.isblank(detail.dasaniDataEffectvieDate)){
                detail.validationPassed=false;
                detail.validationErrorMessage+='Hide/Show Dasani  is required if we have Effective Hide/Show Dasani Date;';
                               
             }*/
             if(!string.isblank(detail.waterHideData) && string.isblank(detail.waterHideEffectvieDate)){
                detail.validationPassed=false;
                detail.validationErrorMessage+='Effective Non Branded Water Date is required if we have value in Non Branded Water;';

             }
             if(string.isblank(detail.waterHideData) && !string.isblank(detail.waterHideEffectvieDate)){
                detail.validationPassed=false;
                detail.validationErrorMessage+='Non Branded Water Button is required if we have Effectvie Non Branded Water Date;';
                
             }    
             
              
                         
             if((!string.isblank(detail.dasaniData) && !string.isblank(detail.dasaniDataEffectvieDate) && (FSUtil.dateParserHelper(detail.dasaniDataEffectvieDate) <Date.today()))
                ||(!string.isblank(detail.waterHideData) && !string.isblank(detail.waterHideEffectvieDate) && (FSUtil.dateParserHelper(detail.waterHideEffectvieDate) < Date.today()))
                ||(!string.isblank(detail.newBrandset) && !string.isblank(detail.brandsetEffectiveDate) && (FSUtil.dateParserHelper(detail.brandsetEffectiveDate) < Date.today()))){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='Date values should not be earlier than today;';                 
             }           
           //OCR Changes to validate requested date
             if(string.isblank(detail.RequestedDate)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='Requested Date is required;';
                 
             }    
             
             if((!string.isblank(detail.RequestedDate) && (FSUtil.dateParserHelper(detail.RequestedDate) <Date.today()))){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='Requested Date cannot be earlier than today'+'s date;'; 
                 
             }
             
             if(string.isblank(detail.newBrandset) && string.IsBlank(detail.dasaniData) && string.IsBlank(detail.waterHideData)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='A value change with an effective date needs to be provided in order to proceed to the next step;';
             }           
             if(!fsBrandsetMap.containsKey(futureBrandNameIdMap.get(detail.newBrandset)) && !detail.validationErrorMessage.contains('Brandset is required') && !detail.validationErrorMessage.contains('A value change') && !string.isblank(detail.brandsetEffectiveDate)){
                detail.validationPassed=false; 
                 if(String.isBlank(detail.newBrandset)){
                     detail.validationErrorMessage+='Future brandset field is Blank;';
                 }
                 else{
                     FS_Brandset__c brandObj=new FS_Brandset__c();
                     brandObj=futureBrandUploadMap.get(futureBrandNameIdMap.get(detail.newBrandset));
                     if(brandObj==NULLOBJ){
                         detail.validationErrorMessage+='The brandset does not exist;';
                     }
                     else{
                         detail.validationErrorMessage+='The brandset is not available for selection;';
                     }
                 }                
             }
             if(fsBrandsetMap.containsKey(futureBrandNameIdMap.get(detail.newBrandset))){
                 FS_Brandset__c brandObj=new FS_Brandset__c();
                 brandObj=fsBrandsetMap.get(futureBrandNameIdMap.get(detail.newBrandset));
                 if(!(brandObj.FS_Platform__c).containsIgnoreCase(detail.platform) || string.isBlank(detail.platform)){
                     detail.validationPassed=false; 
                     detail.validationErrorMessage+='The brandset is not matching with the given platform;';
                 }                 
             }
             if(string.isNotBlank(detail.outletACN) && acnAccountMap.get(formattedACN)!=NULLOBJ && !string.isblank(detail.newBrandset) && !string.isblank(detail.brandsetEffectiveDate)){
                 String deliveryMethod='';
                 String orderMethod='';
                 if(acnAccountMap.get(formattedACN).FS_Requested_Delivery_Method__c!=NULLOBJ){
                     deliveryMethod=acnAccountMap.get(formattedACN).FS_Requested_Delivery_Method__c;
                 }
                 if(acnAccountMap.get(formattedACN).FS_Requested_Order_Method__c!=NULLOBJ){
                     orderMethod=acnAccountMap.get(formattedACN).FS_Requested_Order_Method__c;
                 } 
                 if(deliveryMethod.containsIgnoreCase('direct') && !detail.CDMSetupComplete.containsIgnoreCase('yes')){
                    detail.validationPassed=false;
                    detail.validationErrorMessage+='CDM approval is necessary to save the records;';
                 }
                 if(deliveryMethod.containsIgnoreCase('direct') && !detail.POMActionsComplete.containsIgnoreCase('yes')){
                    detail.validationPassed=false;
                    detail.validationErrorMessage+='POM approval is necessary to save the records;';
                 }
                 if(((deliveryMethod.containsIgnoreCase('distributor') && orderMethod.containsIgnoreCase('distributor')) ||
                     (deliveryMethod.containsIgnoreCase('bottler') && orderMethod.containsIgnoreCase('bottler'))) &&
                     !(detail.NDOapprovalCheck.containsIgnoreCase('yes') || detail.NDOapprovalCheck.containsIgnoreCase('approv'))){
                        detail.validationPassed=false;
                        detail.validationErrorMessage+='NDO approval is necessary to save the records;';
                 }
                 if((deliveryMethod.containsIgnoreCase('distributor') && !orderMethod.containsIgnoreCase('distributor')) &&
                       !((detail.NDOapprovalCheck.containsIgnoreCase('yes') || detail.NDOapprovalCheck.containsIgnoreCase('approv')) &&
                         detail.CDMSetupComplete.containsIgnoreCase('yes') && detail.POMActionsComplete.containsIgnoreCase('yes'))){
                        detail.validationPassed=false;
                        if(!(detail.NDOapprovalCheck.containsIgnoreCase('yes') || detail.NDOapprovalCheck.containsIgnoreCase('approv'))){
                            detail.validationErrorMessage+='NDO approval is necessary to save the records;';
                        }
                        if(!detail.CDMSetupComplete.containsIgnoreCase('yes')){
                            detail.validationErrorMessage+='CDM approval is necessary to save the records;';
                        }
                        if(!detail.POMActionsComplete.containsIgnoreCase('yes')){
                            detail.validationErrorMessage+='POM approval is necessary to save the records;';
                        }                        
                 }
             }
             /*else if(!((detail.NDOapprovalCheck.containsIgnoreCase('yes') || detail.NDOapprovalCheck.containsIgnoreCase('approv')) &&
                         detail.CDMSetupComplete.containsIgnoreCase('yes') && detail.POMActionsComplete.containsIgnoreCase('yes'))){
                            detail.validationPassed=false;
                        detail.validationErrorMessage+='NDO/CDM/POM approvals are necessary to save the records;';
             }*/
             
             if(string.isblank(detail.acUser)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='AC/PC mail ID should not be blank;';
             }
             else if(string.isblank(acUserMap.get(detail.acUser.toUpperCase(UserInfo.getLocale())))){
                 detail.validationPassed=false;
                 //detail.validationErrorMessage+='The AC/PC mail Id does not exist in the system;';
                 detail.validationErrorMessage+='The AC/PC mail Id does not exist in the system;';
             }
             if(string.isblank(detail.comUser)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='COM mail Id should not be blank;';
             }
             else if(string.isblank(acUserMap.get(detail.comUser.toUpperCase(UserInfo.getLocale())))){
                 detail.validationPassed=false;
                // detail.validationErrorMessage+='The COM mail Id does not exist in the system;';
                detail.validationErrorMessage+='The COM mail Id does not exist in the system;';
             }
           
             if(string.isblank(detail.productOrderHandeledBy)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='Flavor Change Initial Order handled by? should not be blank;';
             }  
             if(string.isblank(detail.customerPayorAccountPay)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='Customer/Account Pay should not be blank;';
             }
             if(string.isblank(detail.spNeedToGoOut) && !string.isblank(detail.newBrandset)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='SP needs to go out? should not be blank;';
             }
             //Production Support - Defect - 4695
             //Added by Aman
             if(!string.isblank(detail.pungentChangeIndicator) && (!detail.pungentChangeIndicator.containsIgnoreCase('yes') && !detail.pungentChangeIndicator.containsIgnoreCase('no'))){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='Pungent Change Indicator value is limited to either Yes or No';
             }
             if(string.isblank(detail.pungentChangeIndicator) && !string.isblank(detail.newBrandset)){
                 detail.validationPassed=false;
                 detail.validationErrorMessage+='Pungent Change Indicator should not be blank;';
             }
             if(detail.validationPassed){
                 atleastOneSuccess='YES';
             }             
         }
          return DetailFlavorChangesList;
      }
    //This method is used to create the flavor change lines under HQ and Flavor change Outlets headers and their lines along with service provides
    public static void createFlavorChanges(List<detailFlavorChangeWrapper> DetailFlavorChangesList,string accountID,ID parentId){
            
            List<FS_Outlet_Dispenser__c> outletDispList=new List<FS_Outlet_Dispenser__c>(); 
            //fetch the holder where the excel file is stored
            FS_WorkBook_Holder__c holder=[SELECT FS_FCHeaderId__c FROM FS_WorkBook_Holder__c WHERE ID=:parentId];
            ID flavorChangeHeadID;
            Integer zero=0;
            Integer five=5;
            FS_Flavor_Change_Head__c flavorChangeHead=new FS_Flavor_Change_Head__c();
            //fetch the fc header id if it is already updated by first batch of records
            //if not, insert a new header at HQ level and update in the else condition
            if(!string.IsEmpty(holder.FS_FCHeaderId__c)){
                flavorChangeHeadID=holder.FS_FCHeaderId__c;
            }
            else{                
                flavorChangeHead.FS_HQ_Chain__c=accountID;
                flavorChangeHead.FS_FC_Type__c='File Upload Flavor Change';
                flavorChangeHead.recordtypeID=recTypeHeadHQChain;
                try{
                    insert flavorChangeHead;
                    
                    holder.FS_FCHeaderId__c=flavorChangeHead.Id;
                    update holder;
                    flavorChangeHeadID=flavorChangeHead.Id;
                }
                catch(DMLException dmlExp){ ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateFlavorChangeBatchHelper','createFlavorChanges','FS_Flavor_Change_Head__c','HIGH',dmlExp,dmlExp.getMessage());}
                
            }
            //Below variable stores the header at hq level and updates few fields on the header based on record values
            FS_Flavor_Change_Head__c flavorChangeHeadUpdate=new FS_Flavor_Change_Head__c();
            flavorChangeHeadUpdate=[SELECT ID,NAME,FS_Estimated_FC_Date__c,FS_AC__c,FS_Product_Order_handled_By_txt__c,FS_Pay_Type__c,FS_Customer_Note__c,FS_Project_Id__c,FS_Project_Name__c FROM FS_Flavor_Change_Head__c WHERE ID=:flavorChangeHeadID];
            
            Boolean recordFailed=false;
            Map<string,FS_Outlet_Dispenser__c> serailNumberOutletMap=new Map<string,FS_Outlet_Dispenser__c>();
            for(FS_Outlet_Dispenser__c od:ODList){
                serailNumberOutletMap.put(od.FS_Serial_Number2__c,od);
            }
            Map<string,id> serailNumberCurentBrandsetMap=new Map<string,id>();
            for(FS_Association_Brandset__c assosiatedbrandset: assignedBrandsetList){
                serailNumberCurentBrandsetMap.put(assosiatedbrandset.FS_Dispenser_Serial_Number__c,assosiatedbrandset.FS_Brandset__c);
            }
        
            List<FS_Brandset__c> newBrandsetList =[SELECT ID,name FROM FS_Brandset__c WHERE name =:newBrandsetSet];
            
            Map<string,id> newBrandsetMap=new Map<string,id>();
            for(FS_Brandset__c newBrandset: newBrandsetList){
                newBrandsetMap.put(newBrandset.name,newBrandset.ID);
            }
            //The FC line list that is going to be created under the HQ fc header
            list<FS_Flavor_Change_New__c> flavorChangeList=new List<FS_Flavor_Change_New__c>();
            Integer detailWrapperNo=-1;
            //Getting the describe information of pay type and storing the values for comparison
            Schema.DescribeFieldResult fieldResult = FS_Flavor_Change_Head__c.FS_Pay_Type__c.getDescribe();
            List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
            Set<String> pleSet=new set<String>();
            for(Schema.PicklistEntry pObj : pleList){
                pleSet.add(pObj.getValue());
            }           
            //Below loop adds the flavor change line items to the line list and then inserts them in the system
            //the parent for all the line records will be the fc HQ header
            for(detailFlavorChangeWrapper detailFlavorChangeWrapper:DetailFlavorChangesList){
                detailWrapperNo++;
                if(String.isNotBlank(detailFlavorChangeWrapper.estimatedFlavorChangeDate) && flavorChangeHeadUpdate.FS_Estimated_FC_Date__c==NULLOBJ){
                    flavorChangeHeadUpdate.FS_Estimated_FC_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.estimatedFlavorChangeDate);
                }                
                //if(aCUserMap.get(detailFlavorChangeWrapper.aCUser)!=NULLOBJ && flavorChangeHeadUpdate.FS_AC__c==NULLOBJ){
                    flavorChangeHeadUpdate.FS_AC__c=aCUserMap.get(detailFlavorChangeWrapper.aCUser.toUpperCase(UserInfo.getLocale())); 
                //}
                //if(aCUserMap.get(detailFlavorChangeWrapper.pmUser)!=NULLOBJ && flavorChangeHeadUpdate.FS_PM__c==NULLOBJ){
                    flavorChangeHeadUpdate.FS_PM__c=aCUserMap.get(detailFlavorChangeWrapper.pmUser.toUpperCase(UserInfo.getLocale())); 
                //}
                //if(aCUserMap.get(detailFlavorChangeWrapper.comUser)!=NULLOBJ){
                    flavorChangeHeadUpdate.FS_Entering_COM__c=aCUserMap.get(detailFlavorChangeWrapper.comUser.toUpperCase(UserInfo.getLocale())); 
                //}
                //if(String.IsBlank(flavorChangeHeadUpdate.FS_Product_Order_handled_By_txt__c)){
                    flavorChangeHeadUpdate.FS_Product_Order_handled_By_txt__c=detailFlavorChangeWrapper.productOrderHandeledBy;
                //}                
                //if(pleSet.contains(detailFlavorChangeWrapper.customerPayorAccountPay) && String.IsBlank(flavorChangeHeadUpdate.FS_Pay_Type__c)){
                    flavorChangeHeadUpdate.FS_Pay_Type__c=detailFlavorChangeWrapper.customerPayorAccountPay;
                //}
                //if(String.IsBlank(flavorChangeHeadUpdate.FS_Customer_Note__c)){
                    flavorChangeHeadUpdate.FS_Customer_Note__c=detailFlavorChangeWrapper.customerServiceNotes;
                //}
                //if(String.IsBlank(flavorChangeHeadUpdate.FS_Project_Id__c)){
                    flavorChangeHeadUpdate.FS_Project_Id__c=detailFlavorChangeWrapper.projectID;
                //}
                //if(String.IsBlank(flavorChangeHeadUpdate.FS_Project_Name__c)){
                    flavorChangeHeadUpdate.FS_Project_Name__c=detailFlavorChangeWrapper.projectDescription;
                    flavorChangeHeadUpdate.FS_isBatch__c=true;
                	flavorChangeHeadUpdate.FS_Approved__c=true; //
                //} 
                //if(!flavorChangeHeadUpdate.FS_Customer_Readiness__c){
                    //flavorChangeHeadUpdate.FS_Customer_Readiness__c=booleanParser(detailFlavorChangeWrapper.customerReadiness);
                    //flavorChangeHeadUpdate.FS_Approved__c=booleanParser(detailFlavorChangeWrapper.fcCommerciallyApproved);
                //}
                //Process line records only if all the validations are passed 
                if(detailFlavorChangeWrapper.validationPassed){
                    
                FS_Flavor_Change_New__c flavorChange=new FS_Flavor_Change_New__c();
                flavorChange.FS_FC_Head__c=flavorChangeHeadID;
                flavorChange.FS_Platform__c=detailFlavorChangeWrapper.platform;
                if(serailNumberOutletMap.containsKey(detailFlavorChangeWrapper.serialNumber)){
                 flavorChange.FS_Outlet__c=serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c;
                 flavorChange.FS_Outlet_Dispenser__c=serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).id;
                }
                if(serailNumberCurentBrandsetMap.containsKey(detailFlavorChangeWrapper.serialNumber)){
                    flavorChange.FS_Current_Brandset__c=serailNumberCurentBrandsetMap.get(detailFlavorChangeWrapper.serialNumber);
                }
                if(newBrandsetMap.containsKey(detailFlavorChangeWrapper.newBrandset)){
                    flavorChange.FS_New_Brandset__c=newBrandsetMap.get(detailFlavorChangeWrapper.newBrandset);
                }
                    //OCR Changes
                    else{
                        flavorChange.FS_Only_Water_Dasani__c=True;
                    }
                try{
                    if(detailFlavorChangeWrapper.brandsetEffectiveDate!=null && detailFlavorChangeWrapper.brandsetEffectiveDate!=''){
                        flavorChange.FS_BS_Effective_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.brandsetEffectiveDate);
                    }
                    flavorChange.FS_WA_Effective_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.waterHideEffectvieDate);
                    //flavorChange.FS_DA_Effective_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.dasaniDataEffectvieDate);
                    flavorChange.FS_Flavor_Change_Requested_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.requestedDate);
                    //flavorChangeHeadUpdate.FS_Estimated_FC_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.estimatedFlavorChangeDate);    
                }
                catch(TypeException ex){ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateFlavorChangeBatchHelper','createFlavorChanges','FS_Flavor_Change_New__c','COSMETIC',ex,ex.getMessage());  }
                
                flavorChange.FS_Hide_Show_Water_Button__c=detailFlavorChangeWrapper.waterHideData;                
                //flavorChange.FS_Hide_Show_Dasani__c=detailFlavorChangeWrapper.dasaniData;                
                flavorChange.FS_DataUsedInCode__c=detailWrapperNo;
                flavorChangeList.add(flavorChange);                
                //flavorChangeHeadUpdate.FS_Project_Id__c=detailFlavorChangeWrapper.projectID;
                //flavorChangeHeadUpdate.FS_Project_Name__c=detailFlavorChangeWrapper.projectDescription;
                system.Debug('flavorChangeList'+flavorChangeList);
            }
           }
             
            try{
                if(DetailFlavorChangesList.size()>0 && flavorChangeList.size()>0){
                    
                    Database.update(flavorChangeHeadUpdate); 
                   
                    Database.SaveResult[] updateResults = Database.insert(flavorChangeList, false);
                    Integer updateResultSize=updateResults.size();                 
                 
                     for(Integer i=0;i<updateResultSize;i++){
                        if(!updateResults.get(i).isSuccess()){
                           // DML operation failed
                            String failedDMLMessage='';
                            Integer obj=0;
                            for(Database.Error error : updateResults.get(i).getErrors()){
                                failedDMLMessage+= '[' +error.getMessage() +']';
                                detailFlavorChangeWrapper detailWrapItem=new detailFlavorChangeWrapper();
                                obj=integer.valueOf(flavorChangeList.get(i).FS_DataUsedInCode__c);
                                detailWrapItem=DetailFlavorChangesList.get(obj);
                                detailWrapItem.validationPassed=false;
                                detailWrapItem.validationErrorMessage='System Error:Please correct the data-'+failedDMLMessage;
                                //DetailFlavorChangesList.remove(obj);
                                //DetailFlavorChangesList.add(obj, detailWrapItem);                                
                            }
                        }                       
                     }
                    
                    }
                    else{ Database.update(flavorChangeHeadUpdate);}
              }
              catch(DMLException dmlExp){ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateFlavorChangeBatchHelper','createFlavorChanges','FS_Flavor_Change_Head__c','HIGH',dmlExp,dmlExp.getMessage()); }
            
            Map<ID,FS_Flavor_Change_Head__c> flavorChangeHeadOutletMap=new map<ID,FS_Flavor_Change_Head__c>();
            for(detailFlavorChangeWrapper detailFlavorChangeWrapper:DetailFlavorChangesList){
                
                if(serailNumberOutletMap.containsKey(detailFlavorChangeWrapper.serialNumber) && detailFlavorChangeWrapper.validationPassed){
                    if(!flavorChangeHeadOutletMap.containsKey(serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c)){
                        FS_Flavor_Change_Head__c flavorChangeHeadOutlet=new FS_Flavor_Change_Head__c();
                        flavorChangeHeadOutlet.FS_HQ_Chain__c=serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c; 
                        flavorChangeHeadOutlet.FS_FC_Type__c='File Upload Flavor Change';
                        flavorChangeHeadOutlet.recordtypeID=recTypeHeadOutlet;
                        
                        flavorChangeHeadOutlet.FS_Flavor_Change_Request_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.requestedDate);
                        if(aCUserMap.get(detailFlavorChangeWrapper.aCUser.toUpperCase(UserInfo.getLocale()))!=NULLOBJ){
                           flavorChangeHeadOutlet.FS_AC__c=aCUserMap.get(detailFlavorChangeWrapper.aCUser.toUpperCase()); 
                        } 
                        if(aCUserMap.get(detailFlavorChangeWrapper.pmUser.toUpperCase(UserInfo.getLocale()))!=NULLOBJ){
                           flavorChangeHeadOutlet.FS_PM__c=aCUserMap.get(detailFlavorChangeWrapper.pmUser.toUpperCase(UserInfo.getLocale())); 
                        }
                        if(aCUserMap.get(detailFlavorChangeWrapper.comUser.toUpperCase(UserInfo.getLocale()))!=NULLOBJ){
                           flavorChangeHeadOutlet.FS_Entering_COM__c=aCUserMap.get(detailFlavorChangeWrapper.comUser.toUpperCase(UserInfo.getLocale())); 
                        }                        
                        flavorChangeHeadOutlet.FS_SP_go_out__c=detailFlavorChangeWrapper.spNeedToGoOut;
                        flavorChangeHeadOutlet.FS_Pungent_Change_Indicator__c=detailFlavorChangeWrapper.pungentChangeIndicator;                                             
                        flavorChangeHeadOutlet.FS_Pay_Type__c=detailFlavorChangeWrapper.customerPayorAccountPay;
                        flavorChangeHeadOutlet.FS_Date_product_is_available_at_DC__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.dateProductidAvaliableInDC);
                        flavorChangeHeadOutlet.FS_Estimated_FC_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.estimatedFlavorChangeDate);
                        flavorChangeHeadOutlet.FS_Customer_Note__c=detailFlavorChangeWrapper.customerServiceNotes;
                        //flavorChangeHeadOutlet.FS_POM_Action_Complete__c=false;
                        //flavorChangeHeadOutlet.FS_Approved__c=false;
                        //flavorChangeHeadOutlet.FS_CDM_setup_complete__c=false;
                        //flavorChangeHeadOutlet.FS_NDO_Action_Completed_by__c=UserInfo.getName();
                        flavorChangeHeadOutlet.FS_Parent_Flavor_Change__c=flavorChangeHeadID;
                        flavorChangeHeadOutlet.FS_Product_Order_handled_By_txt__c=detailFlavorChangeWrapper.productOrderHandeledBy;
                        flavorChangeHeadOutlet.FS_Order_Processed__c=booleanParser(detailFlavorChangeWrapper.orderProcessed);
                        flavorChangeHeadOutlet.FS_Project_Id__c=detailFlavorChangeWrapper.projectID;
                        flavorChangeHeadOutlet.FS_Project_Name__c=detailFlavorChangeWrapper.projectDescription;
                       /* flavorChangeHeadOutlet.FS_Customer_Readiness__c=booleanParser(detailFlavorChangeWrapper.customerReadiness);
                        if(booleanParser(detailFlavorChangeWrapper.customerReadiness)){
                            flavorChangeHeadOutlet.FS_Customer_Readiness_Completed_By__c=UserInfo.getName();
                            flavorChangeHeadOutlet.FS_Customer_Readiness_Completed_DateTime__c=system.now();
                        } */
                        flavorChangeHeadOutlet.FS_SP_Scheduled_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.scheduledDate);
                        flavorChangeHeadOutlet.FS_SS_Readiness_Alert__c=false;
                        flavorChangeHeadOutlet.FS_SS_Alert_Status__c=false;
                        flavorChangeHeadOutlet.FS_isBatch__c=true;    
                        //This field needs to be checked by other class and not here-so for now it is not touched                        
                        //flavorChangeHeadOutlet.FS_Approved__c=booleanParser(detailFlavorChangeWrapper.fcCommerciallyApproved);                        
                        flavorChangeHeadOutletMap.put(serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c,flavorChangeHeadOutlet);
                   }
                    else{
                        FS_Flavor_Change_Head__c flavorChangeHeadOutlet=new FS_Flavor_Change_Head__c();
                        flavorChangeHeadOutlet=flavorChangeHeadOutletMap.get(serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c);
                        if(!flavorChangeHeadOutlet.FS_SP_go_out__c.containsIgnoreCase('Yes') && detailFlavorChangeWrapper.spNeedToGoOut.containsIgnoreCase('Yes')){
                            flavorChangeHeadOutlet.FS_SP_go_out__c='Yes';
                        }
                        if(!flavorChangeHeadOutlet.FS_Pungent_Change_Indicator__c.containsIgnoreCase('Yes') && detailFlavorChangeWrapper.pungentChangeIndicator.containsIgnoreCase('Yes')){
                            flavorChangeHeadOutlet.FS_Pungent_Change_Indicator__c='Yes';
                        }
                        flavorChangeHeadOutletMap.put(serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c,flavorChangeHeadOutlet);
                   }
                }
            
            }
            
        try{
            if(flavorChangeHeadOutletMap.values().size()>zero){
                Database.insert(flavorChangeHeadOutletMap.values(),false);
                
            }
        }
        
        catch(DMLException dmlExp){ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateFlavorChangeBatchHelper','createFlavorChanges','FS_Flavor_Change_Head__c','HIGH',dmlExp,dmlExp.getMessage());
        }
             list<FS_Flavor_Change_New__c> flavorChangeLineOutletList=new List<FS_Flavor_Change_New__c>();
            for(detailFlavorChangeWrapper detailFlavorChangeWrapper:DetailFlavorChangesList){
                if(detailFlavorChangeWrapper.validationPassed &&
                    serailNumberOutletMap.containsKey(detailFlavorChangeWrapper.serialNumber) &&
                    flavorChangeHeadOutletMap.containsKey(serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c)){
                        ID FCOutletHeadID=flavorChangeHeadOutletMap.get(serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c).id;
                        //FS_Flavor_Change_Head__c FCOutletHead =flavorChangeHeadOutletMap.get(serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c);
                        ID FCOutletID=flavorChangeHeadOutletMap.get(serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c).FS_HQ_Chain__c;
       					
                        if(FCOutletID==serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c){
                            FS_Flavor_Change_New__c flavorChangeLineOutlet=new FS_Flavor_Change_New__c();
                              flavorChangeLineOutlet.FS_FC_Head__c=FCOutletHeadID;
                            flavorChangeLineOutlet.FS_Platform__c=detailFlavorChangeWrapper.platform;
                            if(serailNumberOutletMap.containsKey(detailFlavorChangeWrapper.serialNumber)){
                             flavorChangeLineOutlet.FS_Outlet__c=serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).FS_Outlet__c;
                             flavorChangeLineOutlet.FS_Outlet_Dispenser__c=serailNumberOutletMap.get(detailFlavorChangeWrapper.serialNumber).id;
                            }
                            if(serailNumberCurentBrandsetMap.containsKey(detailFlavorChangeWrapper.serialNumber)){
                                flavorChangeLineOutlet.FS_Current_Brandset__c=serailNumberCurentBrandsetMap.get(detailFlavorChangeWrapper.serialNumber);
                            }
                        
                            if(newBrandsetMap.containsKey(detailFlavorChangeWrapper.newBrandset)){
                                flavorChangeLineOutlet.FS_New_Brandset__c=newBrandsetMap.get(detailFlavorChangeWrapper.newBrandset);
                            }
                              //OCR Changes
                            else{
                                
                                flavorChangeLineOutlet.FS_Only_Water_Dasani__c=True;
                            }
                            if(detailFlavorChangeWrapper.brandsetEffectiveDate!=null && detailFlavorChangeWrapper.brandsetEffectiveDate!=''){
                                flavorChangeLineOutlet.FS_BS_Effective_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.brandsetEffectiveDate);
                            }
                            flavorChangeLineOutlet.FS_Hide_Show_Water_Button__c=detailFlavorChangeWrapper.waterHideData;
                            flavorChangeLineOutlet.FS_WA_Effective_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.waterHideEffectvieDate);
                            flavorChangeLineOutlet.FS_DA_Effective_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.dasaniDataEffectvieDate);
                            flavorChangeLineOutlet.FS_Hide_Show_Dasani__c=detailFlavorChangeWrapper.dasaniData;
                            flavorChangeLineOutlet.recordtypeid=recTypeLineOutletOD;
                            //flavorChangeLineOutlet.FS_Final_Approval__c=true;
                            flavorChangeLineOutlet.FS_Flavor_Change_Requested_Date__c=FSUtil.dateParserHelper(detailFlavorChangeWrapper.requestedDate);
                            flavorChangeLineOutlet.FS_Pungent_Change_Indicator__c=detailFlavorChangeWrapper.pungentChangeIndicator;
                            flavorChangeLineOutlet.FS_SP_go_out__c=detailFlavorChangeWrapper.spNeedToGoOut;
                            flavorChangeLineOutletList.add(flavorChangeLineOutlet);
                        }
                }
            }
   
        try{
            if(!flavorChangeLineOutletList.isEmpty()){
                Database.insert(flavorChangeLineOutletList,false);
                
                system.debug('Result'+flavorChangeLineOutletList);
            }
            
        }
        
        catch(DMLException dmlExp){ ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateFlavorChangeBatchHelper','createFlavorChanges','FS_Flavor_Change_New__c','HIGH',dmlExp,dmlExp.getMessage());
        }
        
        createServiceOrder(outletZIPs,flavorChangeHeadOutletMap);
       
       }
    
         //This method creates the service orders based on spAlignedZip object
       public static void createServiceOrder(list<String> outletZIPs,Map<ID,FS_Flavor_Change_Head__c> flavorChangeHeadOutletMap){
          
           set<id> FCheadOutletIDs=new set<ID>();
        
           for(FS_Flavor_Change_Head__c fcOutletHead:flavorChangeHeadOutletMap.values()){
               FCheadOutletIDs.add(fcOutletHead.id);
           }
           List<FS_Service_Order__c> serviceOrderList = New List<FS_Service_Order__c> ();
           serviceOrderList=FSUtil.createServiceOrder(outletZIPs,flavorChangeHeadOutletMap);
            try{
                Database.insert(serviceOrderList,false);
              }
              catch(DMLException dmlExp){
                    ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateFlavorChangeBatchHelper','createFlavorChanges','FS_Service_Order__c','HIGH',dmlExp,dmlExp.getMessage());
           }           
           System.enqueueJob(new FSFlavorChangeHeaderQueueClass(FCheadOutletIDs));        
       }    
    public static void createSuccessFailureAttachments(String csvFileName,Id holderId,Blob csvBlob){
       Attachment attch =new Attachment();
       attch.body = csvBlob ;
       attch.parentId = holderId;
       attch.Name=csvFileName; 
       insert attch;
    }
    
    //Wrapper to store the values of uploaded csv file columns
    public class detailFlavorChangeWrapper{
            public string  outletACN{set;get;}
            public string   platform{set;get;}  
            public string   serialNumber{set;get;}
            public string   currentbrandset{set;get;}
            public string   newBrandset{set;get;}
            public string   brandsetEffectiveDate{set;get;}
            public string   waterHideData{set;get;}
            public string   waterHideEffectvieDate{set;get;}
            public string   dasaniData{set;get;}
            public string   dasaniDataEffectvieDate{set;get;}
            public string   pungentChangeIndicator{set;get;}
            public string   customerPayorAccountPay{set;get;}
            public string   requestedDate{set;get;}
            public string   productOrderHandeledBy{set;get;}            
            public string   dateProductidAvaliableInDC{set;get;}
            public string   NDOapprovalCheck{set;get;}
            public string   CDMSetupComplete{set;get;}
            public string   spNeedToGoOut{set;get;}
            public string   estimatedFlavorChangeDate{set;get;}
            public string   customerServiceNotes{set;get;}
            public string   POMActionsComplete{set;get;}
            public string   orderProcessed{set;get;}
            //public string   fcCommerciallyApproved{set;get;}
            public string   aCUser{set;get;}
            public string   aCUserName{set;get;}
            public string   projectID{set;get;}
            public string   projectDescription{set;get;}
            public string   pmUser{set;get;}
            public string   pmUserName{set;get;}
            public string   comUser{set;get;}
            public string   comUserName{set;get;}
            public string   scheduledDate{set;get;}
            //public string   customerReadiness{set;get;}
            public string   orderMethod{set;get;}
            public string   deliveryMethod{set;get;}
            public boolean  validationPassed{set;get;}
            public string   validationErrorMessage{set;get;}
        } 
    
}