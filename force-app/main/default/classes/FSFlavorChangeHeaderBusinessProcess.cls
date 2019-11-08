/***************************************************************************
 Name         : FSFlavorChangeHeaderBusinessProcess
 Created By   : Infosys Limited
 Description  : FSFlavorChangeHeaderBusinessProcess has all functions (Business logic) 
 Created Date : 23-JAN-2017
*********************** *****************************************************/
public without sharing class FSFlavorChangeHeaderBusinessProcess{
	
    private static final Integer FIVE=5;
    private static final string SPYESSTRING='Yes';
    Public static list<FS_Outlet_Dispenser__c> odList;
    private static final string PLATFORM7K='7000';
    private static final String FLAVORCHANGEOUTLET='FS Flavor Change Outlet';
    private static final String FLAVORCHANGEINSTALL='FS Flavor Change Installation';
    private static final String FLAVORCHANGEOUTLETDISPENSER='FS Flavor Change Outlet Dispenser';
    private static final String DELIVERYMETHODDIRECTSHIP='Direct Ship';
    private static final String DELIVERYMETHODDISTRIBUTOR='Distributor';
    private static final String DELIVERYMETHODBOTTLER='Bottler';
    private static final String APPROVED='Approved';
    private static final String CHNGDTODIRECTSHIP='Changed to Direct Ship';
    private static final Object NULLOBJ = null;
    private static final String FILETYPE='File';
    private static final String ACTION='FUP Needed';
    private static final String STATUS='Not Started';
    private static final String PRIORITY='Normal';
    Public Map<Id,List<FS_Flavor_Change_New__c>> headerWithList = New Map<Id,List<FS_Flavor_Change_New__c>>();
    public static final Id FCLINEOUTLETRECORDTYPEID=Schema.SObjectType.FS_Flavor_Change_New__c.getRecordTypeInfosByName().get(FLAVORCHANGEOUTLET).getRecordTypeId(); 
    public static final Id FCLINEDISPENSERRECORDTYPEID=Schema.SObjectType.FS_Flavor_Change_New__c.getRecordTypeInfosByName().get(FLAVORCHANGEOUTLETDISPENSER).getRecordTypeId();  
    public static final Map<Id,String> FLAVORCHANGEHEADERRECORDTYPEMAP=FSUtil.getObjectRecordTypeIdAndNAme(FS_Flavor_Change_Head__c.SObjectType);  
    public static final Map<Id,String> FLAVORCHANGELINERECORDTYPEMAP=FSUtil.getObjectRecordTypeIdAndNAme(FS_Flavor_Change_New__c.SObjectType);
    private static list<String> outletZIPs{set;get;}
     
 
    /*
    * @methodName: updateChildHeaders
    * @parameter : trigger.newList,trigger.oldMap
    * @return Type: void
    * @description: Method updates all the outlet level headers' fields under the HQ level header for mentioned fields
    */
    public static void updateChildHeaders(final List<FS_Flavor_Change_Head__c> newList,final Map<Id,FS_Flavor_Change_Head__c> oldMap){
        final Set<Id> hqIdSet=new Set<Id>();
        final Map<Id,List<FS_Flavor_Change_Head__c>> hqAndOlMap=new Map<Id,List<FS_Flavor_Change_Head__c>>();
        final List<FS_Flavor_Change_Head__c> finalUpdateList=new List<FS_Flavor_Change_Head__c>();
        

        
        //This loop iterates over the HQ header and any change on below fields, will copy the header to the SET
        for(FS_Flavor_Change_Head__c fcHQHead:newList){
            FS_Flavor_Change_Head__c fcOld=new FS_Flavor_Change_Head__c();
            fcOld=oldMap.get(fcHQHead.Id);
            if(!(fcHQHead.FS_FC_Type__c).contains(FILETYPE) &&
              	FLAVORCHANGEHEADERRECORDTYPEMAP.get(fcHQHead.RecordTypeId)=='FS Flavor Change Chain HQ' &&
                (fcOld.FS_Approved__c!=fcHQHead.FS_Approved__c ||
                 fcOld.FS_Entering_COM__c!=fcHQHead.FS_Entering_COM__c ||
                 fcOld.FS_Description__c!=fcHQHead.FS_Description__c ||
                 fcOld.FS_Product_Order_handled_By_txt__c!=fcHQHead.FS_Product_Order_handled_By_txt__c ||
                 fcOld.FS_Flavor_Change_Notes_Comments__c!=fcHQHead.FS_Flavor_Change_Notes_Comments__c ||
                 fcOld.FS_PM__c!=fcHQHead.FS_PM__c ||
                 fcOld.FS_Project_Id__c!=fcHQHead.FS_Project_Id__c ||
                 fcOld.FS_Pay_Type__c!=fcHQHead.FS_Pay_Type__c ||
                 fcOld.FS_AC__c!=fcHQHead.FS_AC__c ||
                 fcOld.FS_Flavor_Change_Notes_Comments__c!=fcHQHead.FS_Flavor_Change_Notes_Comments__c ||
                 fcOld.FS_Project_Name__c!=fcHQHead.FS_Project_Name__c||
                 fcOld.FS_Estimated_FC_Date__c!=fcHQHead.FS_Estimated_FC_Date__c)){
                 	hqIdSet.add(fcHQHead.Id);
            }
            
        }
        if(!hqIdSet.isEmpty()){
            //The loop queries all the outlet level headers under the HQ header and assigns its values to the respective outlet level headers
             for(FS_Flavor_Change_Head__c fcOlHead:[SELECT Id,FS_Approved__c,FS_Parent_Flavor_Change__c,FS_Parent_Flavor_Change__r.FS_Approved__c,
                                                    FS_Parent_Flavor_Change__r.FS_Entering_COM__c,FS_Parent_Flavor_Change__r.FS_Description__c,
                                                    FS_Parent_Flavor_Change__r.FS_Product_Order_handled_By_txt__c,FS_Parent_Flavor_Change__r.FS_Flavor_Change_Notes_Comments__c,
                                                    FS_Parent_Flavor_Change__r.FS_PM__c,
                                                    FS_Parent_Flavor_Change__r.FS_Project_Id__c,FS_Parent_Flavor_Change__r.FS_Pay_Type__c,
                                                    FS_Parent_Flavor_Change__r.FS_AC__c,FS_Parent_Flavor_Change__r.FS_Project_Name__c,
                                                    FS_Parent_Flavor_Change__r.FS_Estimated_FC_Date__c from FS_Flavor_Change_Head__c where 
                                                  	FS_Parent_Flavor_Change__c IN:hqIdSet]){                                                     
                if(hqAndOlMap.get(fcOlHead.FS_Parent_Flavor_Change__c)==NULLOBJ){
                    //fill the outlet level fields with HQ values
                    fcOlHead.FS_Approved__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Approved__c;
                     fcOlHead.FS_Entering_COM__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Entering_COM__c;
                     fcOlHead.FS_Description__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Description__c;
                     fcOlHead.FS_Product_Order_handled_By_txt__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Product_Order_handled_By_txt__c;
                     fcOlHead.FS_Flavor_Change_Notes_Comments__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Flavor_Change_Notes_Comments__c;
                     fcOlHead.FS_PM__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_PM__c;
                     fcOlHead.FS_Project_Id__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Project_Id__c;
                     fcOlHead.FS_Pay_Type__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Pay_Type__c;
                     fcOlHead.FS_AC__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_AC__c;
                     fcOlHead.FS_Project_Name__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Project_Name__c;
                     fcOlHead.FS_Estimated_FC_Date__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Estimated_FC_Date__c;
                    //add each outlet level header to the list to update
                    hqAndOlMap.put(fcOlHead.FS_Parent_Flavor_Change__c,new List<FS_Flavor_Change_Head__c>{fcOlHead});
                    
                }
                else{
                  List<FS_Flavor_Change_Head__c> olList=new List<FS_Flavor_Change_Head__c>();
                  olList=hqAndOlMap.get(fcOlHead.FS_Parent_Flavor_Change__c);
                  //fill the outlet level fields with HQ values
                  fcOlHead.FS_Approved__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Approved__c;
                  fcOlHead.FS_Entering_COM__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Entering_COM__c;
                  fcOlHead.FS_Description__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Description__c;
                  fcOlHead.FS_Product_Order_handled_By_txt__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Product_Order_handled_By_txt__c;
                  fcOlHead.FS_Flavor_Change_Notes_Comments__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Flavor_Change_Notes_Comments__c;
                  fcOlHead.FS_PM__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_PM__c;
                  fcOlHead.FS_Project_Id__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Project_Id__c;
                  fcOlHead.FS_Pay_Type__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Pay_Type__c;
                  fcOlHead.FS_AC__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_AC__c;
                  fcOlHead.FS_Project_Name__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Project_Name__c;
                  fcOlHead.FS_Estimated_FC_Date__c=fcOlHead.FS_Parent_Flavor_Change__r.FS_Estimated_FC_Date__c;
                  //add each outlet level header to the list to update
                  olList.add(fcOlHead);
                  hqAndOlMap.put(fcOlHead.FS_Parent_Flavor_Change__c,olList); 
                }
            }
            if(!hqAndOlMap.values().isEmpty()){
                for(List<FS_Flavor_Change_Head__c> olList:hqAndOlMap.values()){
                	finalUpdateList.addAll(olList);
                    
                }
                try{
                    //Updating the Final List
                    update finalUpdateList;
                    
                }    
                catch(DMLException e){
                    system.debug(e.getMessage());
                    //Apex errror logger code here
                }
            }
            
        }
        
     }
   
    /*
    * @methodName: updateRelatedRecords
    * @parameter : trigger.newList,trigger.newMap,Map<Id, SObject>
    * @return Type: void
    * @description: Method updates related Flavor Change Line, Outlet Dispenser and Association Brandset Records
    */
    public static void updateRelatedRecords(final List<FS_Flavor_Change_Head__c> newList,final Map<Id,FS_Flavor_Change_Head__c> oldMap, final Map<Id, SObject> sObjectsToUpdate) {  
  		                      
      final Map<Id,FS_Outlet_Dispenser__c>  oDMap = new Map<Id,FS_Outlet_Dispenser__c>();
      final List<FS_Flavor_Change_Head__c> flavorChangeHeaderRecordsToProcess =new List<FS_Flavor_Change_Head__c>();
      final Set<Id> flavorChangeHeaderRecordsIdToProcess =new Set<Id>();
       // Integer zero=0;
     
      //Criteria Check Block. Process those records that meet the criteria as per below logic
      for(FS_Flavor_Change_Head__c fcHeader : newList){
         
         final FS_Flavor_Change_Head__c fcHeaderOld = oldMap.get(fcHeader.Id);         
     if(FLAVORCHANGEHEADERRECORDTYPEMAP.get(fcHeader.RecordTypeId)==FLAVORCHANGEOUTLET || FLAVORCHANGEHEADERRECORDTYPEMAP.get(fcHeader.RecordTypeId)==FLAVORCHANGEINSTALL){
            
            //scenario 1: Delivery Method is 'Direct Ship'
            if(fcHeaderOld.FS_Approved__c != fcHeader.FS_Approved__c && fcHeader.FS_Approved__c &&
                (!String.isBlank(fcHeader.FS_Delivery_method__c) && fcHeader.FS_Delivery_method__c.contains(DELIVERYMETHODDIRECTSHIP))){
                system.debug('secn 1');
                flavorChangeHeaderRecordsToProcess.add(fcHeader); 
                flavorChangeHeaderRecordsIdToProcess.add(fcHeader.Id); 
            }
            //scenario 2: Delivery Method is 'Distributor' & 'Bottler'
            if(fcHeader.FS_Approved__c && (fcHeaderOld.FS_NDO_Approval__c!=fcHeader.FS_NDO_Approval__c && fcHeader.FS_NDO_Approval__c==APPROVED)
               && (!String.isBlank(fcHeader.FS_Delivery_method__c) && (fcHeader.FS_Delivery_method__c.contains(DELIVERYMETHODDISTRIBUTOR) 
                                                                       || fcHeader.FS_Delivery_method__c.contains(DELIVERYMETHODBOTTLER)))){
                flavorChangeHeaderRecordsToProcess.add(fcHeader); 
                flavorChangeHeaderRecordsIdToProcess.add(fcHeader.Id);                                                     
            }   
            //scenario 3: Customer Switching back to direct ship
            if(fcHeader.FS_Approved__c && (fcHeaderOld.FS_NDO_Approval__c!=fcHeader.FS_NDO_Approval__c && fcHeader.FS_NDO_Approval__c==CHNGDTODIRECTSHIP)
               && (!String.isBlank(fcHeader.FS_Delivery_method__c) && (fcHeader.FS_Delivery_method__c.contains(DELIVERYMETHODDIRECTSHIP)))){
               
                flavorChangeHeaderRecordsToProcess.add(fcHeader); 
                flavorChangeHeaderRecordsIdToProcess.add(fcHeader.Id);                                                     
            }
          //OCR'17 FR_12 Rahim_Uddin
         //scenario 4:add the headerrecords directly if created by file upload  Or condition For only water/dasani
         if(fcHeader.FS_FC_Type__c.containsIgnoreCase(FILETYPE) ||(fcHeader.FS_Approved__c && fcHeader.isWaterDasani__c>FSConstants.ZERO)){
                
             	flavorChangeHeaderRecordsToProcess.add(fcHeader); 
                flavorChangeHeaderRecordsIdToProcess.add(fcHeader.Id);
             }  
			
			
         }  
      }
      
      //Do Further operation if criteria satisfied
      if(!flavorChangeHeaderRecordsToProcess.isEmpty()){
         
         //Collection to store Flavor Change Header and corresponding Flavor Change Line under it. 
         final Map<Id,List<FS_Flavor_Change_New__c>> flavorChangeHeaderAndLineMap=new Map<Id,List<FS_Flavor_Change_New__c>>();
         final Set<Id> outletDispenserIds=new Set<Id>();
         
         /*********Iteration Starts*********************************************************************************************/
         for(FS_Flavor_Change_New__c flavorChangeLine : [SELECT Id,FS_Outlet_Dispenser__c,FS_Platform__c,FS_FC_Head__c,FS_Current_Brandset__c,
                                                         FS_New_Brandset__c,FS_Hide_Show_Dasani__c,FS_Hide_Show_Water_Button__c,
                                                         FS_BS_Effective_Date__c,FS_DA_Effective_Date__c,FS_WA_Effective_Date__c
                                                         FROM FS_Flavor_Change_New__c WHERE (RecordTypeId=:FCLINEOUTLETRECORDTYPEID OR RecordTypeId=:FCLINEDISPENSERRECORDTYPEID)
                                                         AND FS_FC_Head__c in:flavorChangeHeaderRecordsIdToProcess ]){
             
             //Collect Dispenser Ids
             if(flavorChangeLine.FS_Outlet_Dispenser__c!=NULLOBJ){
                outletDispenserIds.add(flavorChangeLine.FS_Outlet_Dispenser__c);
             }
             
             if(flavorChangeHeaderAndLineMap.containsKey(flavorChangeLine.FS_FC_Head__c)){
                flavorChangeHeaderAndLineMap.get(flavorChangeLine.FS_FC_Head__c).add(flavorChangeLine);
             }
             else{
                flavorChangeHeaderAndLineMap.put(flavorChangeLine.FS_FC_Head__c,new List<FS_Flavor_Change_New__c>{flavorChangeLine});
             }                                            
         } 
        /*********Iteration Ends*********************************************************************************************/   
        
        //Collection to hold Outlet Dispenser and Corressponding Association Brandset
        //Map<Id,FS_Association_Brandset__c> dispenserAndAssociationBrandsetMap=new Map<Id,FS_Association_Brandset__c>();
        Map<id,FS_Association_Brandset__c> abODMap=new Map<id,FS_Association_Brandset__c>();
        Map<id,FS_Association_Brandset__c> updateAB=new Map<id,FS_Association_Brandset__c>();
          for(FS_Association_Brandset__c ab:[select id,name,FS_NonBranded_Water__c,FS_Brandset__c,FS_Outlet_Dispenser__c from  FS_Association_Brandset__c where FS_Outlet_Dispenser__c IN: outletDispenserIds]){
          	    abODMap.put(ab.FS_Outlet_Dispenser__c,ab);
          }
          
          if(!outletDispenserIds.isEmpty() && !flavorChangeHeaderAndLineMap.isEmpty()){
            //dispenserAndAssociationBrandsetMap=FSFlavorChangeHeaderBusinessHelper.fetchAssociationBrandsetForOutletDispensers(outletDispenserIds);
           
            /*********Iteration Starts*********************************************************************************************/
            for(List<FS_Flavor_Change_New__c> flavorChangeLineList  : flavorChangeHeaderAndLineMap.values()){
               
              for(FS_Flavor_Change_New__c  flavorChangeLine:  flavorChangeLineList){
                flavorChangeLine.FS_Final_Approval__c=true;
                
                //add flavor change line to collection for update
                sObjectsToUpdate.put(flavorChangeLine.Id,flavorChangeLine);
                final FS_Outlet_Dispenser__c dispenserObj=new FS_Outlet_Dispenser__c(Id=flavorChangeLine.FS_Outlet_Dispenser__c);
                
                /* Commented out as part of FET 5.1 - FFET-651  
                if(flavorChangeLine.FS_Platform__c.contains(PLATFORM7K)){
                    dispenserObj.FS_7000_Series_Hide_Water_Button_New__c=flavorChangeLine.FS_Hide_Show_Water_Button__c;
                    dispenserObj.FS_7000_Series_Hide_Water_Effective_Date__c=flavorChangeLine.FS_WA_Effective_Date__c; 
                    if(flavorChangeLine.FS_WA_Effective_Date__c!=NULLOBJ && flavorChangeLine.FS_WA_Effective_Date__c<=date.today()){
                        dispenserObj.FS_7000_Series_Hide_Water_Effective_Date__c=date.today();
                    }
                }
                else{
                    dispenserObj.FS_Water_Button_New__c=flavorChangeLine.FS_Hide_Show_Water_Button__c;
                    dispenserObj.FS_Water_Hide_Show_Effective_Date__c=flavorChangeLine.FS_WA_Effective_Date__c;
                    if(flavorChangeLine.FS_WA_Effective_Date__c!=NULLOBJ && flavorChangeLine.FS_WA_Effective_Date__c<=date.today()){
                        dispenserObj.FS_Water_Hide_Show_Effective_Date__c=date.today();
                    }
                }*/
                  
                dispenserObj.FS_Hide_Water_Dispenser_New__c=flavorChangeLine.FS_Hide_Show_Water_Button__c;
                dispenserObj.FS_showHideWater_Effective_date__c=  flavorChangeLine.FS_WA_Effective_Date__c;
                
                if(abODMap.containskey(flavorChangeLine.FS_Outlet_Dispenser__c)){
                  abODMap.get(flavorChangeLine.FS_Outlet_Dispenser__c).FS_NonBranded_Water__c = flavorChangeLine.FS_Hide_Show_Water_Button__c;
               	   	
                }
                  
                updateAB.put(abODMap.get(flavorChangeLine.FS_Outlet_Dispenser__c).id,abODMap.get(flavorChangeLine.FS_Outlet_Dispenser__c));
                if(flavorChangeLine.FS_WA_Effective_Date__c!=NULLOBJ && flavorChangeLine.FS_WA_Effective_Date__c<=date.today()){
                        dispenserObj.FS_showHideWater_Effective_date__c=date.today();
                }
                
                /* Commented out as part of FET5.1- FFET-651 Remove Dasani
                dispenserObj.FS_Dasani_New__c=flavorChangeLine.FS_Hide_Show_Dasani__c;  
                dispenserObj.FS_Dasani_Settings_Effective_Date__c=flavorChangeLine.FS_DA_Effective_Date__c;
                if(flavorChangeLine.FS_DA_Effective_Date__c!=NULLOBJ && flavorChangeLine.FS_DA_Effective_Date__c<=date.today()){
                   dispenserObj.FS_Dasani_Settings_Effective_Date__c=date.today();
                }
                */
                dispenserObj.FS_Brandset_New__c=flavorChangeLine.FS_New_Brandset__c;
                dispenserObj.FS_Brandset_Effective_Date__c=flavorChangeLine.FS_BS_Effective_Date__c;
                if(flavorChangeLine.FS_BS_Effective_Date__c!=NULLOBJ && flavorChangeLine.FS_BS_Effective_Date__c<=date.today()){
                   dispenserObj.FS_Brandset_Effective_Date__c=date.today();
                    
                }                  
                
                //add Outlet Dispensers to collection for update
                //sObjectsToUpdate.put(dispenserObj.Id,dispenserObj);
                  oDMap.put(dispenserObj.Id,dispenserObj);
                  system.debug('OD UPDATE'+ oDMap);
            }  
          }   
            /*********Iteration Ends*********************************************************************************************/   
        
            try{
                system.debug('Before inactivation');
                FSConstants.odtriggercheck=true;
                //Updating the Final List
                update oDMap.values();
				
                //Update AB
                //if(updateAB != null &&!updateAB.isEmpty()){
                    //update updateAB.values();
               // }
                
            }
                catch(DMLException e){
                    system.debug(e.getMessage());
                    //Apex errror logger code here
                }
        }
      }
    }
     //OCR'17 FR_12 Rahim_Uddin
    //Create SO, when SP needs to go out changes to YES.
    public static void createServiceOrder(final Map<ID,FS_Flavor_Change_Head__c> fcHeadOutletMap){
        
        final List<FS_Flavor_Change_Head__c> headListWithSOs = New List<FS_Flavor_Change_Head__c>([Select Id,Name,FS_HQ_Chain__c,FS_SP_go_out__c,(SELECT Id,Name FROM Service_Orders__r) from FS_Flavor_Change_Head__c where ID in :fcHeadOutletMap.keySet()]);
        
        final List<FS_Flavor_Change_New__c> lstOfLines = New List<FS_Flavor_Change_New__c>([SELECT ID,RecordTypeId,FS_FC_Head__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_IsActive__c,FS_Platform__c from FS_Flavor_Change_New__c WHERE  FS_FC_Head__c =: fcHeadOutletMap.keySet()]);
        List<FS_Association_Brandset__c> assocBsetRecs= New List<FS_Association_Brandset__c>();
        outletZIPs=new list<String>();
        List<FS_Service_Order__c> lstSOs=new List<FS_Service_Order__c>();
      	final Map<Id,List<FS_Service_Order__c>> mapHeadWithSOs = New  Map<Id,List<FS_Service_Order__c>>();
        
        odList=new list<FS_Outlet_Dispenser__c> ();
        //Creation of service orders based on spAlignedZip codes
        final Map<String,FS_SP_Aligned_Zip__c> spAlignedZip7000SeriesBasesdOnZip=new Map<String,FS_SP_Aligned_Zip__c>();
        final Map<String,FS_SP_Aligned_Zip__c> spAlignedZip8K9KSeriesBasesdOnZip=new Map<String,FS_SP_Aligned_Zip__c>();
        final Map<String,FS_SP_Aligned_Zip__c> spAlignedZip6K65KSeriesBasesdOnZip=new Map<String,FS_SP_Aligned_Zip__c>();
    	
        
        //Create Map to count no of SOs under Head
        For(FS_Flavor_Change_Head__c fHead : headListWithSOs){
            lstSOs=fHead.Service_Orders__r;
            mapHeadWithSOs.put(fHead.Id,lstSOs);
        } 
        
       //Odlist to fetch Association brandset
        for(FS_Flavor_Change_New__c lineList:lstOfLines){
            if(lineList.FS_Outlet_Dispenser__r.FS_IsActive__c){
                odList.add(lineList.FS_Outlet_Dispenser__r);
            }
            
        }
        
        assocBsetRecs = [SELECT Id,FS_Platform__c,name,FS_Brandset__c,FS_Outlet_Dispenser__c,
                                      FS_Brandset__r.FS_Brandset_Number__c,FS_Outlet_Dispenser__r.FS_outlet__c,
                                      FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode 
                                      FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c in : odList 
                                      ORDER BY FS_Platform__c];
        
        for(FS_Association_Brandset__c assosiatedBrandset : assocBsetRecs){
            
            if(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode!= FSConstants.NULLVALUE){
                outletZIPs.add(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode);
            }  
            
        }
        //Form Collection based on ZipCode:
        for(FS_SP_Aligned_Zip__c sp7000 : FSServiceProviderHelper.get7000SPAlignedZip(outletZIPs)){
            spAlignedZip7000SeriesBasesdOnZip.put(sp7000.FS_Zip_Code__c,sp7000);
        }           
        for(FS_SP_Aligned_Zip__c sp8K9K : FSServiceProviderHelper.get80009000SPAlignedZip(outletZIPs)){
            spAlignedZip8K9KSeriesBasesdOnZip.put(sp8K9K.FS_Zip_Code__c,sp8K9K);
        }
        for(FS_SP_Aligned_Zip__c sp6K65K : FSServiceProviderHelper.get60006050SPAlignedZip(outletZIPs)){
            spAlignedZip6K65KSeriesBasesdOnZip.put(sp6K65K.FS_Zip_Code__c,sp6K65K);
        }
        
        final List<FS_Service_Order__c> serviceOrderList=new List<FS_Service_Order__c>();
        for(FS_Flavor_Change_Head__c FCOutletheader:[SELECT Id,FS_Outlet_Postal_ZIP__c,FS_SP_go_out__c,isWaterDasani__c from FS_Flavor_Change_Head__c WHERE  Id=:fcHeadOutletMap.values()]){
            if(FCOutletheader.FS_SP_go_out__c==SPYESSTRING && mapHeadWithSOs.get(FCOutletheader.Id).size()==FSConstants.ZERO){
                FS_Service_Order__c serviceOrder=new FS_Service_Order__c();
                serviceOrder.FS_Flavor_Change_Header__c=FCOutletheader.id;
                if(FCOutletheader.FS_Outlet_Postal_ZIP__c!=FSConstants.NULLVALUE){
                    String zipCode=FCOutletheader.FS_Outlet_Postal_ZIP__c;
                    if(zipcode.length() > FIVE) {
                        zipCode = zipcode.substring(0,5);
                    }else{
                        zipCode = zipcode;
                    }
                    
                    if(spAlignedZip7000SeriesBasesdOnZip.containsKey(zipCode) && spAlignedZip7000SeriesBasesdOnZip.get(zipCode)!=null){
                        FS_SP_Aligned_Zip__c  spObj=spAlignedZip7000SeriesBasesdOnZip.get(zipCode);
                        serviceOrder.FS_Service_Provider__c=spObj.FS_Service_Provider__c;                    
                        serviceOrder.FS_Market_Activation_Date__c=spObj.FS_Selling_Market_Activation_Date__c;
                        serviceOrder.FS_Market__c=spObj.FS_Selling_Activity_Market__r.Name;
                        serviceOrder.FS_SP_Code__c=spObj.FS_SP_Code__c;
                    }
                    if(spAlignedZip8K9KSeriesBasesdOnZip.containsKey(zipCode) && spAlignedZip8K9KSeriesBasesdOnZip.get(zipCode)!=null){
                        FS_SP_Aligned_Zip__c  spObj=spAlignedZip8K9KSeriesBasesdOnZip.get(zipCode);
                        serviceOrder.FS_Other_Service_Provider__c=spObj.FS_Service_Provider__c;            
                        serviceOrder.FS_Other_Market_Activation_Date__c=spObj.FS_Selling_Market_Activation_Date__c;
                        serviceOrder.FS_Other_Market__c=spObj.FS_Selling_Activity_Market__r.Name;
                        serviceOrder.FS_Other_SP_Code__c=spObj.FS_SP_Code__c;
                    } 
                    if(spAlignedZip6K65KSeriesBasesdOnZip.containsKey(zipCode) && spAlignedZip6K65KSeriesBasesdOnZip.get(zipCode)!=null){
                        FS_SP_Aligned_Zip__c  spObj=spAlignedZip6K65KSeriesBasesdOnZip.get(zipCode);
                        serviceOrder.FS_New_Service_Provider__c=spObj.FS_Service_Provider__c;            
                        serviceOrder.FS_New_Market_Activation_Date__c=spObj.FS_Selling_Market_Activation_Date__c;
                        serviceOrder.FS_New_Market__c=spObj.FS_Selling_Activity_Market__r.Name;
                        serviceOrder.FS_New_SP_Code__c=spObj.FS_SP_Code__c;
                    }
                }  
                serviceOrderList.add(serviceOrder);
            }
        }
        try{
            Database.insert(serviceOrderList,false);
        }
        catch(DMLException dmlExp){
            ApexErrorLogger.addApexErrorLog('FET','FSFlavorChangeHeaderBusinessProcess','createServiceOrder','FS_Service_Order__c','HIGH',dmlExp,dmlExp.getMessage());
        }
    } 
     public static void createTaskAlertsForSSUser(final List<FS_Flavor_Change_Head__c> newList,final Map<Id,FS_Flavor_Change_Head__c> newMap,
                                                  final Map<Id,FS_Flavor_Change_Head__c> oldMap){
       final List<Task> createTaskAlerts=new List<Task>();
     
      
       //Criteria check : If POM Action is complete
        //OCR'17 FR_12 Rahim_Uddin // Add fcHeader.isWaterDasani__c==ZERO,
       for(FS_Flavor_Change_Head__c fcHeader: newList){
           
              if(string.isNotBlank(fcHeader.FS_Delivery_method__c) && string.isNotBlank(fcHeader.FS_Order_method__c)&&
                 (fcHeader.FS_Delivery_method__c.contains(DELIVERYMETHODDIRECTSHIP) || (fcHeader.FS_Delivery_method__c.contains(DELIVERYMETHODDISTRIBUTOR) && !fcHeader.FS_Order_method__c.contains(DELIVERYMETHODBOTTLER) && !fcHeader.FS_Order_method__c.contains(DELIVERYMETHODDISTRIBUTOR)))
                 && fcHeader.FS_POM_Action_Complete__c!=oldMap.get(fcHeader.Id).FS_POM_Action_Complete__c 
                 && fcHeader.FS_POM_Action_Complete__c
                 && !fcHeader.FS_FC_Type__c.containsIgnoreCase(FILETYPE) 
                && fcHeader.isWaterDasani__c==FSConstants.ZERO){
                 
                 createTaskAlerts.add(new Task(WhatId=fcHeader.Id,
                                                OwnerId=fcHeader.FS_AC__c,
                                                Subject='FC SCHDLD date needed - '+fcHeader.FS_Flavor_Change_Status__c,
                                                Status=STATUS,
                                                Priority=PRIORITY,
                                                FS_Action__c=ACTION,
                                                ActivityDate=Date.today().addDays(15)));
              }
       } 
       //Criteria check : If NDO Rejects/Approves the order method 
       //for Distributor or Bottler
       //OCR'17 FR_12 Rahim_Uddin :fcHeader.isWaterDasani__c==FSConstants.ZERO
       //To stop alerts for only water/dasani
       for(FS_Flavor_Change_Head__c fcHeader: newList){
         
          if(string.isNotBlank(fcHeader.FS_Delivery_method__c) &&
             fcHeader.FS_Delivery_method__c.contains(DELIVERYMETHODDISTRIBUTOR)
             && fcHeader.FS_NDO_Approval__c!=oldMap.get(fcHeader.Id).FS_NDO_Approval__c
             && !fcHeader.FS_FC_Type__c.containsIgnoreCase(FILETYPE) && fcHeader.isWaterDasani__c==FSConstants.ZERO){
                 if(fcHeader.FS_NDO_Approval__c.contains('Rejected')){
                     createTaskAlerts.add(new Task(WhatId=fcHeader.Id,
                                            OwnerId=fcHeader.FS_AC__c,
                                            Subject='FC Rejected - '+fcHeader.FS_Flavor_Change_Status__c,
                                            Status=STATUS,
                                            Priority=PRIORITY,
                                            FS_Action__c=ACTION,
                                            ActivityDate=Date.today().addDays(15)));
                 }
                 if(fcHeader.FS_NDO_Approval__c.contains('Approved') &&
                    fcHeader.FS_Order_method__c.contains(DELIVERYMETHODDISTRIBUTOR)){
                     createTaskAlerts.add(new Task(WhatId=fcHeader.Id,
                                            OwnerId=fcHeader.FS_AC__c,
                                            Subject='FC SCHDLD date needed - '+fcHeader.FS_Flavor_Change_Status__c,
                                            Status=STATUS,
                                            Priority=PRIORITY,
                                            FS_Action__c=ACTION,
                                            ActivityDate=Date.today().addDays(15)));
                 }
          }
          //OCR'17 FR_12 Rahim_Uddin// Add fcHeader.isWaterDasani__c==ZERO,
           if(string.isNotBlank(fcHeader.FS_Delivery_method__c) &&
             fcHeader.FS_Delivery_method__c.contains(DELIVERYMETHODBOTTLER) &&
             fcHeader.FS_Order_method__c.contains(DELIVERYMETHODBOTTLER)
             && fcHeader.FS_NDO_Approval__c!=oldMap.get(fcHeader.Id).FS_NDO_Approval__c 
             && !fcHeader.FS_FC_Type__c.containsIgnoreCase(FILETYPE) && fcHeader.isWaterDasani__c==FSConstants.ZERO){
             	 
                 if(fcHeader.FS_NDO_Approval__c.contains('Rejected')){
                     createTaskAlerts.add(new Task(WhatId=fcHeader.Id,
                                            OwnerId=fcHeader.FS_AC__c,
                                            Subject='FC Rejected - '+fcHeader.FS_Flavor_Change_Status__c,
                                            Status=STATUS,
                                            Priority=PRIORITY,
                                            FS_Action__c=ACTION,
                                            ActivityDate=Date.today().addDays(15)));
                 }
                 if(fcHeader.FS_NDO_Approval__c.contains('Approved')){
                     createTaskAlerts.add(new Task(WhatId=fcHeader.Id,
                                                OwnerId=fcHeader.FS_AC__c,
                                                Subject='FC SCHDLD date needed - '+fcHeader.FS_Flavor_Change_Status__c,
                                                Status=STATUS,
                                                Priority=PRIORITY,
                                                FS_Action__c=ACTION,
                                                ActivityDate=Date.today().addDays(15)));
                 }
             
          }
       }
       
     if(!createTaskAlerts.isEmpty()){
           final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c='FET',Class_Name__c='FSFlavorChangeHeaderBusinessProcess',
                                                           Method_Name__c='createTaskAlertsForSSUser',Object_Name__c='Task',
                                                           Error_Severity__c='High');
          FSUtil.dmlProcessorInsert(createTaskAlerts,true,apexError);
       }                                     
     }
    //Method to create alerts on scheduled date and 
    //4 days prior to scheduled date based on time based workflow and same day wf
    public static void alert4DaysBeforeSchedule(final List<FS_Flavor_Change_Head__c> newList,final Map<Id,FS_Flavor_Change_Head__c> newMap,
                                                  final Map<Id,FS_Flavor_Change_Head__c> oldMap){
      
       final List<Task> createTaskAlerts=new List<Task>();
    	List<FS_Flavor_Change_New__c> lstWALines = New List<FS_Flavor_Change_New__c>();
	   final Map<Id,List<FS_Flavor_Change_New__c>> mapHeadWithList = New  Map<Id,List<FS_Flavor_Change_New__c>>();
	   final List<FS_Flavor_Change_Head__c> headWithList = New List<FS_Flavor_Change_Head__c>([SELECT Id,Name,FS_Flavor_Change_Status__c,FS_AC__c,FS_SS_Alert_Status__c,FS_SS_Readiness_Alert__c,(SELECT Id,FS_Only_Water_Dasani__c  FROM Flavor_Changes_New__r WHERE FS_Only_Water_Dasani__c=False) FROM FS_Flavor_Change_Head__c WHERE Id =:newList]);
	 
	   For(FS_Flavor_Change_Head__c fHead : headWithList){
	   lstWALines=fHead.Flavor_Changes_New__r;
	   mapHeadWithList.put(fHead.Id,lstWALines);
	   } 
       //Criteria check : If SSAlert Check is checked by the time based trigger
       //OCR'17 FR_12 Rahim_Uddin mapHeadWithList.get(fcHeader.Id).size()!=ZERO
       for(FS_Flavor_Change_Head__c fcHeader: newList){
           
          if(fcHeader.FS_SS_Readiness_Alert__c && mapHeadWithList.get(fcHeader.Id).size()!=FSConstants.ZERO){ 
             createTaskAlerts.add(new Task(WhatId=fcHeader.Id,
                                            OwnerId=fcHeader.FS_AC__c,
                                            Subject='FC Readiness needed - '+fcHeader.FS_Flavor_Change_Status__c,
                                            Status=STATUS,
                                            Priority=PRIORITY,
                                            FS_Action__c=ACTION,
                                            ActivityDate=Date.today().addDays(15)));
             
            fcHeader.FS_SS_Readiness_Alert__c=false;
          }
           //Create task on the scheduled date
          if(fcHeader.FS_SS_Alert_Status__c){ 
             createTaskAlerts.add(new Task(WhatId=fcHeader.Id,
                                            OwnerId=fcHeader.FS_AC__c,
                                            Subject='FC Closeout needed - '+fcHeader.FS_Flavor_Change_Status__c,
                                            Status=STATUS,
                                            Priority=PRIORITY,
                                            FS_Action__c=ACTION,
                                            ActivityDate=Date.today().addDays(15)));
             
              fcHeader.FS_SS_Alert_Status__c=false;
          }   

       }    
       //Create tasks 4 days prior to the scheduled date via time based workflow
     if(!createTaskAlerts.isEmpty()){
           final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c='FET',Class_Name__c='FSFlavorChangeHeaderBusinessProcess',
                                                           Method_Name__c='alert4DaysBeforeSchedule',Object_Name__c='Task',
                                                           Error_Severity__c='High');
          FSUtil.dmlProcessorInsert(createTaskAlerts,true,apexError);
       }
     }
}