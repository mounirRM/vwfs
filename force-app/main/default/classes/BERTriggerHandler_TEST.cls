@IsTest
public class BERTriggerHandler_TEST {
    @testSetup static void setup() {
      integer nbAccountACreer=10;
      integer nbBERparAccount=2;
      List<BER__c> BERS= new list <BER__c>();
      List<Account> accts = new List<Account>();
      for(Integer i=0;i<nbAccountACreer;i++) {
          Account a = new Account(Name='TestAccount' + i);
          accts.add(a);
      }
            insert accts;
            for (Integer j=0;j<nbAccountACreer;j++) {
                Account acct = accts[j];
                // For each account just inserted, add BERS
                for (Integer k=0;k<nbBERparAccount;k++) {
                    BERs.add(new BER__c(Name='BER_'+k+'_'+acct.Name,Compte_partenaire_associe__c=acct.Id));
                }
            }
            insert BERs;
    }
    public static void assertBersFieldIsOK(){
        List <Account> accts= [SELECT Id, BERs__c, (SELECT name FROM BERs__r ORDER BY name DESC) FROM Account];
        for(Account a:accts){
            String bers ='';
            if (a.BERs__r.size()==0)
                bers=null+' ';
            else{
                for (BER__c b:a.BERs__r)
                    bers+=b.name+' ';
            }
            system.debug(bers);
            System.assertEquals(bers,a.BERs__c+' ');            
        }
    }
    
    @IsTest
    public static void testCreateBER() {
      Test.startTest();
      Test.stopTest();
      assertBersFieldIsOK();
  }

  @IsTest
  public static void testDeleteBER() {
      List <BER__c> bers= [SELECT Id FROM BER__c LIMIT 4];
      DELETE bers;
      Test.startTest();
      Test.stopTest();
      assertBersFieldIsOK();
  }

  @IsTest
  public static void testUpdateBER() {
      List <BER__c> bers= [SELECT Id,Compte_partenaire_associe__c FROM BER__c LIMIT 4];
      for(integer i=1;i<4;i++){
          bers[i].Compte_partenaire_associe__c=bers[0].Compte_partenaire_associe__c;
      }
      UPDATE bers;
      Test.startTest();
      Test.stopTest();
      assertBersFieldIsOK();
  }
    
}