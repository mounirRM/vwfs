public with sharing class EmailMessageTriggerHandler {
  public static void handleTrigger(
    List<EmailMessage> emailList,
    System.TriggerOperation triggerEvent
  ) {
    switch on triggerEvent {
      when AFTER_INSERT {
        //handleAfterInsert(emailList);
      }
      when BEFORE_INSERT {
        handleBeforeInsert(emailList);
      }
    }
  }

  public static void handleBeforeInsert(List<EmailMessage> emailList) {
    System.debug('######emailList:' + emailList);

    List<Case> caseList = [
      SELECT
        Id,
        OwnerId,
        Status,
        IsClosed,
        Origin,
        Equipe__c,
        Motif__c,
        Sous_motif__c,
        ContactId,
        Contrat__c,
        AccountId,
        CreatedById
      FROM Case
      WHERE id = :emailList[0].parentId
      LIMIT 1
    ];
    System.debug('######caseList:' + caseList);
    Case newCase = new Case();
    Id ownerIdQueuorUser;
    if (caseList.size() > 0) {
      ownerIdQueuorUser = caseList[0].OwnerId;
    }
    List<ExternalRoleSharingConfig__mdt> allowedQueues = [
      SELECT Id, Label
      FROM ExternalRoleSharingConfig__mdt
    ];
    Set<Id> userIdstoAllows = new Set<Id>();
    Set<Id> queuesIdstoAllows = new Set<Id>();

    System.debug('######ownerIdQueuorUser:' + ownerIdQueuorUser);
    List<User> myUser = [
      SELECT id, UserRoleId, Equipe__c
      FROM USER
      WHERE id = :ownerIdQueuorUser
    ];
    System.debug('myUser:' + myUser);
    //2533
    Id extAgentRleId;
    Id extSuperviseurRleId;
    List<UserRole> extRoleList = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = 'agent_RC_ext' OR Name = 'superviseur_RC_ext'
    ];
    System.debug('extRoleList:' + extRoleList);
    for (UserRole usr : extRoleList) {
      if (usr.Name == 'agent_RC_ext') {
        extAgentRleId = usr.Id;
      } else if (usr.Name == 'superviseur_RC_ext') {
        extSuperviseurRleId = usr.Id;
      }
    }
    List<Profile> Profiles = [SELECT Id, Name FROM Profile];
    System.debug('Profiles:' + Profiles);
    Id SystemAdminProfileId;
    Id TechRef360Id;
    for (Profile p : Profiles) {
      if (p.Name == 'System Administrator') {
        SystemAdminProfileId = p.Id;
      } else if (p.Name == 'TechRef360') {
        TechRef360Id = p.Id;
      }
    }
    String uRoleId = UserInfo.getUserRoleId();
    system.debug('uRoleId:' + uRoleId);
    Boolean isUserOrQueue = false;
    Id connectedUserId = UserInfo.getUserId();
    System.debug('######connectedUserId:' + connectedUserId);
    Set<Id> roleRelatedId = new Set<Id>();
    Set<Id> parentRoleId = new Set<Id>();
    Set<Id> groupMembersId = new Set<Id>();
    if (myUser.size() < 1) {
      List<Group> myQueue = [
        SELECT id, Related.Name, Name
        FROM Group
        WHERE id = :ownerIdQueuorUser
      ];
      //Group myQueue = [SELECT id,RelatedId,Related.Name from Group where RelatedId=:uRoleId and type='Role'][0];
      System.debug('myQueue:' + myQueue);

      List<GroupMember> grpMembers = [
        SELECT Id, UserOrGroupId
        FROM GroupMember
        WHERE GroupId = :myQueue[0].Id
      ];
      System.debug('grpMembers:' + grpMembers);
      for (GroupMember gpM : grpMembers) {
        groupMembersId.add(gpM.UserOrGroupId);
      }
      system.debug('groupMembersId:' + groupMembersId);
      List<Group> getRoleInQueue = [
        SELECT id, Related.Name, RelatedId
        FROM Group
        WHERE id IN :groupMembersId
      ];
      for (Group gp : getRoleInQueue) {
        roleRelatedId.add(gp.RelatedId);
      }
      System.debug('getRoleInQueue:' + getRoleInQueue);
      system.debug('roleRelatedId:' + roleRelatedId);
      List<UserRole> parentRole = [
        SELECT Id, ParentRoleId
        FROM UserRole
        WHERE Id IN :roleRelatedId
      ];
      System.debug('parentRole:' + parentRole);
      for (UserRole usr : parentRole) {
        parentRoleId.add(usr.ParentRoleId);
      }
      system.debug('parentRoleId:' + parentRoleId);
      system.debug('parentRole:' + parentRole);
      List<UserRole> getAllChildRole = [
        SELECT Id, ParentRoleId
        FROM UserRole
        WHERE
          ParentRoleId IN :parentRoleId
          OR ParentRoleId IN :roleRelatedId
          OR Id IN :parentRoleId
          OR Id IN :roleRelatedId
      ];
      System.debug('getAllChildRole:' + getAllChildRole);

      for (UserRole rle : getAllChildRole) {
        if (rle.Id == uRoleId) {
          isUserOrQueue = true;
        }
      }
      //2533
      if (
        UserInfo.getUserRoleId() == extAgentRleId ||
        UserInfo.getUserRoleId() == extSuperviseurRleId
      ) {
        for (Group grp : myQueue) {
          for (ExternalRoleSharingConfig__mdt ext : allowedQueues) {
            if (grp.Name == ext.Label) {
              queuesIdstoAllows.add(grp.Id);
            }
          }
        }
      }
    }

    if (
      UserInfo.getUserRoleId() == extAgentRleId ||
      UserInfo.getUserRoleId() == extSuperviseurRleId
    ) {
      for (User usr : myUser) {
        for (ExternalRoleSharingConfig__mdt ext : allowedQueues) {
          if (usr.Equipe__c == ext.Label) {
            userIdstoAllows.add(usr.Id);
          }
        }
      }
    }
    if (myUser.size() > 0 && myUser[0].Id == connectedUserId) {
      isUserOrQueue = true;
    }

    if (
      UserInfo.getProfileId() == SystemAdminProfileId ||
      UserInfo.getProfileId() == TechRef360Id ||
      UserInfo.getUserRoleId() == extAgentRleId ||
      UserInfo.getUserRoleId() == extSuperviseurRleId ||
      UserInfo.getLastName() == 'System'
    ) {
      isUserOrQueue = true;
    }
    if (isUserOrQueue == false) {
      emailList[0]
        .id.addError('Vous n\'êtes pas autorisé à envoyer des emails ');
    }

    //2533
    system.debug('queuesIdstoAllows:' + queuesIdstoAllows);
    system.debug('userIdstoAllows:' + userIdstoAllows);
    if (
      UserInfo.getUserRoleId() == extAgentRleId ||
      UserInfo.getUserRoleId() == extSuperviseurRleId
    ) {
      for (EmailMessage EM : emailList) {
        Boolean displayError = true;
        if (queuesIdstoAllows.size() > 0) {
          for (Id ids : queuesIdstoAllows) {
            if (caseList[0].ownerId == ids) {
              displayError = false;
            }
          }
        }
        if (userIdstoAllows.size() > 0) {
          for (Id ids : userIdstoAllows) {
            if (caseList[0].ownerId == ids) {
              displayError = false;
            }
          }
        }
        if (displayError == true) {
          EM.addError(System.label.extRleEmailRestrictionError);
        }
      }
    }
    // developpement 2597
    /*if (caseList.size() > 0) {
      if (caseList[0].Status == 'Résolue' 
         || caseList[0].Status == 'Absence de retour client'
         || caseList[0].Status == 'Absence de retour partenaire'
         || caseList[0].Status == 'Requête déjà traitée (doublon)'
         || caseList[0].Status == 'Requête annulée (le client ne souhaite pas donner suite)'
         || caseList[0].Status == 'Erreur destinataire'
         || caseList[0].Status == 'Opportunité commerciale') {
        try {
          String sObjName = caseList[0]
            .OwnerId.getSObjectType()
            .getDescribe()
            .getName();
          if (sObjName != 'User') {
            List<Group> currentGroup = [
              SELECT Id, Name
              FROM Group
              WHERE Id = :caseList[0].OwnerId
            ];
            system.debug('currentGroup :' + currentGroup);

            system.debug('enter AP_SendEMail');
            system.debug('group Name:' + currentGroup[0].Name);
            system.debug('ValidatedFromAddress:' + emailList[0].ValidatedFromAddress); 
            system.debug('FromAddress :' + emailList[0].FromAddress);
            AP_SendEMail.autoReply(
              currentGroup[0].Name,
              emailList[0].FromAddress
            );
            system.debug('after AP_SendEMail');
          }
          //emailList[0].addError('You cannot send email to or from a closed case');
        } catch (Exception e) {
          system.debug('error :' + e.getMessage());
        }
      }
    } */

    //Début partie gestion parent case
    EmailMessage emsg = emailList.get(0);
    String emsgSubjectBody = emsg.Subject + ' ' + emsg.TextBody;
    System.debug('emsg = ' + emsg);
    System.debug('emsgSubjectBody = ' + emsgSubjectBody);

    newCase = ParentCase.getParentCaseId(newCase, emsg);
    
    Pattern myPatternThreadId = Pattern.compile('ref:.*:ref ');
    Matcher myMatcherThreadId = myPatternThreadId.matcher(emsgSubjectBody);
    Boolean myMatcherThreadIdBoolean = myMatcherThreadId.find();
    System.debug('matcher threadId = ' + myMatcherThreadIdBoolean);
    System.debug('parent case isClosed = ' + ParentCase.parentCaseIsClosed);
    System.debug('emsg.Incoming = ' + emsg.Incoming);

    if (emsg.Incoming && (myMatcherThreadIdBoolean || ParentCase.parentCaseIsClosed)) {
      System.debug('Dans le if création newCase');
      newCase.Subject = emsg.Subject;
      newCase.Equipe__c = caseList[0].Equipe__c;
      newCase.Motif__c = caseList[0].Motif__c;
      newCase.Sous_motif__c = caseList[0].Sous_motif__c;
      newCase.Origin = caseList[0].Origin;
      //Si requête parent avec un ancien thread id détecté, on ouvre une nouvelle requête
      if (myMatcherThreadIdBoolean) {
        insert newCase;
      } else {
        newCase.Id = emsg.parentId;
      }
      //Rajouter un try pour ne pas bloquer l'exécution du code en cas de problème. Ex : automated process ne peut pas accéder à l'api chatter donc ne peut pas poser de message dans le feed
      //Contournement : mettre un utilisateur admin dans Support Settings > Automated Case User
      try {
        if (ParentCase.parentCaseIsClosed) {
          String newCaseIdString = Id.valueOf(newCase.Id);
          String OwnerIdString = Id.valueOf(newCase.OwnerId);
          if (OwnerIdString.startsWith('005')) {
            ConnectApiHelper.postFeedItemWithMentions(
                null,
                newCaseIdString,
                '{' +
                OwnerIdString +
                '}' +
                ' Nouvelle requête créée depuis une requête fermée (voir requête Parent dans détail)'
            );
          } else {
              ConnectApiHelper.postFeedItemWithMentions(
                  null,
                  newCaseIdString, 
                  'Nouvelle requête créée depuis une requête fermée (voir requête Parent dans détail)'
                );
          }
        }
      } catch (Exception e) {
        System.debug('erreur post message requête créée depuis une requête fermée : ' + e);
      }
        
      emsg.ParentId = newCase.Id;
    } else {
      newCase.Id = emsg.parentId;
    }
    System.debug('newCase = ' + newCase);
    if (ParentCase.newParentChildFamily) {
      Pattern patternEmailInReplyTo = Pattern.compile('In-Reply-To: <.*>');
      Matcher matcherEmailInReplyTo = patternEmailInReplyTo.matcher(emsg.Headers);

      Pattern patternEmailReference = Pattern.compile('References:.*');
      Matcher matcherEmailReference = patternEmailReference.matcher(emsg.Headers);

      if (matcherEmailInReplyTo.find() && matcherEmailReference.find()) {
        String inReplyTo = emsg.Headers.substringBetween('In-Reply-To: <', '>');
        inReplyTo = '<' + inReplyTo + '>';

        String textToReplace = emsg.Headers.substringBetween('References:', inReplyTo);
        System.debug('textToReplace = ' + textToReplace);

        List<String> listEmailParentCase = emsg.Headers.split('<');
        System.debug('listEmailParentCase = ' + listEmailParentCase);

        try {
          String emailParentCase =  '<' + listEmailParentCase[listEmailParentCase.size()-2];
          emsg.Headers = emsg.Headers.replace(textToReplace, emailParentCase);
          System.debug('emsg.Headers = ' + emsg.Headers);
          
        } catch (Exception e) {
          System.debug(e);
        }

      }
    }

    if (emailList.size() != 1 || !emailList?.get(0)?.incoming)
      return;

    try {
      newCase = KeywordDetection.rulesMatcher(emsg, newCase);

      //getting the contact
      /*String email = emsg.FromAddress;
      if (String.isNotBlank(email)) {
        List<Profile> profileId = [
          SELECT Id
          FROM Profile
          WHERE Name = 'Manager' OR Name LIKE 'Agent%'
          ];
          List<User> user = [
            SELECT Id
            FROM User
            WHERE Email LIKE :email AND ProfileId IN :profileId
            LIMIT 1
            ];
        if (user.isEmpty()) {
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
                Contact ctc = (Contact) searchResult.get(0).get(0);
                newCase.ContactId = ctc.Id;
                newCase.AccountId = ctc.AccountId;
              }
            }
          }*/

      String resultatDetection = ImmatOuNumContratDetection.immatContratDetection(
        emsgSubjectBody
      );
      System.debug('resultatDetection : ' + resultatDetection);
      Contract__c ctr;
      if (String.isNotBlank(resultatDetection)) {
        ctr = ImmatOuNumContratDetection.linkContrat(resultatDetection);
        if (ctr != null) {
          newCase.Contrat__c = ctr.Id;
          System.debug('ctr : ' + ctr);
        }
      }
      System.debug('newCase 2 = ' + newCase);
      update newCase;
      Case contactCase = [
        SELECT Id, ContactId, SuppliedEmail
        FROM Case
        WHERE Id = :newCase.Id
      ];
      if (contactCase.ContactId != null) {
        List<Profile> profileId = [
          SELECT Id
          FROM Profile
          WHERE Name = 'Manager' OR Name LIKE 'Agent%'
        ];
        List<User> user = [
          SELECT Id
          FROM User
          WHERE
            Email LIKE :contactCase.SuppliedEmail
            AND ProfileId IN :profileId
          LIMIT 1
        ];
        if (!user.isEmpty()) {
          newCase.ContactId = '';
          newCase.AccountId = '';
          update newCase;
        }
      }
    } catch (Exception e) {
      System.debug(
        e.getTypeName() +
        '\n' +
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }

  /*public static void handleAfterInsert(List<EmailMessage> emailList) {
      Map<Id,EmailMessage> caseIdEmailMessage = new Map<Id,EmailMessage>();
      Boolean isClient = true;
      Boolean doNotDelEmail = false;
      List<Case> caseList = [
      SELECT
        Id,
        OwnerId,
        Status,
        Equipe__c,
        Motif__c,
        Sous_motif__c,
        ContactId,
        Contrat__c,
        AccountId,
        CreatedById
      FROM Case
      WHERE id = :emailList[0].parentId
      LIMIT 1
      ];
      System.debug('caseList :' + caseList);
      
      for(EmailMessage em : emailList){
              caseIdEmailMessage.put(em.ParentId,em);
      }
        List<QueueOrUserEmail__mdt> queuesEmailList = [SELECT Id,usedForAtraiter__c,Email__c FROM QueueOrUserEmail__mdt WHERE usedForAtraiter__c = True];
      
      for(QueueOrUserEmail__mdt mdt : queuesEmailList){
        if(emailList[0].FromAddress == mdt.Email__c){
          isClient = false;
        }
      }
      if (caseList.size() > 0 && isClient) {
        if (caseList[0].Status == 'En attente') {
          caseList[0].Status = 'A traiter';
          update caseList[0];
        }
      }
        List<QueueOrUserEmail__mdt> queuesEmailList2 = [SELECT Id,UsedForNoReply__c,Email__c FROM QueueOrUserEmail__mdt WHERE UsedForNoReply__c = True];
      for(QueueOrUserEmail__mdt queuesEm : queuesEmailList2){
        if(emailList[0].FromAddress == queuesEm.Email__c){
          doNotDelEmail = true;
        }
      }
      if (caseList.size() > 0) {
        if ((caseList[0].Status == 'Résolue' 
          || caseList[0].Status == 'Absence de retour client'
          || caseList[0].Status == 'Absence de retour partenaire'
          || caseList[0].Status == 'Requête déjà traitée (doublon)'
          || caseList[0].Status == 'Requête annulée (le client ne souhaite pas donner suite)'
          || caseList[0].Status == 'Erreur destinataire'
          || caseList[0].Status == 'Opportunité commerciale') && !doNotDelEmail) {
          deleteEmailMessage(new List<Id>{caseIdEmailMessage.get(caseList[0].Id).Id});
        }
      } 
    }
     @future
    public static void deleteEmailMessage(List<Id> emailMssgId) {
      List<EmailMessage> emailMssg =[SELECT Id FROM EmailMessage WHERE Id =:emailMssgId];
      Delete emailMssg;
    } 
    
    */
}