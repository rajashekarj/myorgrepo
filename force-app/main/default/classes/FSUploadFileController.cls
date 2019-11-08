/*=================================================================================================================
* Date         : 31-12-2018
* Developer    : Goutham Rapolu
* Purpose      : This is a Controller class for FSUploadFile which will handle Upload Documents to File Object.
*=================================================================================================================
*                                 Update History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 31-12-2018 | Goutham Rapolu |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

global class FSUploadFileController {
    public blob file {get;set;}
    public String Parentid {get;set;}
    public String fname{get;set;}
    public String RetURL{get;set;}
    public String UserID{get;set;}
    public static final string ErrorMsg = 'Please choose a file';
    public static final string SHARETYPE = 'I';
    public static final string VISIBILITY = 'AllUsers';
    
    public PageReference upload() {
        Parentid = apexpages.currentpage().getparameters().get('Recid');
        RetURL = apexpages.currentpage().getparameters().get('RetURL');
        UserID = userinfo.getUserId();
        Try{
            //Create ContentVersion
            ContentVersion v = new ContentVersion();
            v.versionData = file;
            v.title = fname;
            v.pathOnClient ='/'+fname;
            insert v;
            
            //Get the ContentDocumentId
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:v.Id].ContentDocumentId;
            
            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = id.valueof(Parentid);
            cDe.ShareType = SHARETYPE; // Inferred permission, checkout description of ContentDocumentLink object for more details
            cDe.Visibility = VISIBILITY; //Visibility to All Users
            insert cDe;
            
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorMsg));  
            system.debug('@@ Error Line Number :: '+ e.getLineNumber() +':: @@ Error Message :: '+e.getMessage());
            return null;
        }
        return new PageReference('/'+RetURL);
    }
}