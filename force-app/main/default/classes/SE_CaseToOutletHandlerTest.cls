/**************************************************************************************
Apex Class Name     : SE_CaseToOutletHandlerTest
Version             : 1.0
Function            : This test class is for FS_SelectOutletDispenserRemoveRelocate Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys            			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
public class SE_CaseToOutletHandlerTest{
    
    public static Account headQuarterAcc,outletAcc, defaultAccount, internationalOutlet, chainAccount,bottler;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;
    static RecordType recordType9000;
    static RecordType recType8000;
    static final string SERIES_7K='7000';
    public static User apiUser, coordinatorUser;
    public static FS_Outlet_Dispenser__c outletDispenser,outletDispenser1,outletDispenser2,outletDispenserInt,outletDispenserInt1;
    public static FS_Integration_NMS_User__c integrationUser;
    public static FS_IP_Technician_Instructions__c  ipTechInstruction;
    public static Shipping_Form__c shippingForm;
    public static Dispenser_Model__c dispenserModel;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    //-------------------------------------------------------------------------------------
    //Create Test Data For Account Update
    //-------------------------------------------------------------------------------------
    private static void createTestData(){
        try
        {       
            apiUser=FSTestUtil.createUser(null,null,'API User',false);
            coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
            chainAccount = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
            chainAccount.FS_ACN__c = '76876876';
            insert chainAccount;
            HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false); 
            HeadQuarterAcc.FS_ACN__c = '7658765876';
            insert HeadQuarterAcc;
            
            //Creates Outlet Accounts
            outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, true);
            bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
            defaultAccount = FSTestUtil.createAccountOutlet(FSConstants.defaultOutletName,FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, false);
            internationalOutlet = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET_INT,HeadQuarterAcc.Id,false);
            system.runAs(coordinatorUser){
                shippingForm = FSTestUtil.createShippingForm(true);
            }
            dispenserModel = FSTestUtil.createDispenserModel(true, '7000');
            //Creates execution plan
            executionPlan = FSTestUtil.createExecutionPlan(FSConstants.x7000SeriesRecType,HeadQuarterAcc.Id, true);
            //creates installation
            installation = FSTestUtil.createInstallationAcc(FSConstants.x7000SeriesRecType,executionPlan.Id,outletAcc.Id,true);      
            
            ipTechInstruction=FSTestUtil.createTechnicianInstructions('7000 Series',false);
            
            //creates initial order
            recType8000 = [SELECT Id, Name, DeveloperName
                           FROM RecordType where Name='7000 Series' limit 1];
            recordType9000= [Select r.Name From RecordType r where Name='8000/9000 Series' limit 1];
            
            outletDispenser = FSTestUtil.createOutletDispenserAllTypes(SERIES_7K,null,outletAcc.id,null,false);
            
            outletDispenser1 = FSTestUtil.createOutletDispenserAllTypes(SERIES_7K,null,outletAcc.id,null,false);
            outletDispenser2= FSTestUtil.createOutletDispenserAllTypes(SERIES_7K,null,outletAcc.id,null,false);        
            outletDispenserInt = FSTestUtil.createOutletDispenserAllTypes(SERIES_7K,null,internationalOutlet.id,null,false);
            outletDispenserInt1 = FSTestUtil.createOutletDispenserAllTypes(SERIES_7K,null,outletAcc.id,null,false);
            
        }
        catch(Exception e){
            system.debug('SE_CaseToODHandlerTest error:'+e.getMessage());
        }
    }  
    
    private static testmethod void checkCaseToOutletDispenserTrigger(){
        Test.startTest();
        createTestData();
        Try
        {
            outletDispenser1.FS_Outlet__c = outletAcc.Id;
            outletDispenser1.FS_Equip_Type__c  ='8000';
            outletDispenser1.FS_Serial_Number2__c='ZPL12345';
            outletDispenser1.FS_IsActive__c=true;
            insert outletDispenser1;         
           
            List<CaseToOutletdispenser__c> caseODList1=new List<CaseToOutletdispenser__c>();
            
            case sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c='7000 Series',Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c+','+outletDispenser2.FS_Serial_Number2__c);
            insert sampleCase;
            
            CaseToOutletdispenser__c caseToODJunction=new CaseToOutletdispenser__c (Case__c=sampleCase.id,Customer__c=outletAcc.Id,Outlet_Dispenser__c=outletDispenser1.id);
            insert caseToODJunction; 
            final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
            insert fetSysAdminUser;
            system.runAs(fetSysAdminUser){
                List<CaseToOutletdispenser__c> caseODList=new List<CaseToOutletdispenser__c>();
                caseODList=[select Case__c,Customer__c,Outlet_Dispenser__c,ZPL__c from CaseToOutletdispenser__c];
                SE_CaseToOutletHandler caseHandlerObj=new SE_CaseToOutletHandler();
                //caseHandlerObj.AfterDelete(caseODList);
                delete caseODList;
            }
            Test.stopTest();
        }
        catch(Exception exp){
            System.debug('Exception occurred - '+exp);
        }
    }    
}