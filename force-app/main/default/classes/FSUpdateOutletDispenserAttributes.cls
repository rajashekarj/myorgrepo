/*********************************************************************************************************
Name         : FSUpdateOutletDispenserAttributes
Created By   : Infosys Limited
Created Date : 24-April-2017
Usage        : Class is Invoked in trigger context to Copy Todays Brandsets to Current Brandset of Dispenser
***********************************************************************************************************/
public class FSUpdateOutletDispenserAttributes {
    public static Id recTypeInternational=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(Label.INT_OD_RECORD_TYPE).getRecordTypeId();
    public final static Object NULLOBJ = null;
    private static final string AGITATED_CODE='A';
    private static final string STATIC_CODE='S';
    private static final string SPICY_CHERRY_CODE='C';
    private static final string AGITATED_SPICY='B';
    /**@desc update OutletDispenser Attributes
*@param List<FS_Outlet_Dispenser__c>: List of outlet dispensers to which we need to update the attributes
*@return void
*/
    public static void updateOutletDispenserAttributes(final List<FS_Outlet_Dispenser__c> oDList){
        final Map<ID,ID> oDBrandMap=new Map<ID,ID>();
        final Set<ID> outletDispIdSet=new Set<ID>();
        //FET 7.1 Updating Brands check logic using custom setting
        final Platform_Type_ctrl__c platformTypeBrands = Platform_Type_ctrl__c.getInstance('updateBrands');
        final Map<ID,FS_Association_Brandset__c> assoBrandIDMap=new Map<ID,FS_Association_Brandset__c>();
        //Collection to store all Catridges for each Brandset
        final Map<Id,List<FS_Brandsets_Cartridges__c>> brandsetCartridgeMap=new Map<Id,List<FS_Brandsets_Cartridges__c>>();
        for(FS_Outlet_Dispenser__c oDObj:oDList){
            if(oDObj.recordTypeId!=recTypeInternational){
                outletDispIdSet.add(oDObj.Id);
            }            
        }        
        for(FS_Association_Brandset__c assoBrandObj:[SELECT Id,FS_Outlet_Dispenser__c,FS_Brandset__c,FS_Platform__c from FS_Association_Brandset__c 
                                                     WHERE FS_Outlet_Dispenser__c !=null AND FS_Outlet_Dispenser__c IN:outletDispIdSet AND FS_Brandset__c!=NULL]){
                                                         oDBrandMap.put(assoBrandObj.FS_Brandset__c,assoBrandObj.FS_Outlet_Dispenser__c);
                                                         assoBrandIDMap.put(assoBrandObj.FS_Outlet_Dispenser__c,assoBrandObj);
                                                     }
        
        //Proceed if both collections have values
        if(!oDBrandMap.isEmpty()){            
            /******************Iteration Start*******************************************************************/
            for(FS_Brandsets_Cartridges__c brandsetCatridge: 
                [SELECT Id,Name,FS_Brandset__c,FS_Cartridge__c,FS_Airwatch_Flag__c,FS_Cartridge__r.FS_Brand__c,
                 FS_Cartridge__r.FS_Flavor__c
                 FROM FS_Brandsets_Cartridges__c WHERE 
                 FS_Brandset__c IN :oDBrandMap.keySet()]){
                     
                     if(brandsetCartridgeMap.containsKey(brandsetCatridge.FS_Brandset__c)){
                         brandsetCartridgeMap.get(brandsetCatridge.FS_Brandset__c).add(brandsetCatridge);
                     }
                     else{
                         brandsetCartridgeMap.put(brandsetCatridge.FS_Brandset__c,new List<FS_Brandsets_Cartridges__c>{brandsetCatridge});
                     }
                 }
        }
        
        //Update OutletDispensers values based on cartridge attributes
        /******************Iteration Start*******************************************************************/ 
        for(FS_Outlet_Dispenser__c dispenserObj : oDList){
            if(assoBrandIDMap.containsKey(dispenserObj.Id)){
                
                //FET 7.1 Updating Brands check logic using custom setting
                if(!string.isEmpty(dispenserObj.FS_Equip_Type__c) && platformTypeBrands.Platforms__c.contains(dispenserObj.FS_Equip_Type__c)){
                    dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c='';
                    dispenserObj.FS_7000_Series_Static_Brands_Selections__c='';
                }
                else{
                    dispenserObj.FS_Spicy_Cherry__c='';
                }
                if(brandsetCartridgeMap.containsKey(assoBrandIDMap.get(dispenserObj.Id).FS_Brandset__c)){
                    for(FS_Brandsets_Cartridges__c cartridgeObj: brandsetCartridgeMap.get(assoBrandIDMap.get(dispenserObj.Id).FS_Brandset__c)){
                        
                        if((cartridgeObj.FS_Airwatch_Flag__c.equalsIgnoreCase(AGITATED_CODE) || cartridgeObj.FS_Airwatch_Flag__c.equalsIgnoreCase(AGITATED_SPICY)) &&
                           !string.isEmpty(dispenserObj.FS_Equip_Type__c) && platformTypeBrands.Platforms__c.contains(dispenserObj.FS_Equip_Type__c)){
                               //FET 7.1 Updating Brands check logic using custom setting
                               if(String.isBlank(dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c)){
                                   if(String.isBlank(cartridgeObj.FS_Cartridge__r.FS_Brand__c)){
                                       dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c=cartridgeObj.FS_Cartridge__r.FS_Flavor__c;
                                   }
                                   else{
                                       dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c=cartridgeObj.FS_Cartridge__r.FS_Brand__c;
                                   }                                      
                               }   
                               else{
                                   if(String.isBlank(cartridgeObj.FS_Cartridge__r.FS_Brand__c)){
                                       if(!dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c.containsIgnoreCase(cartridgeObj.FS_Cartridge__r.FS_Flavor__c)){                                          
                                           dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c+=';'+cartridgeObj.FS_Cartridge__r.FS_Flavor__c;
                                       }                                           
                                   }
                                   else{
                                       if(!dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c.containsIgnoreCase(cartridgeObj.FS_Cartridge__r.FS_Brand__c)){                                          
                                           dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c+=';'+cartridgeObj.FS_Cartridge__r.FS_Brand__c;
                                       }    
                                   }
                               }
                           }
                        
                        if(cartridgeObj.FS_Airwatch_Flag__c.equalsIgnoreCase(STATIC_CODE) &&
                           !string.isEmpty(dispenserObj.FS_Equip_Type__c) && platformTypeBrands.Platforms__c.contains(dispenserObj.FS_Equip_Type__c)){
                               //FET 7.1 Updating Brands check logic using custom setting
                               String brand='';
                               String flavor='';
                               brand=cartridgeObj.FS_Cartridge__r.FS_Brand__c;
                               flavor=cartridgeObj.FS_Cartridge__r.FS_Flavor__c;
                               if(String.isNotBlank(brand) && brand.equals('Vitaminwater')){
                                   brand='Vitamin Water';
                               }
                               if(String.isNotBlank(flavor) && flavor.equals('Vitaminwater')){
                                   flavor='Vitamin Water';
                               }
                               if(String.isBlank(dispenserObj.FS_7000_Series_Static_Brands_Selections__c)){
                                   if(String.isBlank(brand)){
                                       
                                       dispenserObj.FS_7000_Series_Static_Brands_Selections__c=flavor;
                                   }
                                   else{
                                       dispenserObj.FS_7000_Series_Static_Brands_Selections__c=brand;
                                   }
                               }   
                               else{                                       
                                   if(String.isBlank(brand)){
                                       if(!dispenserObj.FS_7000_Series_Static_Brands_Selections__c.containsIgnoreCase(flavor)){                                          
                                           dispenserObj.FS_7000_Series_Static_Brands_Selections__c+=';'+flavor;
                                       }                                           
                                   }
                                   else{
                                       if(!dispenserObj.FS_7000_Series_Static_Brands_Selections__c.containsIgnoreCase(brand)){                                          
                                           dispenserObj.FS_7000_Series_Static_Brands_Selections__c+=';'+brand;
                                       }    
                                   }
                               }
                           }
                        if((cartridgeObj.FS_Airwatch_Flag__c.equalsIgnoreCase(SPICY_CHERRY_CODE) || cartridgeObj.FS_Airwatch_Flag__c.equalsIgnoreCase(AGITATED_SPICY)) &&
                           !string.isEmpty(dispenserObj.FS_Equip_Type__c) && !platformTypeBrands.Platforms__c.contains(dispenserObj.FS_Equip_Type__c)){
                               //FET 7.1 Updating Brands check logic using custom setting
                               if(String.isBlank(cartridgeObj.FS_Cartridge__r.FS_Brand__c)){
                                   dispenserObj.FS_Spicy_Cherry__c=cartridgeObj.FS_Cartridge__r.FS_Flavor__c;
                               }
                               else{
                                   dispenserObj.FS_Spicy_Cherry__c=cartridgeObj.FS_Cartridge__r.FS_Brand__c;
                               }                                
                           }                            
                    }                       
                }    
            }
            
        }
        /******************Iteration End*******************************************************************/ 
    }
}