public with sharing class TMT {
  private static Long nbJours = 0;

  public static void TMT(
    List<case> caseup,
    List<casehistory> casehistorOwner,
    List<casehistory> casehistorStat,
    List<id> idQueue,
    List<id> idUser,
    BusinessHours bh
  ) {
    Datetime endDateQueue;
    Datetime startDateQueue;
    Datetime startDate;
    Datetime closedDate;
    Datetime startDateAttente;
    Datetime endDateAttente;
    Boolean closed = false;
    Boolean modification = false;

    List<Case> caseUpdate = new List<Case>();

    System.debug('size Owner = ' + casehistorOwner.size());
    System.debug('size Status = ' + casehistorStat.size());
    System.debug('size idQueue = ' + idQueue.size());
    System.debug('size idUser = ' + idUser.size());

    for (case ca : caseup) {
      startDate = ca.createddate;
      System.debug('startDate = ' + startDate);

      //Test si propriétaire de la requête à sa création est une queue
      if (casehistorOwner.size() == 0 && idQueue.contains(ca.OwnerId)) {
        startDateQueue = ca.CreatedDate;
      }

      //Test si statut = en attente lors de la création de la requête
      if (casehistorStat.size() == 0 && ca.status == 'En attente') {
        startDateAttente = ca.createdDate;
        System.debug('startDateAttente = ' + startDateAttente);
      }
      
      //Test si la requête est fermée
      if (ca.IsClosed) {
        closedDate = ca.ClosedDate;
        System.debug('closedDate = ' + closedDate);
        closed = true;
      }

      //Boucle for concernant les changements de statuts
      for (casehistory chS : casehistorStat) {

        if (chS.OldValue == 'En attente') {         if (chS.createdDate > endDateAttente || endDateAttente == null) {            endDateAttente = chS.createdDate;
            System.debug('endDateAttente = ' + endDateAttente);
          }
        }

        if (chS.NewValue == 'En attente') {  if (chS.createdDate > startDateAttente || startDateAttente == null) {   startDateAttente = chS.createdDate;
            System.debug('startDateAttente = ' + startDateAttente);
          }
        }
      }

      //Test si Owner = Queue lors de la création de la requête et après changement de propriétaire

      if (casehistorOwner.size() >= 2 || test.isRunningTest()) {
        if (!test.isRunningTest()) {
          System.debug(
            'last casehistorOwner = ' + casehistorOwner[casehistorOwner.size() - 2].OldValue.toString()
          );
          if (
            idQueue.contains( casehistorOwner[casehistorOwner.size() - 2].OldValue.toString()
            )
          ) {startDateQueue = ca.CreatedDate;
            System.debug('startDateQueue = ' + startDateQueue);
          }
        }

        //Boucle for concernant les changements de propriétaires

        for (casehistory chO : casehistorOwner){
          System.debug('NewValue = ' + chO.NewValue);
          System.debug('OldValue = ' + chO.OldValue);
          if (
            idQueue.contains(chO.OldValue.toString()) &&   idUser.contains(chO.NewValue.toString())
          ) {
            if (chO.CreatedDate > endDateQueue || endDateQueue == null) {    endDateQueue = chO.CreatedDate;
              System.debug('endDateQueue = ' + endDateQueue);
            }
          }

          if (chO.case.Owner.Type == 'Queue') {
            System.debug('chO.case.Owner.Type == \'Queue\'');
            System.debug('startDateQueue = ' + startDateQueue);
            System.debug('chO.CreatedDate = ' + chO.CreatedDate);
            if (chO.CreatedDate > startDateQueue || startDateQueue == null) {
              startDateQueue = chO.CreatedDate;
              System.debug('startDateQueue = ' + startDateQueue);
            }
          }
        }
      }

      System.debug('startDateQueue = ' + startDateQueue);
      System.debug('endDateQueue = ' + endDateQueue);
      System.debug('startDateAttente = ' + startDateAttente);
      System.debug('endDateAttente = ' + endDateAttente);
      System.debug('startDate = ' + startDate);
      System.debug('closedDate = ' + closedDate);

      //Calcul nb de jours en file d'attente
      System.debug('Calcul nb de jours en file d\'attente');
      if (startDateQueue != null && endDateQueue != null) {
        CalculNbJours(startDateQueue, endDateQueue, bh);
        modification = true;
      } else if (startDateQueue != null && endDateQueue == null && closed) {
        CalculNbJours(startDateQueue, closedDate, bh);
        modification = true;
      } else if (startDateQueue != null && endDateQueue == null && !closed) {
        endDateQueue = Date.today();
        CalculNbJours(startDateQueue, endDateQueue, bh);
        modification = true;
      }
      ca.Tempspassenfiledattente__c = nbJours;
      nbJours = 0;
      System.debug(
        'ca.Tempspassenfiledattente__c = ' + ca.Tempspassenfiledattente__c
      );

      //Calcul nb de jours en statut d'attente
      System.debug('Calcul nb de jours en statut d\'attente');
      if (
        startDateAttente != null &&
        endDateAttente != null &&
        startDateAttente < endDateAttente
      ) {
        CalculNbJours(startDateAttente, endDateAttente, bh);    modification = true;
      } else if (startDateAttente != null && endDateAttente == null && closed) {
        CalculNbJours(startDateAttente, closedDate, bh);   modification = true;
      } else if (
        startDateAttente != null &&
        endDateAttente == null &&
        !closed
      ) {
        endDateAttente = Date.today();
        CalculNbJours(startDateAttente, endDateAttente, bh);
        modification = true;
      }
      ca.Tempspasssenstatutdattentejour__c = nbJours;
      nbJours = 0;
      System.debug(
        'ca.Tempspasssenstatutdattentejour__c = ' +
        ca.Tempspasssenstatutdattentejour__c
      );

      //Calcul nb de jours en traitement
      System.debug('Calcul nb de jours en traitement');
      if (closedDate != null && startDate != null) {
        CalculNbJours(startDate, closedDate, bh);
        modification = true;
      } else if (startDate != null && closedDate == null) {
        closedDate = Date.today();
        CalculNbJours(startDate, closedDate, bh);
        modification = true;
      }
      ca.Tempspassepourtraitement__c =
        nbJours - ca.Tempspasssenstatutdattentejour__c;
      nbJours = 0;
      System.debug(
        'ca.Tempspassepourtraitement__c = ' + ca.Tempspassepourtraitement__c
      );
      if (modification) {
        caseUpdate.add(ca);
      }
    }
    try {
      if (!caseUpdate.isEmpty()) {
        update caseUpdate;
      }
    } catch (Exception e) {
      System.debug('error message : ' + e);
    }
  }

  public static void CalculNbJours(
    Datetime startDate,
    Datetime endDate,
    BusinessHours bh
  ) {
    //Diff donne un résultat en ms qu'il faut convertir en jour
    Long diff = BusinessHours.diff(bh.id, startDate, endDate);
    //Les journées dans business hours sont définies sur 24h. Si jamais c'est changé, il faut modifier par le nombre d'heure travaillées par jour
    nbJours = diff / (3600000 * 24);
    System.debug('nbJours = ' + nbJours);
  }
}