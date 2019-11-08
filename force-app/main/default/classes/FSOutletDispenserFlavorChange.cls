/*********************************************************************************************************
Name         : FSOutletDispenserFlavorChange
Created By   : Infosys Limited 
Created Date : 12-May-2017
Usage        : Custom Controller for FSOutletDispenserFlavorChange which is used create Flavor Change Header/Line.

********************* **************************************************************************************/
public class FSOutletDispenserFlavorChange{
    
    public Id dispenserId ;
    public List<FS_Flavor_Change_New__c> newFlavorChangeData{set;get;}
    
    @TestVisible
    private Object nullConstant=NULL;
   
    private final static Integer numVal5=5;
    @TestVisible
    private enum stringLiterals{Yes,Medium,NA} 
    //Enum has all the method names that perform DML
    @TestVisible
    private enum methodNamesDML{createFlavorChangeHeader,createFlavorChange,createServiceOrder} 
    
    @TestVisible                            
    private enum flavorChangeErrorMessageHeader {EarlyDateError,EffBrandsetRequired,NewBrandsetRequired,
                                       EffDasainiDateRequired,DasaniRequired,EffWaterButtonDateRequired,
                                       WaterButtonRequired,PungentChangeRequired,SpNeedsToGoOutRequired}
                                       
    private final static String falvorChangeOutletRecordType='FS Flavor Change Outlet'; 
    private final static String falvorChangeLineDispenserRecordType='FS Flavor Change Outlet Dispenser';         
    private final static String flavorChangeHeadSobject='FS_Flavor_Change_Head__c';
    private final static String flavorChangeSobject='FS_Flavor_Change_New__c';
    private final static String serviceOrderSobject='FS_Service_Order__c';
    
    private final static String appName='FET';
    private final static String className='FSOutletDispenserFlavorChange';
    private final static String flavorChangeType='Workflow Flavor Change';
                                       
    public FSOutletDispenserFlavorChange() {
        dispenserId =  ApexPages.currentPage().getParameters().get('odId');
        newFlavorChangeData=new List<FS_Flavor_Change_New__c>();
        
        populateFlavorChangeInput();
    }
    
    
    
    
    public Map<String,FS_Flavor_Change_New__c> setCurrentBrandsetValues(){
        Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap=new Map<String,FS_Flavor_Change_New__c>();
       
        for(Fs_flavor_change_new__c flavorChange :newFlavorChangeData){
            if(flavorChange.FS_New_Brandset__c!=nullConstant ||  flavorChange.FS_Hide_Show_Dasani__c!=nullConstant
                    ||  flavorChange.FS_Hide_Show_Water_Button__c!=nullConstant){
                newPlatformBrandsetFlavorChangeMap.put(flavorChange.FS_Current_Brandset__c+flavorChange.FS_Platform__c,flavorChange );
            }
              
        }
       return newPlatformBrandsetFlavorChangeMap;
     }
     
     
      
         
     
    public pageReference populateFlavorChangeInput(){
     
        Map<String,FS_Flavor_Change_New__c> existingPlatformBrandsetFlavorChangeMap=new Map<String,FS_Flavor_Change_New__c>();
       
        for(FS_Association_Brandset__c  associationBrandset: fetchAssociationBrandsets()) {
            String key=associationBrandset.FS_Brandset__c+associationBrandset.FS_Platform__c; 
            
            FS_Flavor_Change_New__c flavorChangeNew=new FS_Flavor_Change_New__c();
            flavorChangeNew.FS_Platform__c=associationBrandset.FS_Platform__c;
            flavorChangeNew.FS_Current_Brandset__c=associationBrandset.FS_Brandset__c;
            flavorChangeNew.FS_Current_Brandset_Name_txt__c=associationBrandset.FS_Brandset__r.FS_Brandset_Number__c;   
            flavorChangeNew.FS_Outlet__c=associationBrandset.FS_Outlet_Dispenser__r.FS_Outlet__c;
            existingPlatformBrandsetFlavorChangeMap.put(key,flavorChangeNew);   
                
        }
       
        for(String platfromBrandset  :  existingPlatformBrandsetFlavorChangeMap.keyset()){
            newFlavorChangeData.add(existingPlatformBrandsetFlavorChangeMap.get(platfromBrandset));
        }
       return null;
     }
     
     public List<FS_Association_Brandset__c> fetchAssociationBrandsets(){
           
        return [SELECT Id,FS_Platform__c,name,FS_Brandset__c,FS_Outlet_Dispenser__c,
                FS_Brandset__r.FS_Brandset_Number__c,FS_Outlet_Dispenser__r.FS_outlet__c,
                FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode 
                FROM FS_Association_Brandset__c where FS_Outlet_Dispenser__c =: dispenserId];
     }
     
    public pagereference backToPrevious(){
        return new PageReference('/' + dispenserId);
    }
    
    
    public pageReference saveFlavorChange(){   
        Boolean validation=false;
        PageReference pageRef;
      
        if(!newFlavorChangeData.isEmpty()) {validation = validateCurrentBrandAttributes();}
        
        if(validation){
            //Create a savepoint
            Savepoint savepoint1 = Database.setSavepoint();
           
            FS_Flavor_Change_Head__c flavorChangeHeadOutlet=createRecordsRelatedToOutlet();
            if(flavorChangeHeadOutlet!= nullConstant){                 
                pageRef=new Pagereference('/'+flavorChangeHeadOutlet.Id);
            }
            else{
             // Rollback to the previous null value
                Database.rollback(savepoint1);
            }
           
        }
        return pageRef;
    }
    
    public FS_Flavor_Change_Head__c  createRecordsRelatedToOutlet(){
         
        //Variable to be returned
        FS_Flavor_Change_Head__c  returnReference;
        List<String> outletZipCodes =new List<String>();  
        List<FS_Association_Brandset__c> associationBrandsetRecords=fetchAssociationBrandsets();
        for(FS_Association_Brandset__c assosiatedBrandset : associationBrandsetRecords){
            if(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode!= nullConstant){
             outletZipCodes.add(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode);
            }
        }
         
        //Refer user selected values
        Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap=setCurrentBrandsetValues();
         
        if(!newPlatformBrandsetFlavorChangeMap.isEmpty()){
            //Create Flavor Change Header
            Map<Id,FS_Flavor_Change_Head__c> flavorChangeHeaderOutletMap=createFlavorChangeHeader(associationBrandsetRecords,newPlatformBrandsetFlavorChangeMap);
            //Create Flavor Change 
            createFlavorChange(flavorChangeHeaderOutletMap,associationBrandsetRecords,newPlatformBrandsetFlavorChangeMap);
            //Create Service Order
            createServiceOrder(outletZipCodes,flavorChangeHeaderOutletMap);
             
            returnReference= flavorChangeHeaderOutletMap.values()[0];
        }
         return returnReference;
     }
    
    public Map<Id,FS_Flavor_Change_Head__c> createFlavorChangeHeader(List<FS_Association_Brandset__c> associationBrandsetRecords,
                                                                      Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap){
      
        //Collection with Outlet Id as key and Flavor Change Header as values
        Map<Id,FS_Flavor_Change_Head__c> flavorChangeHeaderOutletMap=new Map<Id,FS_Flavor_Change_Head__c>();
       
        Id recTypeHeadOutlet=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_Head__c.SObjectType,falvorChangeOutletRecordType);
       
       
        //Iterate over association brandset
        for(FS_Association_Brandset__c assosiatedBrandset: associationBrandsetRecords){
            if(newPlatformBrandsetFlavorChangeMap.containsKey(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c)){
                FS_Flavor_Change_New__c inputFlavorChange=newPlatformBrandsetFlavorChangeMap.get(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c);
              
                if(!flavorChangeHeaderOutletMap.containsKey(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c)){
              
                    FS_Flavor_Change_Head__c flavorChangeHeadOutlet=new FS_Flavor_Change_Head__c();       
                    flavorChangeHeadOutlet.FS_HQ_Chain__c=assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c;
                    flavorChangeHeadOutlet.FS_FC_Type__c=flavorChangeType;
                    flavorChangeHeadOutlet.RecordTypeId=recTypeHeadOutlet;
                    flavorChangeHeadOutlet.FS_Pungent_Change_Indicator__c=inputFlavorChange.FS_Pungent_Change_Indicator__c;
                    flavorChangeHeadOutlet.FS_SP_go_out__c=inputFlavorChange.FS_SP_go_out__c;
                      
                    flavorChangeHeaderOutletMap.put(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c,flavorChangeHeadOutlet);
                }
           }
       }
       
        try{
            insert flavorChangeHeaderOutletMap.values();
        }
        catch(DMLException ex){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
           ApexErrorLogger.addApexErrorLog(appName,className,methodNamesDML.createFlavorChangeHeader.name(),
                                           flavorChangeHeadSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name());
           flavorChangeHeaderOutletMap=new Map<Id,FS_Flavor_Change_Head__c>();
        }
        return flavorChangeHeaderOutletMap;
     }
      
    public List<FS_Flavor_Change_New__c> createFlavorChange(Map<Id,FS_Flavor_Change_Head__c> flavorChangeHeaderOutletMap,
                                                             List<FS_Association_Brandset__c> associationBrandsetRecords,
                                                             Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap){
      
        List<FS_Flavor_Change_New__c> flavorChangeLineOutletList=new List<FS_Flavor_Change_New__c>();
        Set<ID> outID=new Set<ID>();
        Id recTypeLineOutletOD=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_New__c.SObjectType,falvorChangeLineDispenserRecordType);
      
        for(FS_Association_Brandset__c assosiatedBrandset : associationBrandsetRecords){
            if(newPlatformBrandsetFlavorChangeMap.containsKey(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c)){
                FS_Flavor_Change_New__c inputFlavorChange=newPlatformBrandsetFlavorChangeMap.get(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c);
                Id outletId=assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c;
                if(flavorChangeHeaderOutletMap.containsKey(outletId)){
            
                    FS_Flavor_Change_New__c fcLineOutlet=new FS_Flavor_Change_New__c ();
                    fcLineOutlet.FS_FC_Head__c=flavorChangeHeaderOutletMap.get(outletId).id;
                    fclineOutlet.RecordTypeId=recTypeLineOutletOD;
                    fcLineOutlet.FS_outlet__c=assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c;
                    fcLineOutlet.FS_Outlet_Dispenser__c=assosiatedBrandset.FS_Outlet_Dispenser__c;
                    fcLineOutlet.FS_Platform__c =assosiatedBrandset.FS_Platform__c;
                    fcLineOutlet.FS_Current_Brandset__c =assosiatedBrandset.FS_Brandset__c;
                    fcLineOutlet.FS_New_Brandset__c=inputFlavorChange.FS_New_Brandset__c;
                    fcLineOutlet.FS_BS_Effective_Date__c=inputFlavorChange.FS_BS_Effective_Date__c;
                    //fcLineOutlet.FS_Hide_Show_Dasani__c=inputFlavorChange.FS_Hide_Show_Dasani__c;
                    fcLineOutlet.FS_Hide_Show_Water_Button__c=inputFlavorChange.FS_Hide_Show_Water_Button__c;
                    //fcLineOutlet.FS_DA_Effective_Date__c=inputFlavorChange.FS_DA_Effective_Date__c;
                    fcLineOutlet.FS_WA_Effective_Date__c=inputFlavorChange.FS_WA_Effective_Date__c;
                    fcLineOutlet.FS_Flavor_Change_Requested_Date__c=inputFlavorChange.FS_Flavor_Change_Requested_Date__c;
                    fcLineOutlet.FS_SP_go_out__c=inputFlavorChange.FS_SP_go_out__c;
                    fcLineOutlet.FS_Pungent_Change_Indicator__c=inputFlavorChange.FS_Pungent_Change_Indicator__c;
                    //OCR changes
                    if(inputFlavorChange.FS_New_Brandset__c==nullConstant)
                    {
                        outID.add(flavorChangeHeaderOutletMap.get(outletId).id);
                        
                        fcLineOutlet.FS_Only_Water_Dasani__c= true;
                    }
                    flavorChangeLineOutletList.add(fcLineOutlet);
                }
            }
       }
       
        try{
          insert flavorChangeLineOutletList;
         //OCR'17:to update schedule date
            List<FS_Flavor_Change_Head__c> outletWithNoBS=[Select Id,Name,FS_SP_Scheduled_Date__c,(SELECT Id,FS_Only_Water_Dasani__c,FS_WA_Effective_Date__c,FS_DA_Effective_Date__c  FROM Flavor_Changes_New__r LIMIT 1) from FS_Flavor_Change_Head__c where ID in :outID ];
            
            
            List<FS_Flavor_Change_Head__c> outlet = new List<FS_Flavor_Change_Head__c>();
            if(!outletWithNoBS.isEmpty()){
             for(FS_Flavor_Change_Head__c value:outletWithNoBS )
             {
                 List<FS_Flavor_Change_New__c> lineItems =value.Flavor_Changes_New__r;
                 if(lineItems.size()>FSConstants.ZERO){
                     if(lineItems[0].FS_WA_Effective_Date__c!=nullConstant){
                         value.FS_SP_Scheduled_Date__c=lineItems[0].FS_WA_Effective_Date__c;
                     }
                     else{
                         value.FS_SP_Scheduled_Date__c=lineItems[0].FS_DA_Effective_Date__c;
                     }
                 }
                 outlet.add(value); 
             }
            update  outlet;
        }
        }
        catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            ApexErrorLogger.addApexErrorLog(appName,className,methodNamesDML.createFlavorChange.name(),
                                        flavorChangeSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name());
                                        
            flavorChangeLineOutletList=new List<FS_Flavor_Change_New__c>();
       }
        return flavorChangeLineOutletList;
     }
     //Creating dummy Service orders to Outlet level
     //Falvor change header where SP needs to go out Value is 'yes'
     public void createServiceOrder(List<String> outletZipCodes, Map<Id,FS_Flavor_Change_Head__c> flavorChangeHeaderOutletMap){
        
         List<FS_Service_Order__c> serviceOrderList=new List<FS_Service_Order__c>();
        
      
        serviceOrderList=FSUtil.createServiceOrder(outletZipCodes,flavorChangeHeaderOutletMap);
        
        try{
            insert serviceOrderList;
        }
        catch(DMLException ex){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                               ApexErrorLogger.addApexErrorLog(appName,className,methodNamesDML.createServiceOrder.name(),
                                                               serviceOrderSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name()); }
           
     }
     
     
     
    public Boolean validateCurrentBrandAttributes() {
        Boolean validationPassed=true;
        Boolean userInputsAtleastOneValidRow=false;
        Map<String, FS_FlavorChange_ErrorMessages__c> errorMessages= FS_FlavorChange_ErrorMessages__c.getAll();
           for(FS_Flavor_Change_New__c flavorChange :newFlavorChangeData){
               if(flavorChange.FS_New_Brandset__c!=nullConstant ||  flavorChange.FS_Hide_Show_Water_Button__c!=nullConstant){
                    validationPassed=attributesAndDatesValidation(flavorChange,errorMessages);
                    userInputsAtleastOneValidRow=validationPassed;
                }
            } 
           
            if(!userInputsAtleastOneValidRow){
                for(FS_Flavor_Change_New__c flavorChange :newFlavorChangeData){
                  validationPassed=attributesAndDatesValidation(flavorChange,errorMessages); 
                }
            } 
      
       return validationPassed;
    }
     
    public Boolean attributesAndDatesValidation(FS_Flavor_Change_New__c flavorChange,Map<String, FS_FlavorChange_ErrorMessages__c> errorMessages){
        Boolean validationPassed=true;
        
        if((flavorChange.FS_BS_Effective_Date__c<Date.today())||(flavorChange .FS_DA_Effective_Date__c < Date.today())
            ||(flavorChange.FS_WA_Effective_Date__c < Date.today())){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages.get(flavorChangeErrorMessageHeader.EarlyDateError.name()).FS_Error_Message__c));
           validationPassed= false;
        }
       //Added for FS_Flavor_Change_Requested_Date__c validation
        if(flavorChange.FS_Flavor_Change_Requested_Date__c<Date.today()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Requested Date cannot be earlier than today’s date'));
            validationPassed= false;
        }
        Account acc = [SELECT Id,FS_Final_Delivery_Method__c,FS_Final_Order_Method__c FROM Account WHERE Id=:flavorChange.FS_Outlet__c];
        if(acc.FS_Final_Order_Method__c == null || acc.FS_Final_Delivery_Method__c == null){
            system.debug('OD'+ acc.FS_Final_Order_Method__c);
            
            system.debug('Delivery'+flavorChange.FS_Outlet__r.FS_Final_Delivery_Method__c);
            system.debug('Delivery'+flavorChange.FS_FC_Head__r.FS_HQ_Chain__r.FS_Final_Order_Method__c);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure the order and delivery methods are present against this outlet, otherwise the flavor change workflow will not work'));
            validationPassed= false;
        }
        if(flavorChange.FS_New_Brandset__c!=nullConstant  && flavorChange.FS_BS_Effective_Date__c== nullConstant){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.EffBrandsetRequired.name()).FS_Error_Message__c));
           validationPassed= false;
        }
        
         if(flavorChange.FS_New_Brandset__c==nullConstant  && flavorChange.FS_BS_Effective_Date__c!= nullConstant ){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.NewBrandsetRequired.name()).FS_Error_Message__c));
           validationPassed= false;
        }
        /* Commented as part of FFET-651 FET5.1
        if(flavorChange.FS_Hide_Show_Dasani__c!=nullConstant && flavorChange.FS_DA_Effective_Date__c== nullConstant ){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.EffDasainiDateRequired.name()).FS_Error_Message__c));
           validationPassed= false;
         }
         if(flavorChange.FS_Hide_Show_Dasani__c==nullConstant && flavorChange.FS_DA_Effective_Date__c!= nullConstant ){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.DasaniRequired.name()).FS_Error_Message__c));
           validationPassed= false;
         }*/
         if(flavorChange.FS_Hide_Show_Water_Button__c!=nullConstant && flavorChange.FS_WA_Effective_Date__c==nullConstant ){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.EffWaterButtonDateRequired.name()).FS_Error_Message__c));
           validationPassed= false;
         }
         if(flavorChange.FS_Hide_Show_Water_Button__c==nullConstant && flavorChange.FS_WA_Effective_Date__c!=nullConstant ){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages.get(flavorChangeErrorMessageHeader.WaterButtonRequired.name()).FS_Error_Message__c));
           validationPassed= false;
         }
         if(flavorChange.FS_New_Brandset__c==nullConstant &&  flavorChange.FS_BS_Effective_Date__c==nullConstant && flavorChange.FS_DA_Effective_Date__c==nullConstant && flavorChange.FS_WA_Effective_Date__c==nullConstant && flavorChange.FS_Hide_Show_Dasani__c==nullConstant
            &&  flavorChange.FS_Hide_Show_Water_Button__c==nullConstant){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A value change with an effective date needs to be provided in order to proceed to the next step'));
           validationPassed= false;
         }
         
          if(flavorChange.FS_New_Brandset__c!=nullConstant && string.isBlank(flavorChange.FS_Pungent_Change_Indicator__c)){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages.get(flavorChangeErrorMessageHeader.PungentChangeRequired.name()).FS_Error_Message__c));
           validationPassed= false;
         }
        if(flavorChange.FS_New_Brandset__c!=nullConstant && string.isBlank(flavorChange.FS_SP_go_out__c)){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages.get(flavorChangeErrorMessageHeader.SpNeedsToGoOutRequired.name()).FS_Error_Message__c));
           validationPassed= false;
         }
        return validationPassed;
    }
}