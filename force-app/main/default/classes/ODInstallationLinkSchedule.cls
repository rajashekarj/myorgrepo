global class ODInstallationLinkSchedule implements Schedulable {
global void execute(SchedulableContext sc) {
      ODInstallationLinkBatch b = new ODInstallationLinkBatch(); 
      database.executebatch(b);
   }
}