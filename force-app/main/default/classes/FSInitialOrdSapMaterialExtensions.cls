/***************************************************************************************************************************
Name         : FSInitialOrdSapMaterialExtensions
Created By   : Pallavi Sharma (Appiro)
Created Date : 23 - Oct - 2013
Usage        : Extension for FSInitialOrdSapMaterial Page. This is inline page in Initial order to show calculations.

15th Jan 2014      Modified By : Deepti Maheshwari       Ref :    I-145254
Description       Moved initial order SAP material logic to trigger
****************************************************************************************************************************/
public with sharing class FSInitialOrdSapMaterialExtensions{

  public FS_Initial_Order__c initialOrder{get;set;}
  public Boolean show7000Section{get;set;}
  public static Id ioId;
 /* Commenting Initial Order SAP Data Object related lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0
  public Map<String,Decimal> sapMaterialOverrideMap{get;set;}
  public Map<String,FS_Initial_Order_SAP_Data__c> sapMaterialMap {get;set;}
  private static String transactionDataRecordType = 'Initial Order Transaction Data';
  //Constructor
 
  public FSInitialOrdSapMaterialExtensions( Apexpages.Standardcontroller sc ){
    ioId = sc.getId();
    initialOrder = (FS_Initial_Order__c)sc.getRecord();
  } 

  public List<InitialOrderWrp> lstInitialOrderWrp {get;set;}
  public void populatelstInitialOrderWrp(){
        lstInitialOrderWrp = new List<InitialOrderWrp>();
        RecordType recordTypeInitialOrder = [SELECT name FROM recordType WHERE id =: initialOrder.RecordTypeId];
        try {
            if(recordTypeInitialOrder.Name == '7000 Series'  || recordTypeInitialOrder.Name == 'Relocation 7000 Series'){
                show7000Section = true;
                updatelstInitialOrderWrp();
            }else{
                show7000Section = false;
                initDisplayFields();
            }   
        } catch(Exception exp) {
            System.debug('populatelstInitialOrderWrp#Exception occurred- '+exp);
        }
        
        return;
    }

  //Start
  //Added by @Harshita Khandelwal
    public static void setlstInitialOrderWrp(List<FS_Initial_Order__c> initialOrderIdList){
    List<FS_Initial_Order_SAP_Data__c> initialOrderSAPList = [SELECT Cartridge_Name__c,Brand_Group__c,Days_In_Stock__c,Cost_per_Unit__c,Name,Master_Data__c,
                                                                Brand_Name__c,FS_7000_Package_Days_Capacity_1000__c FROM FS_Initial_Order_SAP_Data__c where Initial_Order__r.id in: initialOrderIdList];
    system.debug('before deleting existing data'+ initialOrderSAPList );
    if(initialOrderSAPList.size() > 0){
        delete initialOrderSAPList;
    }
    Set<Id> initialOrderIDSet = new Set<Id>();
    for(FS_Initial_Order__c initialOrder : initialOrderIdList){
      initialOrderIDSet.add(initialOrder.id);
    }
    FSInitialOrderHandler.createSAPData(initialOrderIDSet);
  }
  //End @Harshita Khandelwal

  private void updatelstInitialOrderWrp(){
    lstInitialOrderWrp = new List<InitialOrderWrp>();
    InitialOrderWrp initialOrderWrpTemp;
    List<FS_Initial_Order_SAP_Data__c> sapMaterialTransactionList = [SELECT Cartridge_Name__c,Cost_per_Unit__c,Name,Brand_Name__c,Customer_Cost__c,Load_in_Stock__c,
                                                    Total_Order__c,Brand_Group__c,Days_In_Stock__c,Master_Data__c,FS_7000_Package_Days_Capacity_1000__c FROM FS_Initial_Order_SAP_Data__c
                                                    WHERE Master_Data__c =: false AND FS_Type__c='7000 Series' AND Initial_Order__r.id =: ioId];
    for(FS_Initial_Order_SAP_Data__c initialOrderSAPMaterial : sapMaterialTransactionList){

        initialOrderWrpTemp = new InitialOrderWrp();
        initialOrderWrpTemp.sapMaterial = initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c;
        initialOrderWrpTemp.sapMaterialNumber = initialOrderSAPMaterial.Name;
        initialOrderWrpTemp.costUnit = String.valueof(initialOrderSAPMaterial.Cost_per_Unit__c);
        initialOrderWrpTemp.customerCost = String.valueof(initialOrderSAPMaterial.Customer_Cost__c);
        initialOrderWrpTemp.totalOrdered = string.valueOf(initialOrderSAPMaterial.Total_Order__c);
        lstInitialOrderWrp.add(initialOrderWrpTemp);
    }
        return;
  }


  //----------------------------------------------------------------------------------------------------------------
  // Prepare a list with API names so that IO can be displayed row wise
  // For 26 Caculations 26 rows are added in list
  //----------------------------------------------------------------------------------------------------------------
  private void initDisplayFields(){
    
    try {
            List<FSSAPMaterialNameAndOverrideField__c> customSettingList=[select SAP_Material_Name__c,Cartridge_Name__c,OverrideField__c from FSSAPMaterialNameAndOverrideField__c];
            Map<String,String>  customSettingMap = new Map<String,String>();
            for(FSSAPMaterialNameAndOverrideField__c csList: customSettingList){
               customSettingMap.put(csList.SAP_Material_Name__c+ ':' + csList.Cartridge_Name__c,csList.OverrideField__c);
            } 
            
            Map<Id,FS_Initial_Order__c> ioMap=new Map<Id,FS_Initial_Order__c>([select id,FS_Order_Processed_DataTime__c,FS_VPO_Override__c,FS_SpicyCherry__c,FS_Slots_Partial_Case__c,FS_Load_In_Stock__c,FS_ACN_Initial_Order_Days_Stock2__c,
                                                        FS_1_Override__c,FS_2_Override__c, FS_3_Override__c,FS_4_Override__c,FS_5_Override__c,FS_6_Override__c,FS_7_Override__c,FS_8_Override__c,FS_9_Override__c,
                                                       FS_10_Override__c,FS_11_Override__c,FS_12_Override__c,FS_13_Override__c,FS_14_Override__c,FS_15_Override__c,FS_16_Override__c,FS_17_Override__c,
                                                       FS_18_Override__c,FS_19_Override__c,FS_20_Override__c,FS_21_Override__c,FS_22_Override__c,FS_23_Override__c,FS_24_Override__c, 
                                                       FS_25_Override__c,FS_26_Override__c from FS_Initial_Order__c where id=: ioId]);
            
            
            
            List<FS_Initial_Order_SAP_Data__c> sapMaterialTransactionList = [SELECT Name,Cartridge_Name__c,Cost_per_Unit__c,Brand_Name__c,True_Total_Ordered_8k9k__c,Total_Ordered_8k9k__c,
                                                           Brand_Group__c,Master_Data__c, Load_In_Stock__c, Safety_Stock_8k9k__c, Slots_to_Add__c, 
                                                           Initial_Order__r.FS_Mello_Yello_Check__c, Initial_Order__r.FS_SpicyCherry__c, Initial_Order__r.FS_Installation__r.FS_Outlet__r.Name   
                                                           FROM FS_Initial_Order_SAP_Data__c WHERE Master_Data__c =: false AND FS_Type__c='8000 OR 9000 Series' AND Initial_Order__r.id =: ioId 
                                                           ORDER BY Brand_Group__c, Cartridge_Name__c];
            
            System.debug('sapMaterialTransactionList Value- '+sapMaterialTransactionList);
            sapMaterialOverrideMap=new Map<String,Decimal>();
            sapMaterialMap=new Map<String,FS_Initial_Order_SAP_Data__c >();
            InitialOrderWrp initialOrderWrpTemp;
            
            
            
            for(FS_Initial_Order_SAP_Data__c initialOrderSAPMaterial : sapMaterialTransactionList ){
                sapMaterialMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c,initialOrderSAPMaterial);
            }
            
            for(FS_Initial_Order_SAP_Data__c initialOrderSAPMaterial : sapMaterialTransactionList ){
                
                   String overrideField='';
                   Decimal tempValue=null;
                   
                   if(initialOrderSAPMaterial.Name=='222878' && initialOrderSAPMaterial.Initial_Order__r.FS_Installation__r.FS_Outlet__c!=null
                                && initialOrderSAPMaterial.Initial_Order__r.FS_Installation__r.FS_Outlet__r.Name.containsIgnoreCase('firehouse')) { // Black Chery
                    overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 1'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                   
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                    populateWrapperList(initialOrderSAPMaterial);
                   }
                   else if(initialOrderSAPMaterial.Name=='247578' && initialOrderSAPMaterial.Initial_Order__r.FS_Installation__r.FS_Outlet__c!=null
                                && !initialOrderSAPMaterial.Initial_Order__r.FS_Installation__r.FS_Outlet__r.Name.containsIgnoreCase('firehouse')) { // Seagram's Gingerale
                                
                    overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 2'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                   
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                    populateWrapperList(initialOrderSAPMaterial);
                  }
                  else if(initialOrderSAPMaterial.Name=='241078' 
                                && initialOrderSAPMaterial.Initial_Order__r.FS_Mello_Yello_Check__c == true ) { // Mello Yello 
                     
                     overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 3'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                   
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                    populateWrapperList(initialOrderSAPMaterial);
                  }
                  else if(initialOrderSAPMaterial.Name=='1473972' 
                                && initialOrderSAPMaterial.Initial_Order__r.FS_Mello_Yello_Check__c == false) { //  Vault / Vault Zero
                     
                     overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 4'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                   
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                    populateWrapperList(initialOrderSAPMaterial);
                  } 
                  else if(initialOrderSAPMaterial.Name=='205082'
                                && initialOrderSAPMaterial.Initial_Order__r.FS_SpicyCherry__c != null 
                                && initialOrderSAPMaterial.Initial_Order__r.FS_SpicyCherry__c.containsIgnoreCase('Pepper') ) { // Dr. Pepper / Diet Dr. Pepper 
                    
                    overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 5'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                   
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                    populateWrapperList(initialOrderSAPMaterial);
                  }
                  else if(initialOrderSAPMaterial.Name=='1445014' 
                                && initialOrderSAPMaterial.Cartridge_Name__c == 'Pibb Xtra / Pibb Xtra Zero'
                                && initialOrderSAPMaterial.Initial_Order__r.FS_SpicyCherry__c != null 
                                && initialOrderSAPMaterial.Initial_Order__r.FS_SpicyCherry__c.equalsIgnoreCase('Pibb/Pibb Zero')) { // Pibb Xtra / Pibb Xtra Zero
                    
                    overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 6'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                    
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                   populateWrapperList(initialOrderSAPMaterial);
                    
                  } else if(initialOrderSAPMaterial.Name=='1445014' 
                                && initialOrderSAPMaterial.Cartridge_Name__c == 'Pibb'
                                && initialOrderSAPMaterial.Initial_Order__r.FS_SpicyCherry__c != null 
                                && initialOrderSAPMaterial.Initial_Order__r.FS_SpicyCherry__c.equalsIgnoreCase('Pibb')) { // Pibb
                    
                    overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 7'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                    
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                   populateWrapperList(initialOrderSAPMaterial);
                    
                 } else if(initialOrderSAPMaterial.Name=='222878' && initialOrderSAPMaterial.Initial_Order__r.FS_Installation__r.FS_Outlet__c!=null
                                && initialOrderSAPMaterial.Initial_Order__r.FS_Installation__r.FS_Outlet__r.Name.containsIgnoreCase('firehouse')) { // Black Chery
                    
                    overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 8'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                    
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                   populateWrapperList(initialOrderSAPMaterial);
                    
                 } else if(initialOrderSAPMaterial.Name=='247578' && initialOrderSAPMaterial.Initial_Order__r.FS_Installation__r.FS_Outlet__c!=null
                                && !initialOrderSAPMaterial.Initial_Order__r.FS_Installation__r.FS_Outlet__r.Name.containsIgnoreCase('firehouse')) { // Seagram's Gingerale
                    
                    overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                    system.debug('Condition 9'+overrideField);
                    tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                    
                    sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                    populateWrapperList(initialOrderSAPMaterial);
                 }
                  else if(initialOrderSAPMaterial.Name!='222878' && initialOrderSAPMaterial.Name!='247578' && initialOrderSAPMaterial.Name!='241078' 
                         && initialOrderSAPMaterial.Name!='1473972' && initialOrderSAPMaterial.Name!='205082' && initialOrderSAPMaterial.Name!='1445014' 
                         && initialOrderSAPMaterial.Name!='222878' && initialOrderSAPMaterial.Name!='247578'){
                   overrideField=customSettingMap.get(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c);
                   system.debug('Condition 10'+overrideField);
                   tempValue=(Decimal)ioMap.get(initialOrderSAPMaterial.Initial_Order__r.id).get(overrideField);
                   
                   sapMaterialOverrideMap.put(initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c, tempValue!=null? tempValue :(initialOrderSAPMaterial.True_Total_Ordered_8k9k__c!=null? initialOrderSAPMaterial.True_Total_Ordered_8k9k__c:null));
                   populateWrapperList(initialOrderSAPMaterial);
                  } 
                 system.debug('new mapper'+sapMaterialOverrideMap);
                
            }
            
            lstInitialOrderWrp.sort();
            
    } catch(Exception exp) {
        System.debug('FSInitialOrdSapMaterialExtensions#initDisplayFields#Exception occurred- '+exp);
    }
   
    return;
  }
  
  private void populateWrapperList(FS_Initial_Order_SAP_Data__c  initialOrderSAPMaterial){
    system.debug('object SAP'+initialOrderSAPMaterial);
    Decimal customerCostTemp=null;
    Decimal totalOrderedTemp= null;  
    Decimal costUnitTemp=null; 
    
    InitialOrderWrp initialOrderWrpTemp=new InitialOrderWrp ();
    initialOrderWrpTemp.brandGroup = initialOrderSAPMaterial.Brand_Group__c;
    initialOrderWrpTemp.brandName = initialOrderSAPMaterial.Brand_Name__c;
    initialOrderWrpTemp.sapMaterial = initialOrderSAPMaterial.Name + ':' + initialOrderSAPMaterial.Cartridge_Name__c;
    initialOrderWrpTemp.sapMaterialNumber= initialOrderSAPMaterial.Name;
    initialOrderWrpTemp.costUnit= String.valueOf(sapMaterialMap.get(initialOrderWrpTemp.sapMaterial).Cost_per_Unit__c);
    costUnitTemp=sapMaterialMap.get(initialOrderWrpTemp.sapMaterial).Cost_per_Unit__c;
    initialOrderWrpTemp.totalOrdered=  String.valueOf(sapMaterialOverrideMap.get(initialOrderWrpTemp.sapMaterial)!=null && sapMaterialOverrideMap.get(initialOrderWrpTemp.sapMaterial)!=0.00 ?sapMaterialOverrideMap.get(initialOrderWrpTemp.sapMaterial): null) ;
    totalOrderedTemp=sapMaterialOverrideMap.get(initialOrderWrpTemp.sapMaterial)!=null && sapMaterialOverrideMap.get(initialOrderWrpTemp.sapMaterial)!=0.00 ?sapMaterialOverrideMap.get(initialOrderWrpTemp.sapMaterial): null;
    if(totalOrderedTemp != null && costUnitTemp != null && totalOrderedTemp != 0.00 && costUnitTemp != 0.00) {
        customerCostTemp= (costUnitTemp * totalOrderedTemp).setScale(2);
    } 
    initialOrderWrpTemp.customerCost=String.valueOf( customerCostTemp);
    lstInitialOrderWrp.add(new InitialOrderWrp(initialOrderWrpTemp.brandGroup, initialOrderWrpTemp.brandName, initialOrderWrpTemp.sapMaterial,initialOrderWrpTemp.sapMaterialNumber,'','','','',initialOrderWrpTemp.totalOrdered,initialOrderWrpTemp.costUnit,initialOrderWrpTemp.customerCost));
    system.debug('lstInitialOrderWrp Size'+lstInitialOrderWrp.size());
    system.debug('lstInitialOrderWrp Keys'+lstInitialOrderWrp);     
  }

  //----------------------------------------------------------------------------------------------------------------
  //Wrapper Class to show calculations
  //----------------------------------------------------------------------------------------------------------------
  public class InitialOrderWrp implements Comparable {
    public String brandGroup{get;set;}
    public String brandName{get;set;}
    public String sapMaterial{get;set;}
    public String sapMaterialNumber{get;set;}
    public String capacity1000{get;set;}
    public String capacity{get;set;}
    public String loadInStock{get;set;}
    public String safetyStock{get;set;}
    public String totalOrdered{get;set;}
    public String costUnit{get;set;}
    public String customerCost{get;set;}
    public Double customerCostDouble{get;set;}
    
    public InitialOrderWrp() {

    }
    
    
    //Constructor  to initialize wrapper
    public InitialOrderWrp(String brandGroup, String brandName, String sapMaterial, String sapMaterialNumber, String capacity1000, String capacity, String loadInStock,
                           String safetyStock, String totalOrdered, String costUnit, String customerCost ) {
      this.brandGroup = brandGroup;
      this.brandName = brandName;
      this.sapMaterial = sapMaterial;
      this.sapMaterialNumber = sapMaterialNumber;
      this.capacity1000 = capacity1000;
      this.capacity = capacity;
      this.loadInStock = loadInStock;
      this.safetyStock = safetyStock;
      this.totalOrdered = totalOrdered;
      this.costUnit = costUnit;
        this.customerCost = customerCost;
    }

    
    
    public Integer compareTo(Object compareTo) 
    {
        InitialOrderWrp obj = (InitialOrderWrp) compareTo;
        if (this.brandGroup == obj.brandGroup) return 0;
        if (this.brandGroup > obj.brandGroup) {
            if(this.brandName > obj.brandName) {
                return 1;
            }   
        }
        return -1;        
    }
    

  }*/
}