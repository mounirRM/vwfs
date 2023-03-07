public class KeywordDetection {
  public static Case rulesMatcher(EmailMessage emailEntrant, Case parentCase) {
    //////////////////////////// Déclarations ////////////////////////////
    //Case parentCase = new Case(/* Id = emailEntrant.ParentId */);
    List<KeywordDetectionRule__mdt> rulesList;
    List<Group> queueList = new List<Group>();
    Map<String, Id> queueMap = new Map<String, Id>();
    Boolean isMatched = false;
    String regex;

    ////////////////////////////// Queries ///////////////////////////////
    //Query pour avoir la liste des rules concernées
    rulesList = [
      SELECT
        Destinataires__c,
        Expediteurs__c,
        Expression__c,
        File_d_attente__c,
        Motif__c,
        Sous_motif__c,
        Ou__c,
        Priorite__c,
        Operateur__c
      FROM KeywordDetectionRule__mdt
      WHERE Destinataires__c = :emailEntrant.ToAddress
      ORDER BY Priorite__c DESC
    ];
    System.debug('emailToAdress = ' + emailEntrant.ToAddress);
    System.debug('ruleslist = ' + rulesList);
    //Query pour avoir la liste des queues
    queueList = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];

    //Formation d'une Map <Nom de la queue,Id de la queue>
    for (Group q : queueList) {
      queueMap.put(q.Name, q.Id);
    }

    //Suppression des accents dans le mail entrant
    if (emailEntrant.Subject != null) {
      emailEntrant.Subject = clean(emailEntrant.Subject);
    }
    if (emailEntrant.TextBody != null) {
      emailEntrant.TextBody = clean(emailEntrant.TextBody);
    }

    ////////////////////// Détection des mots clés ///////////////////////
    for (KeywordDetectionRule__mdt ruleChecking : rulesList) {
      //Suppression des accents dans la regle
      ruleChecking.Expression__c = clean(ruleChecking.Expression__c);

      ///On construit le regex en fonction de l'opérateur indiqué dans la règle
      regex = constructRegexFromOperator(
        ruleChecking.Operateur__c,
        ruleChecking.Expression__c
      );

      Pattern keywordPattern = Pattern.compile(regex);

      if (
        ruleChecking.Ou__c == 'Objet' && String.IsNotBlank(emailEntrant.Subject)
      ) {
        isMatched = matchingThePattern(
          ruleChecking,
          keywordPattern,
          emailEntrant.Subject,
          emailEntrant.ParentId,
          queueMap,
          parentCase
        );
        if (isMatched) {
          break;
        }
      } else if (
        ruleChecking.Ou__c == 'Corps' &&
        String.IsNotBlank(emailEntrant.TextBody)
      ) {
        isMatched = matchingThePattern(
          ruleChecking,
          keywordPattern,
          emailEntrant.TextBody,
          emailEntrant.ParentId,
          queueMap,
          parentCase
        );
        if (isMatched) {
          break;
        }
      } else if (
        ruleChecking.Ou__c == 'Objet/Corps' &&
        (String.IsNotBlank(emailEntrant.Subject) ||
        String.IsNotBlank(emailEntrant.TextBody))
      ) {
        String objetCorps = emailEntrant.Subject + ' ' + emailEntrant.TextBody;
        isMatched = matchingThePattern(
          ruleChecking,
          keywordPattern,
          objetCorps,
          emailEntrant.ParentId,
          queueMap,
          parentCase
        );
        if (isMatched) {
          break;
        }
      }
    }

    return parentCase;
  }

  public static Boolean matchingThePattern(
    KeywordDetectionRule__mdt rule,
    Pattern keywordPattern,
    String lieuOuChercher,
    String parentId,
    Map<String, Id> queueMap,
    Case parentCase
  ) {
    System.debug('lieuOuChercher = ' + lieuOuChercher);
    Boolean isMatched = false;
    Matcher keywordMatcher = keywordPattern.matcher(lieuOuChercher);
    System.debug('Motif = ' + rule.Motif__c);
    System.debug('Sous-Motif = ' + rule.Sous_motif__c);
    System.debug('File d\'attente = ' + rule.File_d_attente__c);
    System.debug('OwnerId = ' + queueMap.get(rule.File_d_attente__c));
    if (keywordMatcher.find()) {
      //Case creation
      System.debug('je suis dans le if');
      parentCase.Motif__c = rule.Motif__c;
      parentCase.Sous_motif__c = rule.Sous_motif__c;
      parentCase.Equipe__c = rule.File_d_attente__c;
      parentCase.OwnerId = queueMap.get(rule.File_d_attente__c);
      isMatched = true;
    }
    return isMatched;
  }

  /////Méthode qui reçoit un String et enlève tous les accents//////
  private static String clean(String stringToClean) {
    String acc = 'ÀÂÄÇÉÈÊËÎÏÛÜÔÖàâäçéèêëîïôöùûü';
    String maj = 'AAACEEEEIIUUOOaaaceeeeiioouuu';

    String cleanString = '';
    for (Integer i = 0; i < stringToClean.length(); i++) {
      String car = stringToClean.substring(i, i + 1);
      Integer idx = acc.indexOf(car);
      if (idx != -1) {
        cleanString += maj.substring(idx, idx + 1);
      } else {
        cleanString += car;
      }
    }

    return cleanString;
  }

  public static String constructRegexFromOperator(
    String Operateur,
    String Expression
  ) {
    String boundaryCommencePar = '(?m)(?u)(?i)\\b',
      boundaryContient = '(?m)(?u)(?i)',
      boundaryMotEntierFin = '\\b',
      regex;
    if (Operateur == 'Commence par' || Operateur == null || Operateur == '') {
      regex = boundaryCommencePar + Expression;
    } else if (Operateur == 'Contient') {
      regex = boundaryContient + Expression;
    } else if (Operateur == 'Mot entier') {
      regex = boundaryCommencePar + Expression + boundaryMotEntierFin;
    }
    return regex;
  }
}