/*
Class Name :FSScheduleCopyTodaysBrandsets
Description :Schedulable batch job that copies brandsets from OD to Assosiation Brandsets when the effective date reaches todays date
Author: Infosys Limited
Date: 11/01/2017
*/
global class FSScheduleCopyTodaysBrandsets implements Schedulable{
  global void execute(final SchedulableContext sc) {
      database.executebatch(new FSCopyTodaysBrandsets(System.Today()),60);
   }
}