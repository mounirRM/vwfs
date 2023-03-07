global class FormsEmailHandler implements Messaging.InboundEmailHandler {
  private static Integer CONTRACT_NUMBER_LENGTH = 12;

  Case cse;
  EmailMessage emsg;
  Contact ctc;
  Contract__c ctr;
  Messaging.inboundEmail email;
  String regexImmat = '( [A-Za-z]{1,3}[-_/. ]{0,1}[0-9]{2,4}[-_/. ]{0,1}[A-Za-z]{1,3})';
  String regexNumContrat = '( [0-9]{6,10}[A-Za-z]{0,3}[0-9]{0,1})';
  String regexChassis = '([A-Za-z0-9]{17})';

  /*
   *
   *
   *
   * */

  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.inboundEmail email,
    Messaging.InboundEnvelope env
  ) {
    this.email = email;
    System.debug('email = ' + email);
    boolean oldBypass = PAD.bypassAllTriggers;
    PAD.bypassAllTriggers = true;
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    initCaseAndEmailMessage(email);
    try {
      handleEmailMessage();
    } catch (Exception e) {
      System.debug(
        e.getTypeName() +
        '\n' +
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
    try {
      commitChanges();
    } catch (Exception e) {
      result.success = false;
      result.message = 'An error occured during the parsing of this form, please make sure that format matchs the form definition';
    }
    PAD.bypassAllTriggers = oldBypass;
    result.success = true;
    return result;
  }
  /*
   *
   *
   *
   * */
  public void handleEmailMessage() {
    String subject = emsg.Subject, body = '';
    if (emsg.TextBody != null)
      body = emsg.TextBody;
    else
      body = emsg.htmlBody.stripHtmlTags();
    System.debug('subject = ' + subject);
    System.debug('body = ' + body);

    //getting form name from subject
    String formName = subject.trim();
    if (formName.contains(':'))
      formName = formName.substringAfterLast(':').trim();

    //Removal contract/immat/chassis num from subject to match keywords for kiss the bride form as they sent form with contract num is the subject
    Pattern myPatternContrat = Pattern.compile(regexNumContrat);
    Pattern myPatternImmat = Pattern.compile(regexImmat);
    Pattern myPatternChassis = Pattern.compile(regexChassis);

    Matcher myMatcherContrat = myPatternContrat.matcher(formName);
    Matcher myMatcherImmat = myPatternImmat.matcher(formName);
    Matcher myMatcherChassis = myPatternChassis.matcher(formName);

    if (myMatcherContrat.find())
      formName = myPatternContrat.matcher(formName).replaceAll('');
    if (myMatcherImmat.find())
      formName = myPatternImmat.matcher(formName).replaceAll('');
    if (myMatcherChassis.find())
      formName = myPatternChassis.matcher(formName).replaceAll('');
    System.debug('formName = ' + formName);

    //Get the form
    List<Form__mdt> forms = [
      SELECT
        Equipe__c,
        CaseReason__c,
        CaseSubReason__c,
        Queue__c,
        ContractNumberLabel__c,
        ContactEmailLabel__c,
        Label,
        QualifiedApiName
      FROM Form__mdt
      WHERE Subject__c = :formName
      LIMIT 1
    ];

    if (forms.isEmpty())
      return;

    Form__mdt form = forms.get(0);
    System.debug(
      'Retrieved Form ' +
      '\nEquipe__c: ' +
      form.Equipe__c +
      '\nCaseReason__c: ' +
      form.CaseReason__c +
      '\nCaseSubReason__c: ' +
      form.CaseSubReason__c +
      '\nQueue__c: ' +
      form.Queue__c +
      '\nContactEmailLabel__c: ' +
      form.ContactEmailLabel__c
    );

    try {
      //getting the contact
      System.debug(form.ContactEmailLabel__c);
      String email = getValueForLabel(body, form.ContactEmailLabel__c)
        .substringBefore('<'); // to handle this kind of mails fanny.allal@kissthebride.fr<mailto:fanny.allal@kissthebride.fr>
      if (String.isNotBlank(email)) {
        List<Profile> profileId = [
          SELECT Id
          FROM Profile
          WHERE Name = 'Manager' OR Name = 'Agent'
        ];
        List<User> user = [
          SELECT Id
          FROM User
          WHERE Email LIKE :email AND ProfileId IN :profileId
          LIMIT 1
        ];
        if (user.isEmpty()) {
          System.debug('From address = ' + emsg.FromAddress);
          this.cse.SuppliedEmail = emsg.FromAddress;
          this.emsg.FromAddress = emsg.FromAddress;
          System.debug('### YRU from adress : ' + this.emsg.FromAddress);
          List<List<SObject>> searchResult = [
            FIND :email
            IN EMAIL FIELDS
            RETURNING Contact(id, AccountId)
          ];
          if (
            searchResult != null &&
            !searchResult.isEmpty() &&
            searchResult.get(0) != null &&
            !searchResult.get(0).isEmpty() &&
            searchResult.get(0).get(0) != null
          ) {
            this.ctc = (Contact) searchResult.get(0).get(0);
            cse.ContactId = ctc.Id;
            cse.AccountId = ctc.AccountId;
          }
        }
      }
      System.debug('ctc' + ctc);
    } catch (Exception e) {
      System.debug(
        e.getTypeName() +
        '\n' +
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }

    try {
      //getting the contract

      ///Appel des fonctions de la classe ImmatOuNumContratDetection pour détecter une immat ou un num de contrat et relier à un contrat ///
      System.debug('body = ' + body);
      System.debug(
        'form.ContractNumberLabel__c = ' + form.ContractNumberLabel__c
      );
      String rawContractNumber = getValueForLabel(
          body,
          form.ContractNumberLabel__c
        )
        .deleteWhitespace();
      System.debug('rawContractNumber = ' + rawContractNumber);
      String resultatDetection = ImmatOuNumContratDetection.immatContratDetection(
        rawContractNumber
      );
      System.debug('resultatDetection = ' + resultatDetection);
      this.ctr = ImmatOuNumContratDetection.linkContrat(resultatDetection);
      cse.Contrat__c = ctr.Id;
    } catch (Exception e) {
      System.debug(
        e.getTypeName() +
        '\n' +
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }

    if (String.isNotBlank(form.Queue__c)) {
      List<Group> queues = [
        SELECT Id, DeveloperName
        FROM Group
        WHERE type = 'Queue' AND DeveloperName = :form.Queue__c
      ];
      if (!queues.isEmpty())
        cse.OwnerId = queues.get(0).Id;
    }

    if (String.isNotBlank(form.Equipe__c))
      cse.Equipe__c = form.Equipe__c;
    System.debug(
      'Form Equipe = ' +
      form.Equipe__c +
      ' cse Equipe = ' +
      cse.Equipe__c
    );
    if (String.isNotBlank(form.CaseReason__c))
      cse.Motif__c = form.CaseReason__c;
    System.debug(
      'Form CaseReason = ' +
      form.CaseReason__c +
      ' Motif = ' +
      cse.Motif__c
    );
    if (String.isNotBlank(form.CaseSubReason__c))
      cse.Sous_Motif__c = form.CaseSubReason__c;
    System.debug(
      'Form caseSubReason = ' +
      form.CaseSubReason__c +
      ' cse sous motif = ' +
      cse.Sous_Motif__c
    );
  }

  /*
   *
   *
   *
   * */
  private void commitChanges() {
    try {
      insert this.cse;
      System.debug('Cse insérée');
    } catch (Exception e) {
      System.debug('###YRU ligne 118 ça se passe comme ça ' + cse.Equipe__c);
      System.debug(
        e.getTypeName() +
        '\n' +
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
      cse.Equipe__c = '';
      cse.Motif__c = '';
      cse.Sous_Motif__c = '';
      insert this.cse;
    }
    this.emsg.ParentId = cse.Id;
    //ActivityId = newTask.Id,
    insert emsg;
    insertFiles(this.email);
  }

  private void initCaseAndEmailMessage(Messaging.inboundEmail email) {
    String DescriptionTmp = '';
    if (email.plainTextBody != null) {
      DescriptionTmp = email.plainTextBody.abbreviate(32000);
    }
    this.cse = new Case(
      Origin = 'WEB',
      Subject = email.subject.abbreviate(255),
      Description = DescriptionTmp
    );
    this.emsg = new EmailMessage(
      FromAddress = email.fromAddress,
      FromName = email.fromName,
      ToAddress = String.join(email.toAddresses, ','),
      Subject = email.subject,
      TextBody = email.plainTextBody,
      HtmlBody = email.htmlBody,
      Incoming = true
    );
  }
  /*
   *
   *
   *
   * */
  private void insertFiles(Messaging.inboundEmail email) {
    List<ContentVersion> cVersions = new List<ContentVersion>();
    if (email.textAttachments != null || Test.isRunningTest())
      for (Messaging.Inboundemail.TextAttachment att : email.textAttachments)
        cVersions.add(new ContentVersion(ContentLocation = 'S',Origin = 'H',PathOnClient = att.fileName,Title = att.fileName,VersionData = Blob.valueOf(att.Body)));
    if (email.binaryAttachments != null || Test.isRunningTest())
      for (Messaging.Inboundemail.BinaryAttachment att : email.binaryAttachments)
        cVersions.add(new ContentVersion(ContentLocation = 'S',Origin = 'H',PathOnClient = att.fileName,Title = att.fileName,VersionData = att.Body));

    if (cVersions.isEmpty())
      return;

    insert cVersions;
    cVersions = [SELECT ContentDocumentId, id FROM ContentVersion WHERE Id IN :cVersions];
    List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();
    for (ContentVersion cv : cVersions) {
      cdLinks.add(new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId,LinkedEntityId = emsg.Id));
      cdLinks.add(new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId,LinkedEntityId = cse.Id));
    }
    insert cdLinks;
  }
  /*
   *
   *
   *
   * */
  private String getValueForLabel(String body, String label) {
    try {
      Integer index = body.indexOf(label) + label.length();
      System.debug('body.indexOf(label) = ' + body.indexOf(label));
      System.debug('label.length() = ' + label.length());
      System.debug('index = ' + index);
      System.debug(
        'body.indexOf(\'\n\', index) = ' + body.indexOf('\n', index)
      );
      return body.substring(index, body.indexOf('\n', index)).trim();
    } catch (Exception e) {
      System.debug(
        e.getTypeName() +
        '\n' +
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
    return null;
  }
}