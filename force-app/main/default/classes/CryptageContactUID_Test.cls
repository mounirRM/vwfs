@isTest
public class CryptageContactUID_Test {
    static final String UIDCONTACT='uidcontactid';
    @isTest
    public static void encrypt(){
       List<id> listcont= new List<id>();
        Contact c = new Contact(LastName='Test Contact',UID__c=UIDCONTACT,OptinQuestionnaireSatisfaction__c=true);
        insert c;
        listcont.add(c.id);
        CryptageContactUID.encrypt(listcont);
        SurveyOptout.clearOptOutField(UIDCONTACT);
 }

}