global with sharing class BatchCaseTMT implements Database.Batchable<sObject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, IsClosed FROM Case WHERE IsClosed = false';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope){
        CaseTriggerHandler.handleAfterUpdate(scope);
    }

    global void finish(Database.BatchableContext bc) {}
}