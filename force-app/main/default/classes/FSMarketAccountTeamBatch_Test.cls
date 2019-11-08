@isTest 
public Class FSMarketAccountTeamBatch_Test{    
    static testMethod void FSMarketAccountTeamBatch_Test1(){
        
        recordtype recId = [Select Id from recordtype Where SobjectType = 'Account' and Name='FS Chain'];
        //Profile p = [select id,name from profile where name='System Administrator'];
           User testUser=FSTestUtil.createUser(null,1,'System Administrator',false);
           testUser.FirstName='Anthony';
           testUser.LastName ='Marcello1';
           insert testUser;
           
        FS_Market_ID__c testMarketId = new FS_Market_ID__c();
        testMarketId.FS_KO_ID__c = 'E62216';
        testMarketId.FS_Market_ID_Value__c = '400001';
        testMarketId.FS_User__c = [SELECT Id FROM User WHERE Name = 'Anthony Marcello1' LIMIT 1].Id;
        insert testMarketId;
        
        MarketAccountTeamJunction__c testMarketAccountTeamJunction = new MarketAccountTeamJunction__c();
        testMarketAccountTeamJunction.Name = 'Test Market Account Team Junction';
        testMarketAccountTeamJunction.AccountTeamMemberIds__c = 'Test';
        testMarketAccountTeamJunction.Market__c = testMarketId.Id;
        insert testMarketAccountTeamJunction;
                
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.FS_Market_ID__c= '400001';
        acc.RecordTypeId=recId.id;
        insert acc;
        
        AccountTeamMember testAccountTeamMember = new AccountTeamMember();
       // testAccountTeamMember.UserId = [SELECT Id FROM User WHERE Name = 'Anthony Marcello1' LIMIT 1].Id;
        testAccountTeamMember.UserId = testUser.Id;
        testAccountTeamMember.TeamMemberRole = 'PM';
        testAccountTeamMember.AccountId = acc.Id;
        
        insert testAccountTeamMember;
        
        Map<String, MarketAccountTeamJunction__c> testMapMarketJunctionWithAtm = new Map<String, MarketAccountTeamJunction__c>();
        testMapMarketJunctionWithAtm.put(testAccountTeamMember.Id,testMarketAccountTeamJunction);
        
        Map<Id,FS_Market_ID__c> testModifiedMarkets = new Map<Id,FS_Market_ID__c>();
        testModifiedMarkets.put(testMarketId.Id, testMarketId);
        
        Test.startTest();
            FSMarketAccountTeamBatch controller = new FSMarketAccountTeamBatch(testMapMarketJunctionWithAtm, testModifiedMarkets);
            Database.executeBatch(controller);
        Test.stopTest();
    }
}