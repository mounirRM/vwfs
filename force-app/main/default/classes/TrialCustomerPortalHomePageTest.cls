@IsTest
public class TrialCustomerPortalHomePageTest {

    @testSetup public static void setup(){
       Account myaccount = new Account(
            Name = 'My Account'
        );     
        insert myaccount; 
        Contact myContact = new Contact(
            Firstname = 'New Contact',
            Lastname = 'Contact Lastname'
        );
        insert myContact;      
    }
    
    @isTest public static void SortProductsTest(){    
        // query the contact    
        Contact myContact = [SELECT Id FROM Contact LIMIT 1];
    
        Test.startTest();
		TrialCustomerPortalHomePageController trialCustomer = new TrialCustomerPortalHomePageController();
        trialCustomer.sortField1 = 'test';
        trialCustomer.previousSortField1 = 'test';
        trialCustomer.previousSortField4 = 'test';
        trialCustomer.sortField4 = 'test';
        trialCustomer.previousSortField3 = 'test';
        trialCustomer.sortField3 = 'test';
        trialCustomer.previousSortField2 = 'test';
        trialCustomer.sortField2 = 'test';
        Test.stopTest();

    } 
}