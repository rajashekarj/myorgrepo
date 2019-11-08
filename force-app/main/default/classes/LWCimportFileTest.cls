@istest
public class LWCimportFileTest {
    
    private static Account headQuarterAcc, outletAcc;
    private static FS_Execution_Plan__c executionPlan;       
    private static FS_Outlet_Dispenser__c outletDispenser,outletDispenser1,outletDispenser2,outletDispenser3;
    
   //private static FS_Brandset__c brandSet1;    
    private static String location='Test Location';
    private static String location2='Test Location 2';
    private static String noVal='No';    
    public static FS_Installation__c installation;
    private static List<FS_Outlet_Dispenser__c > addAllODs=new List<FS_Outlet_Dispenser__c> ();
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5; 
    	
    	@testSetup
      private static void createTestData(){        
        
        final List<Account> accList=new List<Account>();
        headQuarterAcc=new Account(Name='Test Account 2',FS_ACN__c='0001503594',ShippingCountry= 'US',RecordTypeId= FSConstants.RECORD_TYPE_HQ);
        accList.add(headQuarterAcc);
        outletAcc=new Account(Name='Test Account',FS_ACN__c='0001503594',ShippingCountry = 'US', RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId());
        accList.add(outletAcc);  
        insert accList;
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headQuarterAcc.id, true);       
   
        FSTestFactory.createTestDisableTriggerSetting();
        
        final Disable_Trigger__c disableABTrigger = new Disable_Trigger__c(Name='FSAssociationBrandsetTrigger',IsActive__c=false,Trigger_Name__c='FSAssociationBrandsetTrigger');
        insert disableABTrigger; 
        final String recTypeReplace=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Replacement_Rec_Type).getRecordTypeId() ;
        installation=new FS_Installation__c(FS_Outlet__c=outletAcc.id,Type_of_Dispenser_Platform__c='7000;8000;9000',FS_Execution_Plan__c=executionPlan.id,recordtypeid=recTypeReplace);
        insert installation;
        
        FSTestFactory.lstPlatform();        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final Disable_Trigger__c disableODTrigger = new Disable_Trigger__c(Name='FSODBusinessProcess',IsActive__c=false,Trigger_Name__c='Fs_OD_Trigger');
        insert disableODTrigger;
        outletDispenser=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,FS_Serial_Number2__c='ZPL000117M',FS_Dispenser_Location__c=location,
                                                   FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                   FS_Equip_Type__c='7000',FS_IsActive__c=true,Installation__c = installation.id );
        
        outletDispenser1=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,FS_Serial_Number2__c='ZPL349430U',FS_Dispenser_Location__c=location,
                                                    FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                    FS_Equip_Type__c='8000',FS_IsActive__c=true);
          
        addAllODs.add(outletDispenser);
        addAllODs.add(outletDispenser1);
        insert addAllODs;
    }
    
    static testmethod void testProcess(){
        final User sysAdminUser=FSTestUtil.createUser(null, 1, FSConstants.systemAdmin, true);
        
        System.runAs(sysAdminUser){
        String jSon='{"case":[{"Case Record Type":"North American Case","Account ACN":"6197188","Serials":"ZPL320889H;ZPL000117M","Issue Name":"ARS Case #1","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"9000 Series","Issue Categories":"Modem/Connectivity","Description of issue":"Case #1 description","Status":"New","Comment":"Part of the work orders for ARS to visit and replace internal modem with an external modem","Project ID":"67876543","Project Batch ID":"5678987654","Project Batch ID Date":"12/11/2019"},{"Case Record Type":"North American Case","Account ACN":"1503594","Serials":"ZPL349430U","Issue Name":"ARS Case #2","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"8000 Series","Issue Categories":"Mechanical","Description of issue":"Case #2 description","Status":"Assigned","Comment":"test","Project ID":"67889","Project Batch ID":"8765434567","Project Batch ID Date":"11/27/2018","Sub-Status":"In Progress"},{"Case Record Type":"North American Case","Account ACN":"1854833","Serials":"ZSA300646O;ZSA301212S","Issue Name":"ARS Case #3","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"7000 Series","Issue Categories":"Mechanical","Description of issue":"Case #3 description","Status":"Assigned","Comment":"Case #3 comments","Project ID":"234234","Project Batch ID":"8765434512","Project Batch ID Date":"5/14/19","Sub-Status":"In Progress"}]}';
        LWCimportFile.sendJson(jSon);
        }
    }
    static testmethod void testProcess1(){
        final User sysAdminUser=FSTestUtil.createUser(null, 1, FSConstants.systemAdmin, true);
        
        System.runAs(sysAdminUser){
        String jSon='{"case":[{"Case Record# Type":"North American Case","Account ACN":"6197188","Serials":"-/nZPL320889H;ZPL000117M","Issue Name":"ARS Case #1","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"9000 Series","Issue Categories":"Modem/Connectivity","Description of issue":"Case #1 description","Status":"New","Comment":"Part of the work orders for ARS to visit and replace internal modem with an external modem","Project ID":"67876543","Project Batch ID":"5678987654","Project Batch ID Date":"12/11/2019"},{"Case Record Type":"North American Case","Account ACN":"1503594","Serials":"ZPL349430U","Issue Name":"ARS Case #2","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"8000 Series","Issue Categories":"Mechanical","Description of issue":"Case #2 description","Status":"Assigned","Comment":"test","Project ID":"67889","Project Batch ID":"8765434567","Project Batch ID Date":"11/27/2018","Sub-Status":"In Progress"},{"Case Record Type":"North American Case","Account ACN":"1854833","Serials":"ZSA300646O;ZSA301212S","Issue Name":"ARS Case #3","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"7000 Series","Issue Categories":"Mechanical","Description of issue":"Case #3 description","Status":"Assigned","Comment":"Case #3 comments","Project ID":"234234","Project Batch ID":"8765434512","Project Batch ID Date":"5/14/19","Sub-Status":"In Progress"}]}';
        LWCimportFile.sendJson(jSon);
        }
    }
     static testmethod void testProcess2(){
         final User sysAdminUser=FSTestUtil.createUser(null, 1, FSConstants.systemAdmin, true);
        
        System.runAs(sysAdminUser){
        String jSon='{"case":[{"Case Record Type":"North American Case","Account ACN":"1503594","Serials":"ZPL349430U;ZPL000117M","Issue Name":"ARS Case #1","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"9000 Series","Issue Categories":"Modem/Connectivity","Description of issue":"Case #1 description","Status":"New","Comment":"Part of the work orders for ARS to visit and replace internal modem with an external modem","Project ID":"67876543","Project Batch ID":"5678987654","Project Batch ID Date":"12/11/2019"},{"Case Record Type":"North American Case","Account ACN":"1503594","Serials":"ZPL349430U","Issue Name":"ARS Case #2","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"8000 Series","Issue Categories":"Mechanical","Description of issue":"Case #2 description","Status":"Assigned","Comment":"test","Project ID":"67889","Project Batch ID":"8765434567","Project Batch ID Date":"11/27/2018","Sub-Status":"In Progress"},{"Case Record Type":"North American Case","Account ACN":"1854833","Serials":"ZSA300646O;ZSA301212S","Issue Name":"ARS Case #3","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"7000 Series","Issue Categories":"Mechanical","Description of issue":"Case #3 description","Status":"Assigned","Comment":"Case #3 comments","Project ID":"234234","Project Batch ID":"8765434512","Project Batch ID Date":"5/14/19","Sub-Status":"In Progress"}]}';
        LWCimportFile.sendJson(jSon);
        }
    }
    
     static testmethod void testProcess3(){
         final User sysAdminUser=FSTestUtil.createUser(null, 1, FSConstants.systemAdmin, true);
        
        System.runAs(sysAdminUser){
        String jSon='{"case":[{"Case Record Type":"North American Case","Account ACN":"6197188","Serials":"ZzPL333220889H;ZPL0334500117M","Issue Name":"ARS Case #1","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"9000 Series","Issue Categories":"Modem/Connectivity","Description of issue":"Case #1 description","Status":"New","Comment":"Part of the work orders for ARS to visit and replace internal modem with an external modem","Project ID":"67876543","Project Batch ID":"5678987654","Project Batch ID Date":"12/11/2019"},{"Case Record Type":"North American Case","Account ACN":"1503594","Serials":"ZP43L349430U","Issue Name":"ARS Case #2","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"8000 Series","Issue Categories":"Mechanical","Description of issue":"Case #2 description","Status":"Assigned","Comment":"test","Project ID":"67889","Project Batch ID":"8765434567","Project Batch ID Date":"11/27/2018","Sub-Status":"In Progress"},{"Case Record Type":"North American Case","Account ACN":"1854833","Serials":"ZSA300646O;ZSA301212S","Issue Name":"ARS Case #3","Request Type":"STA Request","Case Category":"Mechanical","Priority":"Medium Decreased Functionality","FS Dispenser Type":"7000 Series","Issue Categories":"Mechanical","Description of issue":"Case #3 description","Status":"Assigned","Comment":"Case #3 comments","Project ID":"234234","Project Batch ID":"8765434512","Project Batch ID Date":"5/14/19","Sub-Status":"In Progress"}]}';
        LWCimportFile.sendJson(jSon);
        }
}
}