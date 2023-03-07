@isTest
public class FR_TestDataFactory {
    
    public static Case createCase(String status, Id ownerId, String origin, String equipe, String motif){
        Case testCase = new Case(Status=status, OwnerId=ownerId,Origin =origin, Equipe__c=equipe, Motif__c=motif);
		insert testCase;
        return testCase;
    }
    
    public static Case createCase(String status, Id ownerId, String origin, String equipe, String motif, String sousMotif){
        Case testCase = new Case(Status=status, OwnerId=ownerId,Origin =origin, Equipe__c=equipe, Motif__c=motif, Sous_motif__c=sousMotif);
		insert testCase;
        return testCase;
    }
    
	public static EmailMessage createEmail(String cseId,String lieuOuChercher,String valeurExpression){
        EmailMessage email = new EmailMessage();
        email.ToAddress = 'rcfleet-uat@vwfs.com';
        email.incoming=true;
        switch on lieuOuChercher{
            when 'Objet'{
                email.Subject = 'Test Contrat ' + valeurExpression;
                email.TextBody = 'le corps du mail ';
            }
            when 'Corps'{
                email.Subject = 'Test Contrat ';
                email.TextBody = 'le corps du mail et le mot ' + valeurExpression;
            }
            when 'Objet/Corps'{
                email.Subject = 'Test Contrat ' + valeurExpression;
                email.TextBody = 'le corps du mail et le mot ' + valeurExpression;
            }
        }
        email.ParentId = cseId;
        insert email;
        return email;
      }

}