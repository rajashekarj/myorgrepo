/***************************************************************************
 Name         : FSFlavorChangeHeaderQueueClass
 Created By   : Infosys Limited
 Description  : FSFlavorChangeHeaderQueueClass updates fields asynchronosly. This class mehtods are called from FSmassupdateflavorchanagebatchhelper
 Created Date : 23-JAN-2017
**********************************  ******************************************/
public without sharing class FSFlavorChangeHeaderQueueClass implements Queueable{
    public Set<Id> recordids;
    public List<FS_Flavor_Change_Head__c> flavorRecords;
    public static final String DISTRIBUTOR='distributor';
    public static final String BOTTLER='bottler';
      /*****************************************************************
      Method: FSFlavorChangeHeaderQueueClass
      Description: Constructor
      *******************************************************************/
    public FSFlavorChangeHeaderQueueClass(Set<Id> recordIds) {
        this.recordIds = recordIds;
        this.flavorRecords=[SELECT Id,FS_Order_method__c,FS_Delivery_method__c,FS_CDM_setup_complete__c,FS_NDO_Approval__c,
                            FS_POM_Action_Complete__c,FS_Approved__c,FS_isBatch__c,isWaterDasani__c
                            from FS_Flavor_Change_Head__c where Id IN :recordIds];
    }
      /*****************************************************************
      Method: execute
      Description: Execute method of the queue class
      *******************************************************************/
    public void execute(QueueableContext context) {
        final List<FS_Flavor_Change_Head__c> fcHeadList=new List<FS_Flavor_Change_Head__c>(); 
        String orderMethod='';
        String deliveryMethod='';
        //provide the approvals as per the flow description.
        //For file upload, making NDO Approval to "Approved"
        //For only water/dasani, escaping the below NDO approval update.
        for(FS_Flavor_Change_Head__c fcHeadId : flavorRecords){            
            FS_Flavor_Change_Head__c fcHead=new FS_Flavor_Change_Head__c();
            fcHead=fcHeadId;
            orderMethod=fcHead.FS_Order_method__c;
            deliveryMethod=fcHead.FS_Delivery_method__c;
            if(string.isNotBlank(deliveryMethod) && string.isNotBlank(orderMethod)  && fcHeadId.isWaterDasani__c==FSConstants.ZERO){
                if(deliveryMethod.containsIgnoreCase('direct') ){
                    fcHead.FS_CDM_setup_complete__c=true;
                    fcHead.FS_POM_Action_Complete__c=true;
            	}
                if((deliveryMethod.containsIgnoreCase(DISTRIBUTOR) && orderMethod.containsIgnoreCase(DISTRIBUTOR)) 
                   ||(deliveryMethod.containsIgnoreCase(BOTTLER) && orderMethod.containsIgnoreCase(BOTTLER))){
                        fcHead.FS_NDO_Approval__c='Approved';
                }
                if(deliveryMethod.containsIgnoreCase(DISTRIBUTOR) && !orderMethod.containsIgnoreCase(DISTRIBUTOR) ){
                    fcHead.FS_POM_Action_Complete__c=true;
                    fcHead.FS_NDO_Approval__c='Approved';
                    fcHead.FS_CDM_setup_complete__c=true;
                }
            }
            else if(fcHeadId.isWaterDasani__c==FSConstants.ZERO){
                fcHead.FS_POM_Action_Complete__c=true;
                fcHead.FS_NDO_Approval__c='Approved';
                fcHead.FS_CDM_setup_complete__c=true;
            }
           
            fcHead.FS_Approved__c=true;
            fcHead.FS_isBatch__c=true;
            fcHeadList.add(fcHead);
            
    	}
    	final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSFlavorChangeHeaderQueueClass',
                                                           Method_Name__c='execute',Object_Name__c='FS_Flavor_Change_Head__c',
                                                           Error_Severity__c=FSConstants.MediumPriority);
    	FSUtil.dmlProcessorUpdate(fcHeadList,true,apexError);
    }
}