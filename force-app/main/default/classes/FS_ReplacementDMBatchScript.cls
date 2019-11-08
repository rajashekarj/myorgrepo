//DM Batchable for FNF-828
//Can be deleted once data migration is validated
global class FS_ReplacementDMBatchScript implements Database.Batchable<SObject>, Database.Stateful {
    //can edit this to whoever needs the After CSVs
    private static final List<String> recipients = new List<String>{userInfo.getUserEmail(), 'jneufer@coca-cola.com'};
    
    private static String replacementCSVname = 'replacements.csv';
    private static String CIFCSVname = 'cifs.csv';
    private static String newInstallCSVname = 'new-installs.csv';
    private static String multipleMatchesCSVname = 'multiple-matches.csv';
    private static String zeroMatchesCSVname = 'zero-matches.csv';
            
    private String replacementCSV = '';
    private String CIFCSV = '';
    private String newInstallCSV = '';
    private String multipleMatchesCSV = '';
    private String zeroMatchesCSV = '';
    
    private Map<String, String> replacementErrors = new Map<String, String>();
    private Map<String, String> cifErrors = new Map<String, String>();
    private Map<String, String> newInstallErrors = new Map<String, String>();
    
    private static Map<String, List<String>> nameToCSV = new Map<String, List<String>>
    {'replacements.csv' => new List<String>{'Id', 'FS_Same_Incoming_Platform__c', 'FS_Reason_Code__c', 'FS_Scheduled_Install_Date__c'},
     'cifs.csv' => new List<String>{'Id', 'FS_Does_Install_Involve_a_Replacement__c', 'FS_Replacement_1__c'},
     'new-installs.csv' => new List<String>{'Id', 'FS_Does_Install_Involve_a_Replacement__c', 'FS_Replacement_1__c', 'FS_Scheduled_Install_Date__c'},
     'multiple-matches.csv' => new List<String>{'Id', 'FS_Same_Incoming_Platform__c', 'FS_Reason_Code__c', 'FS_Scheduled_Install_Date__c'},
     'zero-matches.csv' => new List<String>{'Id', 'FS_Same_Incoming_Platform__c', 'FS_Reason_Code__c', 'FS_Scheduled_Install_Date__c'}};
    
	private Integer numFailReplacements = 0;
    private Integer numFailCIFs = 0;
    private Integer numFailNewInstalls = 0;
    
    //csv vars
    List<String> columns = new List<String>();
    List<SObject> rows = new List<SObject>();
        
    global FS_ReplacementDMBatchScript() {}
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, FS_CIF__c, FS_Reason_Code__c, Outlet_ACN__c, FS_Scheduled_Install_Date__c, FS_Outlet__c, FS_Same_Incoming_Platform__c
                                         FROM FS_Installation__c
                                         WHERE RecordType.Name = 'Replacement'
                                         AND FS_Reason_Code__c IN ('Platform Change', 'Change of Color', 'Bridge 9000 to 9100', 'Early Replacement 9000 to 9100')
                                         ORDER BY FS_Outlet__c]);
    }
    
    private void generateCSV(String fileName, String[] columns, SObject[] rows) {
        String csv;
        
        if(fileName == 'replacements.csv') {
            csv = replacementCSV;
        } else if (fileName == 'cifs.csv') {
            csv = CIFCSV;
        } else if (fileName == 'new-installs.csv') {
            csv = newInstallCSV;
        } else if (fileName == 'multiple-matches.csv') {
            csv = multipleMatchesCSV;
        } else if (fileName == 'zero-matches.csv') {
            csv = zeroMatchesCSV;
        }
        
        String tempRow = '';
        for(SObject row : rows) {
            tempRow = '';
            for(String column : columns) {
                tempRow += row.get(column) + ',';
            }
            csv += endRow(tempRow);
        }
        
        if(fileName == 'replacements.csv') {
            replacementCSV = csv;
        } else if (fileName == 'cifs.csv') {
            CIFCSV = csv;
        } else if (fileName == 'new-installs.csv') {
            newInstallCSV = csv;
        } else if (fileName == 'multiple-matches.csv') {
            multipleMatchesCSV = csv;
        } else if (fileName == 'zero-matches.csv') {
            zeroMatchesCSV = csv;
        }
    }
    
    private String endRow(String line) {
        return line.left(line.length()-1) + '\n';
    }    
    
    private void sendEmail() {       
        Messaging.EmailFileAttachment[] csvs = new List<Messaging.EmailFileAttachment>();
        
        for(String fileName : nameToCSV.keySet()) {
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            String csvAttach = '';
            for(String col : nameToCSV.get(fileName)) {
                csvAttach += col + ',';
            }
            csvAttach = endRow(csvAttach);
            if(fileName == 'replacements.csv') {
                csvAttach += replacementCSV;
            } else if (fileName == 'cifs.csv') {
                csvAttach += CIFCSV;
            } else if (fileName == 'new-installs.csv') {
                csvAttach += newInstallCSV;
            } else if (fileName == 'multiple-matches.csv') {
           		csvAttach += multipleMatchesCSV;
        	} else if (fileName == 'zero-matches.csv') {
            	csvAttach += zeroMatchesCSV;
        	}
            
            attach.setFileName(fileName);
            attach.setBody(blob.valueOf(csvAttach));
            csvs.add(attach);
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = 'FNF-828: Data Migration Complete';
        email.setToAddresses(recipients);
        String emailBody = '';
        emailBody += 'Replacement Records: ' + numFailReplacements + ' failures.<br/>';
        if(numFailReplacements > 0) for(String id : replacementErrors.keySet()) emailBody += id + ': ' + replacementErrors.get(id) + '<br/>';
        emailBody += 'New Install Records: ' + numFailNewInstalls + ' failures.<br/>';
        if(numFailNewInstalls > 0) for(String id : newInstallErrors.keySet()) emailBody += id + ': ' + newInstallErrors.get(id) + '<br/>';
        emailBody += 'CIF Records: ' + numFailCIFs + ' failures.<br/>';
        if(numFailCIFs > 0) for(String id : cifErrors.keySet()) emailBody += id + ': ' + cifErrors.get(id) + '<br/>';
        email.setHtmlBody(emailBody);
        email.setFileAttachments(csvs);
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
    
    global void execute(Database.BatchableContext BC, List<FS_Installation__c> scope) {
        Map<Id, FS_Installation__c> replacements = new Map<Id, FS_Installation__c>();
        for(FS_Installation__c inst : scope) {
            replacements.put(inst.Id, inst);
        }
        
        Set<String> picklistVals = new Set<String>{'Bridge 9000 To 9100', 'Early Replacement 9000 To 9100',
            'Platform Change'};
                
        for(FS_Installation__c inst : replacements.values()) {
           if(picklistVals.contains(inst.FS_Reason_Code__c)) {
               inst.FS_Same_incoming_platform__c = 'No';
           } else {
               inst.FS_Same_incoming_platform__c = 'Yes';
           }
		}
        
        Database.SaveResult[] replacementsResult = Database.update(replacements.values(), false);
              
        
        generateCSV(replacementCSVName, nameToCSV.get(replacementCSVName), replacements.values());
        
        for(Integer i = 0; i < replacementsResult.size(); i++) {
            Database.SaveResult res = replacementsResult[i];
            if(!res.isSuccess()) {
                replacementErrors.put(replacements.values()[i].Id, String.valueOf(res.getErrors()));
                numFailReplacements++;
            }
        }
        System.debug('ERROR replacementErrors -->'+replacementErrors);
        Map<Id, List<FS_Installation__c>> accToInstallations = new Map<Id, List<FS_Installation__c>>();
        for(FS_Installation__c installation : replacements.values()) {
            if(accToInstallations.containsKey(installation.FS_Outlet__c)) {
                accToInstallations.get(installation.FS_Outlet__c).add(installation);
            } else {
                accToInstallations.put(installation.FS_Outlet__c, new List<FS_Installation__c>{installation});
            }
        }
        
        for(id i : accToInstallations.keySet()) {
            if(accToInstallations.get(i).size() > 1) {
                String redundantReplacements = '';
                for(fs_installation__c fsi : accToInstallations.get(i)) redundantReplacements += fsi.Id +', ';
            }    
        }
        
        FS_Installation__c[] allOtherInstallations = [SELECT Id, FS_Outlet__c, FS_CIF__c, FS_Scheduled_Install_Date__c, Outlet_ACN__c, FS_Same_Incoming_Platform__c, FS_Reason_Code__c
                                                      FROM FS_Installation__c
                                                      WHERE RecordType.Name = 'New Install'
                                                      AND FS_Outlet__c IN :accToInstallations.keySet()];
                
        Map<Id, List<FS_Installation__c>> replacementToOtherInstalls = new Map<Id, List<FS_Installation__c>>();
        
        for(FS_Installation__c otherInstall : allOtherInstallations) {
            for(FS_Installation__c removal : accToInstallations.get(otherInstall.FS_Outlet__c)) {
                if(otherInstall.FS_Scheduled_Install_Date__c != null && removal.FS_Scheduled_Install_Date__c != null && otherInstall.FS_Scheduled_Install_Date__c.daysBetween(removal.FS_Scheduled_Install_Date__c) <= 60 && otherInstall.FS_Scheduled_Install_Date__c.daysBetween(removal.FS_Scheduled_Install_Date__c) >= -60) {
                       if(replacementToOtherInstalls.containsKey(removal.Id)) {
                           replacementToOtherInstalls.get(removal.Id).add(otherInstall);
                       } else {
                           replacementToOtherInstalls.put(removal.Id, new List<FS_Installation__c>{otherInstall});
                       }
                   }
            }
        }
        
        List<FS_Installation__c> replacementsWithoutInstalls = new List<FS_Installation__c>();
        Map<Id, List<FS_Installation__c>> multipleInstalls = new Map<Id, List<FS_Installation__c>>();
        
        Map<Id, FS_Installation__c> cifToReplacement = new Map<Id, FS_Installation__c>();
        Map<Id, FS_Installation__c> cifToNewInstall = new Map<Id, FS_Installation__c>();
        
        for(Id i : replacementToOtherInstalls.keySet()) {
            if(replacementToOtherInstalls.get(i).size() == 1) {
                Id cifId = replacementToOtherInstalls.get(i)[0].FS_CIF__c;
                if(cifId != null) {
                    cifToReplacement.put(cifId, replacements.get(i));
                    cifToNewInstall.put(cifId, replacementToOtherInstalls.get(i)[0]);
                }
            } else if(replacementToOtherInstalls.get(i).size() > 1) {
                for(FS_Installation__c install : replacementToOtherInstalls.get(i)) {
                    if(multipleInstalls.containsKey(i)) {
                        multipleInstalls.get(i).add(install);
                    } else {
                        multipleInstalls.put(i, new List<FS_Installation__c>{install});
                        multipleInstalls.get(i).add(replacements.get(i));
                    }                       
                }
            } else {
                replacementsWithoutInstalls.add(replacements.get(i));
            }
        }
        
        //handle single matches
        List<FS_Installation__c> newInstallsToUpdate = new List<FS_Installation__c>();
        List<FS_CIF__c> cifsToUpdate = [SELECT Id FROM FS_CIF__c WHERE Id IN :cifToReplacement.keySet()];
        for(FS_CIF__c cif : cifsToUpdate) {
            cif.FS_Does_Install_Involve_a_Replacement__c = 'Yes';
            cif.FS_Replacement_1__c = cifToReplacement.get(cif.Id).Id;
            FS_Installation__c newInst = cifToNewInstall.get(cif.Id);
            newInst.FS_Does_Install_Involve_a_Replacement__c = 'Yes';
            newInst.FS_Replacement_1__c = cifToReplacement.get(cif.Id).Id;
            newInstallsToUpdate.add(newInst);
        }
        
        Database.SaveResult[] cifResult = Database.update(cifsToUpdate, false);
        
        //get CIFs
        generateCSV(CIFCSVName, nameToCSV.get(CIFCSVName), cifsToUpdate);
        
        //CIF errors
        for(Integer i = 0; i < cifResult.size(); i++) {
            Database.SaveResult res = cifResult[i];
            if(!res.isSuccess()) {
                CIFErrors.put(cifsToUpdate[i].Id, String.valueOf(res.getErrors()));
                numFailCIFs++;
            }
        }
        System.debug('ERROR CIFErrors -->'+CIFErrors);
        Database.SaveResult[] installsResult = Database.update(newInstallsToUpdate, false);
        generateCSV(newInstallCSVName, nameToCSV.get(newInstallCSVName), newInstallsToUpdate);
        
        //get new installs
        for(Integer i = 0; i < installsResult.size(); i++) {
            Database.SaveResult res = installsResult[i];
            if(!res.isSuccess()) {
                newInstallErrors.put(newInstallsToUpdate[i].Id, String.valueOf(res.getErrors()));
                numFailNewInstalls++;
            }
        }
        System.debug('ERROR newInstallErrors -->'+newInstallErrors);
        //handle multiple and zero matches
        FS_Installation__c[] multipleInstallsList = new List<FS_Installation__c>();
        for(List<FS_Installation__c> install : multipleInstalls.values()) multipleInstallsList.addAll(install);
        generateCSV(multipleMatchesCSVName, nameToCSV.get(multipleMatchesCSVName), multipleInstallsList);
        generateCSV(zeroMatchesCSVName, nameToCSV.get(zeroMatchesCSVName), replacementsWithoutInstalls);
        System.debug('ERROR multipleInstallsList -->'+multipleInstallsList);
        System.debug('ERROR replacementsWithoutInstalls -->'+replacementsWithoutInstalls);
    }
    
    global void finish(Database.BatchableContext BC) {
        sendEmail();
    }
}