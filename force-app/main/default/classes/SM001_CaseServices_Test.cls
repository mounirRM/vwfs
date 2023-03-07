@isTest
public class SM001_CaseServices_Test {
  @isTest
  public static void createDraftEmailWithDefaultTemplate() {
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
    ctra.Numero_de_contrat__c = '98989000LOA1';
    ctra.Name = '98989000LOA1';
    ctra.Compte_client_associe__c = a.Id;
    ctra.Contact_client_associe__c = ctc.Id;
    insert ctra;

    Case c0 = new Case();
    c0.Subject = 'ctr Test';
    c0.Status = 'Closed';
    c0.Contrat__c = ctra.id;
    c0.RecordTypeId = rtcaseid.id;
    c0.ContactId = ctra.Contact_client_associe__c;
    c0.AccountId = a.id;
    c0.Priority = 'Low';
    c0.Origin = 'Web';
    c0.Equipe__c = 'Acceptation Annexes';
    c0.Motif__c = 'Divers';
    insert c0;

    SM001_CaseServices.createDraftEmailWithDefaultTemplate(c0.Id);
  }
}