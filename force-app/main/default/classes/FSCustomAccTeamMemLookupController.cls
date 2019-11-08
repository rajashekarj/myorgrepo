/*********************************************************************************
 Author		 	 	: INFOSYS
 Apex Class Name 	: FSCustomAccTeamMemLookupController
 Version         	: 1.0
 Function        	: This class is to generate custom lookup for Account team member
					  object in team members section of CIF
 Modification Log   :
 Developer           Date             Description
 ________________________________________________________________ 
 

**********************************************************************************/
public class FSCustomAccTeamMemLookupController {
    	public integer valZero = 0;
  		public List<AccountTeamMember__c> results{get;set;} // search results
  		public string searchString{get;set;} // search keyword
  		public string strTeamRole{get;set;}
  		public string strRT{get;set;}
  		public string strAccID{get;set;}
  		public ID accIDVal {get;set;}
  		public List<AccountTeamMember__c> allATM{get;set;}
  		public Map<String,String> atmUsers {get;set;}
  	
    /****************************************************************************
	Description 	: Constructor of the class FSCustomAccTeamMemLookupController
    *****************************************************************************/
    public FSCustomAccTeamMemLookupController() {
    	// get the current search string
    	atmUsers = new Map<String,String>();
    	strTeamRole = System.currentPageReference().getParameters().get('sri');
    	strRT = System.currentPageReference().getParameters().get('fshq');
    	strAccID = System.currentPageReference().getParameters().get('accID');
    	searchString =  System.currentPageReference().getParameters().get('lksrch');  
    	allATM = new List<AccountTeamMember__c>();
    	String soqlAllATM = 'select id, name,UserId__r.name from AccountTeamMember__c where TeamMemberRole__c = '+strTeamRole+' AND AccountId__c = '+strAccID;
    	allATM = database.query(soqlAllATM);
    	for(AccountTeamMember__c atm : allATM){
          atmUsers.put(atm.Name, atm.UserId__r.Name);
      	} 
      	if(atmUsers.containsKey(searchString)){
          	searchString = atmUsers.get(searchString);
      	} else{
         	searchString =  System.currentPageReference().getParameters().get('lksrch');  
      	}
    	if(strTeamRole.indexOf('Contact Lookup')< valZero )
    	{
   			results = performSearch(searchString);    
    	} 
    	  
  	}
    
    /**************************************************************************
    Method      	: search
	Description 	: Method performs the keyword search
    **************************************************************************/
    public PageReference search() {        	
    	results = performSearch(searchString);    
    	return null;
  	}
  
    /**************************************************************************
    Method      	: search
	Description 	: Method used to run the search and return the Account 
					  team member records found
    **************************************************************************/
    private List<AccountTeamMember__c> performSearch(string searchString) {
		String soql = 'select id, name,UserId__r.name from AccountTeamMember__c where TeamMemberRole__c = '+strTeamRole+' AND AccountId__c = '+strAccID;
        if(searchString != '' && searchString != null)
        { 
            searchString = String.escapeSingleQuotes(searchString);
        	soql = soql +  ' AND UserId__r.name LIKE \'%' + searchString +'%\'';
        }        
        soql = soql +Label.FS_PerformSearch_Limit;
        return database.query(soql); 
    }
    
    
    /**************************************************************************
    Method      	: getFormTag
	Description 	: Method used by the visualforce page to send the link to 
			  		  the right dom element
    **************************************************************************/
	public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    
    /**************************************************************************
    Method      	: getTextBox
	Description 	: Method used by the vf page to send the link to the 
					  right dom element for the text box
    **************************************************************************/
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }      
}