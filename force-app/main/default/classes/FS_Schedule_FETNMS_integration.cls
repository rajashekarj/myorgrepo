global class FS_Schedule_FETNMS_integration implements Schedulable {
   global void execute(SchedulableContext sc) {
      FS_FETNMS_integration b = new FS_FETNMS_integration(System.Today()); 
      integer scopesize =10;
      database.executebatch(b,scopesize);
   }
}