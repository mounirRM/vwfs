public class SM001_CaseServices {
    public static boolean createDraftEmailWithDefaultTemplate(Id recordId){
        EmailTemplate template= [SELECT Id, DeveloperName, Name FROM EmailTemplate WHERE TemplateType='Visualforce' LIMIT 1];
        Case record=[SELECT id,ContactId,Contrat__c FROM Case WHERE Id=:recordId];
            
            Messaging.SingleEmailMessage sEMsg = 
            Messaging.renderStoredEmailTemplate(String.valueOf(template.Id),
                                                String.valueOf (record.ContactId),
                                                recordId);
        
        EmailMessage eMsg=new EmailMessage(FromAddress=UserInfo.getUserEmail(),
            							   Subject=sEMsg.getSubject(), 
                                           HtmlBody=sEMsg.getHtmlBody(), 
                                           ToIds= new String[]{record.ContactId},
                                           MessageDate=system.now(), 
                                           ParentId=recordId, 
                                           Incoming=false,
                                           Status='5');
        insert eMsg;
        
        return false;
    }
}