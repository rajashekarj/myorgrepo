@isTest
public class FSCopytoLower_Cancel_PIM_ExtensionTest {
    private static Account headquartersAcc,outletAcc;
    Private static FS_Post_Install_Marketing__c pim;
    
    public static testMethod void createtestData(){
        //HQ Record
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        insert headquartersAcc;
        
        //PIM Record under HQ
        List<FS_Post_Install_Marketing__c> listPim = new List<FS_Post_Install_Marketing__c>();
        pim=new FS_Post_Install_Marketing__c();
        pim.FS_Account__c=headquartersAcc.id;
        pim.FS_Enable_Consumer_Engagement__c='Yes';
        pim.FS_Enable_CE_Effective_Date__c=System.today()+1;
        listPim.add(pim);        
        insert listpim;
        
        test.startTest();
        ApexPages.PageReference myVfPage = Page.FSCopytoLowerPIM;
        test.setCurrentPage(myVfPage);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(listpim);
        sc.setSelected(listpim);
        sc.getSelected();
        final FSCopytoLower_Cancel_PIM_Extension controller= new FSCopytoLower_Cancel_PIM_Extension(sc);
        
        test.stopTest();
        
    }
}