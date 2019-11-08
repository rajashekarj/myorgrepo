/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UserTriggerHandlerTest {
    static Shipping_Form__c shippingForm1,shippingForm2;
    static User user1, user2;
    
    static testMethod void myUnitTest() {
        final List<User> userList=new List<User>();
        shippingForm1 = FSTestUtil.createShippingForm(false);
        user1 = FSTestUtil.createUser(null,1,FSConstants.dispenserManufacturerProfile,false);                
        user2 =FSTestUtil.createUser(null,2,FSConstants.dispenserManufacturerProfile,false);
        user2.IC_Code__c = '3454';
        userList.add(user1);
        userList.add(user2);
        insert userList;
        system.runAs(user1){
            insert shippingForm1;
        }
        system.assertNotEquals(user2.id, null);
        shippingForm2 = FSTestUtil.createShippingForm(false);
        shippingForm2.IC_Code__c = '3454';
        shippingForm2.Name = 'Test Shipping Form 2';    
        user2.IC_Code__c = '1234,3454';
        update user2; 
        
        system.runAs(user2){
            insert shippingForm2;
            system.assertNotEquals(shippingForm2.id, null);            
            shippingForm2.IC_Code__c = '1234';                   
            update shippingForm2;        
        }
    }
    // static testMethod void myUnitTest2() {
       // UserTriggerHandler.afterUpdate();
        
    //}
      @testSetup  
     static void mytestSetup() {
       Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
       
       disableTriggerSetting.name='UserTriggerHandler';
       disableTriggerSetting.IsActive__c=true;
       disableTriggerSetting.Trigger_Name__c='UserTrigger' ; 
       insert disableTriggerSetting;   
      }    
}