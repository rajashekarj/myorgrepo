trigger FS_FeedItemTrigger on FeedItem (after insert) {
    List<FeedAttachment> attachments =  [SELECT Id, Title, Type, FeedEntityId 
                                         FROM FeedAttachment 
                                         WHERE FeedEntityId IN :Trigger.new ];
     System.debug('attachments' + attachments);
    String forbiddenExt = Label.ForbiddenFiles;

    for (FeedAttachment attachment : attachments) {
       // String forbiddenExt = Label.ForbiddenFiles;
        System.debug(attachment.Type + ' , ' + attachment.Title);
         List<String> lststr = attachment.Title.split('\\.');
        String fileExt = lststr[lststr.size() - 1];
        if(forbiddenExt.contains(fileExt)) {
            trigger.new[0].addError(fileExt + ' File Type is not allowed');
        }
    }
}