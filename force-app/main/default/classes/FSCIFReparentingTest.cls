@isTest
public class FSCIFReparentingTest {
    
    private static final string FPS = 'FS PM_P';
    private static final string COM = 'COM';
    private static CIF_Header__c cifHead;
    private static CIF_Header__c updCifHead;
    private static final string ACCID = 'AccId';
    private static final string IDSTRING = 'id';
    private static final string PROG_STATUS='In Progress';
    private static final string CLOSED_STATUS='Closed – Converted to EP';
    private Static Id recTypeHQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Headquarters');
    private static List<String> updAcntIdList=new List<String>();
    private static List<Account> updAcntList=new List<Account>();
    private static List<Account> updAcntList1=new List<Account>();
    private static List<Account> updAcntList2=new List<Account>();
    private static List<FS_CIF__c> cifList=new List<FS_CIF__c>();
    private static List<Account> hqList=new List<Account>();
    private static FS_Execution_Plan__c executionPlan;
    private static FS_Installation__c installation;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    @testSetup
    private static void loadTestData(){
        Integer count=0;
         List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSAccountBusinessProcess','FSInstallationBusinessProcess','FSExecutionPlanTriggerHandler'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
        final List<Account> hqCustList= FSTestFactory.createTestAccount(true,4,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        final List<User> userLst = new List<User>();
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        System.runAs(sysAdmin){
            final Profile comProf = FSTestFactory.getProfileId('FS COM_P');
            final User comUserID = FSTestFactory.createUser(comProf.id);
            userLst.add(comUserID);
            final Profile fpsProf = FSTestFactory.getProfileId(FPS);
            final User fpsUserID = FSTestFactory.createUser(fpsProf.id);
            userLst.add(fpsUserID);
        }
        insert userLst;
        //Create Account Team Member
        final List<AccountTeamMember__c> atmLst = new List<AccountTeamMember__c>();
        final AccountTeamMember__c atmCom=new AccountTeamMember__c();
        atmCom.AccountId__c=hqCustList[0].id;
        atmCom.TeamMemberRole__c =COM;
        atmCom.UserId__c =userLst[0].id;
        atmLst.add(atmCom);
        final AccountTeamMember__c atmSales=new AccountTeamMember__c();
        atmSales.AccountId__c=hqCustList[0].id;
        atmSales.TeamMemberRole__c ='Sales Team Member';
        atmSales.UserId__c =userLst[0].id;
        atmLst.add(atmSales);
        Insert atmLst;
        
        system.runAs(userLst[1])
        {
            //Create Contact
            final Contact cntct = FSTestUtil.createTestContact(hqCustList[0].id, 'New Contact', false);
            cntct.phone='9874563210';
            cntct.email='newcontact@mail.com';
            insert cntct;    
        }
        
        //Create Outlets
        final List<Account> outletCustList= FSTestFactory.createTestAccount(false,25,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        for(Account acc:outletCustList){
            acc.FS_Headquarters__c = hqCustList.get(0).id;
            acc.FS_ACN__c = '00001673'+count;
            count++;
        }
        Insert outletCustList;
        //Creating cifHead
        cifHead = new CIF_Header__c();
        cifHead.Name =hqCustList[0].name+' V.0';
        cifHead.FS_Version__c = 10.02;
        cifHead.FS_HQ__c=hqCustList[0].id;
        cifHead.FS_Status__c=PROG_STATUS;
        insert cifHead;
        //Creating CIF records
        final List<FS_CIF__c> cifLst = new  List<FS_CIF__c>();
        final FS_CIF__c cif = new FS_CIF__c();
        cif.CIF_Head__c = cifHead.id;
        cif.FS_Account__c = outletCustList[0].id;
        cif.FS_Headquarters__c =hqCustList[0].id; 
        cif.FS_Platform1__c='7000';
        cif.FS_Platform1_Qty__c = 15;
        cifLst.add(cif);
        
        final FS_CIF__c cif1 = new FS_CIF__c();
        cif1.CIF_Head__c = cifHead.id;
        //Edited 12 Dec - Assigned different account to cif
        cif1.FS_Account__c = outletCustList[1].id;
        cif1.FS_Headquarters__c =hqCustList[0].id; 
        cif.FS_Platform1__c='7000';
        cif.FS_Platform1_Qty__c = 12;
        cifLst.add(cif1);
        
        insert cifLst;
        //FSTestFactory.createTestDisableTriggerSetting();
    }
    
    
    private static testmethod void testNoReparent(){        
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        test.startTest();
        system.runAs(fetSysAdminUser){
            pageLoadUnderHQ(parentRecord.id,cifHead);
        }
        test.stopTest();
                System.assertNotEquals(fetSysAdminUser,null);
    }
    
    private static testmethod void testPartialReparentDiffHQs(){
        
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  and id=:cifHead.FS_HQ__c];
        
        cifList=[select id, name,FS_Account__c from FS_CIF__c where CIF_Head__c=:cifHead.id];
        
        hqList=[select id, name from Account where RecordTypeId=:recTypeHQ and id!=:cifHead.FS_HQ__c];
        
        //updating outlet's HQ
        updAcntList1=[Select id, name, fs_headquarters__c from Account where id=:cifList.get(0).fs_account__c];
        updAcntList1[0].FS_Headquarters__c=hqList[0].id;
        
        
        updAcntList2=[Select id, name, fs_headquarters__c from Account where id=:cifList.get(1).fs_account__c];
        updAcntList2[0].FS_Headquarters__c=hqList[1].id;
        
        updAcntList.add(updAcntList1[0]);
        updAcntList.add(updAcntList2[0]);
        
        update updAcntList;
        test.startTest();
        update cifHead;
        
        final List<FS_CIF__c> cifListNew=[select id, name,FS_Account__r.fs_headquarters__c from FS_CIF__c where CIF_Head__c=:cifHead.id];
        system.assertNotEquals(cifHead.FS_HQ__c, cifListNew.get(0).FS_Account__r.fs_headquarters__c);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            pageLoadUnderHQ(parentRecord.id,cifHead);
        }  
        test.stopTest();
    }
    
    private static testmethod void testPartialReparent(){        
        
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c,FS_Status__c from CIF_Header__c Limit 1];
        
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  and id=:cifHead.FS_HQ__c];
        
        cifList=[select id, name,FS_Account__c from FS_CIF__c where CIF_Head__c=:cifHead.id];
        
        hqList=[select id, name from Account where RecordTypeId=:recTypeHQ and id!=:cifHead.FS_HQ__c];
        
        //updating outlet's HQ
        updAcntList=[Select id, name, fs_headquarters__c from Account where id=:cifList.get(0).fs_account__c];
        updAcntList[0].FS_Headquarters__c=hqList[0].id;
        
        update updAcntList;
        test.startTest();
        final List<FS_CIF__c> cifListNew=[select id, name,FS_Account__r.fs_headquarters__c from FS_CIF__c where CIF_Head__c=:cifHead.id];
        system.assertNotEquals(cifHead.FS_HQ__c, cifListNew.get(0).FS_Account__r.fs_headquarters__c);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            pageLoadUnderHQ(parentRecord.id,cifHead);  
        }
       test.stopTest();
    }
    
    private static testmethod void testPartialReparentClosedCIF(){
        
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c,FS_Status__c,FS_EP__c from CIF_Header__c Limit 1];
        
        cifList=[select id, name,FS_Account__c from FS_CIF__c where CIF_Head__c=:cifHead.id];
        
        //creating execution plan record
        executionPlan=FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,cifhead.FS_HQ__c, false); 
        executionPlan.FS_Execution_Plan_Status__c=PROG_STATUS;
        insert executionPlan;
        
        cifhead.FS_Status__c=CLOSED_STATUS;
        cifhead.FS_EP__c=executionPlan.id;
        update cifhead;
      
        //creating installation record
        installation=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id, cifList.get(0).fs_account__c, true);
                     
        cifList.get(0).FS_Installation__c=installation.id;
        update cifList;
        
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  and id=:cifHead.FS_HQ__c];
        
        hqList=[select id, name from Account where RecordTypeId=:recTypeHQ and id!=:cifHead.FS_HQ__c];
        
        //updating outlet's HQ
        updAcntList=[Select id, name, fs_headquarters__c from Account where id=:cifList.get(0).fs_account__c];
        updAcntList[0].FS_Headquarters__c=hqList[0].id;
        test.startTest();
        update updAcntList;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;    
       
        FSUpdateExecutionPlan.updateReparentedInst(cifhead.id);
        system.runAs(fetSysAdminUser){
            final List<FS_CIF__c> cifListNew=[select id, name,FS_Account__r.fs_headquarters__c from FS_CIF__c where CIF_Head__c=:cifHead.id];
            system.assertNotEquals(cifHead.FS_HQ__c, cifListNew.get(0).FS_Account__r.fs_headquarters__c);
            
            pageLoadUnderHQ(parentRecord.id,cifHead);   
        }
        
       test.stopTest();
    }
    
    private static testmethod void testAllReparent(){
        
       
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  and id=:cifHead.FS_HQ__c];
        
        cifList=[select id, name,FS_Account__c from FS_CIF__c where CIF_Head__c=:cifHead.id];
        
        hqList=[select id, name from Account where RecordTypeId=:recTypeHQ and id!=:cifHead.FS_HQ__c];
        
        for(FS_CIF__c cif:cifList){
            updAcntIdList.add(cif.FS_Account__c);
        }
        updAcntList=[select id,name from Account where id IN:updAcntIdList];
        for(Account a:updAcntList){
            a.FS_Headquarters__c=hqList[0].id;
        }
        update updAcntList;
        
        cifHead.FS_HQ__c=hqList[0].id;
        update cifHead;
        test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            
            final List<FS_CIF__c> cifListNew=[select id, name,FS_Account__r.fs_headquarters__c from FS_CIF__c where CIF_Head__c=:cifHead.id];
            system.assertEquals(cifHead.FS_HQ__c, cifListNew.get(0).FS_Account__r.fs_headquarters__c);
            
            pageLoadUnderHQ(parentRecord.id,cifHead); 
        } 
        test.stopTest();
    }
    
    private static void pageLoadUnderHQ(final Id parentRec,final CIF_Header__c cifHead){
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        
        //Add parameters to page URL 
        ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
        ApexPages.currentPage().getParameters().put(IDSTRING, cifHead.id);  
        
        
        final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
        final FSCIFReparenting controller=new FSCIFReparenting(stdcon);
        
        system.assertEquals(2,controller.CiFs.size());
        
        controller.processReparent();
        
        updCifHead = [Select id,Name,FS_Version__c,FS_HQ__c,FS_Sales_Rep_Name__c from CIF_Header__c Limit 1];
        
        if(!updAcntList.isEmpty()){
            system.assertEquals(null, updCifHead.FS_Sales_Rep_Name__c);
        }
    
    }
}