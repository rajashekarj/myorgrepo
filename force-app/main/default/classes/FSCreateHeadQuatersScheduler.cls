/******************************************************************************************
 *  Purpose : Batch class to create Headquaters
 *  Author  : Sunil Gupta
 *  Date    : November 15, 2013
*******************************************************************************************/  
global class FSCreateHeadQuatersScheduler implements Schedulable {
    // Call a batch class
  global void execute(SchedulableContext sc) {
    FSCreateHeadquartersBatch b = new FSCreateHeadquartersBatch(); 
    database.executebatch(b, 20);
    //To Do Change size
  }
}