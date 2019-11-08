/**************************************************************************************
Apex Class Name     : FSAssociationBrandsetTriggerTest
Version             : 1.0
Function            : This test class is for  FSAssociationBrandsetTrigger code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
public class FSAssociationBrandsetTriggerTest {
	private static List<FS_Brandset__c> branset7000List,branset8000List,branset9000List;
    private static Account headquartersAcc,outletAcc;
	private static FS_Execution_Plan__c executionPlan;
    private static FS_Installation__c installation;
    private static Profile fetSysAdmin;
    
    public static void createTestData(){

        //Create custom seting for platform type
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        //Create Recepients list
        
	     insert new FS_Brandset_Change_Recipient_List__c(name='TestUser',FS_Email__C='test@coca-cola.com',FS_User_Type__c = 'CDM');
         insert new FS_Brandset_Change_Recipient_List__c(name='TestUser1',FS_Email__C='test@coca-cola.com',FS_User_Type__c = 'POM');
        //create Brandset records
        final List<FS_Brandset__c> brandsetRecordList=FSTestFactory.createTestBrandset();  
        //Separate Brandset based on platform 
        branset7000List=new List<FS_Brandset__c>();
        branset8000List=new List<FS_Brandset__c>();
        branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecordList){
            if(branset.FS_Platform__c.contains('7000')){      branset7000List.add(branset);          }
            if(branset.FS_Platform__c.contains('8000')){      branset8000List.add(branset);          }           
            if(branset.FS_Platform__c.contains('9000')){      branset9000List.add(branset);          }
        }
        
        List<Account> insertAccounts = new List<Account>();
        //HQ Record
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        //Outlet Records
        outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
        outletAcc.ShippingPostalCode='1234';
        insertAccounts.add(headquartersAcc);
        insertAccounts.add(outletAcc);
        
        insert insertAccounts;
        
        //Creating Execution Plan Record
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);
        executionPlan.FS_Platform_Type__c='7000;8000;9000;9100';
        insert executionPlan;
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        FSTestFactory.createTestDisableTriggerSetting();
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id,false);      
       
    }
    
    public static testmethod void checkCDMnotificationUpdate(){
        
        createTestData();
         final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){ 
            installation.Type_of_Dispenser_Platform__c='8000;9000';
            installation.Overall_Status2__c= FSConstants.x4InstallSchedule;
            insert installation;
            
            insert new Disable_Trigger__c(name='FSInstallationBusinessProcess',IsActive__c=false);
            
            FS_Initial_Order__c io= new FS_Initial_Order__c();
            io.FS_Order_Processed__c=true;
            io.FS_Installation__c=installation.id;
            insert io;
            
            List<FS_Association_Brandset__c> listAb=[select id,FS_Brandset__c,FS_Installation__c,FS_Platform__c,FS_NonBranded_Water__c from FS_Association_Brandset__c where FS_Installation__c=:installation.Id];
            system.assertEquals(2, listAb.size());
            installation.Overall_Status2__c= FSConstants.x4InstallSchedule;
            update installation;
            for(FS_Association_Brandset__c abRec:listAb){
                if(abRec.FS_Platform__c=='8000' &&  !branset8000List.isEmpty() ){  abRec.FS_Brandset__c=branset8000List[0].Id;   }
                if(abRec.FS_Platform__c=='9000' &&  !branset9000List.isEmpty() ){  abRec.FS_Brandset__c=branset9000List[0].Id;   }
                abRec.FS_NonBranded_Water__c='Hide';
            }
            
     		test.startTest();
            update listAb;
            test.stopTest();
        }
    }
    
    public static testmethod void checkCDMnotificationDelete(){
        
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){ 
            installation.Type_of_Dispenser_Platform__c='8000;9000';
            installation.Overall_Status2__c= FSConstants.x4InstallSchedule;
            insert installation;
            insert new Disable_Trigger__c(name='FSAccountBusinessProcess',IsActive__c=false);
            insert new Disable_Trigger__c(name='FSInstallationBusinessProcess',IsActive__c=false);
            //FET 7.0 FNF-823
            insert new Disable_Trigger__c(name='FSInitialOrderHandler',IsActive__c=false);
            //FET 7.0 FNF-823
            FS_Initial_Order__c io= new FS_Initial_Order__c();
            io.FS_Order_Processed__c=true;
            io.FS_Installation__c=installation.id;
            insert io;
            insert new Disable_Trigger__c(name='FSInstallationBusinessProcess',IsActive__c=true);
            List<FS_Association_Brandset__c> listAb=[select id,FS_Brandset__c,FS_Installation__c,FS_Platform__c,FS_NonBranded_Water__c from FS_Association_Brandset__c where FS_Installation__c=:installation.Id];
            
            for(FS_Association_Brandset__c abRec:listAb){
                if(abRec.FS_Platform__c=='8000' &&  !branset8000List.isEmpty() ){  abRec.FS_Brandset__c=branset8000List[0].Id;   }
                if(abRec.FS_Platform__c=='9000' &&  !branset9000List.isEmpty() ){  abRec.FS_Brandset__c=branset9000List[0].Id;   }
                abRec.FS_NonBranded_Water__c='Hide';
            }
            update listAb;
            installation.Type_of_Dispenser_Platform__c='9000';
            installation.Overall_Status2__c= FSConstants.x4InstallSchedule;
            installation.Platform_change_approved__c=true;
            
            test.startTest();
            update installation;
            system.assertEquals(1, [select id from FS_Association_Brandset__c where FS_Installation__c=:installation.Id].size());
            test.stopTest();
        }
        
    }
    
    public static testmethod void insertABonHQ(){
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){ 
            FS_Association_Brandset__c ab=new FS_Association_Brandset__c();
            ab.FS_Platform__c='9000';
            ab.FS_Headquarters__c=headquartersAcc.id;
            ab.FS_Brandset__c=branset9000List[0].Id;
            insert ab;
            
            ab.FS_Brandset__c=branset9000List[1].Id;
            update ab;
            system.assertEquals(branset9000List[1].Id, ab.FS_Brandset__c);
        }
    }
    
}