global class BatchContratCaseCampaignClose implements Database.Batchable<sObject>,Database.Stateful {
    global String numOfAlertCreated;
	global String numOfAlertClosed;
  List<String> listStatus = new List<String>{
    'Closed',
    'Résolue',
    'Requête déjà traitée (doublon)',
    'Fusionée'
  };
  List<String> listcodestatus = new List<String>{
    'RECAMIT',
    'RCONT',
    'RBDFT',
    'RRACRT',
    'RPPT',
    'TREG',
    'TRECAMIT',
    'TCONT'
  };

  List<Case> objToUpdate = new List<Case>();
  Id impRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
    .get('Gestion d’impayé')
    .getRecordTypeId();

  global Database.QueryLocator start(Database.BatchableContext bc) {

    String query =
      'SELECT Id, status,RecordTypeid, CreatedDate,caseClosedByBatch__c, toCloseDoublon__c FROM Case WHERE ' +
      'RecordTypeid=:impRecordTypeId AND ' +
      'Status NOT IN :listStatus AND ' +
      '(Code_statut_contrat__c IN :listcodestatus OR ' +
      'toCloseDoublon__c = true)';

    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext sc, List<sObject> scope) {
    List<Case> caseList = (List<Case>) scope;

    for (Case ca : caseList) {
      /*if (ca.toCloseDoublon__c) {
        ca.status = 'Requête déjà traitée (doublon)';
        objToUpdate.add(ca);
      } else {*/
        ca.status = 'Closed';
        ca.caseClosedByBatch__c = true;
        objToUpdate.add(ca);
      //}
    }
    //numOfAlertClosed = objToUpdate !=null?String.ValueOf(objToUpdate.size()):'0';
    System.debug('objToUpdate = ' + objToUpdate);
    Database.update(objToUpdate, false);
    System.debug('objToUpdate = ' + objToUpdate);
      System.debug('numOfAlertClosed = ' + numOfAlertClosed);
  }
  
  global void finish(Database.BatchableContext bc) {
        System.debug('objToUpdate = ' + objToUpdate);
        //String numOfAlertClosed = objToUpdate !=null?String.ValueOf(objToUpdate.size()):'0';
        System.debug('numOfAlertClosed:'+numOfAlertClosed);
        System.debug('numOfAlertCreated:'+numOfAlertCreated);
        //AP_FollowUpBatchAlert.sendSummary(numOfAlertCreated,numOfAlertClosed);
    }
}