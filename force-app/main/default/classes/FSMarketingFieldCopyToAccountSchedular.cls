global class FSMarketingFieldCopyToAccountSchedular implements Schedulable{
	global void execute(SchedulableContext sc) {
      FSMarketingFieldCopyToAccountBatch b = new FSMarketingFieldCopyToAccountBatch(System.Today()); 
      integer scopesize =50;
      database.executebatch(b,scopesize);
   }
}