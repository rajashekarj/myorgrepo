public with sharing class AllTabsnObjects {
    
    
    public PageReference Export() 
    {
        return page.ListofAllTabsExport;
    }
    
    public Map<String, Map<String,Map<String,String>>> myMap {
        get {
            Map<String, Map<String,Map<String,String>>> map1 = gettabs();
            return map1;
        }
    }
    
    
    public static Map<String, Map<String,Map<String,String>>> gettabs(){
        List<AppMenuItem> a = [Select label from AppMenuItem];
        
        List<String> app = new List<String>();
        for(AppMenuItem appName: a)
        {
            app.add(appName.label);
        }
        
        //To create a string of CustomObject
        String CustomObject = '';
        String Standardobj = '';
        String ManagedPackage = 'APXTConga4';
        for ( Schema.SObjectType typ : Schema.getGlobalDescribe().values() ) {
            
            String sobjName1 = String.valueOf(typ.getDescribe().getName());
            
            if (typ.getDescribe().isCustom()) 
            {
                if(!sobjName1.contains('FAQ__kav')){	
                        CustomObject = CustomObject + sobjName1;
						   }
                
            }
            else
            {
                Standardobj = Standardobj + sobjName1;
            }
        }
        system.debug('Custom==>' + CustomObject);
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        
        
        Map<String,Map<String,Map<String,String>>> apptabs = new Map<String,Map<String,Map<String,String>>>();
        for(Integer i=0; i<app.size();i++){
            for(DescribeTabSetResult tsr : tabSetDesc) {
                if(app[i] == tsr.getlabel())
                {
                    Map<String,Map<String,String>>tabobjects = new Map<String,Map<String,String>>();
                    List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
                    for(Schema.DescribeTabResult tr : tabDesc) {                        
                        
                        List<String> ObjectNames = new List<String>();
                        //String[] temp2 = new String[]{};
                        List<Schema.SObjectType> lstGlobalDes = Schema.getGlobalDescribe().values();
                        for ( Schema.SObjectType typ : lstGlobalDes) {
                            String sobjName = String.valueOf(typ);
                            
                           
                                
                                if (sobjName.contains(tr.getSobjectName()) && !sobjName.endsWith('__kav')) 
                                {
                                    //temp2.add(sobjName);
                                    ObjectNames.add(sobjName);
                                    
                                }
                            
                            
                        }
                       
                        
                        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(ObjectNames);                      
                        Map<String,String> ChObj = new Map<String,String>();
                        if(results.size() > 0){
                            for(Schema.DescribeSobjectResult res : results) {
                                if(tr.getSobjectName() == res.getName())
                                {
                                    String tmp = String.ValueOf(res.getName());
                                    if((CustomObject.contains(tmp)) && (!(Standardobj.contains(tmp))) && (!(tmp.contains(ManagedPackage))))
                                    {
                                        // Get child relationships
                                        List<Schema.ChildRelationship> rels = res.getChildRelationships();
                                        List<Schema.SObjectType> childObjects = new List<Schema.SObjectType>();
                                        String chldlst = '';
                                        for(Schema.ChildRelationship chres : rels) {
                                            if(chres.relationshipName != null)
                                            {  
                                                String temp = String.ValueOf(chres.getChildSObject());
                                                if((CustomObject.contains(temp)) && (!(Standardobj.contains(temp))))
                                                {
                                                    if(!(chldlst.contains(temp)))
                                                    {
                                                        if(chldlst == '')
                                                            chldlst = chldlst + chres.getChildSObject() + ' ';
                                                        else 
                                                            chldlst = chldlst + ';' + ' ' + chres.getChildSObject() + ' ';
                                                        //childObjects.add(chres.getChildSObject());
                                                    }
                                                }
                                            }                             
                                        }
                                        
                                        ChObj.put(res.getName(),chldlst);
                                    }
                                }
                            }
                        }
                        else
                        {   
                            String temp1 = String.ValueOf(tr.getSobjectName());
                            if((CustomObject.contains(temp1)) && (!(Standardobj.contains(temp1))))
                            {
                                ChObj.put(tr.getSobjectName(),'');
                            }
                        }
                        //tabobjects.put(tr.getLabel(),tr.getSobjectName());
                        tabobjects.put(tr.getLabel(),ChObj);
                       
                    }
                    apptabs.put(app[i],tabobjects);
                    
                }                
            }
        }
        return apptabs;
    }
}