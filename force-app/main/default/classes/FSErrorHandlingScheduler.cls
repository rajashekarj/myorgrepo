/***************************************************************************
 Name         : FSErrorHandlingScheduler
 Created By   : Deepti Maheshwari
 Description  : Scheduler Class of Error Handling of service messages
 Created Date : Jan 26, 2015
***************************************************************************/

global class FSErrorHandlingScheduler implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      BatchForErrorHandling b = new BatchForErrorHandling(); 
      database.executebatch(b);
    }
}