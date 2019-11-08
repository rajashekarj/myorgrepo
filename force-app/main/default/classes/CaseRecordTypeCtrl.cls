/**************************************************************************************
Apex Class Name     : CaseRecordTypeCtrl
Function            : This class is created for routing to Case Edit Page based on Record Type.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Denit            3/5/2018           LM RecordType will be routed to FS_LM_CaseEditPage VF others Will be routed to Standard Layout    
*************************************************************************************/
public with sharing class CaseRecordTypeCtrl
{    
    public string strRecordType{get;set;}
    public List<RecordType> RecType{get;set;}
    public list<WrapRecType> ListVaria{get;set;}
    private final Case Acc;
    String stdURL = System.label.StandardCaseURL;
    public CaseRecordTypeCtrl(ApexPages.StandardController stdController)
    {   
        List<String> RecID = new List<String>();
        for(RecordTypeInfo allRecTy : Case.SObjectType.getDescribe().getRecordTypeInfos())
        {
            if(allRecTy.isAvailable() && allRecTy.getName()!='Master') 
            { 
            RecID.add(allRecTy.getName());
            }
        }
        this.Acc = (Case)stdController.getRecord();
        RecType = new List<RecordType>();
        ListVaria = new List<WrapRecType>();
        RecType = [select id,Name,Description from RecordType where sObjectType='Case' and Name IN: RecID];
        for(RecordType Rec: RecType)
        {
            WrapRecType r = new WrapRecType();
            r.RecName = Rec.Name;
            r.RecDesc = Rec.Description;
            ListVaria.add(r);
        }
    }
    public list<SelectOption> getRecordTypesNames()
    {
        list<SelectOption> options = new list<SelectOption>();   
        list<SelectOption> options2 = new list<SelectOption>();  
        for(RecordTypeInfo sRecordType : Case.SObjectType.getDescribe().getRecordTypeInfos())
        {   
                if(sRecordType.isAvailable() && sRecordType.getName()!='Master') 
                {                  
                    if(sRecordType.isDefaultRecordTypeMapping())
                    {                    
                    options.add(new SelectOption(sRecordType.getRecordTypeId(), sRecordType.getName()));    
                    }
                    else
                    {
                    options2.add(new SelectOption(sRecordType.getRecordTypeId(), sRecordType.getName())); 
                    }   
                }           
        } 
        options.addall(options2);
        return options;
    } 
     public Pagereference redirectToNewVFPage()
    {
        Acc.RecordTypeId = strRecordType;        
        Pagereference pg = null;
        if(strRecordType != null)
        {           
            if(strRecordType == Schema.SObjectType.Case.getRecordTypeInfosByName().get(FSConstants.RECORD_TYPE_NAME_LMCASE).getRecordTypeId())
            {
                pg = new Pagereference('/apex/FS_LM_CaseEditPage');
            }
            else 
            {
                pg = new Pagereference(stdURL+strRecordType+'&ent=Case&nooverride=1');
            }            
            pg.setRedirect(true); 
            return pg;
        }
        return null;
    } 
    //Wrapper class added for displaying the name and the Description for Community User and other Users
    public class WrapRecType
    {
        Public String RecName{get; set;}
        Public String RecDesc{get; set;}
    }
}