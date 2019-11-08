public class FSCopytoLower_Cancel_PIM_Extension {
    
    public String pimId {get; set;}
    public String accId {get; set;}
    public Integer pimCount {get; set;}
    
    
    public FSCopytoLower_Cancel_PIM_Extension(ApexPages.StandardSetController controller){        
        
        List<FS_Post_Install_Marketing__c> listPIM = (List<FS_Post_Install_Marketing__c>)controller.getSelected();
        pimCount=listPIM.size();
        
        for(FS_Post_Install_Marketing__c pim:listPIM){
            PIMId=pim.id;
        }  
        for(FS_Post_Install_Marketing__c pim: [select id,FS_Account__c from FS_Post_Install_Marketing__c where id=:PIMId]){
            accid=pim.FS_Account__c;
        }              
    } 
}