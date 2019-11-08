/******************
Name         : FSEnterEditViewCokeSmartInfoController
Created By   : Pallavi Sharma (Appiro)
Created Date : 17 - Sep - 2013
Usage        : Controller for Enter/Edit/View CokeSmart Info Page, which is used to edit information about
Outlet Info related to Execution Plan
9th Jan,2019 Modified by: Sai Krishna. Added a new Cancel method for redirection to prev Execution plan record page. Reg: FET 6 Ref:(Jira FNF-115)
*********************/
public with sharing class FSEnterEditViewCokeSmartInfoController {
    public set<Id> setOutletIds;
    
    public static final string CREDITCARD= 'Credit Card';  
    public static final string BANKDRAFT= 'Bank Draft';  
    public static final string PAYMENTTERM= 'Invoice (Payment Terms)';  
    public static final string DISTRIBUTORBILL='Distributor billing';
    public static final string VMS= 'VMS'; 
    public integer valZero = 0;
    public static final string DELIVERY= 'Delivery';  
    public static final string CHANNEL= 'Channel';   
    public static final string PROGRAMPAYMENT= 'ProgramPaymentMethod'; 
    public static final string PROGRAMPAYMNT= 'PaymentMethod'; 
    public static final string CHANNELNAME= 'ChannelName';    
    public static final string BILLTOADDRESS= 'BillToAddress';
    public static final string BILLTOCOUNTRY= 'BillToCountry';
    public static final string BILLTOCITY= 'BillToCity';    
    public static final string BILLTOSTATE= 'BillToState';   
    public static final string BILLTOZIP= 'BillToZip';   
    public static final string REMOVINGALL= 'RemovingAll';  
    public static final string ALL= 'All';
    public static final string NONE='--None--';
    public static final string YESVALUE='Yes';
    public Map<Id,Account> accountMap;
    public Boolean displayPopup{get;set;}
    public List<Account> lstOutlet{get;set;}
    public Id executionPlan{get;set;}
    public string selectedFillDown{get;set;}
    public List<OutletDetails> listOutletDetails {get;set;}    
    
    public static  object valnull() { return null; }    
    
    public class OutletDetails {
        public Account outlet {get;set;}
        public List<SelectOption> cokesmartPaymentMethodValues{get;set;} 
        public List<SelectOption> programPaymentMethodValues{get;set;}         
        
        public OutletDetails(final Account inputOutlet) {
            this.outlet = inputOutlet;
            cokesmartPaymentMethodValues = new List<SelectOption>();
            if(outlet.Invoice_Customer__c != valnull()) {
                cokesmartPaymentMethodValues.add(new SelectOption(NONE,NONE));
                if(outlet.Invoice_Customer__c.equalsIgnoreCase(YESVALUE)) {
                    cokesmartPaymentMethodValues.add(new SelectOption(CREDITCARD,CREDITCARD));                    
                    cokesmartPaymentMethodValues.add(new SelectOption(BANKDRAFT,BANKDRAFT));
                    cokesmartPaymentMethodValues.add(new SelectOption(PAYMENTTERM,PAYMENTTERM));
                    cokesmartPaymentMethodValues.add(new SelectOption(DISTRIBUTORBILL,DISTRIBUTORBILL));                    
                } 
                else if(outlet.Invoice_Customer__c.equalsIgnoreCase('No')) {                   
                    cokesmartPaymentMethodValues.add(new SelectOption(CREDITCARD,CREDITCARD));
                    cokesmartPaymentMethodValues.add(new SelectOption(BANKDRAFT,BANKDRAFT));
                    cokesmartPaymentMethodValues.add(new SelectOption(DISTRIBUTORBILL,DISTRIBUTORBILL));                    
                }
            }
            programPaymentMethodValues = new List<SelectOption>();
            if(outlet.FS_Payment_Type__c != valnull()) {
                programPaymentMethodValues.add(new SelectOption(NONE,NONE));
                if(outlet.FS_Payment_Type__c.equalsIgnoreCase(YESVALUE)) {
                    programPaymentMethodValues.add(new SelectOption(CREDITCARD,CREDITCARD));
                    programPaymentMethodValues.add(new SelectOption(BANKDRAFT,BANKDRAFT));
                    programPaymentMethodValues.add(new SelectOption(PAYMENTTERM,PAYMENTTERM));                   
                } else if(outlet.FS_Payment_Type__c.equalsIgnoreCase('No')) {                   
                    programPaymentMethodValues.add(new SelectOption(CREDITCARD,CREDITCARD));
                    programPaymentMethodValues.add(new SelectOption(BANKDRAFT,BANKDRAFT));                    
                }
            }
        }            
    }    
   
     /*****************************************************************
  	Method: closePopup
  	Description: closePopup method is close the popup displayed to the user
				added as part of FET 4.0
	*******************************************************************/
    public void closePopup() {displayPopup = false;} 
    /*****************************************************************
  	Method: showPopup
  	Description: showPopup method is show the popup for the user with 
				related message 
				added as part of FET 4.0
	*******************************************************************/
    public void showPopup() {displayPopup = true;}  
    
    //Constructor
    public FSEnterEditViewCokeSmartInfoController (){
        executionPlan = Apexpages.currentPage().getParameters().get('executionplanid');
        accountMap=new Map<Id,Account>();
        if(executionPlan != valnull()){
            setOutletIds = new set<Id>();
            lstOutlet = new List<Account>();
            listOutletDetails = new List<OutletDetails>();
            //Get all outlets Id from installation which is related to Execution Plan
            for(FS_Installation__c installation : [Select FS_Outlet__c,FS_Execution_Plan__c From FS_Installation__c  Where FS_Execution_Plan__c =: executionPlan]){
                setOutletIds.add(installation.FS_Outlet__c);                                   
            }
            
            //Get outlets
            if(!setOutletIds.isEmpty()){
                lstOutlet = [Select FS_VMS_Customer__c,FS_Requested_Order_Method__c,Invoice_Customer__c, FS_CS_Payment_Method__c, 
                             Cokesmart_Payment_Method__c, FS_Outlet_Information__c, FS_CS_Sub_Trade_Channel__c,
                             FS_Payment_Type__c,FS_Requested_Delivery_Method__c,FS_Payment_Method__c,FS_CS_Status__c, 
                             FS_CS_State__c, FS_CS_Bill_To_Zip__c, FS_CS_Bill_To_City__c, FS_CS_Sub_Trade_Channel_Name__c, 
                             FS_CS_Bill_To_Address__c,FS_CS_Bill_To_Country__c, FS_CS_All_Ftn_Removed__c, FS_Headquarters__r.Cokesmart_Payment_Method__c,
                             FS_Headquarters__r.Invoice_Customer__c From Account Where Id IN : setOutletIds];
                
                for(Account outlet: lstOutlet) {
                    listOutletDetails.add(new OutletDetails(outlet));
                    accountMap.put(outlet.Id, outlet);
                }               
            }
        }
    }
    
    //Save Outlets Information
    public PageReference saveOutletInfo(){
        PageReference pageRef;   
        try{         
            //upserting the Outlets
            if(!lstOutlet.isEmpty()){ 
                for(Account acc:lstOutlet){
                    if(acc.Cokesmart_Payment_Method__c==NONE){ acc.Cokesmart_Payment_Method__c=FSConstants.STRING_NULL; }
                    if(acc.FS_Payment_Method__c==NONE){ acc.FS_Payment_Method__c=FSConstants.STRING_NULL; }
                }
                upsert lstOutlet;
            }           
            pageRef= new PageReference('/'+executionPlan);
        }
        //catching DML Exception
        catch(DMLException ex){
			apexpages.addMessages(ex);			          
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSEnterEditViewCokeSmartInfoController','saveOutletInfo','Account',FSConstants.MediumPriority,ex,ex.getMessage());            
        }        
        return pageRef;
    }
    //Fill Down Functionality conditions
    public void fillDown(){ 
        Boolean popupCheck=false;       
        FSConstants.BypassOrderDelivery =true;
        if (selectedFillDown == VMS){
            for (Account acc :lstOutlet){
                acc.FS_Requested_Order_Method__c= lstOutlet[0].FS_Requested_Order_Method__c ;
            }
        }
        else if (selectedFillDown == DELIVERY){
            for (Account acc :lstOutlet){
                acc.FS_Requested_Delivery_Method__c= lstOutlet[0].FS_Requested_Delivery_Method__c ;
            }
        }
        else if(selectedFillDown == CHANNEL){
            for (Account acc :lstOutlet){ 
                acc.FS_CS_Sub_Trade_Channel__c= lstOutlet[0].FS_CS_Sub_Trade_Channel__c ;
            }
        }        
        else if(selectedFillDown == PROGRAMPAYMNT){            
            //  //Prod-Fix Change in Fill Down
            for (Account acc :lstOutlet){
                if(lstOutlet[0].Cokesmart_Payment_Method__c!=PAYMENTTERM || acc.Cokesmart_Payment_Method__c==PAYMENTTERM){
					acc.Cokesmart_Payment_Method__c=lstOutlet[0].Cokesmart_Payment_Method__c;
				}               
				else if(accountMap.containsKey(acc.Id) && acc.Invoice_Customer__c.equalsIgnoreCase(YESVALUE)){
					acc.Cokesmart_Payment_Method__c=lstOutlet[0].Cokesmart_Payment_Method__c;					
				}
                
				else{ popupCheck=true;	}
                
                if(popupCheck){ showPopup(); }
            }
        }
        
        else if(selectedFillDown == PROGRAMPAYMENT){
            for (Account acc :lstOutlet){
                if(lstOutlet[0].FS_Payment_Method__c!=PAYMENTTERM || acc.FS_Payment_Method__c==PAYMENTTERM){
					acc.FS_Payment_Method__c=lstOutlet[0].FS_Payment_Method__c;
				}
                
				else if(accountMap.containsKey(acc.Id) && acc.FS_Payment_Type__c.equalsIgnoreCase(YESVALUE)){
					acc.FS_Payment_Method__c=lstOutlet[0].FS_Payment_Method__c;					
				}
                
				else{ popupCheck=true;	}
                
				if(popupCheck){ showPopup(); }
            }
        }
        else if(selectedFillDown ==BILLTOADDRESS){
            for (Account acc :lstOutlet){
                acc.FS_CS_Bill_To_Address__c= lstOutlet[0].FS_CS_Bill_To_Address__c ;
            }
        }
        else if(selectedFillDown == BILLTOCITY){
            for (Account acc :lstOutlet){
                acc.FS_CS_Bill_To_City__c= lstOutlet[0].FS_CS_Bill_To_City__c ;
            }
        }
        else if(selectedFillDown ==BILLTOSTATE){
            for (Account acc :lstOutlet){
                acc.FS_CS_State__c= lstOutlet[0].FS_CS_State__c ;
            }
        }
        else if(selectedFillDown == BILLTOZIP){
            for (Account acc :lstOutlet){
                acc.FS_CS_Bill_To_Zip__c= lstOutlet[0].FS_CS_Bill_To_Zip__c ;
            }
        }
        //OCR 4393
        else if(selectedFillDown ==BILLTOCOUNTRY){
            for (Account acc :lstOutlet){
                acc.FS_CS_Bill_To_Country__c= lstOutlet[0].FS_CS_Bill_To_Country__c ;
            }
        }
        else if(selectedFillDown == REMOVINGALL){
            for (Account acc :lstOutlet){
                acc.FS_CS_All_Ftn_Removed__c= lstOutlet[0].FS_CS_All_Ftn_Removed__c ;
            }
        }
        else if(selectedFillDown == ALL){
            
            for (Account acc :lstOutlet){
                
                acc.FS_Requested_Order_Method__c= lstOutlet[0].FS_Requested_Order_Method__c ;
                acc.FS_Requested_Delivery_Method__c=lstOutlet[0].FS_Requested_Delivery_Method__c ;
                acc.FS_CS_Sub_Trade_Channel__c= lstOutlet[0].FS_CS_Sub_Trade_Channel__c ;                                
                acc.FS_CS_Bill_To_Address__c= lstOutlet[0].FS_CS_Bill_To_Address__c ;
                acc.FS_CS_Bill_To_Country__c= lstOutlet[0].FS_CS_Bill_To_Country__c ; //OCR
                acc.FS_CS_Bill_To_City__c= lstOutlet[0].FS_CS_Bill_To_City__c ;
                acc.FS_CS_State__c= lstOutlet[0].FS_CS_State__c ;
                acc.FS_CS_Bill_To_Zip__c= lstOutlet[0].FS_CS_Bill_To_Zip__c ;
                acc.FS_CS_All_Ftn_Removed__c= lstOutlet[0].FS_CS_All_Ftn_Removed__c ;
                if(lstOutlet[0].Cokesmart_Payment_Method__c!=PAYMENTTERM || acc.Cokesmart_Payment_Method__c==PAYMENTTERM){
					acc.Cokesmart_Payment_Method__c=lstOutlet[0].Cokesmart_Payment_Method__c;
				}
                
				else if(accountMap.containsKey(acc.Id) && acc.Invoice_Customer__c.equalsIgnoreCase(YESVALUE)){
					acc.Cokesmart_Payment_Method__c=lstOutlet[0].Cokesmart_Payment_Method__c;					
				}
				else{	popupCheck=true; }
                
                if(lstOutlet[0].FS_Payment_Method__c!=PAYMENTTERM || acc.FS_Payment_Method__c==PAYMENTTERM){
					acc.FS_Payment_Method__c=lstOutlet[0].FS_Payment_Method__c;
				}		
                
				else if(accountMap.containsKey(acc.Id) && acc.FS_Payment_Type__c.equalsIgnoreCase(YESVALUE)){
					acc.FS_Payment_Method__c=lstOutlet[0].FS_Payment_Method__c;					
				}
                
				else{ popupCheck=true; }
                if(popupCheck){ showPopup(); }
            }           
        }
    }
    /*****************************************************************
  	Method: cancel
  	Description: cancel method helps the user return back to the execution plan record  
	*******************************************************************/
    public PageReference cancel(){
        PageReference pageRef;
        if(executionPlan!= Null){
            pageRef= new PageReference('/' + executionPlan);
        }
        return pageRef;        
    }
}