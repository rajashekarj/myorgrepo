global class AELDupCleanUpsBatchSchedular implements Schedulable  {
	// Call a batch class
  	global void execute(SchedulableContext sc) {
    	AELDupCleanUpsBatch b = new AELDupCleanUpsBatch(); 
    	database.executebatch(b, 20);
  }

}