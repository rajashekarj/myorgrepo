global class AELDupCheckBatchSchedular implements Schedulable  {
	// Call a batch class
  	global void execute(SchedulableContext sc) {
    	AELDupCheckBatch b = new AELDupCheckBatch(); 
    	database.executebatch(b, 20);
  }
}