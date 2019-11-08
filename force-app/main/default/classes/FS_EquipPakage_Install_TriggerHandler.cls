/**************************************
Name         : FS_EquipPakage_Install_TriggerHandler
Created By   : Infosys
Created Date : 19/01/2016
Usage        : This class holds the business logic of the Equipment Package Trigger
Modified: Venkat -- FET 5.0 US 7 and also code optimization 
****************************************/
public class FS_EquipPakage_Install_TriggerHandler{  
    
    public Static void isBeforeUpdate(final List<FS_IP_Equipment_Package__c> newList,final List<FS_IP_Equipment_Package__c> oldList,final Map<Id,FS_IP_Equipment_Package__c> newMap,final Map<Id,FS_IP_Equipment_Package__c> oldMap){
        validFillNotificationEQP(newList, oldMap);
    }   
    
    public Static void isAfterUpdate(final List<FS_IP_Equipment_Package__c> newList,final List<FS_IP_Equipment_Package__c> oldList,final Map<Id,FS_IP_Equipment_Package__c> newMap,final Map<Id,FS_IP_Equipment_Package__c> oldMap) {
        updateInstallQuantity (newList,oldList,newMap,oldMap);
    }
    
        /*****************************************************************
    Method: updateInstallQuantity
    Description: updateInstallQuantity method to update quantity and planned top mount fields on installation    
    New:Venkat as part of FET 5.0 US 7 copy quantity values from Equipment package to Installation
    *******************************************************************/ 
    
    public static void updateInstallQuantity(final List<FS_IP_Equipment_Package__c> newList,final List<FS_IP_Equipment_Package__c> oldList,final Map<Id,FS_IP_Equipment_Package__c> newMap,final Map<Id,FS_IP_Equipment_Package__c> oldMap) {
        //Map to store Equipment package reocrd with refrence to Install Id and Equipment package Platform
        final Map<String,FS_IP_Equipment_Package__c> equipPlatfromMap=new Map<String,FS_IP_Equipment_Package__c>();
        //Set to store Instalaltion Ids
        final Set<Id> installSet=new Set<Id>();
        //List to store installation records 
        final List<FS_Installation__c> installList=new List<FS_Installation__c>();
        //iterating new list to seperate equipment package records where Dispenser/IM adapter quantity fields been updated
        for(FS_IP_Equipment_Package__c equip:newList){
            if(equip.FS_Dispenser_QTY__c!=oldMap.get(equip.Id).FS_Dispenser_QTY__c){
                //set to store Installation Ids
                installSet.add(equip.FS_Installation__c);
                //Map to store Equipment package records based on Installation Id and Equipment Platform
                equipPlatfromMap.put(equip.FS_Installation__c+equip.FS_Platform_Type__c, equip);
            }
        }
        //Iterating Installation records
        for(FS_Installation__c install:[select id,name,Overall_Status2__c,Type_of_Dispenser_Platform__c,FS_Platform1__c,
                                        FS_Platform2__c,FS_Platform3__c,FS_DispOrder1__c,FS_DispOrder2__c,FS_DispOrder3__c,recordtypeId                     					
                                        from FS_Installation__c where Id IN:installSet and (recordtypeId=:FSInstallationValidateAndSet.ipNewRecType or recordtypeId=:FSInstallationValidateAndSet.ipRecTypeReplacement)]){
            //verifying the map with platform 1 field, to assign quantity fields from Equipment package to Installation                               
        	if(equipPlatfromMap.containsKey(install.Id+install.FS_Platform1__c)){                 
                install.FS_DispOrder1__c=equipPlatfromMap.get(install.Id+install.FS_Platform1__c).FS_Dispenser_QTY__c;                
            }
            //verifying the map with platform 2 field, to assign quantity fields from Equipment package to Installation  
            if(equipPlatfromMap.containsKey(install.Id+install.FS_Platform2__c)){                 
                install.FS_DispOrder2__c=equipPlatfromMap.get(install.Id+install.FS_Platform2__c).FS_Dispenser_QTY__c;               
            }
            //verifying the map with platform 3 field, to assign quantity fields from Equipment package to Installation 
            if(equipPlatfromMap.containsKey(install.Id+install.FS_Platform3__c)){                
                install.FS_DispOrder3__c=equipPlatfromMap.get(install.Id+install.FS_Platform3__c).FS_Dispenser_QTY__c;               
            }                                
            installList.add(install);
        } 
        
        if(!installList.isEmpty()){
            //Creating Apex error logger instance
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSCopyEPEPToInstallationsSearchExtension',
                                                           Method_Name__c='updateQuantity',Object_Name__c=FSConstants.INSTALLATIONOBJECTNAME,
                                                           Error_Severity__c=FSConstants.MediumPriority);
            FSUtil.dmlProcessorUpdate(installList,true,apexError);
        }        
    }  
    
    /*****************************************************************
    Method: validFillNotificationEQP
    Description: validFillNotificationEQP method to find to valid fill quantity been changed and is > 0	
    New:Added this method as part of FET 2.0
    Modified:Venkat as part of FET 5.0 to optimize the code 
    *******************************************************************/  
    
    private Static void validFillNotificationEQP(final List<FS_IP_Equipment_Package__c> newList,final Map<Id,FS_IP_Equipment_Package__c> oldMap){
        //iterating the Equipment Package list
        for(FS_IP_Equipment_Package__c equipPack:newList){
            //Checking Valid Fill qty value been changed and quantity is > 0
            if(oldMap.get(equipPack.id).FS_Valid_Fill_QTY__c!=equipPack.FS_Valid_Fill_QTY__c && equipPack.FS_Valid_Fill_QTY__c>0){
                //assigning Valid Fill Notification flag value opposite to old value 
                if(oldMap.get(equipPack.id).FS_Valid_Fill_Notification_Flag__c){
                    equipPack.FS_Valid_Fill_Notification_Flag__c=false;
                }else{
                    equipPack.FS_Valid_Fill_Notification_Flag__c=true;
                }                
            }
        }       
    }    
}