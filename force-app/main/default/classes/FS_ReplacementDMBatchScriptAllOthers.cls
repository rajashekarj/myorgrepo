//DM Batchable for FNF-828, catches all other Replacements
//Can be deleted once data migration is validated
global class FS_ReplacementDMBatchScriptAllOthers implements Database.Batchable<SObject>, Database.Stateful {
    private static final List<String> recipients = new List<String>{userInfo.getUserEmail(), 'jneufer@coca-cola.com'};
    
    private static String replacementCSVname = 'allOtherReplacements.csv';
            
    private String replacementCSV = '';
    private String CIFCSV = '';
    private String newInstallCSV = '';
    private static String multipleMatchesCSV = '';
    private static String zeroMatchesCSV = '';
    
    private Map<String, String> replacementErrors = new Map<String, String>();
    private Map<String, String> cifErrors = new Map<String, String>();
    private Map<String, String> newInstallErrors = new Map<String, String>();
    
    private static Map<String, List<String>> nameToCSV = new Map<String, List<String>>
    {'allOtherReplacements.csv' => new List<String>{'Id', 'FS_Same_Incoming_Platform__c', 'FS_Reason_Code__c', 'FS_Scheduled_Install_Date__c'},
     'cifs.csv' => new List<String>{'Id', 'FS_Does_Install_Involve_a_Replacement__c', 'FS_Replacement_1__c'}};
    
	private Integer numFailReplacements = 0;
    private Integer numFailCIFs = 0;
    private Integer numFailNewInstalls = 0;
    
    //csv vars
    List<String> columns = new List<String>();
    List<SObject> rows = new List<SObject>();
        
    global FS_ReplacementDMBatchScriptAllOthers() {}
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, FS_CIF__c, FS_Reason_Code__c, Outlet_ACN__c, FS_Scheduled_Install_Date__c, FS_Outlet__c, FS_Same_Incoming_Platform__c
                                         FROM FS_Installation__c
                                         WHERE RecordType.Name = 'Replacement'
                                         AND FS_Reason_Code__c NOT IN ('Platform Change', 'Change of Color', 'Bridge 9000 to 9100', 'Early Replacement 9000 to 9100')
                                         ORDER BY FS_Outlet__c]);
    }
    
    private void generateCSV(String fileName, String[] columns, SObject[] rows) {
        String csv;
        
        if(fileName == 'replacements.csv') {
            csv = replacementCSV;
        }
        
        String tempRow = '';
        for(SObject row : rows) {
            tempRow = '';
            for(String column : columns) {
                tempRow += row.get(column) + ',';
            }
            csv += endRow(tempRow);
        }
        
        if(fileName == 'allOtherReplacements.csv') {
            replacementCSV = csv;
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
            if(fileName == 'allOtherReplacements.csv') {
                csvAttach += replacementCSV;
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
            inst.FS_Same_incoming_platform__c = 'Yes';
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
    }
    
    global void finish(Database.BatchableContext BC) {
        sendEmail();
    }
}