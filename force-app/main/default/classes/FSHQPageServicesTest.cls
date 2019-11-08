/***************************************************************************
 Name         : FSHQPageServicesTest
 Created By   : Mohit Parnami
 Description  : Test class of FSHQPageServices
 Created Date : Sept 24, 2013
****************************************************************************/
@isTest
private class FSHQPageServicesTest { 

    //Headquarter Account
    static Account accHeadQtr,accHeadQtr2, accChain, accHeadQtr1;
    static FS_Customer_Input__c custInput,custInput1;
    static Contact con;
	static FS_CI_Required_Fields_Region__c requiredTypes,requiredTypes1,requiredTypes2,requiredTypes3,requiredTypes4,requiredTypes5,requiredTypes6,requiredTypes7,requiredTypes8,requiredTypes9,requiredTypes10;
    static testmethod void testHQPageServices(){
        createTestData();
		accHeadQtr2 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr1.id,false);       
        accHeadQtr2.FS_Revenue_Center__c = 'East';
        accHeadQtr2.FS_FSM_Review__c='Reviewed';        
        insert accHeadQtr2;
        FSHQPageServices.createCustomerInput(string.ValueOf(accHeadQtr.Id));
        FSHQPageServices.createCustomerInput(string.ValueOf(accHeadQtr2.Id));
        
        FSHQPageServices.initiateExecutionPlan(string.ValueOf(accHeadQtr.Id));
        FSHQPageServices.initiateExecutionPlan(string.ValueOf(accHeadQtr2.Id));
        
        FSHQPageServices.createExecutionPlan(string.ValueOf(accHeadQtr1.Id));
        FSHQPageServices.copyToOutlets(string.ValueOf(accHeadQtr.Id));
        FSHQPageServices.copyToOutlets(string.ValueOf(accHeadQtr2.Id));
        //FSHQPageServices.checkRequiredFields(custInput,null);
		accHeadQtr2.FS_FSM_Review__c=null;
		update accHeadQtr2;
        FSHQPageServices.initiateExecutionPlan(string.ValueOf(accHeadQtr2.Id));
        custInput.FS_Site_Assessment_Required__c = 'Test';
        custInput.FS_Account__c=string.ValueOf(accHeadQtr1.Id);
        update custInput;
        FSHQPageServices.createExecutionPlan(string.ValueOf(accHeadQtr.Id));

        custInput.FS_Number_self_serve_units__c = '1';
        custInput.FS_Number_crew_serve_unit__c = '1';
        custInput.FS_Self_Serve_Top_Mnt_Ice_Maker_Instld__c = '1';
        update custInput;
        //FSHQPageServices.checkRequiredFields(custInput,null);        
        //FSHQPageServices.checkPlannedDispensersIsNotNull(custInput);
        //FSHQPageServices.checkSAContactInformationIsNotNull(custInput);
        //FSHQPageServices.checkStandaredConactHasRole_SA(accHeadQtr.id);
    }
    
    static testmethod void testHQPageServices1(){  
        //createTestData();
        //Create Headquarter Account
        accHeadQtr1 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false); 
        accHeadQtr1.FS_Revenue_Center__c = 'East';
        insert accHeadQtr1;		
        FSHQPageServices.initiateExecutionPlan(string.ValueOf(accHeadQtr1.Id));
        FS_Customer_Input_Type__c custInputType = FSTestUtil.createCustomerInputType(true);

        custInput = new FS_Customer_Input__c();
        custInput.FS_Account__c = accHeadQtr1.Id;
        custInput.FS_Customer_Input_Type__c = custInputType.Id;        
        custInput.FS_Site_Assessment_Contact_Phone__c = '9799559433';
        custInput.FS_Site_Assessment_contact_email__c = 'xyz@test.com';
        custInput.FS_Requested_Cartridge_Order_Method__c = '';
        insert custInput;
         FSHQPageServices.copyToOutlets(string.ValueOf(accHeadQtr1.Id));
        //FSHQPageServices.createExecutionPlan(string.ValueOf(accHeadQtr1.Id));
    }

    static void createTestData(){
		List<FS_CI_Required_Fields_Region__c> requiredList = new List<FS_CI_Required_Fields_Region__c>();
		requiredTypes=new FS_CI_Required_Fields_Region__c();
        requiredTypes.Name='#Planned 7000S Top-Mount IM';
		requiredTypes.Field_API__c='FS_7000_Series_Top_Mnt_Ice_Maker_Instld__c';
        requiredTypes.Field_Lable__c='#Planned 7000 Series Top-Mount Ice Maker';
        requiredList.add(requiredTypes);
        requiredTypes1=new FS_CI_Required_Fields_Region__c();
        requiredTypes1.Name='Number 7000 series unit';
		requiredTypes1.Field_API__c='FS_Number_7000_unit__c';
        requiredTypes1.Field_Lable__c='# Planned Freestyle 7000 Dispensers';
        requiredList.add(requiredTypes1);
        requiredTypes2=new FS_CI_Required_Fields_Region__c();
        requiredTypes2.Name='Number crew serve unit';
		requiredTypes2.Field_API__c='FS_Number_crew_serve_unit__c';
        requiredTypes2.Field_Lable__c='#Planned Crew-Serve Freestyle Dispensers';
        requiredList.add(requiredTypes2);
        requiredTypes3=new FS_CI_Required_Fields_Region__c();
        requiredTypes3.Name='Number self serve units';
		requiredTypes3.Field_API__c='FS_Number_self_serve_units__c';
        requiredTypes3.Field_Lable__c='#Planned Self-Serve Freestyle Dispensers';
        requiredList.add(requiredTypes3);
        requiredTypes4=new FS_CI_Required_Fields_Region__c();
        requiredTypes4.Name='Self Serv Top Mnt Ice Maker Instld';
		requiredTypes4.Field_API__c='FS_Self_Serve_Top_Mnt_Ice_Maker_Instld__c';
        requiredTypes4.Field_Lable__c='#Planned Self-Serve Top-Mount Ice Makers';
        requiredList.add(requiredTypes4);
        requiredTypes5=new FS_CI_Required_Fields_Region__c();
        requiredTypes5.Name='Site Assessment Contact Cel';
		requiredTypes5.Field_API__c='FS_Site_Assessment_Contact_Cell__c';
        requiredTypes5.Field_Lable__c='Site Assessment Contact Phone(Alternate)';
        requiredList.add(requiredTypes5);
        requiredTypes6=new FS_CI_Required_Fields_Region__c();
        requiredTypes6.Name='Site Assessment contact email';
		requiredTypes6.Field_API__c='FS_Site_Assessment_contact_email__c';
        requiredTypes6.Field_Lable__c='Site Assessment contact email';
        requiredList.add(requiredTypes6);
        requiredTypes7=new FS_CI_Required_Fields_Region__c();
        requiredTypes7.Name='Site Assessment Contact name';
		requiredTypes7.Field_API__c='FS_Site_Assessment_Contact_name__c';
        requiredTypes7.Field_Lable__c='Site Assessment Contact name';
        requiredList.add(requiredTypes7);
        requiredTypes8=new FS_CI_Required_Fields_Region__c();
        requiredTypes8.Name='Site Assessment Contact Phone';
		requiredTypes8.Field_API__c='FS_Site_Assessment_Contact_Phone__c';
        requiredTypes8.Field_Lable__c='Site Assessment Contact Phone-(primary)';
        requiredList.add(requiredTypes8);
        requiredTypes9=new FS_CI_Required_Fields_Region__c();
        requiredTypes9.Name='Site Assessment Contact Title';
		requiredTypes9.Field_API__c='FS_Site_Assessment_Contact_Title__c';
        requiredTypes9.Field_Lable__c='Site Assessment Contact Title';
        requiredList.add(requiredTypes9);
        requiredTypes10=new FS_CI_Required_Fields_Region__c();
        requiredTypes10.Name='Site Assessment Required';
		requiredTypes10.Field_API__c='FS_Site_Assessment_Required__c';
        requiredTypes10.Field_Lable__c='Select Davaco Requirements for Project?';
        requiredList.add(requiredTypes10);
        insert requiredList;
        //Create Chain Account
        accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        accChain.FS_FSM_Review__c = 'Reviewed';
        insert accChain;

        //Create Headquarter Account
        accHeadQtr1 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false); 
        accHeadQtr1.FS_Revenue_Center__c = 'East';
        insert accHeadQtr1;

        accHeadQtr = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr1.id,false);        
        accHeadQtr.FS_Chain__c = accChain.Id;
        accHeadQtr.FS_Revenue_Center__c = 'East';
        accHeadQtr.FS_Headquarters__c = accHeadQtr1.Id;
        insert accHeadQtr;

        con = FSTestUtil.createTestContact(accHeadQtr.Id, 'contact', false);
        con.FS_Execution_Plan_Role__c = 'Primary Contact';
        //con.FS_Contact_Info_Complete__c = true  ;
        insert con;

        FS_Customer_Input_Type__c custInputType = FSTestUtil.createCustomerInputType(true);

        custInput = new FS_Customer_Input__c();
        custInput.FS_Account__c = accHeadQtr.Id;
        custInput.FS_Customer_Input_Type__c = custInputType.Id;
        //custInput.FS_Site_Assessment_Required__c = ;
        custInput.FS_Site_Assessment_Contact_name__c = 'testName';
        custInput.FS_Site_Assessment_Contact_Phone__c = '9799559433';
        custInput.FS_Site_Assessment_contact_email__c = 'xyz@test.com';
        custInput.FS_Requested_Cartridge_Order_Method__c = '';
        custInput.FS_Number_self_serve_units__c='10';
        custInput.FS_Number_crew_serve_unit__c='11';
        custInput.FS_Self_Serve_Top_Mnt_Ice_Maker_Instld__c='12';
        insert custInput;
        custInput1 = new FS_Customer_Input__c();
        custInput1.FS_Account__c = accHeadQtr1.Id;
        custInput1.FS_Customer_Input_Type__c = custInputType.Id;
        //custInput.FS_Site_Assessment_Required__c = ;
        custInput1.FS_Site_Assessment_Contact_name__c = 'testName';
        custInput1.FS_Site_Assessment_Contact_Phone__c = '9799559433';
        custInput1.FS_Site_Assessment_contact_email__c = 'xyz@test.com';
        custInput1.FS_Requested_Cartridge_Order_Method__c = '';
        custInput1.FS_Number_self_serve_units__c='10';
        custInput1.FS_Number_crew_serve_unit__c='11';
        custInput1.FS_Self_Serve_Top_Mnt_Ice_Maker_Instld__c='12';
        insert custInput1;

        FS_CI_Required_Fields_Region__c fsReqField =
            new FS_CI_Required_Fields_Region__c(Name = 'Id', Field_Lable__c = 'Id',
                             Field_API__c = 'Id');
        insert fsReqField;
    }
}