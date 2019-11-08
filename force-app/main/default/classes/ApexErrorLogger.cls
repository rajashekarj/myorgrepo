/*********************************************************************
* Class         :   AppErrorLogger
* Purpose       :   This class supports to log various types 
                    of errors in to error log object.
* Date          Who         Description 
* 8/9/2016      Infosys     First Version created 
**********************************************************************/
public without sharing class ApexErrorLogger{
  
  //Constants
   private static String notAvail = 'Not Available';
   private static String emptyString = '';
   private static final String ERR_CAP_FAIL = 'Apex Error Logger : Unable to capture/Log the error ';
   private static final string CRITICAL = 'CRITICAL';
   private static final string HIGH = 'HIGH';
   private static final string MED = 'MEDIUM';
   private static final string LOW = 'LOW';
   private static final string COSM = 'COSMETIC';
  
    //Method : Check if the string is empty assigns a Constant
    public static String checkNResetStr(final String nameStr){
        String retName;
        if(nameStr == null || nameStr == emptyString){
            retName = notAvail;
        }
        return nameStr;
    }
    //Method: Notification will send to asmin if insertation fail 
    /*public static void notifyAdmin(final string clsName,final string errorMsg){
        // Send an email to the Apex job's submitter notifying of job completion.
        final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        final List<String> sendTo=new List<String>();
        sendTo.add(Label.OrgAdminEmail);
        mail.setToAddresses(sendTo);
        mail.setSubject('Action Required : ' + errorMsg);
        mail.setPlainTextBody(clsName + errorMsg );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }*/
    
    //Method: Conver severity to correct value
    public static String checkseverrity(final String sName){
            String severity;
            if(sName==CRITICAL){severity= 'Critical';}
            else if(sName==HIGH){severity= 'High';}
            else if(sName==MED){severity= 'Medium';}
            else if(sName==LOW){severity= 'Low';}
            else if(sName==COSM){severity= 'Cosmetic';}
            else {(severity=sName);}
        return severity;
    }
    
    
  /*
    * Method  -  addApexErrorLog()
    * return type - void
    * description - This method logs an error msg and 
                    stack trace into Apex Error Log object.
    */
    public static void addApexErrorLog(final String aName,final String cName,final String mName,final String oName,final String Severity, final Exception exc,final String eNotes)
   {     
            String exceptionType;
            String errorStackTrace;
            String errorMessage;          
            String appName;
            String className;
            String methodName;
            String objectName;
            String eRRSeverity;
            String extraNotes;
            
            
            appName=checkNResetStr(aName);
            className=checkNResetStr(cName);
            methodName=checkNResetStr(mName);
            objectName=checkNResetStr(oName);
            eRRSeverity=checkseverrity(Severity);
            exceptionType=checkNResetStr(exc.getTypeName());
            errorMessage=checkNResetStr(exc.getMessage());
            errorStackTrace=checkNResetStr(exc.getStackTraceString());
            extraNotes=checkNResetStr(eNotes);
            
            
            final Apex_Error_Log__c errorRec = new Apex_Error_Log__c();

            errorRec.Application_Name__c = appName;
            errorRec.Class_Name__c = className;
            errorRec.Method_Name__c = methodName;
            errorRec.Object_Name__c = objectName;
            errorRec.Error_Severity__c = eRRSeverity;
            errorRec.Exception_Type__c = exceptionType;
            errorRec.Error_Message__c = errorMessage;
            errorRec.Error_Line_Number__c = exc.getLineNumber();
            errorRec.Error_Stack_Trace__c = errorStackTrace;
            errorRec.Notes__c = extraNotes;
                                
            try{
                insert errorRec;
            }
            Catch(exception ex){
                //notifyAdmin(CLASSNAME,ERR_CAP_FAIL);
                System.debug(ex);
            }
    }
    
    
    public static void addAELPayload(final String aName,final  String cName,final String mName,final String oName,final String Severity,final  String eNotes){
        
            
            final Apex_Error_Log__c errorRec = new Apex_Error_Log__c();
            
            errorRec.Application_Name__c = aName;
            errorRec.Class_Name__c = cName;
            errorRec.Method_Name__c = mName;
            errorRec.Object_Name__c = oName;
            errorRec.Error_Severity__c = Severity;
            errorRec.Notes__c= eNotes;
                             
            
            try{
                insert errorRec;
            }
            Catch(exception ex){
                System.debug(ERR_CAP_FAIL); 
            }
    }
    
}