public class BERTriggerHandler {
    
    public static void  handleTrigger(List<BER__c> TriggerNew, Map<Id,BER__c> TriggerOldMap , System.TriggerOperation triggerEvent){
        Set<id> accounts = New Set<id>();
        
        switch on triggerEvent {
            when AFTER_INSERT {
                for(Ber__c b : TriggerNew){
                    accounts.add(b.Compte_partenaire_associe__c);
                }
            }
            
            when AFTER_UPDATE {
                for(Ber__c b : TriggerNew){
                    if(b.Compte_partenaire_associe__c != TriggerOldMap.get(b.Id).Compte_partenaire_associe__c){
                        accounts.add(b.Compte_partenaire_associe__c);
                        accounts.add(TriggerOldMap.get(b.Id).Compte_partenaire_associe__c);
                    }
                }
            }
            
            when AFTER_DELETE {
                for(Ber__c b : TriggerOldMap.values()){
                    accounts.add(b.Compte_partenaire_associe__c);
                }
            }
        }
        System.debug(accounts);
        
        SM001_AccountServices.computeBERsField(accounts);        
    }
}