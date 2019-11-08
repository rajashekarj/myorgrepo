/******************************************************************************************
 *  Purpose : Schedule sending identified Outlet Dispenser records to AirWatch
 *  Author  : J-F Ille
 *  Date    : June 07, 2016
*******************************************************************************************/  
global class FSUpdateAWScheduler implements Schedulable {
    // Call a batch class
  global void execute(final SchedulableContext sc) {
    final FS_Data_Migration_8K_9K b = new FS_Data_Migration_8K_9K(); 
    database.executebatch(b, 100);
  }
}