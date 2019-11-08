@isTest
private class FS_AddressValidationExtensionTest {
    private static FS_AddressValidationExtension classObj;
    private static Account accchain,accHQ,intOutlet;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.systemAdmin);
    public static final String STRX='xxx';
    //@testSetup
    private static testMethod void loadTestData(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        
        //Create Headquarters
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        
        //Create International outlet
        intOutlet= FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET_INT,accHQ.Id,false);
        intOutlet.FS_SAP_ID__c='12345';
        intOutlet.FS_Shipping_City_Int__c = 'sample city';
        intOutlet.FS_Shipping_Country_Int__c = 'GB';
        intOutlet.FS_Shipping_State_Province_INT__c = 'sample state';    
        intOutlet.FS_Shipping_Street_Int__c = 'sample street';
        intOutlet.FS_Shipping_Zip_Postal_Code_Int__c='1213131';
        intOutlet.Phone='12345';
        intOutlet.Fax='12345';
        insert intOutlet;
        
        //Custom setting data creation
        final Google_Messages__c googleMsg = new Google_Messages__c();
        googleMsg.Error_Message__c='Validation Successful';
        googleMsg.Error_type__c='Validation Successful';
        googleMsg.Name='Validation Successful';
        insert googleMsg;
        final Google_Messages__c googleMsg1 = new Google_Messages__c();
        googleMsg1.Error_Message__c='Partial match';
        googleMsg1.Error_type__c='Partial match';
        googleMsg1.Name='Partial match';
        insert googleMsg1;
        
        
        final Google_Messages__c googleMsg2 = new Google_Messages__c();
        googleMsg2.Error_Message__c='The Outlet Address cannot be empty, a minimum of City and Country is required.';
        googleMsg2.Error_type__c='400';
        googleMsg2.Name='Status 400';
        insert googleMsg2;
        
        final Google_Messages__c googleMsg3 = new Google_Messages__c();
        googleMsg3.Error_Message__c='The Outlet Address  has no matches, a minimum of City and Country is required.';
        googleMsg3.Error_type__c='ZERO_RESULTS';
        googleMsg3.Name='ZERO_RESULTS';
        insert googleMsg3;
        
        final Google_Messages__c googleMsg4 = new Google_Messages__c();
        googleMsg4.Error_Message__c='Record save not successful';
        googleMsg4.Error_type__c='Save not successful';
        googleMsg4.Name='Save not successful';
        insert googleMsg4;
        
        final pagereference page1 = page.Fs_addressValidator;
        Test.setCurrentPage(page1);
        ApexPages.currentPage().getParameters().put('Fs_addressValidator',intOutlet.Id);
        final ApexPages.StandardController controller = new ApexPages.StandardController(intOutlet);
        classObj = new FS_AddressValidationExtension(controller);    
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            callout();
            calloutException();
            calloutException1();
            intOutlet.Phone='123456';
            intOutlet.Fax='123456';
            update intOutlet;
            
            testAddressMapping2();
        }
        
        test.stopTest();
    }
    
    @future (callout=true)
    private static void callout(){        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        classObj.initialMapping();
        classObj.validate();
        
        classObj.save();
        system.assertEquals(50.85830319999999, classObj.lat);
        classObj.doCancel();
    }
    @future (callout=true)
    private static void calloutException(){        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        classObj.initialMapping();
        classObj.validate();
        classObj.save();
        system.assertEquals(50.85830319999999, classObj.lat);
        classObj.doCancel();
    }
    @future (callout=true)
    private static void calloutException1(){        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        classObj.initialMapping();
        classObj.validate();
        classobj.statusFlag=false;
        classObj.save();
        
    }
    
    @future (callout=true)
    private static void testAddressMapping2(){        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        classObj.initialMapping();
        classObj.validate();
        final List<String> longName = new List<String>{STRX,STRX};
            final List<String> shortName = new List<String>{STRX,STRX};
                classObj.addressMapping2(longName,shortName,classObj.typeVal);
    }
}