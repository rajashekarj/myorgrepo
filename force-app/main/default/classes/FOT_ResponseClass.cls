/*****************************************************************
	Class: FOT_ResponseClass
	Description: FOT_ResponseClass is a Wrapper class to hold API response.
	Added as part of FOT
	*********************************/ 
public class FOT_ResponseClass {
    
    @AuraEnabled    public boolean valid;
    @AuraEnabled    public string hashCode;
    @AuraEnabled    public string message;	
    @AuraEnabled    public string textArea;
    @AuraEnabled    public string noMsg;
    @AuraEnabled    public string yesMsg;
    
}