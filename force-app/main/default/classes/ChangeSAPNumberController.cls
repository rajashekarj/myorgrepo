// ============================================================================
// (c) 2015 Appirio, Inc.
//
// Controller class for ChangeSAPNumber page
//
// Created By : Deepti Maheshwari
// Created on : 21st May 2015
// =============================================================================

public without sharing Class ChangeSAPNumberController{
    private FS_Outlet_Dispenser__c dispenser{get;set;}
    public FS_Outlet_Dispenser__c newdisp{get;set;}
    public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    public ChangeSAPNumberController(ApexPages.StandardController controller){
        dispenser = (FS_Outlet_Dispenser__c)controller.getRecord();
        
        Map <String, Schema.SObjectField> fieldMap = SchemaMap.get('FS_Outlet_Dispenser__c').getDescribe().fields.getMap();
        String csv = '';        
        for(Schema.SObjectField sfield : fieldMap.Values()){
            csv = csv + ',' + sField;
            
        }        
        String queryStr = 'SELECT ' + csv.replaceFirst(',', '') + ' FROM FS_Outlet_Dispenser__c WHERE Id = \'' + dispenser.id + '\'';         
        FS_Outlet_Dispenser__c dispenser = Database.query(queryStr);        
        newdisp = dispenser.clone(false,true,false,false);
        system.debug('new dispenser :' + newdisp);
    }
    
    public PageReference cloneDispenser(){
        PageReference pg;       
        try{
            newDisp.FS_IsActive__c = false;
            insert newDisp;
            system.debug('New Dispenser ::::' + newDisp);
            pg = new PageReference('/' + newDisp.id);        
        }Catch(Exception ex){
            system.debug('Exception in cloning: ' + ex);   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR , 'Error in Cloning'));
        }
        return pg;
    }
}