@isTest
public class FS_AddContactsToHQTest {

    @testsetup
    public static void testData(){
        Id RECORD_TYPE_HQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_HQ);
        list<string> acnList=new list<string>{'0000844777', '0000342793', '0000844696', '0000347884', '0000288501', '0000851536', '0000103781', '0000943555', '0001500871', '0000844769', '0000947326', '0000702358', '0001127926', '0001136372', '0000089669', '0001971734', '0000900260', '0000996985', '0001992187', '0000971728', '0002225727', '0000948543', '0002061075', '0001677496', '0000941021', '0001821824', '0004901490', '0000829158', '0000968277', '0000966873', '0001985726', '0001907731', '0001136143', '0001477226', '0001717372', '0000942146', '0002053388', '0000860161', '0001157116', '0000942570', '0000908385', '0000854748', '0001404696', '0000937126', '0000848667', '0001136038', '0001591656', '0001512866', '0000932051', '0000968956', '0000404217', '0005832085', '0000974574', '0000103578', '0000834950', '0001136364', '0000861184', '0004904465', '0000942230', '0001553601', '0001538457', '0000991244', '0001705600', '0001925965', '0001452467', '0000861605', '0000024835', '0000850506', '0000844718', '0002093283', '0000342742', '0000975308', '0001544143', '0001169048', '0000904155', '0000901593', '0002030910', '0000914177', '0004904392', '0001621374', '0000332208', '0002026252', '0002206480', '0001881603', '0000834968', '0000704601', '0000842112', '0000842163', '0001769402', '0001583160', '0000333603', '0000969711', '0002083507', '0002068240', '0001157612', '0000937822', '0000941519', '0000915700', '0005606204', '0000342891', '0001677694', '0000984804', '0001798694', '0001940757', '0001798076', '0000427811', '0001603038', '0000964578', '0000103454', '0001472461', '0001137581', '0001657652'}; 
            
            list<account> lstAccs = new list<account>();     
        
        //Sample test data inserting here:
        for(integer i =0; i<acnList.size();i++){
            Account accData = new Account(Name = 'testAcc'+i,FS_ACN__c=  acnList[i],recordtypeId =RECORD_TYPE_HQ);
            lstAccs.add(accData);        
        }
        insert lstAccs; 
    }
    
    public static testmethod void BatchPopulateTest(){
        //Query TestData
        list<account> lstacc= [select Id, name from account ];
        
        system.assertEquals(112, lstacc.size());
        
        //Use test.startTest() and stopTest() for refreshing governor limits.
        test.startTest();
        FS_AddContactsToHQ bch = new FS_AddContactsToHQ();
        Database.executeBatch(bch);
        test.stopTest();
        //Use assert statements      
        list<contact> lstcons=[select Id, name from contact ];
        system.assertEquals(448,lstcons.size());
        
    }
}