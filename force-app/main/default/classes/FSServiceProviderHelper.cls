/**************************************************************************************************************
*@Class Name: FSServiceProviderHelper 
*@owner :Infosys limited
*@Description : Used for fetching Service provider for that particular Zip code
***************************************************************************************************************/
public class FSServiceProviderHelper {
    public final static Object NULLOBJ = null;
    private final static String LIT7K='7000';
    private final static String LIT8K='8000';
    private final static String LIT9K='9000';
    private final static String LIT91K='9100';
    private final static String LIT6K='6000';
    private final static String LIT65K='6500';
    //FNF-534 addition of new platform type 7100
    private final static String LIT71K='7100';
    
    //SP Aligned Zip of 7000 Series Based on ZipCode
    public static List<FS_SP_Aligned_Zip__c> get7000SPAlignedZip(final List<String> outletZipCodes){
        List<FS_SP_Aligned_Zip__c> spAlignedZip=new List<FS_SP_Aligned_Zip__c>();
        if(string.isNotBlank(LIT7K)){
            spAlignedZip= getSPAlignedZip(formatZip(outletZipCodes),LIT7K);
        }
         //FNF-534 addition of new platform type 7100
         if(string.isNotBlank(LIT71K)){
          spAlignedZip.addAll(getSPAlignedZip(formatZip(outletZipCodes),LIT71K));
        }  
        return spAlignedZip;
    }
    
    
    //SP Aligned Zip of 8000 & 9000Series Based on ZipCode
    public static List<FS_SP_Aligned_Zip__c> get80009000SPAlignedZip(final List<String> outletZipCodes){
      	//8000 and 9000 Series Platform
      	List<FS_SP_Aligned_Zip__c> spAlignedZip=new List<FS_SP_Aligned_Zip__c>();
       
        if(string.isNotBlank(LIT8K)){
            spAlignedZip=getSPAlignedZip(formatZip(outletZipCodes),LIT8K);
        }
        if(string.isNotBlank(LIT9K)){
            spAlignedZip.addAll(getSPAlignedZip(formatZip(outletZipCodes),LIT9K));
        }
        if(string.isNotBlank(LIT91K)){
            spAlignedZip.addAll(getSPAlignedZip(formatZip(outletZipCodes),LIT91K));
        }
     	return spAlignedZip;
    }
    //SP Aligned Zip of 6000 & 6050Series Based on ZipCode
    public static List<FS_SP_Aligned_Zip__c> get60006050SPAlignedZip(final List<String> outletZipCodes){
      //6000 and 6050 Series Platform        
        List<FS_SP_Aligned_Zip__c> spAlignedZip=new List<FS_SP_Aligned_Zip__c>();
       
        if(string.isNotBlank(LIT6K)){
            spAlignedZip=getSPAlignedZip(formatZip(outletZipCodes),LIT6K);
        }
        if(string.isNotBlank(LIT65K)){
            spAlignedZip.addAll(getSPAlignedZip(formatZip(outletZipCodes),LIT65K));
        }
        return spAlignedZip;
    }
    
    public static List<FS_SP_Aligned_Zip__c> getSPAlignedZip(final Set<String> zipCodeSet,final String platformType){
    
      return [SELECT ID,FS_Zip_Code__c,FS_Service_Provider__c,FS_Selling_Activity_Market__c,FS_Selling_Activity_Market__r.Name,FS_Selling_Market_Activation_Date__c,FS_SP_Code__c 
                                                        FROM FS_SP_Aligned_Zip__c 
                                                        WHERE FS_Zip_Code__c in: zipCodeSet AND FS_Platform_Type__c=:platformType];
    }
    
    
    public static Set<String> formatZip(final List<String> zipCodes){
    	final Integer five=5;
        final Set<String> zipCodeSet=new  Set<String>();
        for(String zipcode :zipCodes){
             if(zipcode.length() > five) {
                      zipCode = zipcode.substring(0,5);
             }else {
                      zipCode = zipcode;
             }
           
            zipCodeSet.add(zipcode);
          }
        return zipCodeSet;   
    }
}