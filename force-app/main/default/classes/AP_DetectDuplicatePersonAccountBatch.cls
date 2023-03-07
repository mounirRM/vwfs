public class AP_DetectDuplicatePersonAccountBatch implements Database.Batchable<sObject>, Database.Stateful,schedulable{
    public Set<Account> duplicateAccountsCreatedByRefSet = new Set<Account>();
    public Set<Account> duplicateAccountsNotCreatedByRefSet = new Set<Account>();
   public Database.QueryLocator start(Database.BatchableContext BC){
       String Query = 'SELECT Id,Name,IsPersonAccount,FirstName,LastName,Date_de_naissance__c,ShippingPostalCode FROM Account WHERE IsPersonAccount = true and createdby.Name =\'ref360\' and Date_de_naissance__c!=null and (CreatedDate=TODAY OR CreatedDate=YESTERDAY)';
      return Database.getQueryLocator(query);
   }
    public void execute(SchedulableContext sc){
    AP_DetectDuplicatePersonAccountBatch b = new AP_DetectDuplicatePersonAccountBatch();
       database.executeBatch(b,200);
    }
    
    public void execute(Database.BatchableContext BC,List<Account> scope){
        for(Account paRef : [SELECT Id,Name,IsPersonAccount,FirstName,LastName,Date_de_naissance__c,ShippingPostalCode FROM Account where IsPersonAccount = true AND createdby.Name !='ref360' and Date_de_naissance__c!=null]){
            for(Account ref : scope){
                if(paRef.FirstName.equalsIgnoreCase(ref.FirstName) 
                   && paRef.LastName.equalsIgnoreCase(ref.LastName) 
                   && paRef.Date_de_naissance__c == ref.Date_de_naissance__c){
                       system.debug('ref :'+ref);
                       system.debug('paRef :'+paRef);
                    duplicateAccountsCreatedByRefSet.add(ref);
                    duplicateAccountsNotCreatedByRefSet.add(paRef);
                }
            }
        }
        system.debug('duplicateAccountsCreatedByRefSet :'+duplicateAccountsCreatedByRefSet);
        system.debug('duplicateAccountsNotCreatedByRefSet :'+duplicateAccountsNotCreatedByRefSet);
    }
 
    public void finish(Database.BatchableContext BC){
        List<Account> duplicateAccountsNotCreatedByRef = new List<Account>();
        duplicateAccountsNotCreatedByRef.addAll(duplicateAccountsNotCreatedByRefSet);
        system.debug('duplicateAccountsCreatedByRefSet final:'+duplicateAccountsCreatedByRefSet);
        system.debug('duplicateAccountsNotCreatedByRefSet final:'+duplicateAccountsNotCreatedByRefSet);
        AP_DetectDuplicatePersonAccount.replaceOldPersonAccountByNew(duplicateAccountsNotCreatedByRefSet,duplicateAccountsCreatedByRefSet);
		delete duplicateAccountsNotCreatedByRef;
    }
}