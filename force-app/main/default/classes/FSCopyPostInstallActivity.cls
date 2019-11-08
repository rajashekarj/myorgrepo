global class FSCopyPostInstallActivity {
    
    webservice static String ChaintoHqMarketing(String recId,String pmid,String Obj)  {
        FS_Post_Install_Marketing__c PM;
        String qryPM = FSUtil.getSelectQuery('FS_Post_Install_Marketing__c') + ' WHERE Id=:pmid';
        List<FS_Post_Install_Marketing__c> ListPM = (List<FS_Post_Install_Marketing__c>)database.query(qryPM);
        For(FS_Post_Install_Marketing__c PIM:ListPM ){
            PM=PIM;
        }
        if(PM.FS_Cncl_Post_Install_Marketting_fields__c==false){
            PM.FS_Outlet_Dispenser__c=null;
            if(PM.FS_RcdIDForCncl__c==null){            
                PM.FS_RcdIDForCncl__c=PM.id;            
            }
            if(Obj=='Account'){
                String AccountRecType= [SELECT RecordType.Name from Account where id=:recid ].RecordType.Name;
                PM.FS_Installation__c=null;            
                update PM;  
                if(AccountRecType==FSConstants.RECORD_TYPE_NAME_CHAIN){                
                    Database.executeBatch(New FSBatchCopyChaintoHq(recId,Null,PM,null),10);             
                }
                if(AccountRecType==FSConstants.RECORD_TYPE_NAME_HQ){                 
                    Database.executeBatch(New FSBatchCopyHqtoOutlet(recId,NUll,PM,null,null),10);
                }
                if(AccountRecType==FSConstants.RECORD_TYPE_NAME_OUTLET){                
                    Database.executeBatch(New FSBatchCopyOutletToOD(recId,null,PM,null,null),10);
                }   
                
            }
            /*
            if(Obj=='Installation'){ 
                PM.FS_Account__c=null;            
                update PM; 
                Database.executeBatch(New FSBatchCopyInstallToOD (recId,null,PM,null,null),10);
            }*/ 
            FS_Msg_Copy_to_lower_levels__c mc = FS_Msg_Copy_to_lower_levels__c.getValues('Successfully Copied to lower level');
            return mc.FS_Success_Copy_to_Lower_Levels__c;
            
        }
        else{return 'You can not copy already canceled Post Install Marketing record ';}
    }      
    
    webservice static String ChaintoHqValidFill(String recId,String vfid,String Obj)  {
        FS_Valid_Fill__c VF ;
        String qryVF = FSUtil.getSelectQuery('FS_Valid_Fill__c') + ' WHERE Id=:vfid';
        List<FS_Valid_Fill__c> ListVF = (List<FS_Valid_Fill__c>)database.query(qryVF);
        For(FS_Valid_Fill__c VlF:ListVF ){
            VF=VlF;
        }
        if(VF.FS_Cancel_Valid_Fill__c==false){      
            VF.FS_Outlet_Dispenser__c=null;
            if(VF.FS_RcdIDForCncl__c==null){            
                VF.FS_RcdIDForCncl__c=VF.id;            
            }
            if(Obj=='Account'){
                String AccountRecType= [SELECT RecordType.Name from Account where id=:recid ].RecordType.Name;
                VF.FS_Installation__c=null;           
                update VF;      
                if(AccountRecType==FSConstants.RECORD_TYPE_NAME_CHAIN){                
                    Database.executeBatch(New FSBatchCopyChaintoHq(recId,null,null,VF),10);                 
                }
                if(AccountRecType==FSConstants.RECORD_TYPE_NAME_HQ){               
                    Database.executeBatch(New FSBatchCopyHqtoOutlet(recId,null,null,VF,null),10);
                }
                if(AccountRecType==FSConstants.RECORD_TYPE_NAME_OUTLET){               
                    Database.executeBatch(New FSBatchCopyOutletToOD(recId,null,null,VF,null),10);
                }       
            }
            /*if(Obj=='Installation'){
            VF.FS_Outlet__c=null;            
            update VF;
            Database.executeBatch(New FSBatchCopyInstallToOD (recId,null,null,VF,null),10);  
            }*/ 
            FS_Msg_Copy_to_lower_levels__c mc = FS_Msg_Copy_to_lower_levels__c.getValues('Successfully Copied to lower level');
            return mc.FS_Success_Copy_to_Lower_Levels__c;
            
        }
        else{return 'You can not copy already canceled Post Install Valid Fill record'; }      
    }
}