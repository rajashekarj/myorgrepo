/***************************************************************************
 Name         : FSInitialOrderTrigger
 Created By   : Mohit Parnami
 Description  : Handler class of FSInitialOrderTrigger
 Created Date : Oct 22, 2013

 // 9th Jan 2014      Modified By : Kirti Agarwal        Ref :    I-145254
 // Description       functionality update for before insert of initial order record
                      previously it was based on 'initial order' map now it converted to 'outlet' map
                      
   15th Jan 2014      Modified By : Deepti Maheshwari       Ref :    I-145254
 // Description       Moved initial order SAP material logic to trigger
  
//  10th Oct 2017      Modified By: Aman 
  // Description        functionality update populateDispenserCount() Method, to get sum of dispenser value from all        related           equip package   
 
****************************************************************************/
//Commenting Initial Order SAP Data Object related lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0

public with sharing class FSInitialOrderHandler {
  /* public static Map<Id,FS_Initial_Order__c> initialOrderMap=new Map<Id,FS_Initial_Order__c>(); //IO Redesign by Ranjan
   public static Id masterDataRecordTypeId= Schema.SObjectType.FS_Initial_Order_SAP_Data__c.getRecordTypeInfosByName().get('Initial Order Master Data').getRecordTypeId();
   public static Map<String,FS_Initial_Order_SAP_Data__c> initialOrderSapDataMap=new Map<String,FS_Initial_Order_SAP_Data__c>();  //IO Redesign by Ranjan
   private static Boolean alreadyRanbeforeInsert=false;
   private static Boolean alreadyRanafterInsert=false;
   private static Boolean alreadyRanbeforeUpdate=false;
   private static Boolean alreadyRanafterUpdate=false;*/
        //--------------------------------------------------------------------------------------
    // Executes Before Insert
    //--------------------------------------------------------------------------------------
    public static void beforeInsert(){
        updateInitialOrderFields();
        updateLocaltimeFieldInitialOrder();  
        updatePlatformTypes();
    }

        //--------------------------------------------------------------------------------------
    // Executes Before Update
    //--------------------------------------------------------------------------------------
    public static void beforeUpdate(){
        updateInitialOrderFields();
        //added by srini FET 2.1 update comments notes
        updateLocaltimeFieldInitialOrder();
    }
     //--------------------------------------------------------------------------------------
    // Executes After Insert
    //--------------------------------------------------------------------------------------
    public static void afterInsert(){
        updateCPONotesInInstallation();
    }
    //--------------------------------------------------------------------------------------
    // Executes After Update
    //--------------------------------------------------------------------------------------
    public static void afterUpdate(){
        updateCPONotesInInstallation();
    }
    /*public static void createSAPMaterialData(){
        createSAPData(Trigger.newMap.keyset());
    }
    
    public static void createSAPData(Set<ID> initialOrderIDList){
    List<FS_Initial_Order_SAP_Data__c> sapMaterialList = [SELECT Cartridge_Name__c,Brand_Group__c,Days_In_Stock__c,Cost_per_Unit__c,Name,Master_Data__c,Slots_8k9k__c,
                                                        Brand_Name__c,FS_7000_Package_Days_Capacity_1000__c,FS_Type__c,FS_Package_Days_Capacity_Pepper_1000__c  
                                                        FROM FS_Initial_Order_SAP_Data__c where RecordtypeId=:masterDataRecordTypeId and Master_Data__c =: true];
    
    for(FS_Initial_Order_SAP_Data__c sapData : sapMaterialList ){
      if(sapData.FS_Type__c=='8000 OR 9000 Series')
      { initialOrderSapDataMap.put(sapData.Name+':'+sapData.Cartridge_Name__c,sapData); }
    }
    
    
    List<FS_Initial_Order_SAP_Data__c> sapMaterialTransactionListToInsert;
    List<FS_Initial_Order__c> initialOrderList = [SELECT FS_Installation__r.FS_7000_Series_Statics_Brands_Selection__c,FS_Installation__r.FS_7000_Series_Agitated_Brands_Selection__c, Id,Name,
                                                 FS_dispInclude__c,FS_of_dispensers_to_ship_to_outlet__c,FS_Slots_Partial_Case__c,FS_Load_In_Stock__c,FS_ACN_Initial_Order_Days_Stock2__c,
                                                 FS_VPO_Override__c,FS_SpicyCherry__c,FS_Outlet__r.Name,FS_Mello_Yello_Check__c,FS_PADE_Check__c,FS_Installation__r.FS_Outlet__r.Name,
                                                 RecordType.Name FROM FS_Initial_Order__c WHERE id in :initialOrderIDList];
    
    for(FS_Initial_Order__c io: initialOrderList ){
       initialOrderMap.put(io.id,io);
    }
    
    RecordType initialOrderRecordtypeObj = [SELECT id FROM RecordType WHERE RecordType.Name =: FSConstants.INITIAL_ORDER_TRANSACTION_DATA];

    
    sapMaterialTransactionListToInsert = new List<FS_Initial_Order_SAP_Data__c>();
    
    for(FS_Initial_Order__c initialOrder : initialOrderList){

        FS_Initial_Order_SAP_Data__c initialOrderSAPData;
        
        for(FS_Initial_Order_SAP_Data__c sapMaterialData : sapMaterialList){
          if(initialOrder.RecordType.Name==FSConstants.x7000SeriesRecType || initialOrder.RecordType.Name==FSConstants.RELOCATION_7000_SERIES){
            if(sapMaterialData.Brand_Group__c == 'Core' && sapMaterialData.FS_Type__c =='7000 Series'){
                initialOrderSAPData = new FS_Initial_Order_SAP_Data__c();
                initialOrderSAPData.RecordTypeId =  initialOrderRecordtypeObj.id;
                copySAPMaterialDataToInitialOrder(sapMaterialData,initialOrderSAPData, initialOrder);
                sapMaterialTransactionListToInsert.add(initialOrderSAPData);
            }else if(sapMaterialData.Brand_Group__c == 'Agitated' &&  initialOrder.FS_Installation__r.FS_7000_Series_Agitated_Brands_Selection__c != null
                    && (initialOrder.FS_Installation__r.FS_7000_Series_Agitated_Brands_Selection__c.toLowerCase()).contains(sapMaterialData.Brand_Name__c.toLowerCase()) && sapMaterialData.FS_Type__c =='7000 Series'){
                initialOrderSAPData = new FS_Initial_Order_SAP_Data__c(); 
                initialOrderSAPData.RecordTypeId =  initialOrderRecordtypeObj.id;
                copySAPMaterialDataToInitialOrder(sapMaterialData,initialOrderSAPData,initialOrder);
                sapMaterialTransactionListToInsert.add(initialOrderSAPData);
            }else if(sapMaterialData.Brand_Group__c == 'Static' && initialOrder.FS_Installation__r.FS_7000_Series_Statics_Brands_Selection__c != null
                && (initialOrder.FS_Installation__r.FS_7000_Series_Statics_Brands_Selection__c.toLowerCase()).contains(sapMaterialData.Brand_Name__c.toLowerCase()) && sapMaterialData.FS_Type__c =='7000 Series'){
                initialOrderSAPData = new FS_Initial_Order_SAP_Data__c();
                initialOrderSAPData.RecordTypeId =  initialOrderRecordtypeObj.id;
                copySAPMaterialDataToInitialOrder(sapMaterialData,initialOrderSAPData,initialOrder);
                sapMaterialTransactionListToInsert.add(initialOrderSAPData);
            }
           }
            else if((initialOrder.RecordType.Name==FSConstants.x8K9KSeriesRecType || initialOrder.RecordType.Name==FSConstants.RELOCATION_8K9K_SERIES)  && sapMaterialData.FS_Type__c =='8000 OR 9000 Series'){
                    initialOrderSAPData = new FS_Initial_Order_SAP_Data__c();
                    initialOrderSAPData.RecordTypeId =  initialOrderRecordtypeObj.id;
                    copySAPMaterialDataToInitialOrder(sapMaterialData,initialOrderSAPData,initialOrder);
                    sapMaterialTransactionListToInsert.add(initialOrderSAPData);
            }
        }
    }
        
       
        //insert sapMaterialTransactionListToInsert;
        Set<Id> sapDataTransactionIds=new Set<Id>();
        Set<Id> sapDataTransactionIdstobedeleted=new Set<Id>();
        List<FS_Initial_Order_SAP_Data__c> sapDataListtobedeleted=new List<FS_Initial_Order_SAP_Data__c>();
        Set<FS_Initial_Order_SAP_Data__c> sapDataSettobedeleted=new Set<FS_Initial_Order_SAP_Data__c>();
        Database.SaveResult[] srList = Database.insert(sapMaterialTransactionListToInsert, true);
        for(Database.SaveResult sr : srList){
          if (sr.isSuccess()) {
            sapDataTransactionIds.add(sr.getId());
          }
        }
        Map<String,FS_Initial_Order_SAP_Data__c> sapTransactionDataDataMap=new Map<String,FS_Initial_Order_SAP_Data__c>();
        List<FS_Initial_Order_SAP_Data__c> sapMaterialTransactionList = [SELECT Id,Cartridge_Name__c,Brand_Group__c,Days_In_Stock__c,Cost_per_Unit__c,Name,
                                                                          Brand_Name__c,FS_7000_Package_Days_Capacity_1000__c,FS_Type__c, FS_Package_Days_Capacity_Pepper_1000__c, //FS_Spicy_Cherry8k9k__c, 
                                                                          Initial_Order__c,Initial_Order__r.FS_Outlet__r.Name FROM FS_Initial_Order_SAP_Data__c where Id in: sapDataTransactionIds];
                                                                          
        for(FS_Initial_Order_SAP_Data__c transData : sapMaterialTransactionList ){
          if(transData.FS_Type__c=='8000 OR 9000 Series'){
           sapTransactionDataDataMap.put(transData.Name+':'+transData.Cartridge_Name__c,transData);
          }
        }
        for(FS_Initial_Order__c initialOrder : initialOrderList){
          if(initialOrder.RecordType.Name==FSConstants.x8K9KSeriesRecType || initialOrder.RecordType.Name==FSConstants.RELOCATION_8K9K_SERIES){
          for(FS_Initial_Order_SAP_Data__c saptransacData : sapMaterialTransactionList ){
              
              if(initialOrderMap.get(initialOrder.id).FS_SpicyCherry__c=='Pibb/Pibb Zero' && sapTransactionDataDataMap.get('205082'+':'+'Dr. Pepper / Diet Dr. Pepper').Id!=null){
                   sapDataListtobedeleted.add(sapTransactionDataDataMap.get('205082'+':'+'Dr. Pepper / Diet Dr. Pepper'));
               }
              if(initialOrderMap.get(initialOrder.id).FS_SpicyCherry__c=='Dr Pepper/Diet Dr Pepper'){
                   if(sapTransactionDataDataMap.get('1445014'+':'+'Pibb Xtra / Pibb Xtra Zero').Id!=null)
                   { sapDataListtobedeleted.add(sapTransactionDataDataMap.get('1445014'+':'+'Pibb Xtra / Pibb Xtra Zero')); }
                   
                   if(initialOrderMap.get(initialOrder.id). FS_Outlet__r.Name!=null && initialOrderMap.get(initialOrder.id). FS_Outlet__r.Name.tolowercase().contains('firehouse')){
                      sapTransactionDataDataMap.get('205082'+':'+'Dr. Pepper / Diet Dr. Pepper').FS_7000_Package_Days_Capacity_1000__c=28.883429;
                   } 
               }
               
               if(initialOrderMap.get(initialOrder.id).FS_PADE_Check__c==true && sapTransactionDataDataMap.get('1488596'+':'+'Powerade').Id!=null){
                   sapDataListtobedeleted.add(sapTransactionDataDataMap.get('1488596'+':'+'Powerade'));
                 }
               if(initialOrderMap.get(initialOrder.id).FS_PADE_Check__c==false && sapTransactionDataDataMap.get('241378'+':'+'Powerade').Id!=null){
                   sapDataListtobedeleted.add(sapTransactionDataDataMap.get('241378'+':'+'Powerade'));
                }
               if(initialOrderMap.get(initialOrder.id).FS_Mello_Yello_Check__c==true && sapTransactionDataDataMap.get('1473972'+':'+'Vault / Vault Zero').Id!=null){
               	sapDataListtobedeleted.add(sapTransactionDataDataMap.get('1473972'+':'+'Vault / Vault Zero'));
               }
               if(initialOrderMap.get(initialOrder.id).FS_Mello_Yello_Check__c==false && sapTransactionDataDataMap.get('241078'+':'+'Mello Yello').Id!=null){
               	sapDataListtobedeleted.add(sapTransactionDataDataMap.get('241078'+':'+'Mello Yello'));
              	}
              if(initialOrderMap.get(initialOrder.id).FS_Installation__r.FS_Outlet__r.Name!=null && initialOrderMap.get(initialOrder.id).FS_Installation__r.FS_Outlet__r.Name.toLowercase().contains('firehouse') && sapTransactionDataDataMap.get('247578'+':'+'Seagram\'s'+' Gingerale').Id!=null){

               sapDataListtobedeleted.add(sapTransactionDataDataMap.get('247578'+':'+'Seagram\'s'+' Gingerale'));

              }
               if(initialOrderMap.get(initialOrder.id).FS_Installation__r.FS_Outlet__r.Name!=null && initialOrderMap.get(initialOrder.id).FS_Installation__r.FS_Outlet__r.Name.toLowercase().contains('firehouse')==false && sapTransactionDataDataMap.get('222878'+':'+'Black Cherry').Id!=null){

                   sapDataListtobedeleted.add(sapTransactionDataDataMap.get('222878'+':'+'Black Cherry'));

               }
             
               
             }  
           
          }
           
        }     
        try{
           if(sapTransactionDataDataMap.size()>0){
             update sapTransactionDataDataMap.values();
           }
        } 
        catch(Exception e){

        }       

        try{
          List<FS_Initial_Order_SAP_Data__c> tempListtodelete=new List<FS_Initial_Order_SAP_Data__c>();
            if(sapDataListtobedeleted.size()>0){
              sapDataSettobedeleted.addAll(sapDataListtobedeleted);
              tempListtodelete.addAll(sapDataSettobedeleted);

              delete tempListtodelete;
            }
        } 
        catch(Exception e){

        }                                    
    
  }
  
    private static void copySAPMaterialDataToInitialOrder(FS_Initial_Order_SAP_Data__c masterData, FS_Initial_Order_SAP_Data__c child, FS_Initial_Order__c initialOrder){
        if(masterData.FS_Type__c=='7000 Series' &&  (initialOrder.RecordType.Name==FSConstants.x7000SeriesRecType || initialOrder.RecordType.Name==FSConstants.RELOCATION_7000_SERIES)){
                 child.Brand_Group__c = masterData.Brand_Group__c;
                 child.Days_In_Stock__c = masterData.Days_In_Stock__c;
                 child.Brand_Name__c = masterData.Brand_Name__c;
                 child.Cartridge_Name__c = masterData.Cartridge_Name__c;
                 child.Cost_per_Unit__c = masterData.Cost_per_Unit__c;
                 child.Initial_Order__c = initialOrder.Id;
                 child.Master_Data__c = false;
                 child.Name = masterData.Name;
                 child.FS_Type__c= masterData.FS_Type__c; //Initial Order Redesign FET 2.1 by Ranjan
                 child.FS_7000_Package_Days_Capacity_1000__c = masterData.FS_7000_Package_Days_Capacity_1000__c;

             }
             if(masterData.FS_Type__c=='8000 OR 9000 Series' &&  (initialOrder.RecordType.Name==FSConstants.x8K9KSeriesRecType || initialOrder.RecordType.Name==FSConstants.RELOCATION_8K9K_SERIES)){
                  
                      child.Days_In_Stock__c = masterData.Days_In_Stock__c;
                      child.Master_Data__c = false;
                      child.FS_Type__c= masterData.FS_Type__c;
                      child.Initial_Order__c = initialOrder.Id;
                      child.Name = initialOrderSapDataMap.get(masterData.Name+':'+masterData.Cartridge_Name__c).Name;
                      child.Cartridge_Name__c = initialOrderSapDataMap.get(masterData.Name+':'+masterData.Cartridge_Name__c).Cartridge_Name__c;
                      if(initialOrder.FS_SpicyCherry__c != null && initialOrder.FS_SpicyCherry__c.contains('Pibb')) {
                        child.FS_7000_Package_Days_Capacity_1000__c = initialOrderSapDataMap.get(masterData.Name+':'+masterData.Cartridge_Name__c).FS_7000_Package_Days_Capacity_1000__c;  
                      } else if(initialOrder.FS_SpicyCherry__c != null && initialOrder.FS_SpicyCherry__c.contains('Pepper')) {
                        child.FS_7000_Package_Days_Capacity_1000__c = initialOrderSapDataMap.get(masterData.Name+':'+masterData.Cartridge_Name__c).FS_Package_Days_Capacity_Pepper_1000__c;    
                      }
                      child.Brand_Group__c = initialOrderSapDataMap.get(masterData.Name+':'+masterData.Cartridge_Name__c).Brand_Group__c;
                      child.Brand_Name__c = initialOrderSapDataMap.get(masterData.Name+':'+masterData.Cartridge_Name__c).Brand_Name__c;
                      child.Cost_per_Unit__c = initialOrderSapDataMap.get(masterData.Name+':'+masterData.Cartridge_Name__c).Cost_per_Unit__c;
                      child.Slots_8k9k__c=initialOrderSapDataMap.get(masterData.Name+':'+masterData.Cartridge_Name__c).Slots_8k9k__c;

                  
             }
  }
  
  */
  
  
    //----------------------------------------------------------------------------------------------
    // Method to get map of intial order Id and Initial order object to get reference fields (outlet)
    //-----------------------------------------------------------------------------------------------
    public static Map<Id, Account> getMapInitialOrder(){
        //I-145254 - Added outletsMap

        Map<Id, Account> outletsMap = new Map<Id, Account>();
        Set<Id> outletIds = new Set<Id>();
        for(FS_Initial_Order__c odr : (List<FS_Initial_Order__c>)Trigger.new) {
            outletIds.add(odr.FS_Outlet__c);
        }
        if(Trigger.newMap != null){
            outletsMap = new Map<Id, Account>([Select Id, Name
                                                From Account
                                                Where Id IN : outletIds]);
            return outletsMap;
        }
                return null;
    }


    //--------------------------------------------------------------------------------------
    // Method to Update fields of Initial Order Object
    //--------------------------------------------------------------------------------------
    public static void updateInitialOrderFields(){

        Map<Id, Account> outletsMap = getMapInitialOrder();

        //Loop to update fields of all intial orders inserted or updated
        for(FS_Initial_Order__c initialOrder : (List<FS_Initial_Order__c>)Trigger.new){

            //method to update FS_X7_Slots_to_Add2__c field of intial Order.
            update7SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_X2_Slots_to_Add2__c field of intial Order.
            update2SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_X4_Slots_to_Add2__c field of intial Order.
            update4SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_X5_Slots_to_Add2__c field of intial Order.
            update5SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_X3_Slots_to_Add2__c field of intial Order.
            update3SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_X18_Slots_to_Add2__c field of intial Order.
            update18SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_X22_Slots_to_Add2__c field of intial Order.
            update22SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_X16_Slots_to_Add2__c field of intial Order.
            update16SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_X15_Slots_to_Add2__c field of intial Order.
            update15SlotsToAdd(initialOrder, outletsMap);

            //method to update FS_Total_Customer_Cost2__c field of intial Order.
           // updateTotalCustomerCost(initialOrder);

            //method to update FS_Total_Initial_Slots2__c field of intial Order.
            //updateInitialSlot(initialOrder);
        }
    }



    //--------------------------------------------------------------------------------------
    // Method to Update FS_X7_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
    private static void update7SlotsToAdd (FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){

            if(outletsMap != null &&  outletsMap.get(initialOrder.FS_Outlet__c) != null
            && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){
                If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                            If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_7_Slots__c <=  initialOrder.FS_Slots_Partial_Case__c) ||
                                    (initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_7_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                        initialOrder.FS_X7_Slots_to_Add2__c = initialOrder.FS_7_Slots__c;
                            }else{
                                    initialOrder.FS_X7_Slots_to_Add2__c = 0;
                            }
                }else{
                    If((initialOrder.FS_1_Slots_to_Add__c+ initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_7_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                         initialOrder.FS_X7_Slots_to_Add2__c = initialOrder.FS_7_Slots__c;
                    }else{
                        initialOrder.FS_X7_Slots_to_Add2__c = 0;
                    }
                }
            }
        }



        //--------------------------------------------------------------------------------------
    // Method to Update FS_X2_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
        private static void update2SlotsToAdd(FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){
            if(outletsMap != null && outletsMap.get(initialOrder.FS_Outlet__c) != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){
            If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                        If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_2_Slots__c) <=  initialOrder.FS_Slots_Partial_Case__c ||
                                (initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_2_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                    initialOrder.FS_X2_Slots_to_Add2__c = initialOrder.FS_2_Slots__c;
                        }else{
                                initialOrder.FS_X2_Slots_to_Add2__c = 0;
                        }
                }else{
                        If((initialOrder.FS_1_Slots_to_Add__c+ initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_2_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                             initialOrder.FS_X2_Slots_to_Add2__c = initialOrder.FS_2_Slots__c;
                        }else{
                            initialOrder.FS_X2_Slots_to_Add2__c = 0;
                        }
                }
            }
        }


        //--------------------------------------------------------------------------------------
    // Method to Update FS_X4_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
        private static void update4SlotsToAdd(FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){
        if(outletsMap != null && outletsMap.get(initialOrder.FS_Outlet__c) != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){


            If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                        If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_4_Slots__c) <=  initialOrder.FS_Slots_Partial_Case__c ||
                                (initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_4_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                    initialOrder.FS_X4_Slots_to_Add2__c = initialOrder.FS_4_Slots__c;
                        }else{
                                initialOrder.FS_X4_Slots_to_Add2__c = 0;
                        }
                }else{
                    If(initialOrder.FS_1_Slots_to_Add__c+ initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_4_Slots__c <= initialOrder.FS_Slots_Partial_Case__c){
                         initialOrder.FS_X4_Slots_to_Add2__c = initialOrder.FS_4_Slots__c;
                    }else{
                        initialOrder.FS_X4_Slots_to_Add2__c = 0;
                    }

                }
        }
        }


        //--------------------------------------------------------------------------------------
    // Method to Update FS_X5_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
        private static void update5SlotsToAdd(FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){

        if(outletsMap != null && outletsMap.get(initialOrder.FS_Outlet__c) != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){
            If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                        If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_5_Slots__c) <=  initialOrder.FS_Slots_Partial_Case__c ||
                            (initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_5_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                    initialOrder.FS_X5_Slots_to_Add2__c = initialOrder.FS_5_Slots__c;
                        }else{
                                initialOrder.FS_X5_Slots_to_Add2__c = 0;
                        }
                }else{
                    If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_5_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                         initialOrder.FS_X5_Slots_to_Add2__c = initialOrder.FS_5_Slots__c;
                    }else{
                        initialOrder.FS_X5_Slots_to_Add2__c = 0;
                    }
                }
        }
        }



        //--------------------------------------------------------------------------------------
    // Method to Update FS_X3_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
        private static void update3SlotsToAdd(FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){
        if(outletsMap != null && outletsMap.get(initialOrder.FS_Outlet__c) != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){
            If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                        If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c+ + initialOrder.FS_3_Slots__c) <=  initialOrder.FS_Slots_Partial_Case__c ||
                            (initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_3_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                    initialOrder.FS_X3_Slots_to_Add2__c = initialOrder.FS_3_Slots__c;
                        }else{
                                initialOrder.FS_X3_Slots_to_Add2__c = 0;
                        }

                }else{

                        If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_3_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                             initialOrder.FS_X3_Slots_to_Add2__c = initialOrder.FS_3_Slots__c;
                        }else{
                            initialOrder.FS_X3_Slots_to_Add2__c = 0;
                        }
                }
        }
        }


        //--------------------------------------------------------------------------------------
    // Method to Update FS_X18_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
        private static void update18SlotsToAdd(FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){
        if(outletsMap != null && outletsMap.get(initialOrder.FS_Outlet__c) != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){
                If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                        If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c+ + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_18_Slots__c) <=  initialOrder.FS_Slots_Partial_Case__c ||
                            (initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_18_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                    initialOrder.FS_X18_Slots_to_Add2__c = initialOrder.FS_18_Slots__c;
                        }else{
                                initialOrder.FS_X18_Slots_to_Add2__c = 0;
                        }
                }else{
                    If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_18_Slots__c)  <= initialOrder.FS_Slots_Partial_Case__c){
                         initialOrder.FS_X18_Slots_to_Add2__c = initialOrder.FS_18_Slots__c;
                    }else{
                        initialOrder.FS_X18_Slots_to_Add2__c = 0;
                    }
                }
        }
        }

        //--------------------------------------------------------------------------------------
    // Method to Update FS_X22_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
        private static void update22SlotsToAdd(FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){
        if(outletsMap != null && outletsMap.get(initialOrder.FS_Outlet__c) != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){
                If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                    If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c+ + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_X16_Slots_to_Add2__c + initialOrder.FS_22_Slots__c) <=  initialOrder.FS_Slots_Partial_Case__c ||
                        (initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_X16_Slots_to_Add2__c + initialOrder.FS_22_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                initialOrder.FS_X22_Slots_to_Add2__c = initialOrder.FS_22_Slots__c;
                    }else{
                            initialOrder.FS_X22_Slots_to_Add2__c = 0;
                    }
                }else{
                    If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_X16_Slots_to_Add2__c + initialOrder.FS_22_Slots__c)  <= initialOrder.FS_Slots_Partial_Case__c){
                         initialOrder.FS_X22_Slots_to_Add2__c = initialOrder.FS_22_Slots__c;
                    }else{
                        initialOrder.FS_X22_Slots_to_Add2__c = 0;
                    }
                }
        }
        }



        //--------------------------------------------------------------------------------------
    // Method to Update FS_X16_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
        private static void update16SlotsToAdd(FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){
        if(outletsMap != null && outletsMap.get(initialOrder.FS_Outlet__c) != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){
                If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                    If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c+ + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_16_Slots__c) <=  initialOrder.FS_Slots_Partial_Case__c ||
                        (initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_16_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                initialOrder.FS_X16_Slots_to_Add2__c = initialOrder.FS_16_Slots__c;
                    }else{
                            initialOrder.FS_X16_Slots_to_Add2__c = 0;
                    }
                }else{
                    If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_16_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                         initialOrder.FS_X16_Slots_to_Add2__c = initialOrder.FS_16_Slots__c;
                    }else{
                        initialOrder.FS_X16_Slots_to_Add2__c = 0;
                    }
                }
        }
        }


        //--------------------------------------------------------------------------------------
    // Method to Update FS_X15_Slots_to_Add2__c
    //--------------------------------------------------------------------------------------
        private static void update15SlotsToAdd(FS_Initial_Order__c initialOrder, Map<Id, Account> outletsMap){
        if(outletsMap != null && outletsMap.get(initialOrder.FS_Outlet__c) != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != null && outletsMap.get(initialOrder.FS_Outlet__c).Name != ''){
                If( outletsMap.get(initialOrder.FS_Outlet__c).Name.Contains('firehouse') &&  initialOrder.FS_11_Package_Days_Capacity_1000__c != 10.6){
                    If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c+ + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_X16_Slots_to_Add2__c + initialOrder.FS_X22_Slots_to_Add2__c + initialOrder.FS_15_Slots__c) <=  initialOrder.FS_Slots_Partial_Case__c ||
                        (initialOrder.FS_11_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_X16_Slots_to_Add2__c + initialOrder.FS_X22_Slots_to_Add2__c + initialOrder.FS_15_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                                initialOrder.FS_X15_Slots_to_Add__c = initialOrder.FS_15_Slots__c;
                    }else{
                            initialOrder.FS_X15_Slots_to_Add__c = 0;
                    }
                }else{
                    If((initialOrder.FS_1_Slots_to_Add__c + initialOrder.FS_13_Slots_to_Add__c + initialOrder.FS_X7_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_X4_Slots_to_Add2__c + initialOrder.FS_X5_Slots_to_Add2__c + initialOrder.FS_X3_Slots_to_Add2__c + initialOrder.FS_X18_Slots_to_Add2__c + initialOrder.FS_X16_Slots_to_Add2__c + initialOrder.FS_X2_Slots_to_Add2__c + initialOrder.FS_15_Slots__c) <= initialOrder.FS_Slots_Partial_Case__c){
                         initialOrder.FS_X15_Slots_to_Add__c = initialOrder.FS_15_Slots__c;
                    }else{
                        initialOrder.FS_X15_Slots_to_Add__c = 0;
                    }
                }
        }
        }

        //--------------------------------------------------------------------------------------
    // Method to Update FS_Total_Customer_Cost2
    //--------------------------------------------------------------------------------------
       /* private static void updateTotalCustomerCost(FS_Initial_Order__c initialOrder){

            set<String> setFields = new Set<String>{'FS_1_Customer_Cost__c', 'FS_2_Customer_Cost__c', 'FS_3_Customer_Cost__c', 'FS_4_Customer_Cost__c', 'FS_5_Customer_Cost__c', 'FS_6_Customer_Cost__c', 'FS_7_Customer_Cost__c', 'FS_8_Customer_Cost__c'
                                                                                    , 'FS_9_Customer_Cost__c', 'FS_10_Customer_Cost__c', 'FS_11_Customer_Cost__c', 'FS_12_Customer_Cost__c', 'FS_13_Customer_Cost__c', 'FS_14_Customer_Cost__c', 'FS_15_Customer_Cost__c', 'FS_16_Customer_Cost__c'
                                                                                    , 'FS_17_Customer_Cost__c', 'FS_18_Customer_Cost__c', 'FS_19_Customer_Cost__c', 'FS_20_Customer_Cost__c', 'FS_21_Customer_Cost__c', 'FS_22_Customer_Cost__c', 'FS_23_Customer_Cost__c', 'FS_24_Customer_Cost__c'
                                                                                    , 'FS_25_Customer_Cost__c', 'FS_26_Customer_Cost__c'};

            if(initialOrder != null){
                initialOrder.FS_Total_Customer_Cost2__c = 0;
                for(String s : setFields){
                        Decimal returnValue = (Decimal) initialOrder.get(s);
                        if(returnValue != null){
                            initialOrder.FS_Total_Customer_Cost2__c += returnValue;
                        }
                }
            }
        }*/

            /*if(initialOrder != null){
                initialOrder.FS_Total_Customer_Cost2__c = initialOrder.FS_1_Customer_Cost__c + initialOrder.FS_2_Customer_Cost__c + initialOrder.FS_3_Customer_Cost__c +
                                                                    initialOrder.FS_4_Customer_Cost__c + initialOrder.FS_5_Customer_Cost__c + initialOrder.FS_6_Customer_Cost__c +
                                                                    initialOrder.FS_7_Customer_Cost__c + initialOrder.FS_8_Customer_Cost__c + initialOrder.FS_9_Customer_Cost__c +
                                                                    initialOrder.FS_10_Customer_Cost__c + initialOrder.FS_11_Customer_Cost__c + initialOrder.FS_12_Customer_Cost__c +
                                                                    initialOrder.FS_13_Customer_Cost__c + initialOrder.FS_14_Customer_Cost__c + initialOrder.FS_15_Customer_Cost__c +
                                                                    initialOrder.FS_16_Customer_Cost__c + initialOrder.FS_17_Customer_Cost__c + initialOrder.FS_18_Customer_Cost__c +
                                                                    initialOrder.FS_19_Customer_Cost__c + initialOrder.FS_20_Customer_Cost__c + initialOrder.FS_21_Customer_Cost__c +
                                                                    initialOrder.FS_22_Customer_Cost__c + initialOrder.FS_23_Customer_Cost__c + initialOrder.FS_24_Customer_Cost__c +
                                                                    initialOrder.FS_25_Customer_Cost__c + initialOrder.FS_26_Customer_Cost__c;
            }

        }*/

        //--------------------------------------------------------------------------------------
    // Method to Update FS_Total_Initial_Slots2
    //--------------------------------------------------------------------------------------
      /*  private static void updateInitialSlot(FS_Initial_Order__c initialOrder){


            set<String> setFields = new Set<String>{'FS_1_Initial_Total_Slots__c', 'FS_2_Initial_Total_Slots__c', 'FS_3_Initial_Total_Slots__c', 'FS_4_Initial_Total_Slots__c', 'FS_5_Initial_Total_Slots__c', 'FS_6_Initial_Total_Slots__c', 'FS_7_Initial_Total_Slots__c', 'FS_8_Initial_Total_Slots__c'
                                                                                    , 'FS_9_Initial_Total_Slots__c', 'FS_10_Initial_Total_Slots__c', 'FS_11_Initial_Total_Slots__c', 'FS_12_Initial_Total_Slots__c', 'FS_13_Initial_Total_Slots__c', 'FS_14_Initial_Total_Slots__c', 'FS_15_Initial_Total_Slots__c', 'FS_16_Initial_Total_Slots__c'
                                                                                    , 'FS_17_Initial_Total_Slots__c', 'FS_18_Initial_Total_Slots__c', 'FS_19_Initial_Total_Slots__c', 'FS_20_Initial_Total_Slots__c', 'FS_21_Initial_Total_Slots__c', 'FS_22_Initial_Total_Slots__c', 'FS_23_Initial_Total_Slots__c', 'FS_24_Initial_Total_Slots__c'
                                                                                    };

            if(initialOrder != null){
                initialOrder.FS_Total_Initial_Slots2__c = 0;
                for(String s : setFields){
                        Decimal returnValue = (Decimal) initialOrder.get(s);
                        if(returnValue != null){
                            initialOrder.FS_Total_Initial_Slots2__c += returnValue;
                        }
                }
            }
        }*/

            /*if(initialOrder != null){
                initialOrder.FS_Total_Initial_Slots2__c = initialOrder.FS_1_Initial_Total_Slots__c + initialOrder.FS_2_Initial_Total_Slots__c + initialOrder.FS_3_Initial_Total_Slots__c +
                                                                    initialOrder.FS_4_Initial_Total_Slots__c + initialOrder.FS_5_Initial_Total_Slots__c + initialOrder.FS_6_Initial_Total_Slots__c +
                                                                    initialOrder.FS_7_Initial_Total_Slots__c + initialOrder.FS_8_Initial_Total_Slots__c + initialOrder.FS_9_Initial_Total_Slots__c +
                                                                    initialOrder.FS_10_Initial_Total_Slots__c + initialOrder.FS_11_Initial_Total_Slots__c + initialOrder.FS_12_Initial_Total_Slots__c +
                                                                    initialOrder.FS_13_Initial_Total_Slots__c + initialOrder.FS_14_Initial_Total_Slots__c + initialOrder.FS_15_Initial_Total_Slots__c +
                                                                    initialOrder.FS_16_Initial_Total_Slots__c + initialOrder.FS_17_Initial_Total_Slots__c + initialOrder.FS_18_Initial_Total_Slots__c +
                                                                    initialOrder.FS_19_Initial_Total_Slots__c + initialOrder.FS_20_Initial_Total_Slots__c + initialOrder.FS_21_Initial_Total_Slots__c +
                                                                    initialOrder.FS_22_Initial_Total_Slots__c + initialOrder.FS_23_Initial_Total_Slots__c + initialOrder.FS_24_Initial_Total_Slots__c ;
            }

        }*/
 /*This method is covered under the process builder FSUpdateInstallNotesAndReadinessNotes
 private Static void updateInstall_Notes_Comments_IntialOrder(){
        List<FS_Initial_Order__c> ListInitialOrders=trigger.New;    
        Set<id> InstallationIDSet=new Set<id>();        
        Map<Id,FS_Installation__c> MapInstallation=new Map<Id,FS_Installation__c>();
        For(FS_Initial_Order__c InitialOrder:ListInitialOrders){
            InstallationIDSet.add(InitialOrder.FS_Installation__c);         
        }
        MapInstallation=new Map<Id,FS_Installation__c>([SELECT ID,FS_Install_Notes_Comments__c,FS_Readiness_Notes__c FROM FS_Installation__c WHERE ID=: InstallationIDSet ]);     
        For(FS_Initial_Order__c initialOrders:ListInitialOrders){       
            if( !MapInstallation.isEmpty()  && MapInstallation.containskey(initialOrders.FS_Installation__c)    
                                            && initialOrders.FS_InstallNotesComments_text__c!=MapInstallation.get(initialOrders.FS_Installation__c).FS_Install_Notes_Comments__c){                                  
            initialOrders.FS_InstallNotesComments_text__c=MapInstallation.get(initialOrders.FS_Installation__c).FS_Install_Notes_Comments__c;
            } 
            
            if( !MapInstallation.isEmpty()  && MapInstallation.containskey(initialOrders.FS_Installation__c)    
                                            && initialOrders.FS_Readiness_Notes__c!=MapInstallation.get(initialOrders.FS_Installation__c).FS_Readiness_Notes__c){                                  
            initialOrders.FS_Readiness_Notes__c=MapInstallation.get(initialOrders.FS_Installation__c).FS_Readiness_Notes__c;
            }
                                           
        }       
                 
    }*/
private Static void updateCPONotesInInstallation(){
    List<FS_Initial_Order__c> ListInitialOrder=trigger.new;     
    Map<id,FS_Initial_Order__c> oldMapInitialOrder=(Map<Id,FS_Initial_Order__c>)trigger.oldMap;
    Set<id> InstallationIDSet=new Set<id>();
    List<FS_Installation__c> installationList=new List<FS_Installation__c>();
    Map<Id,FS_Initial_Order__c> MaptoUpdateCPONotes=new Map<Id,FS_Initial_Order__c>();
    List<FS_Initial_Order__c> allInitialOrderOfInstallList=new List<FS_Initial_Order__c>();
    For(FS_Initial_Order__c InitialOrder:ListInitialOrder){
        if((trigger.isUpdate &&(oldMapInitialOrder.get(InitialOrder.id).FS_CPO_Notes__c!=InitialOrder.FS_CPO_Notes__c
                             || oldMapInitialOrder.get(InitialOrder.id).FS_Order_Processed_By_form__c!=InitialOrder.FS_Order_Processed_By_form__c 
                             || oldMapInitialOrder.get(InitialOrder.id).FS_Order_Processed_DataTime__c!=InitialOrder.FS_Order_Processed_DataTime__c))
                             ||(trigger.isInsert 
                             && (InitialOrder.FS_CPO_Notes__c!=''
                             || InitialOrder.FS_Order_Processed_By_form__c!=''
                             || InitialOrder.FS_Order_Processed_DataTime__c!=null))){
            InstallationIDSet.add(InitialOrder.FS_Installation__c);
        }   
        if (InitialOrder.FS_Order_Processed__c == true){
        
        }       
    }
    
    installationList=[SELECT ID,FS_Order_Processed_Data_Time__c,FS_Order_Processed_By__c,FS_CPO_Notes__c    FROM FS_Installation__c WHERE id=:installationIDSet];
    allInitialOrderOfInstallList=[SELECT ID,FS_Installation__c,FS_Order_Processed_DataTime__c,FS_Order_Processed_By_form__c,FS_CPO_Notes__c,CreatedDate FROM FS_Initial_Order__c WHERE FS_Installation__c=:installationIDSet];
    
    for(FS_Initial_Order__c initialorder:allInitialOrderOfInstallList){
            if(!MaptoUpdateCPONotes.containsKey(initialorder.FS_Installation__c) ){                 
                MaptoUpdateCPONotes.put(initialorder.FS_Installation__c,initialorder);  
            }
            else if(MaptoUpdateCPONotes.containsKey(initialorder.FS_Installation__c) 
                                && MaptoUpdateCPONotes.get(initialorder.FS_Installation__c).CreatedDate<initialorder.CreatedDate ){
                MaptoUpdateCPONotes.put(initialorder.FS_Installation__c,initialorder);
            }               
    }
      
    for(FS_Installation__c install:InstallationList){       
        if(MaptoUpdateCPONotes.containsKey(install.id)){
            install.FS_CPO_Notes__c=MaptoUpdateCPONotes.get(install.id).FS_CPO_Notes__c;
            install.FS_Order_Processed_By__c=MaptoUpdateCPONotes.get(install.id).FS_Order_Processed_By_form__c;
            install.FS_Order_Processed_Data_Time__c=MaptoUpdateCPONotes.get(install.id).FS_Order_Processed_DataTime__c;             
        }
    }   
    if(!InstallationList.isEmpty()){
        try{
            update InstallationList;
        }
        catch(Exception Ex){            
            
        }
    }
 }
 Public static void updateLocaltimeFieldInitialOrder(){
       List<FS_Initial_Order__c> InstallationLocalField = (List<FS_Initial_Order__c>)Trigger.new;
       
        
       for(FS_Initial_Order__c install :InstallationLocalField)
       {
         
          
         Datetime dr= DateTime.now().addHours(-4);
         String srcString=String.valueof((dr.formatGMT('YYYY-MM-dd hh:mm:ss a')));
         install.FS_Local_Time__c=srcString;
          
       }
    }
    
    
    //FET 5.0 
    /*To cascade platform type from related installation*/

    public static void updatePlatformTypes(){
        Decimal quantityValue; 
        FS_Installation__c install;
        //New Trigger Value
        List<FS_Initial_Order__c> InstallationLocalField = (List<FS_Initial_Order__c>)Trigger.new;
        //To hold installation id
        Set<Id> instllationIDList= new Set<Id>();
        for(FS_Initial_Order__c io:InstallationLocalField){
            instllationIDList.add(io.FS_Installation__c);
        }
        //Fetch related installation
        Map<id,FS_Installation__c> MapInst =new Map<id,FS_Installation__c>([select id,Type_of_Dispenser_Platform__c,FS_DispOrder1__c,
                                                                            FS_DispOrder2__c,FS_DispOrder3__c from FS_Installation__c where id in: instllationIDList  ]);
    
        //Update initial order platform
        for(FS_Initial_Order__c initialOrder:InstallationLocalField){
            if(MapInst.containsKey(initialOrder.FS_Installation__c)){
                install=MapInst.get(initialOrder.FS_Installation__c);
                quantityValue=0;
                quantityValue+=install.FS_DispOrder1__c != null? install.FS_DispOrder1__c : 0;
                quantityValue+=install.FS_DispOrder2__c != null? install.FS_DispOrder2__c : 0;
                quantityValue+=install.FS_DispOrder3__c != null? install.FS_DispOrder3__c : 0;
                initialOrder.FS_Number_of_Freestyle_Dispensers__c=quantityValue;
            }            
        }
    }
}