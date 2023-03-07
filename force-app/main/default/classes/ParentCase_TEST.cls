@isTest
public class ParentCase_TEST {
  /*@isTest
  public static void getParentCaseId_TEST() {

    //EmailMessageTriggerHandler_TEST.TestInsertEmailMessage();
Test.startTest();
    Group queueId = [
      SELECT DeveloperName, Id, Name, Type
      FROM Group
      WHERE Type = 'Queue' AND Name = 'Partenaire-réseau'
      LIMIT 1
    ];
    Recordtype rtCaseId = [
        SELECT id, DeveloperName
        FROM recordtype
        WHERE DeveloperName = 'Requ_te_standard'
        LIMIT 1
    ];
Test.stopTest();
    List<Case> caseToInsert = new List<Case>();
    
    
    Case ca = new Case();
    ca.OwnerId = queueId.id;
    ca.Equipe__c = 'Partenaire-réseau';
    ca.Motif__c = 'Administratif';
    ca.Sous_motif__c = 'Amende';
    ca.Subject = 'ctr Test';
    ca.Status = 'En attente';
    ca.RecordTypeId = rtCaseId.id;
    ca.Priority = 'Low';
    ca.Origin = 'Email';
    
    insert ca;
    
    Case ca1 = new Case();
    ca1.OwnerId = queueId.id;
    ca1.Equipe__c = 'Partenaire-réseau';
    ca1.Motif__c = 'Administratif';
    ca1.Sous_motif__c = 'Amende';
    ca1.Subject = 'ctr Test';
    ca1.Status = 'Résolue';
    ca1.RecordTypeId = rtCaseId.id;
    ca1.Priority = 'Low';
    ca1.Origin = 'Email';
    ca1.ParentId = ca.Id;

    insert ca1;

    Case ca2 = new Case();
    ca2.OwnerId = queueId.id;
    ca2.Equipe__c = 'Partenaire-réseau';
    ca2.Motif__c = 'Administratif';
    ca2.Sous_motif__c = 'Amende';
    ca2.Subject = 'ctr Test';
    ca2.Status = 'En attente';
    ca2.RecordTypeId = rtCaseId.id;
    ca2.Priority = 'Low';
    ca2.Origin = 'Email';
    ca2.ParentId = ca1.Id;

    insert ca2;

    ca2.Status = 'Résolue';
    checkRecursive.firstcall = true;
    
    update ca2;

    Case ca3 = new Case();
    ca3.OwnerId = queueId.id;
    ca3.Equipe__c = 'Partenaire-réseau';
    ca3.Motif__c = 'Administratif';
    ca3.Sous_motif__c = 'Amende';
    ca3.Subject = 'ctr Test';
    ca3.Status = 'En attente';
    ca3.RecordTypeId = rtCaseId.id;
    ca3.Priority = 'Low';
    ca3.Origin = 'Email';
    ca3.ParentId = ca2.Id;

    insert ca3;

    Case ca4 = new Case();
    ca4.OwnerId = queueId.id;
    ca4.Equipe__c = 'Partenaire-réseau';
    ca4.Motif__c = 'Administratif';
    ca4.Sous_motif__c = 'Amende';
    ca4.Subject = 'ctr Test';
    ca4.Status = 'En attente';
    ca4.RecordTypeId = rtCaseId.id;
    ca4.Priority = 'Low';
    ca4.Origin = 'Email';
    ca4.ParentId = ca3.Id;

    insert ca4;

    ca4.Status = 'Résolue';
    checkRecursive.firstcall = true;

    update ca4;
  }*/
}