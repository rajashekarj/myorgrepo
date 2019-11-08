/*
Class Name :FSScheduleCopyTodaysBrandsets
Description :Schedulable batch job that copies brandsets from OD to Assosiation Brandsets when the effective date reaches todays date
Author: Infosys Limited
Date: 11/01/2017
*/
global class FSScheduleCopyBrandsetsToDispenser implements Schedulable{
  global void execute(SchedulableContext shdldctx) {
      database.executebatch(new FSCopyBrandsetsToDispenser());
   }
}