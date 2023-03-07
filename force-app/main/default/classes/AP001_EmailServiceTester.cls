global with sharing class AP001_EmailServiceTester implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
        Messaging.InboundEnvelope env) {

        // Create an InboundEmailResult object for returning the result of the
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        String myPlainText = '';
        String myHTMLBody = '';

        // Add the email plain text into the local variable
        myPlainText = email.plainTextBody;
        myHTMLBody = email.htmlBody;

 
        // Try to look up any contacts based on the email from address
        // If there is more than one contact with the same email address,
        // an exception will be thrown and the catch statement will be called.
        try {
            /*System.debug('############## myPlainText : ' + myPlainText);
            System.debug('############## myHTMLBody : ' + myHTMLBody);

            Pattern myPattern = pattern.compile('([0-9]{10})'); 
            Matcher vMatcher = myPattern.matcher(myPlainText);

            if (vMatcher.find()) {
                System.debug('############## vValue : ' + vMatcher.group(0));
            }

            
            myPattern = pattern.compile('([0-9]{10})'); 
            Matcher vMatcherHTML = myPattern.matcher(myHTMLBody);
            if (vMatcherHTML.find()) {
                System.debug('############## vValue : ' + vMatcherHTML.group(0));
            }*/
            Case vCase = new CAse();
            vCase.Subject = 'Test Kiss the bride';
            vCase.Equipe__c = 'Recouvrement - Retail';
            vCase.Motif__c = 'Amiable';
            vCase.Sous_motif__c = 'Amende';
            vCase.Description = myPlainText;
            insert vCase;

        }
        // If an exception occurs when the query accesses
        // the contact record, a QueryException is called.
        // The exception is written to the Apex debug log.
        catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }

        // Set the result to true. No need to send an email back to the user
        // with an error message
        result.success = true;

        // Return the result for the Apex Email Service
        return result;
    }
}