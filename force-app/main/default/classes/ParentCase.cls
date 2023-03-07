public class ParentCase {
    public static Boolean parentCaseIsClosed = false;
    public static Boolean newParentChildFamily = false;

    //Récupération de l'id du case parent
    public static Case getParentCaseId(Case currentCase, EmailMessage email) {

        //System.debug('Début classe getParentCaseId');

        //System.debug('email = ' + email);
        //System.debug('MessageId = ' + email.MessageIdentifier);
        //currentCase est fermé si le client répond sur un ancien case fermé avec un thread id de type [ ref:... ref ]
        //System.debug('currentCase = ' + currentCase);
        if (email.Headers != null) { //Si email.Headers = null alors c'est le premier mail
            //Récupération In reply to    
            Pattern myPatternInReplyTo = Pattern.compile('In-Reply-To: <.*>');
            Matcher myMatcherInReplyTo = myPatternInReplyTo.matcher(email.Headers);

            //Récupération MessageIdentifier
            Pattern myPatternMessageId = Pattern.compile('References: <.*>');
            Matcher myMatcherMessageId = myPatternMessageId.matcher(email.Headers);

            if (myMatcherMessageId.find() || myMatcherInReplyTo.find()) {
                //Reconstruction In Reply To
                String inReplyToParentCase = email.Headers.substringBetween('In-Reply-To: <', '>');
                inReplyToParentCase = '<' + inReplyToParentCase + '>';
                //System.debug('inReplyToParentCase = ' + inReplyToParentCase);

                //Reconstruction MessageIdentifier
                String messageIdentifierParentCase = email.Headers.substringBetween('References: <', '>');
                messageIdentifierParentCase = '<' + messageIdentifierParentCase + '>';
                //System.debug('messageIdentifierParentCase = ' + messageIdentifierParentCase);

                List<EmailMessage> emailParent = [SELECT ParentId, Parent.isClosed, Parent.Owner.Type, Parent.OwnerId, Parent.ParentId, MessageIdentifier FROM EmailMessage WHERE (MessageIdentifier = :inReplyToParentCase OR MessageIdentifier = :messageIdentifierParentCase)];
                List<EmailMessage> listEmail = new List<EmailMessage>();
                //Il faut que inReplyTo soit en premier ce qui n'est pas toujours le cas après la requête, donc on remet dans l'ordre
                Integer i = 0;
                for (EmailMessage emailTri : emailParent) {
                    //System.debug('emailTri.MessageIdentifier = ' + emailTri.MessageIdentifier);
                    listEmail.add(null);
                    if (emailTri.MessageIdentifier.endsWith('sfdc.net>')) {
                        listEmail[0] = emailTri;
                    } else {
                        if (i == 0) {
                            listEmail.add(null);
                            i++;
                        }
                        listEmail[i] = emailTri;
                    }
                    i++;
                }

                try {
                    for (EmailMessage emailP : listEmail) {
                        if (emailP == null) {
                            break;
                        }
                        //Permet de commencer une nouvelle lignée si le parent case a été supprimé manuellement
                        //System.debug('emailP.MessageIdentifier = ' + emailP.MessageIdentifier);
                        //System.debug('emailP.Parent.ParentId = ' + emailP.Parent.ParentId);
                        if (emailP.MessageIdentifier == inReplyToParentCase && emailP.Parent.ParentId != null) {
                            currentCase.ParentId = emailP.Parent.ParentId;
                        } else if (emailP.MessageIdentifier == inReplyToParentCase && emailP.Parent.ParentId == null){
                            currentCase.ParentId = emailP.ParentId;
                            if (listEmail.size() > 1 && listEmail[0].ParentId != listEmail[1].ParentId) { //Les 2 ParentId seront identiques lorsque c'est le 2ème mail
                                newParentChildFamily = true;                                
                            }
                        }

                        //System.debug('emailP.MessageIdentifier = ' + emailP.MessageIdentifier);
                        //System.debug('messageIdentifierParentCase = ' + messageIdentifierParentCase);
                        //System.debug('currentCase.ParentId = ' + currentCase.ParentId);
                        //System.debug('emailP.ParentId = ' + emailP.ParentId);
                        
                        if (emailP.MessageIdentifier == messageIdentifierParentCase && emailP.Parent.isClosed && currentCase.ParentId == emailP.ParentId){
                            parentCaseIsClosed = true;
                            //Si propriétaire de la requête parent est un utilisateur, on le notifie qu'une nouvelle requête a été ouverte depuis une requête fermée (voir classe EmailMessageTriggerHandler)
                            currentCase.OwnerId = emailP.Parent.OwnerId;
                        } 
                    }
                } catch (Exception e) {
                    //System.debug(e);
                } 
            }
        }

        //System.debug('Fin Classe getParentCaseId');
        
        return currentCase;
    }

    public static void caseUpdate(Map<Id,Case> oldMap,Map<Id,Case> newMap){
        List<Case> caseup = new List<Case>();
        List<Case> listCaseToUpdate = new List<Case>();
        for (Case ca : newMap.values()) {
            caseup.add(ca);
        }
        for (Case ca : caseup) {
            try {
                //System.debug('ca = ' + ca);
                //System.debug('ca.status = ' + ca.Status);
                //System.debug('ca.isClosed = ' + ca.isClosed);
                if (!ca.Status.equals('A traiter') && !ca.Status.equals('En cours de traitement') && !ca.Status.equals('En attente')) {
                    if (ca.ParentId != null) {
                        //System.debug('Parent Id = ' + ca.ParentId);
                        List<Case> listCaseEnfant = [SELECT Id, IsClosed, Status, Equipe__c, Motif__c, (SELECT Id, CaseNumber, IsClosed FROM Cases) FROM Case WHERE Id = :ca.ParentId];
                        //System.debug('listCaseEnfant = ' + listCaseEnfant);
                        for (Case caParent : listCaseEnfant) {
                            Boolean allClosed = true;
                            for (Case caEnfant : caParent.Cases) {
                                //System.debug('Dans le 2ème for');
                                //System.debug('caEnfant isClosed = ' + caEnfant.isClosed);
                                //On doit passer l'enfant actuel car il n'est pas encore à jour et donc sera forcément ouvert
                                if (caEnfant.Id == ca.Id) {
                                    break;
                                }
                                if (!caEnfant.IsClosed){
                                    allClosed = false;
                                    break;
                                }
                            }
                            if (!caParent.IsClosed && allClosed) {
                                if (caParent.Equipe__c != null && caParent.Motif__c != null) {
                                    caParent.Status = 'Résolue (via requête fille)';
                                    listCaseToUpdate.add(caParent); 
                                } else {
                                    ca.addError('Impossible de fermer la requête. Vérifier que l\'équipe et le motif/sous-motif de la requête parent soient bien renseignés');
                                }
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug(e);
            }
        }
        if (listCaseToUpdate != null) {
            update(listCaseToUpdate);
        }
    }   
}