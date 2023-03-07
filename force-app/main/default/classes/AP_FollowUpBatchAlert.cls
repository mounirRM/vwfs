public class AP_FollowUpBatchAlert {
    public static void sendSummary(string numOfAlertCreated,string numOfAlertClosed) {
        system.debug('In sendSummary');
        List<String> emailaddresses = new List<String>();
        String fromAdress = '';
        Map<String, BatchAlertFollowUpEmails__mdt> batchAlerts = BatchAlertFollowUpEmails__mdt.getAll();
        for(BatchAlertFollowUpEmails__mdt bt : batchAlerts.values()){
            if(bt.Type__c == 'TO'){
                emailaddresses.add(bt.Email__c);
            }else if(bt.Type__c == 'FROM'){
                fromAdress = bt.Email__c;
            }
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        //emailaddresses.add('oumesh.jhundoo.externe@capgemini.com');
        //mail.setTargetObjectId(userinfo.getUserId()); 
        //mail.setTemplateId(templateId); 
        //mail.setWhatId('objId'); 
        //mail.setPlainTextBody('Number of Alert Created on '+Date.today()+' is :'+numOfAlertCreated+'\n'+'Number of Alert closed on '+Date.today()+' is :'+numOfAlertClosed+'\n'
                              //+'Test Envoie Email pour le Batch d alert => En cours'+':)'+':)'+':)');
        mail.setHtmlBody(emailBody(numOfAlertCreated,numOfAlertClosed));
        //mail.setSubject('email body');
        //setInReplyTo(parentMessageIds)
        mail.setToAddresses(emailaddresses);
        if(!Test.isRunningTest()){
            mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address =:fromAdress LIMIT 1].Id);
        }
        mail.setSaveAsActivity(false); 
        if(!Test.isRunningTest())
        {
            system.debug('inside send mail');
            system.debug('mail :'+mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }  
        system.debug('OUT sendSummary');        
    }
    
    public static String emailBody(string numOfAlertCreated,string numOfAlertClosed) {
        String emailBody = '';
        if(numOfAlertCreated =='0' || numOfAlertCreated ==null){
            numOfAlertCreated = '<h1 style="color:red;">0</h1>';
        }
        if(numOfAlertClosed =='0' || numOfAlertClosed ==null){
            numOfAlertClosed = '<h1 style="color:red;">0</h1>';
        }
        emailBody = 'Bonjour,<br><br>'+
            		'L’execution de Batch d’Alert viens de terminer<br><br>'+
            		'Le nombres d’Alert crees : '+numOfAlertCreated+'</b><br><br>'+
            		'Le nombres d’Alert cloturer : '+numOfAlertClosed+'</b><br><br>'+
            		'** Ceci est un e-mail récurrent **<br><br>'+
            		'** cet e-mail vous sera envoyé tous les jours après l\'exécution du Batch d’Alert**<br><br>';
        return emailBody;
        
    }
}