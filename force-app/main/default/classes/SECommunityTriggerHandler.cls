public without sharing class SECommunityTriggerHandler{

    static final string ACCOUNT_NAME='Freestyle Customer Service Escalation';
    static final string USER_NAME=Label.USER_NAME;
    static final string PROFILE_NAME='Service Escalation Community Plus';
    
    //This method is to change the owner and account for the contact created by community plus users to bypass sfdc error
    public static void insertContacts(List<contact> contacts){
            system.debug('@@@Test cont users');
        //String acName='Freestyle Customer Service Escalation';

        Account acc=[Select Id,Name from account where name=:ACCOUNT_NAME limit 1];
        
        User usr=[Select Id,Name from user where Name=:USER_NAME and IsActive=true limit 1];
        
        if( usr!=null && acc != null  )
        {       
            for(contact c:contacts){
                    c.AccountId =acc.id;
                    c.OwnerId =usr.id;
                
            }
        }
    }
    
    //This method is to insert the users for the contacts created by community users and make them portal enabled
    public static void createCommUsers(List<contact> contacts){
            system.debug('@@@Test comm users');
         List<User> usrList = new List<User> ();
         id commProfileId=[Select Id from Profile where name =:PROFILE_NAME limit 1].id;
         User u=[Select id,TimeZoneSidKey,EmailEncodingKey,LocaleSidKey,LanguageLocaleKey from user where IsActive=true LIMIT 1];  
          
        if(!Contacts.isempty()){
        
           //For every contact Set the values required for User.
            for(contact c:contacts){
                user usr = new user();
                usr.FirstName = c.FirstName;
                usr.LastName = c.FirstName;
                usr.Email = c.Email;
                //Alias can contain maximum of 8 characters-so, trimming the extra characters
                string emailCont=c.Email.split('@').get(0);
                if(emailCont.length()>7)
                {
                    emailCont=emailCont.substring(0,7);
                }
                usr.Alias=emailCont;
                usr.Username = c.Email+'fetcom';
                usr.ProfileID = commProfileId;
                usr.ContactID = c.Id;
                usr.TimeZoneSidKey=u.TimeZoneSidKey;
                usr.EmailEncodingKey=u.EmailEncodingKey;
                usr.LocaleSidKey=u.LocaleSidKey; 
                usr.LanguageLocaleKey=u.LanguageLocaleKey;
                usr.FederationIdentifier=c.Email;
                usr.CommunityNickname= c.Email.split('@').get(0)+DateTime.now().getTime();
                usr.isActive = TRUE; 
                usrList.add(usr);
            }  
        }
        else
        {
            System.debug('No Valid list of Contacts to enable the community users');
            
        }
        
        if( !usrList.isempty() )
        {
            try{
            
             Database.insert(usrList);
             
             }
             Catch(Exception e){
                 system.debug('An exception occured while inserting users:'+e);
             }
        }
        else
                    System.debug('No Valid list of Contacts to enable the community users');

    }
}