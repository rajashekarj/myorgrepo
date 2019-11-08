trigger FSAssociationBrandsetTrigger on FS_Association_Brandset__c (before insert,after insert,before update,after update, before delete) {
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAssociationBrandsetTrigger');
    
    if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c ){  
        if(trigger.isBefore){
            if(trigger.isInsert){
                FSAssociationBrandsetTriggerHandler.preventDuplicatePlatform();
            }
            if(trigger.isUpdate){                
                FSAssociationBrandsetTriggerHandler.preventDuplicatePlatform();
                system.debug('Before update AB'+ Trigger.new);
            }
            if(trigger.isDelete){
                FSAssociationBrandsetTriggerHandler.brandsetChangeNotification();
            }
        }
        if(trigger.isAfter){
            if(trigger.isInsert){
                FSAssociationBrandsetTriggerHandler.brandStatusUpdateIP(Trigger.new,Trigger.old,
                                                                        Trigger.newMap,Trigger.oldMap,Trigger.IsUpdate);
                FSAssociationBrandsetTriggerHandler.updateODWaterFieldInsert();
            }
            if(trigger.isUpdate){
                FSAssociationBrandsetTriggerHandler.brandStatusUpdateIP(Trigger.new,Trigger.old,
                                                                        Trigger.newMap,Trigger.oldMap,Trigger.IsUpdate);
                FSAssociationBrandsetTriggerHandler.brandsetChangeNotification();
                FSAssociationBrandsetTriggerHandler.updateODAB();
                FSAssociationBrandsetTriggerHandler.updateODWaterfield();
                //FSAssociationBrandsetTriggerHandler.triggerAWCall();
                system.debug('After update AB'+ Trigger.new);
            }
            
        }
        system.debug('@@@Current SOQL AB:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }
}