/***************************************************************************
 Name         : FSBrandsetCartridgeBusinessProcess
 Created By   : Infosys Limited
 Description  : Core class where the trigger functionality resides
 Created Date : 15-FEB-2017
****************************************************************************/
public class FSBrandsetCartridgeBusinessProcess{
    
    //This Map is to store the custom setting values of Airwatch data mapping
    private static Map<string,FS_FET_Airwatch_Data_Mapping__c> awSettingsMap=FS_FET_Airwatch_Data_Mapping__c.getAll();
    //These Sets are to store brands of types Agitated,Static and Spicy Cherry
    private static Set<string> agitatedBrands=new Set<string>();
    private static Set<string> staticBrands=new Set<string>();
    private static Set<string> spicyCherryBrand=new Set<string>();
    //These strings store the names of the fet airwatch data mapping custom setting
    private static final string AGITATED_BRAND='AgitatedBrand';
    private static final string STATIC_BRAND='StaticBrand';
    private static final string SPICY_CHERRY='SpicyCherry';
    private static final string AGITATED_CODE='A';
    private static final string STATIC_CODE='S';
    private static final string SPICY_CHERRY_CODE='C';
    private static final string AGITATED_SPICY_CODE='B';
    private static final string NONE_CODE='N';
    private static Map<id,String> cartridgeBrandMap=new Map<id,String>();
    private static Set<Id> cartridgeIdList=new Set<Id>();
    
   /**@desc updateCartridgeAWFlag
      *@param List<FS_Cartridge__c> newList- list of Cartridge records in trigger context
      *       Map<Id, SObject> sObjectsToUpdate- collection to hold all records to be updated in trigger context
      *@return void
   */
    public static void updateCartridgeAWFlag(final List<FS_Brandsets_Cartridges__c> newList,final Map<Id, SObject> sObjectsToUpdate){
        
        //This loop identifies the brand type and then adds the brand value to respective SET collection.
        for(FS_FET_Airwatch_Data_Mapping__c awFlag:awSettingsMap.values()){
            if(awFlag.Name.containsIgnoreCase(AGITATED_BRAND) && awFlag.FS_Active__c){
                agitatedBrands.add(awFlag.FS_FET_Value__c.toLowerCase());
            }
            if(awFlag.Name.containsIgnoreCase(STATIC_BRAND) && awFlag.FS_Active__c){
                staticBrands.add(awFlag.FS_FET_Value__c.toLowerCase());
            }
            if(awFlag.Name.containsIgnoreCase(SPICY_CHERRY) && awFlag.FS_Active__c){
                spicyCherryBrand.add(awFlag.FS_FET_Value__c.toLowerCase());
            }
        }
        //This loop adds cartridge id's to a list for later use
        for(FS_Brandsets_Cartridges__c cartridge:newList){
            cartridgeIdList.add(cartridge.FS_Cartridge__c);
        }
        //This loop puts the cartridge brand and it's id in a Map for later usage
        //A Cartridge may contain flavor or brand, this should be considered
        for(FS_Cartridge__c cart:[SELECT FS_Brand__c,FS_Flavor__c from FS_Cartridge__c where Id IN :cartridgeIdList]){
            String brandFlavorString='';
            if(String.isBlank(cart.FS_Brand__c)){
                brandFlavorString=cart.FS_Flavor__c;
                if(string.isNotBlank(brandFlavorString) && brandFlavorString.equals('Vitaminwater')){
                    brandFlavorString='Vitamin Water';
                }
                cartridgeBrandMap.put(cart.Id,brandFlavorString);
            }
            else if(String.isBlank(cart.FS_Flavor__c)){
                brandFlavorString=cart.FS_Brand__c;
                if(string.isNotBlank(brandFlavorString) && brandFlavorString.equals('Vitaminwater')){
                    brandFlavorString='Vitamin Water';
                }
                cartridgeBrandMap.put(cart.Id,brandFlavorString);
            }
            system.debug('brandFlavorString:-'+brandFlavorString);
        }
        
        //This loop sets the Airwatch Flag in each BrandsetCartridge junction record based on the brand.
        for(FS_Brandsets_Cartridges__c cartridge:newList){
            cartridge.FS_Airwatch_Flag__c=NONE_CODE;
            final String brand=cartridgeBrandMap.get(cartridge.FS_Cartridge__C);
            if(!string.isBlank(brand)){
                if(agitatedBrands.contains(cartridgeBrandMap.get(cartridge.FS_Cartridge__C).toLowerCase())){
                    cartridge.FS_Airwatch_Flag__c=AGITATED_CODE;
                }
                if(staticBrands.contains(cartridgeBrandMap.get(cartridge.FS_Cartridge__C).toLowerCase())){
                    cartridge.FS_Airwatch_Flag__c=STATIC_CODE;
                }
                if(spicyCherryBrand.contains(cartridgeBrandMap.get(cartridge.FS_Cartridge__C).toLowerCase())){
                    cartridge.FS_Airwatch_Flag__c=SPICY_CHERRY_CODE;
                }
                if(agitatedBrands.contains(cartridgeBrandMap.get(cartridge.FS_Cartridge__C).toLowerCase()) && spicyCherryBrand.contains(cartridgeBrandMap.get(cartridge.FS_Cartridge__C).toLowerCase())){
                   
                    cartridge.FS_Airwatch_Flag__c=AGITATED_SPICY_CODE;
                }
        	}
        }
    }
    //As of now, this functionality is put on hold-need further confirmation to enable this
    //Update the Association Brandset if the brandset is edited
    /*public static void updateAssociationBrndSet(List<FS_Brandsets_Cartridges__c> newList,Map<Id, SObject> sObjectsToUpdate){
        system.debug('In updateAssociationBrndSet');
        Set<Id> brandsetIds=new Set<Id>();
        for(FS_Brandsets_Cartridges__c brandCartObj:newList){
            brandsetIds.add(brandCartObj.FS_Brandset__c);
        }
        Map<Id,FS_Association_Brandset__c> associationBrands=new Map<Id,FS_Association_Brandset__c>([SELECT Id from FS_Association_Brandset__c WHERE FS_Brandset__c IN :brandsetIds AND FS_Outlet_Dispenser__c!=NULL AND FS_Headquarters__c=NULL AND FS_Installation__c=NULL]);
        system.debug('associationBrands:-'+associationBrands);
        if(!associationBrands.isEmpty()){
            try{
                database.update(associationBrands.values());
            }
            catch(DMLException dmlExp){
                ApexErrorLogger.addApexErrorLog('FET','FSBrandsetCartridgeBusinessProcess','updateAssociationBrndSet','FS_Association_Brandset__c','HIGH',dmlExp,dmlExp.getMessage());
            }
        }
        
    }*/
}