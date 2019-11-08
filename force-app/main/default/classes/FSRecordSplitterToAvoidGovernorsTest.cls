@isTest
private class FSRecordSplitterToAvoidGovernorsTest{
    
    static testmethod  void testForSingleRecordList(){
        final List<Integer> dataList=new List<Integer>();
        for(Integer i=0;i<1;i++){
            dataList.add(i);
        }
        
        List<List<Object>> resultList=new List<List<Object>>();
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);  
        System.runAs(contextUser){
            Test.startTest();
            resultList=FSRecordSplitterToAvoidGovernorLimits.processRecords(dataList,Integer.valueOf(Label.recordChunkSize));
            Test.stopTest();
            //expected value is 1/50=0.02 => 1
            system.assertEquals(1,resultList.size());
        }
    }
    
    static testmethod  void testFor100RecordsList(){
        final List<Integer> dataList=new List<Integer>();
        for(Integer i=0;i<100;i++){
            dataList.add(i);
        }
        
        List<List<Object>> resultList=new List<List<Object>>();
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);  
        System.runAs(contextUser){
            Test.startTest();
            resultList=FSRecordSplitterToAvoidGovernorLimits.processRecords(dataList,Integer.valueOf(Label.recordChunkSize));
            Test.stopTest();
            //expected value is 100/50=2
            system.assertEquals(2,resultList.size());
        }
    }
    
    static testmethod  void testFor500RecordsList(){
        final List<Integer> dataList=new List<Integer>();
        for(Integer i=0;i<490;i++){
            dataList.add(i);
        }
        
        List<List<Object>> resultList=new List<List<Object>>();
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);  
        System.runAs(contextUser){
            Test.startTest();
            resultList=FSRecordSplitterToAvoidGovernorLimits.processRecords(dataList,Integer.valueOf(Label.recordChunkSize));
            Test.stopTest();
            //expected value is 490/50=9.8 => 10
            system.assertEquals(10,resultList.size());
        }
    }
    
    static testmethod  void testForSingleRecordMap(){
        final  Map<Object,Object> dataMap=new Map<Object,Object>();
        for(Integer i=0;i<1;i++){
            dataMap.put((Object)i,(Object)i);
        }
        
        List<Map<Object,Object>> resultMap=new List<Map<Object,Object>>();
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id); 
        System.runAs(contextUser){
            Test.startTest();
            resultMap=FSRecordSplitterToAvoidGovernorLimits.processRecords(dataMap,Integer.valueOf(Label.recordChunkSize));
            Test.stopTest();
            //expected value is 1/50=0.02 => 1
            system.assertEquals(1,resultMap.size());
        }
    }
    
    static testmethod  void testFor100RecordsMap(){
        final Map<Object,Object> dataMap=new Map<Object,Object>();
        for(Integer i=0;i<100;i++){
            dataMap.put((Object)i,(Object)i);
        }
        
        List<Map<Object,Object>> resultMap=new List<Map<Object,Object>>();
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);  
        System.runAs(contextUser){
            Test.startTest();
            resultMap=FSRecordSplitterToAvoidGovernorLimits.processRecords(dataMap,Integer.valueOf(Label.recordChunkSize));
            Test.stopTest();
            //expected value is 100/50=2
            system.assertEquals(2,resultMap.size());
        }
    }
    
    static testmethod  void testFor500RecordsMap(){
        final Map<Object,Object> dataMap=new Map<Object,Object>();
        for(Integer i=0;i<490;i++){
            dataMap.put((Object)i,(Object)i);
        }
        
        List<Map<Object,Object>> resultMap=new List<Map<Object,Object>>();
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);  
        System.runAs(contextUser){
            Test.startTest();
            resultMap=FSRecordSplitterToAvoidGovernorLimits.processRecords(dataMap,Integer.valueOf(Label.recordChunkSize));
            Test.stopTest();
            //expected value is 490/50=9.8 => 10
            system.assertEquals(10,resultMap.size());
        }
    }
    
}