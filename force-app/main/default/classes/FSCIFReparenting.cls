global class FSCIFReparenting {
    
    public Map<String,String> notifiBody = new Map<String,String>();
    public String linkInEmail = '';
    public String cifHeadNumstr = '';
    public Map<Id,CIF_Header__c> headerVal = new Map<Id,CIF_Header__c>();
    public CIF_Header__c cifHeader;
    public List<FS_CIF__c> cifs;
    public string closedStatus='Closed – Converted to EP';
    public static final Object STR_NULL = null ;
    public static final ID NULL_ID=null;
    public Profile prof;
    public  Boolean profileEnabled{get;set;}
    public  Boolean isReparented{get;set;}
    Public  Boolean isNotReparent{get;set;}
    public  Boolean allReparent{get;set;}
    public  Boolean partialReparent{get;set;}
    public  Boolean noReparent{get;set;}
    public String profileName {get;set;}
    public string objectType{get;set;}
    private transient String hqDate {get;set;}
    private transient String hqTime {get;set;}
    public String olAcn{get;set;}
    public String emailBody {get;set;}
    public String emailSub {get;set;}
    
    //public string cifHeader='CIF_Header__c';
    /*****************************************************************
Method: Constructor
Description: 
*******************************************************************/
    public FSCIFReparenting (final ApexPages.StandardController controller) {
        final string hqAccid = ApexPages.currentPage().getParameters().get('AccId'); //Get the ID from URL.
        final string hqid = ApexPages.currentPage().getParameters().get('Id'); //Get the ID from URL.
        profileEnabled = false;
        if(hqid == STR_NULL){
            objectType = 'Account';
        }else{
            objectType = 'CIF_Header__c';
        } 
        
        system.debug('hqid^^^^^^'+hqid);
        isReparented = false;
        isNotReparent = false;
        allReparent = false;
        partialReparent = false;
        noReparent = false;
        
        If(objectType == 'CIF_Header__c'){
            checkReparentCIF(hqid);
        } 
        
        Id profileId=userinfo.getProfileId();          
        prof = [select id,name from profile where ID=:profileId];
        profileName=prof.Name;  
        
        List<reparent_enabled_profiles__c> reparentProfiles = reparent_enabled_profiles__c.getall().values();
        for(reparent_enabled_profiles__c reparentProfile: reparentProfiles)
        {
            If(profileName == reparentProfile.name)
            {
                profileEnabled = true;
            }            
        }
    }
    
    /*****************************************************************
Method: checkReparentCIF()
Description: Check If CIFHeader has reparent CIF lines
*******************************************************************/
    Public void checkReparentCIF(final Id ssId){        
        system.debug('Printing CIF Header Id' +ssId);
        Boolean isInstalActive = false;
        Set<Id> reparentHQset = new Set<Id>();
        cifHeader = [select Id,name,FS_HQ__c,FS_Status__c,FS_EP__r.FS_Execution_Plan_Status__c from CIF_Header__c where id = :ssId];
        cifs = [select Id,FS_Account__r.FS_Headquarters__c,FS_Account__r.ShippingStreet,FS_Account__r.ShippingCity,FS_Account__r.ShippingState,
                FS_Account__r.ShippingPostalCode,FS_Account__r.ShippingCountry,FS_Account__r.Outlet_ACN__c,FS_Installation__r.FS_Overall_Status__c from FS_CIF__c where CIF_Head__c =:cifHeader.Id];
        
        system.debug('Printing CIF line row count' +cifs.size());
        
        for(FS_CIF__c cif :cifs){
            System.debug('printing CIF ACN:' + cif.FS_Account__r.Outlet_ACN__c);
            //System.debug('printing CIF-Header HQ:' + cifHeader.FS_HQ__c);
            If(cif.FS_Account__r.FS_Headquarters__c == cifHeader.FS_HQ__c ){
                isNotReparent = true;
            }
            else {
                isReparented = true;
                reparentHQset.add(cif.FS_Account__r.FS_Headquarters__c);
            }
        }
        
        If((isNotReparent == false && isReparented == true) || (isNotReparent == true && isReparented == true))
        {
            for(FS_CIF__c cif :cifs)
            {
                If(cif.FS_Installation__r.FS_Overall_Status__c != 'Cancelled' && cif.FS_Installation__r.FS_Overall_Status__c != '5-Install Complete')
                {
                    isInstalActive = true;
                }
            }
        }
        
        If (isNotReparent == true && isReparented == false){
            noReparent = true;
        }
        else If(isNotReparent == false && isReparented == true && reparentHQset.size() == 1){
            allReparent = true;
        }
        else If(isNotReparent == false && isReparented == true && reparentHQset.size() > 1){
            partialReparent = true;
        }
        else If(isNotReparent == true && isReparented == true && cifHeader.FS_Status__c == 'In Progress'){
            partialReparent=true;
        }
        else If(isNotReparent == true && isReparented == true && cifHeader.FS_Status__c == closedStatus && cifHeader.FS_EP__r.FS_Execution_Plan_Status__c == 'In Progress' && isInstalActive == true)
        {
            partialReparent = true;
        }
        system.debug('printing allReparent' +allReparent );
        system.debug('printing partialReparent' +partialReparent );
        system.debug('printing noReparent' +noReparent );
    }
    
    /******************************************************************
Method: ReparentCIF()
Description: Create new CIF headers for reparent CIFs
*******************************************************************/ 
    public PageReference processReparent(){
        system.debug('Inside processReparent');
        final List<CIF_Header__c> newHeaderList 	= new List<CIF_Header__c>();
        final List<FS_CIF__c> updatereparentCIFs 	= new List<FS_CIF__c>(); 
        final Set<Id> instCancelForreparentCIFs 	= new Set<Id>();        
        //final Set<Id> headerIds 					= new Set<id>();        
        final Map<Id,List<FS_CIF__c>> reparentCIFs 	= new Map<Id,List<FS_CIF__c>>();
        
        final String hqid = ApexPages.currentPage().getParameters().get('Id'); //Get the ID from URL.
        
        cifHeader = [select Id,name,FS_HQ__c,FS_HQ__r.Name,FS_Status__c,FSCOM__r.FS_Email__c,FS_FPS__r.Email,FS_CIF_Number__c from CIF_Header__c where id = :hqid];
        cifs = [select Id,FS_Account__r.FS_Headquarters__c,FS_Outlet_ACN__c,FS_Account__r.FS_Concatenated_Address__c,FS_Account__r.ShippingStreet,FS_Account__r.ShippingCity,FS_Account__r.ShippingState,FS_Account__r.ShippingPostalCode,FS_Account__r.ShippingCountry,
                FS_Account__r.FS_Headquarters__r.Name,FS_Account__r.Outlet_ACN__c,FS_Installation__r.Id from FS_CIF__c where CIF_Head__c =:cifHeader.Id];       
        
        for(FS_CIF__c cif :cifs){            
            If(cif.FS_Account__r.FS_Headquarters__c != cifHeader.FS_HQ__c ) {
                If(reparentCIFs.get(cif.FS_Account__r.FS_Headquarters__c) != STR_NULL) {
                    reparentCIFs.get(cif.FS_Account__r.FS_Headquarters__c).add(cif);
                }
                else{
                    reparentCIFs.put(cif.FS_Account__r.FS_Headquarters__c,new List<FS_CIF__c>{cif});                   
                }
                instCancelForreparentCIFs.add(cif.FS_Installation__r.Id);
            }
        }
        
        If(cifHeader.FS_Status__c == closedStatus)
        {
            List<FS_Installation__c> instTobeCancelled = [select Id,name,FS_CIF__c,FS_Survey_Install_Cancelled__c from FS_Installation__c where Id in :instCancelForreparentCIFs];    
            for(FS_Installation__c Inst :instTobeCancelled)
            {
                Inst.FS_Survey_Install_Cancelled__c = true;
                Inst.FS_CIF__c = NULL_ID;
            }
            update instTobeCancelled;
        }
        
        for(Id reparentHQ :reparentCIFs.keySet()){
            final CIF_Header__c newHeader = new CIF_Header__c();
            Datetime hqDT = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
            hqDate = hqDT.format('YYMMdd'); // formats the date
            hqTime = hqDT.format('HHmm');
            
            FS_CIF__c rp_cif =  reparentCIFs.get(reparentHQ)[0];
            newHeader.name = rp_cif.FS_Account__r.FS_Headquarters__r.name+'-'+UserInfo.getLastName()+'-'+hqDate+hqTime+'_V.1';
            newHeader.FS_HQ__c =  reparentCIFs.get(reparentHQ)[0].FS_Account__r.FS_Headquarters__c;
            newHeader.FS_Status__c = 'In Progress';
            newHeaderList.add(newHeader);
        }
        insert newHeaderList;
        Set<Id> headIds = new Set<Id>(); 
        List<CIF_Header__c> headers = new List<CIF_Header__c>();
        for(CIF_Header__c newHeader :newHeaderList) 
        {
            headIds.add(newHeader.Id);   
        }
        
        headers  = [Select Id,Name,FS_HQ__c,FS_HQ__r.Name,FS_CIF_Number__c from CIF_Header__c where Id in: headIds];
        
        for(CIF_Header__c head : headers){
            headerVal.put(head.FS_HQ__c,head) ; 
        }
        
        for(CIF_Header__c newHeader : newHeaderList){
            List<FS_CIF__c> newCIFs = reparentCIFs.get(newHeader.FS_HQ__c);
            //cifHeadNum.add(newHeader.FS_CIF_Number__c);
            cifHeadNumstr = cifHeadNumstr + headerVal.get(newHeader.FS_HQ__c).FS_CIF_Number__c + ';' ;
            System.debug('cifHeadNumstr' + cifHeadNumstr);
            for(FS_CIF__c cifLine : newCIFs){
                cifLine.CIF_Head__c = newHeader.Id;
                cifLine.FS_Headquarters__c = newHeader.FS_HQ__c;
                cifLine.FS_Contractor_Contact__c=NULL_ID;
                cifLine.FS_Outlet_Contact__c=NULL_ID;
                cifLine.FS_On_Boarding_Contact__c=NULL_ID;
                cifLine.FS_Select_Site_assessment_contact__c=NULL_ID;
                cifLine.FS_Secondary_Site_Assessment_Contact__c=NULL_ID;
                cifLine.FS_Training_Customer_Contact__c=NULL_ID;
                cifLine.FS_Water_Filter_Contact__c=NULL_ID;
                cifLine.FS_Water_Filter_Contact_Name__c=NULL_ID;
                cifLine.Water_Filter_Installer_Name__c=NULL_ID;
                cifLine.FS_Order_Administrator__c=NULL_ID;
                cifLine.FS_Order_Standard_User__c=NULL_ID;
                olAcn = 'Outlet ACN: ' + cifLine.FS_Outlet_ACN__c;
                System.debug('olAcnolAcn' + olAcn);
                emailBody = cifLine.FS_Account__r.ShippingStreet+ cifLine.FS_Account__r.ShippingCity +cifLine.FS_Account__r.ShippingState+cifLine.FS_Account__r.ShippingPostalCode + cifLine.FS_Account__r.ShippingCountry+ ' has been recently re-parented to HDQ ' + headerVal.get(newHeader.FS_HQ__c).FS_HQ__r.Name + ' from HDQ ' +
                    cifHeader.FS_HQ__r.Name + ' and as a result a new CIF has been created against it/them. Please validate all information is correct.'+
                    ' All previous CIF contacts have been wiped since all CIF contacts are specific to a HDQ so you will need to reselect the appropriate contacts. \n' +
                    System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/FSCustomerInputForm?id='+newHeader.Id;
                notifiBody.put(olAcn,emailBody);
                System.debug('emailBodyemailBody' + emailBody);
                updatereparentCIFs.add(cifLine) ;
            }
        }
        if(!updatereparentCIFs.isEmpty()){
            update updatereparentCIFs;
        }
        emailSub = 'New CIF for Re-Parented Outlet/s ' + cifHeadNumstr ;
        FsCIF_SendEmail_Helper.sendReparentNotif(cifHeader,cifHeadNumstr,notifiBody,emailSub);
        
        PageReference pageRefHeader  = new PageReference('/apex/FSCustomerInputForm?Id='+hqid);
        pageRefHeader.setRedirect(true);
        return pageRefHeader;
    }   
}