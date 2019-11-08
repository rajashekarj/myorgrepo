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
private class ShippingFormTriggerHandlerTest {
    static Shipping_Form__c shippingForm1,shippingForm2;
    static User user1;
    static User user2;
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        user1 =FSTestUtil.createUser(null,1,FSConstants.dispenserManufacturerProfile,true);
   
        system.runAs(user1){
            shippingForm1 = FSTestUtil.createShippingForm(true);
            user1.IC_Code__c = '1234;5463';
            update user1;
        }    
    }
    
 @testSetup  
     static void mytestSetup() {
       Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
       
       disableTriggerSetting.name='ShippingFormTriggerHandler';
       disableTriggerSetting.IsActive__c=true;
       disableTriggerSetting.Trigger_Name__c='ShippingFormTrigger' ; 
       insert disableTriggerSetting;   
      }    
}