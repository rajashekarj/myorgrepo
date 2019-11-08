/******************************************************************************************
 *  Purpose : controller class to create Account Team Members on click of Link "Realign Accounts Owners and Team Members" on Home Page.   
 *  Author  : Mohit Parnami
 *  Date    : 15/10/2013
*******************************************************************************************/ 
global class FSRealignOwnerAndTeamMembersService implements Schedulable {
        //-----------------------------------------------------------------------------------------------------------------------------
      // Methid to call a batch that updates Account and accordingly account Team members and market-accountTeamMember junction object.
      //------------------------------------------------------------------------------------------------------------------------------
    global void execute(SchedulableContext sc) {
        FSRealignOwnerAndTeamMembersBatch b = new FSRealignOwnerAndTeamMembersBatch(); 
        database.executebatch(b);
    } 
}