//
// 4th March 2015   Created   Original   Kirti Agarwal    Ref(T-367311)
//
// Purpose : Create/delete share records for Chain Heirarchy Accounts on insert/update/delete
//
global class FSAccountTeamMemberHeirarchyScheduler implements Schedulable {

   //method used to call the batch class
   global void execute(SchedulableContext SC) {
              Integer batchSize = 10;
              Database.executeBatch(new FSUpdateAccountTeamMemberHeirarchyBatchI(), batchSize);
   }
}

/*
FSAccountTeamMemberHeirarchyScheduler batchSch = new FSAccountTeamMemberHeirarchyScheduler();
String schedule = '0 0 * * * ?'; // This job will run every hour
system.schedule('Account Team Member Sharing', schedule , batchSch);
'0 0 1/2 * * ?'
'0 0 1,3,5 * * ?'
*/