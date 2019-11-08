public with sharing class FSEquipmentPlacementQuestionsCTRL {


 public List<integer> sequenceList{get;set;}
 
 public FS_Execution_Plan__c fsExecObj{get;set;}
 public Map<integer,FS_Equipment_Placement_Questionnaire__c>  fsEquipmentMap{get;set;}
 public List<FS_Equipment_Placement_Questionnaire__c> epqList{get;set;}  
 Public Boolean displayOutputfield{get;set;}
 Public Boolean displayinputfield{get;set;}
 Public Boolean displayErrorMessage{get;set;} 
 public Boolean displayEditButton{get;set;}
 public string errorMessage{get;set;}
 public Boolean isSetAllNotApplicable{get;set;}
 public String displaysaveCloseExep{set;get;}
 public boolean displaySaveandClose{set;get;}
 public boolean displaySave{set;get;}
 String query='';
 public FSEquipmentPlacementQuestionsCTRL(ApexPages.StandardController controller) {
                 displayOutputfield=true;
                 displaysaveCloseExep='No';  
                 Schema.DescribeSObjectResult dsr = FS_Execution_Plan__c.sObjectType.getDescribe();
                 displayEditButton=dsr.isUpdateable();
                 displayinputfield=false;
                 displayErrorMessage=false;
                 displaySaveandClose=false;
                 displaySave=false;   
                 isSetAllNotApplicable = false;
                fsExecObj = new FS_Execution_Plan__c();
                query = 'Select id,';
        fsEquipmentMap = new Map<integer,FS_Equipment_Placement_Questionnaire__c>();
        epqList = new List<FS_Equipment_Placement_Questionnaire__c>();
        sequenceList = new List<integer>();
                
                epqList= FS_Equipment_Placement_Questionnaire__c.getall().values();
                
                if(epqList!=null && epqList.size()>0){
                                for(FS_Equipment_Placement_Questionnaire__c epqObj:epqList){
                                         if(epqObj.Name!=null && epqObj.Name.isNumeric()){
                                                sequenceList.add(integer.valueOf(epqObj.Name));
                                                fsEquipmentMap.put(integer.valueOf(epqObj.Name),epqObj);
                                                
                                                query+= epqObj.Field_API_Mapping__c+',';
                                         }
                                         
                                }
                                sequenceList.sort();
                }       
                if(query!=''){
                        query = query.substring(0,query.length()-1);
                }
                if(controller.getId()!=null){
                        query+=' from FS_Execution_Plan__c where id=\''+controller.getId()+'\'';
                } 
                System.debug('Query::'+query);
                fsExecObj = database.query(query);
 }
    
    public pageReference setAllNotApplicable(){
        try {
            if(fsExecObj != null && epqList!=null && epqList.size()>0) {
                if(!isSetAllNotApplicable) {
                    fsExecObj = database.query(query);
                } else {
                    fsExecObj.FS_What_type_of_install_is_this__c = 'Not Applicable' ;
                    fsExecObj.FS_What_type_of_beverage_station_is_this__c = 'Not Applicable' ;
                    fsExecObj.FS_Is_ths_Sngle_or_Multiple_dispsr_Instl__c  = 'Not Applicable';
                    fsExecObj.FS_Freestyle_dispenser_will_go_where__c  = 'Not Applicable';
                    fsExecObj.FS_Is_a_top_mount_ice_maker_planned_Loc__c  = 'Not Applicable';
                    fsExecObj.FS_Freestyle_7K_Only_Wht_is_dispsr_Confi__c  = 'Not Applicable';
                    fsExecObj.FS_Frestyle_7k_only_NNS_sweetnr_wil_go_w__c  = 'Not Applicable';
                    fsExecObj.FS_HFCS_sweetener_will_go_where__c  = 'Not Applicable';
                    fsExecObj.FS_Water_Booster_will_go_where__c  = 'Not Applicable';
                    fsExecObj.FS_Water_Filter_will_go_where__c  = 'Not Applicable';
                    fsExecObj.FS_Is_ancillary_equipment_such_Tea_Coffe__c  = 'Not Applicable';
                    fsExecObj.FS_base_cabinet_or_replacement_counter__c  = 'Not Applicable';
                    fsExecObj.Is_a_legacy_bar_gun_being_removed_or_ins__c  = 'Not Applicable';
                }
            }
        } catch(Exception exp) {
            System.debug('setAllNotApplicable#Exception- '+exp);
        }
        
        
        return null;
    }
    
    Public pageReference Save(){
        try{
            update fsExecObj;
             displayErrorMessage=false;
            displayOutputfield=true;
            displayinputfield=false;
            displaysaveCloseExep='No';
            displayEditButton=true;
            displaySaveandClose=false;
            displaySave=false;
              
            //fsExecObj = database.query(query);
            return null;
        }
        catch(DMLException ex){
        displayErrorMessage=true; 
        displaysaveCloseExep='Yes';   
        System.debug('DML Exception:'+displaysaveCloseExep+'##:'+ex.getDmlMessage(0));
       
        errorMessage=ex.getDmlMessage(0);  
        return null;
        }
        catch(Exception ex){
        displayErrorMessage=true;
        displaysaveCloseExep='Yes';   
         System.debug('DML Exception12:'+displaysaveCloseExep+'##:'+ex.getDmlMessage(0));
        
        errorMessage='Exception:Update failed ';  
        return null;
        }
       
    }
 
    public pageReference Edit(){
      
        displayErrorMessage=false;
        displayOutputfield=false;
        displayinputfield=true; 
        displayEditButton=false;
          String displysaveClose=ApexPages.currentPage().getParameters().get('displaySaveandClose');       
                  if(displysaveClose=='true'){
                      displaySaveandClose=!displayOutputfield && true;
                      displaySave=!displaySaveandClose;
                     
                  }
                  else{ 
                      displaySaveandClose=false;
                      displaySave=true;
                  } 
        
        return null;
    }
    
    Public pageReference Cancel(){
        displayErrorMessage=false;   
        displayOutputfield=true;
        displayEditButton=true;   
        displayinputfield=false;   
        displaySaveandClose=false;
        displaySave=false;
        fsExecObj = database.query(query);
        
        return null;
    }
  
}