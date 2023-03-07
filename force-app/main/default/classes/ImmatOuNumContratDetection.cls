public class ImmatOuNumContratDetection {
  public static String immatContratDetection(String texteAChecker) {
    //////////////////////////// Déclarations ////////////////////////////
    String regexImmat = '([A-Z]{2}[-_/. ]{0,1}[0-9]{3}[-_/. ]{0,1}[A-Z]{2})';
    String regexNumContrat = '([0-9]{8}[A-Za-z]{2,3}[0-9]{0,1})';
    String regexChassis = '([A-Za-z]{3}[A-Za-z0-9]{14})';
    String trimImmat = '[-_/. ]';
    String replacement = '';
    String resultat;

    ///// Compilation des Patterns /////
    Pattern myPatternImmat = Pattern.compile(regexImmat);
    Pattern myPatternContrat = Pattern.compile(regexNumContrat);
    Pattern myPatternChassis = Pattern.compile(regexChassis);

    ///// Recherche d'une immatriculation ou d'un numéro de contrat //////
    if (String.IsNotEmpty(texteAChecker)) {
      System.debug('texteAChecker = ' + texteAChecker);
      Matcher myMatcherImmat = myPatternImmat.matcher(texteAChecker);
      Matcher myMatcherContrat = myPatternContrat.matcher(texteAChecker);
      Matcher myMatcherChassis = myPatternChassis.matcher(texteAChecker);

      if (myMatcherImmat.find()) {
        resultat = myMatcherImmat.group().replaceAll(trimImmat, replacement);
        if (resultat.length() == 7) {
          resultat =
            resultat.left(2) +
            '-' +
            resultat.substring(2, 5) +
            '-' +
            resultat.right(2);
        }
      } else if (myMatcherContrat.find()) {
        resultat = myMatcherContrat.group();
      } else if (myMatcherChassis.find()) {
        resultat = myMatcherChassis.group();
      }
    }
    return resultat;
  }

  public static Contract__c linkContrat(String resultDetection) {
    Contract__c contratARelier;
    List<Contract__c> testSiContrat = new List<Contract__c>();

    //// Queries pour récupérer le Contrat trouvé  /////
    if (String.IsNotEmpty(resultDetection)) {
      resultDetection = resultDetection + '%';
      System.debug('resultDetection = ' + resultDetection);
      if (resultDetection.length() == 10) {
        try {
          testSiContrat = [
            SELECT
              Id,
              Numero_de_contrat__c,
              Immatriculation__c,
              Contact_client_associe__r.Id,
              Compte_client_associe__r.Id
            FROM Contract__c
            WHERE Immatriculation__c LIKE :resultDetection
            LIMIT 1
          ];
          if (testSiContrat.isEmpty()) {
            String trimImmat = '[-_/. ]';
            String replacement = '';
            resultDetection = resultDetection.replaceAll(
              trimImmat,
              replacement
            );
            contratARelier = [
              SELECT
                Id,
                Numero_de_contrat__c,
                Immatriculation__c,
                Contact_client_associe__r.Id,
                Compte_client_associe__r.Id
              FROM Contract__c
              WHERE Immatriculation__c LIKE :resultDetection
              LIMIT 1
            ];
          } else {
            contratARelier = testSiContrat[0];
          }
        } catch (Exception ex) {
          contratARelier = null;
        }
      } else if (resultDetection.length() == 18) {
        try {
          testSiContrat = [
            SELECT
              Id,
              Numero_de_contrat__c,
              Immatriculation__c,
              Contact_client_associe__r.Id,
              Compte_client_associe__r.Id,
              Numero_de_chassis__c
            FROM Contract__c
            WHERE Numero_de_chassis__c LIKE :resultDetection
            LIMIT 1
          ];
          if (!testSiContrat.isEmpty()) {
            contratARelier = testSiContrat[0];
          }
        } catch (Exception ex) {
        }
      } else {
        try {
          testSiContrat = [
            SELECT
              Id,
              Numero_de_contrat__c,
              Immatriculation__c,
              Contact_client_associe__r.Id,
              Compte_client_associe__r.Id
            FROM Contract__c
            WHERE Numero_de_contrat__c LIKE :resultDetection
            LIMIT 1
          ];
          if (!testSiContrat.isEmpty()) {
            contratARelier = testSiContrat[0];
          }
        } catch (Exception ex) {
        }
      }
    } else
      contratARelier = null;
    return contratARelier;
  }
}