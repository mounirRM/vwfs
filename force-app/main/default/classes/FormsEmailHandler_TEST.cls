@isTest
public class FormsEmailHandler_TEST {
  @isTest
  static void test1() {
    Recordtype rtcaseid = [
      SELECT id, DeveloperName
      FROM recordtype
      WHERE DeveloperName = 'Requ_te_standard'
      LIMIT 1
    ];
    Account a = new Account(Name = 'account');
    insert a;
    Contact ctc = new Contact(
      firstName = 'John',
      lastName = 'Doe',
      email = 'john@doe.com'
    );

    insert ctc;

    Contract__c ctra = new Contract__c();
    ctra.Numero_de_contrat__c = '98987000LOA0';
    ctra.Immatriculation__c = 'AB-123-CD';
    ctra.Name = '98987000LOA0';
    ctra.Compte_client_associe__c = a.Id;
    ctra.Contact_client_associe__c = ctc.Id;
    insert ctra;

    Contract__c ctra2 = new Contract__c();
    ctra2.Numero_de_contrat__c = '98989000LOA0';
    ctra2.Name = '98989000LOA0';
    ctra2.Compte_client_associe__c = a.Id;
    ctra2.Contact_client_associe__c = ctc.Id;
    insert ctra2;

    Contract__c ctra3 = new Contract__c();
    ctra3.Numero_de_contrat__c = '96989000LOA0';
    ctra3.Numero_de_chassis__c = 'ABCDEFGHIJKLMN123';
    ctra3.Name = '96989000LOA0';
    ctra3.Compte_client_associe__c = a.Id;
    ctra3.Contact_client_associe__c = ctc.Id;
    insert ctra3;

    Case c0 = new Case();
    c0.Subject = 'ctr Test';
    c0.Status = 'Closed';
    c0.Contrat__c = ctra.id;
    c0.RecordTypeId = rtcaseid.id;
    c0.ContactId = ctra.Contact_client_associe__c;
    c0.AccountId = a.id;
    c0.Priority = 'Low';
    c0.Origin = 'Email';
    c0.Equipe__c = 'Acceptation Annexes';
    c0.Motif__c = 'Divers';
    insert c0;

    Test.startTest();
    Messaging.Inboundemail.TextAttachment att = new Messaging.Inboundemail.TextAttachment();
    ContentVersion cVersions = new ContentVersion();
    cVersions.title = 'Test title';
    cVersions.VersionData = blob.valueof('New Bitmap Image.bmp');
    cVersions.ContentLocation = 'S';
    cVersions.Origin = 'H';
    cVersions.PathOnClient = 'ContentAgreement1.pdf';

    insert cVersions;
    /*ContentDocumentLink cdl = new ContentDocumentLink( LinkedEntityId = c0.Id, ShareType= 'V');
     insert cdl;*/

    ContentDocumentLink contentlink = new ContentDocumentLink();
    contentlink.LinkedEntityId = c0.id;
    contentlink.contentdocumentid = [
      SELECT contentdocumentid
      FROM contentversion
      WHERE id = :cVersions.id
    ]
    .contentdocumentid;
    contentlink.ShareType = 'I';
    contentlink.Visibility = 'AllUsers';

    insert contentlink;
    Test.setFixedSearchResults(new List<Id>{ ctc.id });

    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    email.subject = 'RE: Autorisation de prélèvement de solde 12345678LLD0';
    email.toAddresses = (new List<String>{ 'web@forms.com' });
    env.fromAddress = 'user@acme.com';

    email.plainTextBody = 'Autorisation de prélèvement de solde\nNuméro de contrat : 98989000LOA\nCivilité : Mme.\nNom : KARACA\nPrénom : SUKRIYE\nDate de naissance : 22/08/1983\nE-mail : karacasukriye@hotmail.fr\nNuméro de téléphone portable : 0613872786\nMarque Véhicule : Volkswagen\n\nJe soussigné(e) : SUKRIYE KARACA\nNuméro de contrat : 98989000LOA\nMontant du solde : 2528.73\n\nMotif du solde : Revente du véhicule\nPrécision réponse \"autre\" :';

    Messaging.InboundEmail email1 = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
    email1.subject = 'RE: Autorisation de prélèvement de solde test AB-123-CD';
    email1.toAddresses = (new List<String>{ 'web@forms.com' });
    env1.fromAddress = 'useracme.com';

    email1.plainTextBody = 'xml "é"A \nNuméro de contrat : AB-123-CD';

    Messaging.InboundEmail email2 = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
    email2.subject = 'RE: Autorisation de prélèvement de solde test ABCDEFGHIJKLMN123';
    email2.toAddresses = (new List<String>{ 'web@forms.com' });
    env2.fromAddress = 'useracme.com';

    email2.plainTextBody = 'Numéro de contrat : ABCDEFGHIJKLMN123';

    (new FormsEmailHandler()).handleInboundEmail(email, env);
    (new FormsEmailHandler()).handleInboundEmail(email1, env1);
    (new FormsEmailHandler()).handleInboundEmail(email2, env2);

    System.assertEquals([SELECT id FROM case].isEmpty(), false);
    System.assertEquals([SELECT id FROM EmailMessage].isEmpty(), false);
    System.assertEquals(
      [SELECT ContentDocumentId, id FROM ContentVersion].isEmpty(),
      false
    );

    Test.stopTest();
  }
}