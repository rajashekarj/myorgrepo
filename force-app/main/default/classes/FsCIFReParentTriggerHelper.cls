global class FsCIFReParentTriggerHelper {
    public static Set<Id> CifHeadId = New Set<Id>();
    public static Map<id,id> cifHeaders = new Map<id,id>();
    public static Map<id,id> cifHeadHQMap = new Map<id,id>();
    public static string olAcn;
    public static Set<Id> cifHeadHqIds = new Set<Id>();
    public static Map<Id,String> HQNameMap = new Map<Id,String>();
    public static List<CIF_Header__c> cifHeadListnew = new List<CIF_Header__c>();
    public static set<id> oldcifHeadIds = new set<id>();
    public static List<Account> CifoldHqdetails = new List<Account>();
    public static Map<String,String> notifiBody = new Map<String,String>();
    public static String cifHeadNumstr = '';
    public static String emailSub;
    public static Map<Id,CIF_Header__c> oldCIFHeaderMap = new Map<Id,CIF_Header__c>();
    
    //Method to get the CIF details of the header.
    public static void getCIFdetails(List<CIF_Header__c> cifHeadList, Map<Id,CIF_Header__c> oldCIFHeadMap)
    {
        Datetime hqDT = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        String hqDate = hqDT.format('YYMMdd'); // formats the date
        String hqTime = hqDT.format('HHmm');
        cifHeadListnew =  cifHeadList;
        oldCIFHeaderMap = oldCIFHeadMap;
        
        //Loop the cifHeader List which is trigger.new , and build a Set with IDs.
        for(CIF_Header__c CifHeadnew: cifHeadList)
        {
            cifHeadHqIds.add(CifHeadnew.FS_HQ__c);
        }
        
        List<Account> CifHqdetails = [select Id,name from Account where Id in :cifHeadHqIds];
        
        for(CIF_Header__c CifHeadnew1: cifHeadList)
        {
            for(Account CifHqdetail: CifHqdetails)
            {
            	If(CifHeadnew1.FS_HQ__c == CifHqdetail.id)   
                HQNameMap.put(CifHeadnew1.id, CifHqdetail.name)  ;  
            }
            oldcifHeadIds.add(oldCIFHeadMap.get(CifHeadnew1.id).FS_HQ__c);
        }
        
        CifoldHqdetails = [select Id,name from Account where Id in :oldcifHeadIds];
        
        for(CIF_Header__c CifHead: cifHeadList)
        {        
            If(CifHead.FS_HQ__c <> oldCIFHeadMap.get(CifHead.id).FS_HQ__c )
            {
                system.debug('new CIF head:' +CifHead);
                CifHead.FSCOM__c=null;
            	CifHead.FS_Sales_Rep_Name__c=null;
                CifHead.FS_FPS__c = null;
                system.debug('HQNameMap' +HQNameMap.get(CifHead.FS_HQ__c));
                CifHead.name = HQNameMap.get(CifHead.id)+'-'+UserInfo.getLastName()+'-'+hqDate+hqTime+'_V.1';
                CifHeadId.add(CifHead.Id);
                If(CifHead.FS_Status__c == 'Closed – Converted to EP')
                {
                 	CifHead.FS_Status__c = 'In Progress';
                    CifHead.FS_Reparent_CIF__c = true;
                }
                //cifHeaders.put(oldCIFHeadMap.get(CifHead.id).FS_HQ__c,CifHead.FS_HQ__c);
                cifHeadHQMap.put(CifHead.id, CifHead.FS_HQ__c);
            }
        }
        
        //Query the CIF object and get all the details for all the cif header Ids.
        List<FS_CIF__c> cifList = [select FS_Contractor_Contact__c, FS_Outlet_Contact__c, FS_On_Boarding_Contact__c, FS_Select_Site_assessment_contact__c,
                        FS_Training_Customer_Contact__c, FS_Water_Filter_Contact__c, FS_Water_Filter_Contact_Name__c,   Water_Filter_Installer_Name__c,
                        FS_Headquarters__c,CIF_Head__c,CIF_Head__r.FSCOM__c,CIF_Head__r.FS_Sales_Rep_Name__c,FS_Order_Administrator__c,FS_Order_Standard_User__c,
                        FS_Account__r.FS_Concatenated_Address__c,FS_Account__r.ShippingStreet,FS_Account__r.ShippingCity,FS_Account__r.ShippingState,
                        FS_Account__r.ShippingPostalCode,FS_Account__r.ShippingCountry,FS_Account__r.FS_ACN__c From FS_CIF__c where CIF_Head__c in :CifHeadId];
        
        //Call updateContacts method which updates the contacts on CIF.
        updateContacts(cifList);
    }
    
    //Method to update the CIF contact fields to null and create a related record to hold old contact values.
    public static void updateContacts(List<FS_CIF__c> cifList)
    {
        String emailBody;
        for(FS_CIF__c cif: cifList)
        {   
            //Make all the CIF contacts empty.
            Cif.FS_Contractor_Contact__c=null;
            Cif.FS_Outlet_Contact__c=null;
            Cif.FS_On_Boarding_Contact__c=null;
            Cif.FS_Select_Site_assessment_contact__c=null;
            Cif.FS_Training_Customer_Contact__c=null;
            Cif.FS_Water_Filter_Contact__c=null;
            Cif.FS_Water_Filter_Contact_Name__c=null;
            Cif.Water_Filter_Installer_Name__c=null;
            cif.FS_Order_Administrator__c=null;
            cif.FS_Order_Standard_User__c=null;
            Cif.CIF_Head__r.FSCOM__c=null;
            Cif.FS_Secondary_Site_Assessment_Contact__c = null;
            Cif.CIF_Head__r.FS_Sales_Rep_Name__c=null;
            Cif.CIF_Head__r.FS_FPS__c = null;
            //Cif.FS_Headquarters__c = cifHeaders.get(Cif.FS_Headquarters__c);
            Cif.FS_Headquarters__c = cifHeadHQMap.get(Cif.CIF_Head__c);
            olAcn = 'Outlet ACN: ' + Cif.FS_Account__r.FS_ACN__c;
            emailBody = Cif.FS_Account__r.ShippingStreet+ Cif.FS_Account__r.ShippingCity +Cif.FS_Account__r.ShippingState+Cif.FS_Account__r.ShippingPostalCode + Cif.FS_Account__r.ShippingCountry+ ' has been recently re-parented to HDQ ' + HQNameMap.get(cifHeadListnew[0].id) + ' from HDQ ' +
                    CifoldHqdetails[0].Name + ' as a result the CIF has been moved.'+
                    ' All previous CIF contacts have been removed since the contacts within the CIF are specific to a HDQ. Please update the CIF with the point of contacts and validate the remaining CIF details. \n' +
                    System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/FSCustomerInputForm?id='+Cif.CIF_Head__c;
            notifiBody.put(olAcn,emailBody);
        }
        
        //Update the CIF records.
        if(cifList.size()>0){
            update cifList;
        }
        If(cifHeadListnew[0].FS_HQ__c != oldCIFHeaderMap.get(cifHeadListnew[0].id).FS_HQ__c)
        {
            cifHeadNumstr = cifHeadListnew[0].FS_CIF_Number__c;
            emailSub = cifHeadNumstr + ' has been moved for Re-Parented Outlet/s ' ;
            FsCIF_SendEmail_Helper.sendReparentNotif(cifHeadListnew[0],cifHeadNumstr,notifiBody,emailSub);
        }
        
    }
}