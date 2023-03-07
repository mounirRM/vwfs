@IsTest
public class AP001_EmailServiceTester_TEST {
    
@isTest static void TestEmailService() {
    
    Recordtype rtcaseid=[select id,DeveloperName from recordtype where DeveloperName='Requ_te_standard' limit 1 ];
    Recordtype rtaccid=[select id,DeveloperName from recordtype where DeveloperName='ClientB2B' limit 1 ];
    // setup controller object
        AP001_EmailServiceTester objconfirm = new AP001_EmailServiceTester();
        System.debug('Im starting a method');
    
    //créer le compte B2B
         Account acct = new Account();
         acct.Name='Test1';
         acct.RecordTypeId=rtaccid.id;
         insert acct;
    
    //créer le case. Champs obligatoires : Equipe__c, Motif__c, Sous_motif__c
         Case cas = new Case();
         cas.Subject = 'ctar Test';  
         cas.Description = 'myPlainTexttest';
         cas.RecordTypeId=rtcaseid.id;  
         cas.Date_d_ch_ance__c= date.parse('02/04/2022'); 
         cas.Status ='A traiter';
         cas.AccountId= acct.id;
         cas.Priority = 'Low';
         cas.Origin = 'Email';
         cas.Equipe__c = 'Recouvrement - Retail';
         cas.Motif__c = 'Amiable';
         cas.Sous_motif__c = 'Amende';
         insert cas;
    
    
     // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        objconfirm.handleInboundEmail(email, envelope);
        
        email.subject = cas.Subject;
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
        envelope.fromAddress = 'maf@cloudsocius.com';
    
    
  }
}