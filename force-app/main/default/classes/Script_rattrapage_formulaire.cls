global class Script_rattrapage_formulaire implements Database.Batchable<sObject> {
    
  global Database.QueryLocator start(Database.BatchableContext bc) {
      String query = 'SELECT id, Status, Subject, OwnerId, Owner.Name, Equipe__c, CreatedDate, Origin, CreatedBy.Name, LastModifiedBy.Name FROM Case WHERE (CreatedBy.Name LIKE \'Amal Lahm%\' OR CreatedBy.Name LIKE \'Samir Bouch%\') AND LastModifiedDate = TODAY AND Origin = \'Web\' AND IsClosed = false AND CreatedDate < 2022-11-29T18:00:00.000+01:00 AND Owner.Type = \'Queue\' AND (Owner.Name LIKE \'Fleet%\' OR Owner.Name LIKE \'Retail%\')';
      return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext sc, List<sObject> scope) {
      List<Case> listCaseToUpdate = (List<Case>) scope;
      List<Case> listCaseUpdated = new List<Case>();
      for (Case ca : listCaseToUpdate) {  
          ca.Status = 'Requête annulée (le client ne souhaite pas donner suite)';
          listCaseUpdated.add(ca);
      }
      update listCaseUpdated;
  }

  global void finish(Database.BatchableContext bc) {

  }
}