@IsTest
public class BatchContratCaseCampaignCreate_TEST {
  @isTest
  static void TestBatch() {
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
    Recordtype impRecordTypeId = [
      SELECT id, DeveloperName
      FROM recordtype
      WHERE DeveloperName = 'Gestion_d_impay'
      LIMIT 1
    ];
    //créer le compte B2B
    Account accnt = new Account();
    accnt.Name = 'TestBatche';
    accnt.RecordTypeId = rtaccid.id;
    insert accnt;

    //créer le contact
    Contact cont = new Contact();
    cont.FirstName = 'Contact';
    cont.LastName = 'batch';
    cont.RecordTypeId = rtcontid.id;
    cont.AccountId = accnt.id;
    insert cont;

    //créer le contrat
    List<Contract__c> insertcontrat = new List<Contract__c>();
    Contract__c ctrt = new Contract__c();
    ctrt.Name = '12341234LLD';
    ctrt.Code_statut_contrat__c = 'RECAMI';
    ctrt.Compte_client_associe__c = accnt.ID;
    ctrt.Contact_client_associe__c = cont.Id;
    ctrt.Produit_financier__c = 'LLD';
    ctrt.Numero_de_contrat__c = '12341234LLD';
    ctrt.Date_de_l_alerte__c = date.today();//date.parse('07/04/2022');
    insertcontrat.add(ctrt);

    Contract__c ctrt2 = new Contract__c();
    ctrt2.Name = '123411134LOA';
    ctrt2.Code_statut_contrat__c = 'TPCX';
    ctrt2.Compte_client_associe__c = accnt.ID;
    ctrt2.Contact_client_associe__c = cont.Id;
    ctrt2.Produit_financier__c = 'LOA';
    ctrt2.Numero_de_contrat__c = '123411134LOA';
    insertcontrat.add(ctrt2);

    Contract__c ctrt3 = new Contract__c();
    ctrt3.Name = '12341224LLD';
    ctrt3.Code_statut_contrat__c = 'RCONO';
    ctrt3.Compte_client_associe__c = accnt.ID;
    ctrt3.Contact_client_associe__c = cont.Id;
    ctrt3.Produit_financier__c = 'LLD';
    ctrt3.Numero_de_contrat__c = '12341224LLD';
    insertcontrat.add(ctrt3);

    Contract__c ctrt4 = new Contract__c();
    ctrt4.Name = '12341224CRE';
    ctrt4.Code_statut_contrat__c = 'BDFREC';
    ctrt4.Compte_client_associe__c = accnt.ID;
    ctrt4.Contact_client_associe__c = cont.Id;
    ctrt4.Produit_financier__c = 'CRE';
    ctrt4.Numero_de_contrat__c = '12341224CRE';
    ctrt4.Date_de_l_alerte__c = date.parse('12/04/2022');
    insertcontrat.add(ctrt4);

    Contract__c ctrt5 = new Contract__c();
    ctrt5.Name = '12341224CRB';
    ctrt5.Code_statut_contrat__c = 'RLJ';
    ctrt5.Compte_client_associe__c = accnt.ID;
    ctrt5.Contact_client_associe__c = cont.Id;
    ctrt5.Produit_financier__c = 'CRB';
    ctrt5.Numero_de_contrat__c = '12341224CRB';
    ctrt5.Date_de_l_alerte__c = date.parse('10/04/2022');
    insertcontrat.add(ctrt5);

    Contract__c ctrt6 = new Contract__c();
    ctrt6.Name = '12348924CRB';
    ctrt6.Code_statut_contrat__c = 'RLJ';
    ctrt6.Compte_client_associe__c = accnt.ID;
    ctrt6.Contact_client_associe__c = cont.Id;
    ctrt6.Produit_financier__c = 'CRB';
    ctrt6.Numero_de_contrat__c = '12348924CRB';
    ctrt6.Date_de_l_alerte__c = date.parse('10/04/2022');
    insertcontrat.add(ctrt6);
    insert insertcontrat;

    //créer le case
    List<Case> insertcase = new List<Case>();
    Case ca = new Case();
    Case ca2 = new Case();
    Case ca3 = new Case();
    Case ca4 = new Case();
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = true;
    ca.setOptions(dmo);
    ca.Subject = 'ctr Test';
    ca.RecordTypeId = impRecordTypeId.id;
    ca.Date_d_ch_ance__c = date.parse('10/04/2022');
    ca.Status = 'A traiter';
    ca.Contrat__c = ctrt.id;
    ca.AccountId = ctrt.Contact_client_associe__r.AccountId;
    ca.ContactId = ctrt.Contact_client_associe__c;
    ca.Priority = 'Low';
    ca.Origin = 'Gestion_d_impaye';
    ca.Equipe__c = 'Acceptation Annexes';
    ca.Motif__c = 'Divers';
    insertcase.add(ca);

    ca2.setOptions(dmo);
    ca2.Subject = 'ctr Test';
    ca2.RecordTypeId = impRecordTypeId.id;
    ca2.Date_d_ch_ance__c = date.parse('11/04/2022');
    ca2.Status = 'A traiter';
    ca2.Contrat__c = ctrt4.id;
    ca2.AccountId = ctrt4.Contact_client_associe__r.AccountId;
    ca2.ContactId = ctrt4.Contact_client_associe__c;
    ca2.Priority = 'Low';
    ca2.Origin = 'Gestion_d_impaye';
    ca2.Equipe__c = 'Acceptation Annexes';
    ca2.Motif__c = 'Divers';
    insertcase.add(ca2);

    ca4.setOptions(dmo);
    ca4.Subject = 'ctr Test';
    ca4.RecordTypeId = impRecordTypeId.id;
    ca4.Date_d_ch_ance__c = date.parse('10/04/2022');
    ca4.Status = 'Requête déjà traitée (doublon)';
    ca4.Equipe__c = 'Acceptation Annexes';
    ca4.Motif__c = 'Divers';
    ca4.Contrat__c = ctrt5.id;
    ca4.AccountId = ctrt5.Contact_client_associe__r.AccountId;
    ca4.ContactId = ctrt5.Contact_client_associe__c;
    ca4.Priority = 'Low';
    ca4.Origin = 'Gestion_d_impaye';
    insertcase.add(ca4);

    ca3.setOptions(dmo);
    ca3.Subject = 'ctr Test';
    ca3.RecordTypeId = impRecordTypeId.id;
    ca3.Date_d_ch_ance__c = date.parse('09/04/2022');
    ca3.Status = 'A traiter';
    ca3.Contrat__c = ctrt5.id;
    ca3.AccountId = ctrt5.Contact_client_associe__r.AccountId;
    ca3.ContactId = ctrt5.Contact_client_associe__c;
    ca3.Priority = 'Low';
    ca3.Origin = 'Gestion_d_impaye';
    ca3.Equipe__c = 'Acceptation Annexes';
    ca3.Motif__c = 'Divers';
    insertcase.add(ca3);

    insert insertcase;

    Test.startTest();
    BatchContratCaseCampaignCreate obj = new BatchContratCaseCampaignCreate();
    DataBase.executeBatch(obj);
    Test.stopTest();
  }
}