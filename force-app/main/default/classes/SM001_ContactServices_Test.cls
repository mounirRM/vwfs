@isTest
public class SM001_ContactServices_Test {
    @isTest
    public static void SurveyOptOut(){
        Contact c = new Contact(LastName='Test Contact',UID__c='UidTestClass00xCap',OptinQuestionnaireSatisfaction__c=true);
        insert c;
        SM001_ContactServices.clearOptOutField('UidTestClass00xCap');
        SM001_ContactServices.clearOptOutField('UidTestClass00xCap1');
        System.assertEquals(false,[Select OptinQuestionnaireSatisfaction__c from Contact WHERE UID__c='UidTestClass00xCap'][0].OptinQuestionnaireSatisfaction__c,'The OptinQuestionnaireSatisfaction__c field was not updated');  
   }

    @isTest
    public static void SurveyOptOutEmptyString(){
        Contact c = new Contact(LastName='Test Contact',UID__c='UidTestClass00xCap',OptinQuestionnaireSatisfaction__c=true);
        insert c;
        String emptyField;
        SM001_ContactServices.clearOptOutField(emptyField);
   }

}