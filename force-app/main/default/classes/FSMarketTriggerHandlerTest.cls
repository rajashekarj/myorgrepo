/***************************************************************************
Name         : FSMarketTriggerHandlerTest
Created By   : Mohit Parnami
Description  : Test class of FSMarketTriggerHandler
Created Date : Oct 24, 2013         
****************************************************************************/
@isTest
private class FSMarketTriggerHandlerTest {
    
    public static Account headQuarterAcc;
    public static User user, user1, user2; 
    public static FS_Market_ID__c market, market1, market2;
    public static MarketAccountTeamJunction__c matj,matj1,matj2;
    
    //--------------------------------------------------------------------------------------
    // Test method For Market Id Trigger
    //--------------------------------------------------------------------------------------
    private static testmethod void testMarketIdTrigger(){
        createData();
        
        test.startTest();        
        System.runAs(user2){
            market.FS_User__c = user1.Id;
            update market;               
        }          
        test.stopTest();
    }
    
    
    //--------------------------------------------------------------------------------------
    //Create Test Data For Market Id Trigger
    //--------------------------------------------------------------------------------------
    private static void createData(){
        
        final List<FS_Market_ID__c> lstMarketsToInsert = new List<FS_Market_ID__c>();
        final List<MarketAccountTeamJunction__c> lstMarketJunToInsert = new List<MarketAccountTeamJunction__c>();
        final List<User> lstUserToInsert = new List<User>();
        
        //Creates HeadQuater Accounts
        headQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        headQuarterAcc.FS_Market_ID__c = '1234';
        insert headQuarterAcc;
        
        //creates user , parameters : contact , userNo. , isInsert
        user = FSTestUtil.createUser(null,0,FSConstants.systemAdmin, false);
        lstUserToInsert.add(user);  
        
        user1 = FSTestUtil.createUser(null,1,FSConstants.systemAdmin, false);        
        lstUserToInsert.add(user1);
        
        user2 = FSTestUtil.createUser(null,2,FSConstants.USER_POFILE_FETADMIN, false);        
        lstUserToInsert.add(user2);
        
        insert lstUserToInsert;
        
        insert new Disable_Trigger__c(name='FSMarketIdHandler',IsActive__c=false );
        
        //creates Market Id
        market = FSTestUtil.createMarketId(user, false);
        market.FS_Market_ID_Value__c = '1234';
        market.FS_Parent_ID_Value__c = '5678';
        lstMarketsToInsert.add(market);     
        
        market1 = FSTestUtil.createMarketId(user1, false);
        market1.FS_Market_ID_Value__c = '5678';
        market1.FS_Parent_ID_Value__c = '9012';
        lstMarketsToInsert.add(market1);      
        
        market2 = FSTestUtil.createMarketId(user2, false);
        market2.FS_Market_ID_Value__c = '9012';
        lstMarketsToInsert.add(market2);
        
        insert lstMarketsToInsert;
        
        matj=new MarketAccountTeamJunction__c(Market__c=market.id);              
        lstMarketJunToInsert.add(matj);
        
        matj1=new MarketAccountTeamJunction__c(Market__c=market.id);       
        lstMarketJunToInsert.add(matj1);   
        
        matj2=new MarketAccountTeamJunction__c(Market__c=market.id);        
        lstMarketJunToInsert.add(matj2);
        
        insert lstMarketJunToInsert;
        
    }
    private static testMethod void testdeletemethod(){
        createData();
        final Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);             
        
        final List<Account> lstaccount = new List<Account>();
        lstaccount.add(accChain);
        test.startTest();
        System.runAs(user){
            FSAlignAccountTeamMembersUtility.alignAccountTeam(lstaccount,true);   
        }
        test.stopTest();
    }   
}