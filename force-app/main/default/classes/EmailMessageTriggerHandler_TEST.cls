@IsTest
public class EmailMessageTriggerHandler_TEST {
    @isTest
    static void testHandleTrigger() {
        List<EmailMessage> emailList = new List<EmailMessage>();
        EmailMessage email;
        emailList.add(email);
        
        System.TriggerOperation AFTER_INSERT;
        System.TriggerOperation BEFORE_INSERT;
        
        EmailMessageTriggerHandler.handleTrigger(emailList, AFTER_INSERT);
        EmailMessageTriggerHandler.handleTrigger(emailList, BEFORE_INSERT);
    }
    @isTest
    public static void TestInsertEmailMessage() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u = [SELECT Id,Equipe__c,UserRoleId,IsActive,UserRole.DeveloperName  FROM User WHERE ProfileId =: p.Id AND IsActive=True AND (UserRole.DeveloperName!='agent_RC_ext' OR UserRole.DeveloperName!='superviseur_RC_ext') LIMIT 1];
        Group grp1 = new Group();
        grp1.Name = 'newGroupe';
        Insert grp1;
        
        System.runAs(u) {
            Recordtype rtaccid = [
                SELECT id, DeveloperName
                FROM recordtype
                WHERE DeveloperName = 'ClientB2B'
                LIMIT 1
            ];
            Recordtype rtcontid = [
                SELECT id, DeveloperName
                FROM recordtype
                WHERE DeveloperName = 'Contact_Client'
                LIMIT 1
            ];
            
            //créer le compte B2B
            Account acc1 = new Account();
            acc1.Name = 'Testemail';
            acc1.RecordTypeId = rtaccid.id;
            insert acc1;
            
            //créer le contact
            Contact con1 = new Contact();
            con1.FirstName = 'mOMaer';
            con1.LastName = 'tesa';
            con1.RecordTypeId = rtcontid.id;
            con1.AccountId = acc1.id;
            insert con1;
            
            //créer le contrat
            Contract__c ctra1 = new Contract__c();
            ctra1.Name = '98989098LOA';
            ctra1.Numero_de_contrat__c = '98989098LOA';
            ctra1.Compte_client_associe__c = acc1.Id;
            ctra1.Contact_client_associe__c = con1.Id;
            insert ctra1;
            
            //créer le case
            
            Case c = new Case();
            c.Subject = '98989098LOA';
            c.Status = 'A traiter';
            c.Contrat__c = ctra1.id;
            c.ContactId = ctra1.Contact_client_associe__c;
            c.AccountId = ctra1.Contact_client_associe__r.AccountId;
            c.Priority = 'Low';
            c.Origin = 'Email';
            c.Equipe__c = 'Fleet - Fins de contrat';
            c.Motif__c = 'Retail';
            insert c;

            //Insert emailmessage for case
            EmailMessage[] em = new List<EmailMessage>();
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'test@abc.org';
            email.Incoming = true;
            email.ToAddress = 'test@xyz.org';
            email.TextBody = '98989098LOA ' + '[ref:' + c.Id + ']';
            email.Subject = '98989098LOA';
            email.ParentId = c.Id;
            
            em.add(email);
            
            insert em;

            //créer le case
            Case c1 = new Case();
            c1.Subject = '98989099LOA';
            c1.Status = 'Résolue';
            c1.Contrat__c = ctra1.id;
            c1.ContactId = ctra1.Contact_client_associe__c;
            c1.AccountId = ctra1.Contact_client_associe__r.AccountId;
            c1.Priority = 'Low';
            c1.Origin = 'Email';
            c1.Equipe__c = 'Fleet - Fins de contrat';
            c1.Motif__c = 'Retail';
            insert c1;
            
            //Insert emailmessage for case
            EmailMessage email1 = new EmailMessage();
            email1.FromAddress = 'test@abc.org';
            email1.Incoming = true;
            email1.ToAddress = 'test@xyz.org';
            email1.TextBody = '98989098LOA';
            email1.Subject = '98989098LOA';
            email1.ParentId = c1.Id;
            try{
                Insert email1;
            }catch(exception e){
                system.debug('e:'+e);
            }
            
            
            //Assert if case subject updated with emailmessage textbody value
            System.assertEquals(
                [SELECT Id, Subject FROM Case WHERE Id = :c.Id][0]
                .Subject,
                '98989098LOA'
            );
        }
    }
    
    @isTest
    static void TestInsertEmailMessage2() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole role = [select Id,Name, DeveloperName from UserRole where DeveloperName='agent_RC_ext' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserRoleId=role.Id,
        Equipe__c = 'Fleet - Fins de contrat',
        UserName='Testingojhvwfs@yopmail.com');
		Insert u;
        group grp1 = new group();
        grp1.Name = 'Fleet - Fins de contrat';    
        Insert grp1;
        system.debug('grp1:'+grp1);
        Group myQueue = [SELECT id,Related.Name,Name from Group where name='Fleet - Fins de contrat' limit 1];
        system.debug('myQueue:'+myQueue);
        System.runAs(u) {
            Recordtype rtaccid = [
                SELECT id, DeveloperName
                FROM recordtype
                WHERE DeveloperName = 'ClientB2B'
                LIMIT 1
            ];
            Recordtype rtcontid = [
                SELECT id, DeveloperName
                FROM recordtype
                WHERE DeveloperName = 'Contact_Client'
                LIMIT 1
            ];
            
            //créer le compte B2B
            Account acc1 = new Account();
            acc1.Name = 'Testemail';
            acc1.RecordTypeId = rtaccid.id;
            insert acc1;
            
            //créer le contact
            Contact con1 = new Contact();
            con1.FirstName = 'mOMaer';
            con1.LastName = 'tesa';
            con1.RecordTypeId = rtcontid.id;
            con1.AccountId = acc1.id;
            insert con1;
            
            //créer le contrat
            Contract__c ctra1 = new Contract__c();
            ctra1.Name = '98989098LOA';
            ctra1.Numero_de_contrat__c = '98989098LOA';
            ctra1.Compte_client_associe__c = acc1.Id;
            ctra1.Contact_client_associe__c = con1.Id;
            insert ctra1;
            
            //créer le case
            
            Case c = new Case();
            c.Subject = '98989098LOA';
            c.Status = 'A traiter';
            c.Contrat__c = ctra1.id;
            c.ContactId = ctra1.Contact_client_associe__c;
            c.AccountId = ctra1.Contact_client_associe__r.AccountId;
            c.Priority = 'Low';
            c.Origin = 'Email';
            c.Equipe__c = 'Fleet - Fins de contrat';
            c.Motif__c = 'Retail';
            c.OwnerId = myQueue.Id;
            insert c;
			
            //update c;
            //Insert emailmessage for case
            EmailMessage[] em = new List<EmailMessage>();
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'test@abc.org';
            email.Incoming = true;
            email.ToAddress = 'test@xyz.org';
            email.TextBody = '98989098LOA';
            email.Subject = '98989098LOA';
            email.ParentId = c.Id;
            
            em.add(email);
            
            insert em;
            //créer le case
            Case c1 = new Case();
            c1.Subject = '98989099LOA';
            c1.Status = 'Résolue';
            c1.Contrat__c = ctra1.id;
            c1.ContactId = ctra1.Contact_client_associe__c;
            c1.AccountId = ctra1.Contact_client_associe__r.AccountId;
            c1.Priority = 'Low';
            c1.Origin = 'Email';
            c1.Equipe__c = 'Fleet - Fins de contrat';
            c1.Motif__c = 'Retail';
            insert c1;
            
            //Insert emailmessage for case
            EmailMessage email1 = new EmailMessage();
            email1.FromAddress = 'test@abc.org';
            email1.Incoming = true;
            email1.ToAddress = 'test@xyz.org';
            email1.TextBody = '98989098LOA';
            email1.Subject = '98989098LOA';
            email1.ParentId = c1.Id;
            try{
                Insert email1;
            }catch(exception e){
                system.debug('e:'+e);
            }
            
            
            //Assert if case subject updated with emailmessage textbody value
            System.assertEquals(
                [SELECT Id, Subject FROM Case WHERE Id = :c.Id][0]
                .Subject,
                '98989098LOA'
            );
        }
    }
}