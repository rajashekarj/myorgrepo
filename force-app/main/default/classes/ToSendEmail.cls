public class ToSendEmail {
	public static void sendEmail(final List<Account> successOlts,final List<Account> failedOlts,final String finalstr,final String finalstr1)
    {
        final Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        final blob csvBlob = Blob.valueOf(finalstr);
        
        csvAttc.setFileName(FSConstants.CSVNAME);
        csvAttc.setBody(csvBlob);
        
        final Messaging.EmailFileAttachment csvAttc1 = new Messaging.EmailFileAttachment();
        final blob csvBlob1 = Blob.valueOf(finalstr1);
        
        csvAttc1.setFileName(FSConstants.CSVNAME1);
        csvAttc1.setBody(csvBlob1);
        final String[] toAddresses = new list<string>();
        
        final Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        final string userEmail = 'vishnu01@infosys.com';
        toaddresses.add(userEmail);
        
        email.setSubject(FSConstants.SUBJECT);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Hi, PFA list of Outlets processed in batch job');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc,csvAttc1});
        final Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        for(Messaging.SendEmailResult res:result)
        {
            if (res.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + res.errors[0].message);
            } 
        }
        
    }
}