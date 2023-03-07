public without sharing class SurveyOptout {
    //************************************************************************** 
    // La méthode clearOptOutField() de cette classe permet uniquement
    // de mettre le champ "OptinQuestionnaireSatisfaction__c" du contact à FALSE
    //**************************************************************************
    @AuraEnabled
    public static void clearOptOutField(String v) {
        if(String.isEmpty(v))
            return;

        String uid=String.escapeSingleQuotes(v);
        System.debug('UID: '+uid);
        List<Contact> ctcs =[Select id,UID__c,OptinQuestionnaireSatisfaction__c from Contact where UID__c=:uid];

        if(!ctcs.isEmpty()){
            Contact ctc= ctcs.get(0);
        ctc.OptinQuestionnaireSatisfaction__c=false;
        System.debug('Contact found '+JSON.serialize(ctc));
        Database.SaveResult sr=Database.update(ctc,false);
            // Iterate through each returned result
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Contact. Contact ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Contact fields that affected this error: ' + err.getFields());
                }
            }
            System.debug('Contact Update END');
        }
    }
}