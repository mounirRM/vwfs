public class SM001_AccountServices {
    @future
    public static void computeBERsField (set<Id> accountIds){
                        System.debug(accountIds);

        List<Account> accounts = [SELECT  Id,BERs__c, (Select name from BERs__r order by name DESC) From account where Id IN :accountIds];
                System.debug(accounts);

        for(Account a : accounts){
            a.BERs__c='';
            for(BER__c b :  a.BERs__r)
             IF(!a.BERs__c.contains(b.Name)) 
      a.BERs__c+=b.Name +' ';
        }
        
        update accounts;
    }
}