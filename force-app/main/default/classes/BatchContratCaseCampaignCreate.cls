global with sharing class BatchContratCaseCampaignCreate implements Database.Batchable<sObject>,Database.Stateful {
  date dt = date.today() + 15;
  Public String numOfAlertCreatedToday;

  Recordtype impRecordTypeId = [
    SELECT id, DeveloperName
    FROM recordtype
    WHERE DeveloperName = 'Gestion_d_impay'
    LIMIT 1
  ];
  List<String> listproductRetAmiabl = new List<String>{
    'LOA',
    'CRE',
    'CRV',
    'ASV'
  };
  List<String> liststatuscodeRetAmial = new List<String>{
    'RECAMI',
    'PRECTX',
    'TAMI',
    'TPCX',
    'TRECAMI',
    'TPRECTX',
    'PTP'
  };
  List<String> listproductFletAmiabl = new List<String>{ 'LLD', 'CRB' };
  List<String> liststatuscodeFletAmial = new List<String>{
    'RECAMI',
    'PRECTX',
    'TAMI',
    'TPCX',
    'TRECAMI',
    'TPRECTX',
    'PTP'
  };
  List<String> listproductRetContet = new List<String>{
    'LOA',
    'CRE',
    'CRV',
    'ASV'
  };
  List<String> liststatuscodeRetContet = new List<String>{ 'RCONO', 'TCONO' };
  List<String> listproductFletContet = new List<String>{ 'LLD', 'CRB' };
  List<String> liststatuscodeFletContet = new List<String>{ 'RCONO', 'TCONO' };
  List<String> listproductFrenchBank = new List<String>{
    'LOA',
    'CRE',
    'CRV',
    'ASV'
  };
  List<String> liststatuscodeFrenchBank = new List<String>{
    'BDFVAL',
    'TPBDFV',
    'RBDFO',
    'BDFREC',
    'BDFNEG',
    'DDPCTX'
  };
  List<String> listproductColleProc = new List<String>{
    'LLD',
    'CRB',
    'LOA',
    'CRE',
    'ASV',
    'CRV'
  };
  List<String> liststatuscodeColleProc = new List<String>{
    'RJ',
    'LJ',
    'LA',
    'FORC',
    'MAHOC',
    'SJ',
    'RRJ',
    'RLJ',
    'RLA',
    'RMAHOC',
    'RSJ'
  };

  List<String> liststatuscoderecouv = new List<String>{
    'TAVT',
    'TFCT',
    'TSIC'
  };
 List<String> liststatuscodeLPRT = new List<String>{'LPRT'};
 List<String> listproductreamiableretailLPRT = new List<String>{
    'LOA',
    'ASV',
    'LVD',
    'SEG',
    'SEN',
    'SEP',
    'CRE'
  };
     
 List<String> listproductreamiablefleetLPRT = new List<String>{
     'LOU',
     'CBV',
     'CBP',
     'LCD',
     'LLD',
     'SMA'
  };
List<String> listproductreamiableretail = new List<String>{
    'CRV',
    'ACV',
    'LOA',
    'ASV',
    'LVD',
    'SEG',
    'SEN',
    'SEP',
    'CRE'
    
  };
 List<String> listproductreamiablefleet = new List<String>{
     'LOU',
     'CBV',
     'CBP',
     'LCD',
     'CRV',
     'LLD',
     'SMA'
  };
 List<String> liststatuscodeRecouvrementAdmin_B2F = new List<String>{
    'TNBDF',
    'TPBDF'  
  };
      
  List<Case> objToinsert = new List<Case>();
  
  global Database.QueryLocator start(Database.BatchableContext bc) {
    //system.debug('BatchContratCaseCampaign listStages : ' + listproductRetAmiabl);
    Date currentDate = Date.today();
    String query = 'SELECT Id, Produit_financier__c, CreatedDate, Code_statut_contrat__c, Date_de_l_alerte__c  FROM Contract__c WHERE ';
    query += '(((Produit_financier__c IN :listproductRetAmiabl) AND (Code_statut_contrat__c IN :liststatuscodeRetAmial)) OR ';
    query += '((Produit_financier__c IN :listproductFletAmiabl) AND (Code_statut_contrat__c IN :liststatuscodeFletAmial)) OR ';
    query += '((Produit_financier__c IN :listproductRetContet) AND (Code_statut_contrat__c IN :liststatuscodeRetContet)) OR ';
    query += '((Produit_financier__c IN :listproductFletContet) AND (Code_statut_contrat__c IN :liststatuscodeFletContet)) OR ';
    query += '((Produit_financier__c IN :listproductFrenchBank) AND (Code_statut_contrat__c IN :liststatuscodeFrenchBank)) OR ';
    query += '((Produit_financier__c IN :listproductColleProc) AND (Code_statut_contrat__c IN :liststatuscodeColleProc)) OR ';
    query += '((Produit_financier__c IN :listproductreamiableretailLPRT) AND (Code_statut_contrat__c IN :liststatuscodeLPRT)) OR ';
    query += '((Produit_financier__c IN :listproductreamiableretail) AND (Code_statut_contrat__c IN :liststatuscodeRecouvrementAdmin_B2F)) OR ';
    query += '((Produit_financier__c IN :listproductreamiableretailLPRT) AND (Code_statut_contrat__c IN :liststatuscodeLPRT)) OR ';
    query += '((Produit_financier__c IN :listproductreamiablefleetLPRT) AND (Code_statut_contrat__c IN :liststatuscodeLPRT)) OR '; 
    query += '((Produit_financier__c IN :listproductreamiablefleet) AND (Code_statut_contrat__c IN :liststatuscoderecouv)) OR ';
    query += '((Produit_financier__c IN :listproductreamiableretail) AND (Code_statut_contrat__c IN :liststatuscoderecouv)))  ';
    // system.debug('BatchOpportCreditAffecte query : ' + query);
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext sc, List<sObject> scope) {
    List<Contract__c> crtList = (List<Contract__c>) scope;
    List<Id> crtIds = new List<Id>();
    List<Case> caToUpdate = new List<Case>();
    List<Case> caseUpdated = new List<Case>();
    List<String> listStatus = new List<String>{
      'Closed',
      'Résolue',
      'Requête déjà traitée (doublon)',
      'Fusionnée'
    };

    System.debug('crtList = ' + crtList);

    //Get cases "Gestion de l'impayé" still opened that might already exist for the contracts
    List<Case> clist = [
      SELECT
        id,
        Contrat__c,
        status,
        RecordTypeId,
        Date_d_ch_ance__c,
        toCloseDoublon__c,
        Contrat__r.Date_de_l_alerte__c,
        Contrat__r.Contact_client_associe__c,
        Contrat__r.Compte_client_associe__c
      FROM case
      WHERE
        recordtypeid = :impRecordTypeId.id
        AND Contrat__c IN :crtList
        AND (NOT status IN :listStatus)
    ];
    //List to check if a case "doublon" has been already created and closed for a specific "Date de l'alerte"
    /*List<Case> clistDoublon = [
      SELECT id, Contrat__c, status, RecordTypeId, Date_d_ch_ance__c
      FROM case
      WHERE
        recordtypeid = :impRecordTypeId.id
        AND Contrat__c IN :crtList
        AND status = 'Requête déjà traitée (doublon)'
    ];*/

    AssignmentRule AR = new AssignmentRule();
    AR = [
      SELECT id
      FROM AssignmentRule
      WHERE SobjectType = 'Case' AND Active = TRUE
      LIMIT 1
    ];

    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
    Database.DMLOptions dmlOpts = new Database.DMLOptions();
    dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

    //Check if "Date d'échéance" of the existed case is different than "Date de l'alerte" of the contract. If so, create new case with "Date d'échéance" = "Date de l'alerte"
    for (Case ca : clist) {
      crtIds.add(ca.Contrat__c);
      /*if (ca.Date_d_ch_ance__c < ca.Contrat__r.Date_de_l_alerte__c) {
        Boolean caseAlreadyExist = false;
        for (Case caseDoublon : clistDoublon) {
          if (
            ca.Contrat__c == caseDoublon.Contrat__c &&
            caseDoublon.Date_d_ch_ance__c == ca.Contrat__r.Date_de_l_alerte__c
          ) {
            caseAlreadyExist = true;
            break;
          }
        }
        if (!caseAlreadyExist) {
          Case c = new Case(
            status = 'A traiter',
            Origin = 'Gestion_d_impaye',
            recordtypeid = impRecordTypeId.id,
            Contrat__c = ca.Contrat__c,
            ContactId = ca.Contrat__r.Contact_client_associe__c,
            AccountId = ca.Contrat__r.Compte_client_associe__c,
            Date_d_ch_ance__c = ca.Contrat__r.Date_de_l_alerte__c,
            toCloseDoublon__c = true
          );
          c.setOptions(dmlOpts);
          objToinsert.add(c);
        }
      }
      if (ca.Date_d_ch_ance__c > ca.Contrat__r.Date_de_l_alerte__c) {
        Case c = new Case(
          status = 'A traiter',
          Origin = 'Gestion_d_impaye',
          recordtypeid = impRecordTypeId.id,
          Contrat__c = ca.Contrat__c,
          ContactId = ca.Contrat__r.Contact_client_associe__c,
          AccountId = ca.Contrat__r.Compte_client_associe__c,
          Date_d_ch_ance__c = ca.Contrat__r.Date_de_l_alerte__c
        );
        c.setOptions(dmlOpts);
        objToinsert.add(c);
        ca.toCloseDoublon__c = true;
        caToUpdate.add(ca);
      }*/
    }
    //Update previous case with boolean toCloseDoublon__c to close them easily
    //Database.update(caToUpdate, false);

    //Create a case for all others contracts
    for (Contract__c crt : [
      SELECT id, Contact_client_associe__c, Compte_client_associe__c
      FROM Contract__c
      WHERE id IN :crtList AND id NOT IN :crtIds
    ]) {
      Case c = new Case(
        status = 'A traiter',
        Origin = 'Gestion_d_impaye',
        recordtypeid = impRecordTypeId.id,
        Contrat__c = crt.id,
        ContactId = crt.Contact_client_associe__c,
        AccountId = crt.Compte_client_associe__c,
        caseCreatedByBatch__c = True,
        Date_d_ch_ance__c = dt
      );
      /*if (crt.Date_de_l_alerte__c != null)
        c.Date_d_ch_ance__c = crt.Date_de_l_alerte__c;
      else
        c.Date_d_ch_ance__c = dt;*/

      c.setOptions(dmlOpts);
      objToinsert.add(c);
    }

    //numOfAlertCreatedToday = objToinsert != null ? String.ValueOf(objToinsert.size()):'0';
    Database.insert(objToinsert, false);

    //Remplissage de l'équipe et motif en fonction de la file d'attente
    List<id> idCase = new List<id>();
    for (Case myCase : objToinsert) {
      idCase.add(myCase.Id);
    }
    List<Case> caseToUpdate = [
      SELECT id, Service__c, Equipe__c, Motif__c
      FROM Case
      WHERE Id IN :idCase
    ];
    for (Case c : caseToUpdate) {
      String nameOwner = c.Service__c;
      if (nameOwner != null && (c.equipe__c == null || c.motif__c == null)) {
        if (nameOwner.contains('RETAIL')) {
          c.equipe__c = 'Recouvrement - Retail';
        }
        if (nameOwner.contains('FLEET')) {
          c.equipe__c = 'Recouvrement - Small Fleet';
        }
        if (
          nameOwner.contains('AMIABLE') ||
          nameOwner.contains('IPTR') ||
          nameOwner.contains('STAND ALONE')
        ) {
          c.motif__c = 'Amiable';
        }
        if (nameOwner.contains('CTX') || nameOwner.contains('DDPCTX')) {
          c.motif__c = 'Contentieux';
        }
        if (nameOwner.contains('BDF')) {
          c.equipe__c = 'Recouvrement - Administratif';
          c.motif__c = 'Banque de France';
        }
        if (nameOwner.contains('PCL')) {
          c.equipe__c = 'Recouvrement - Small Fleet';
          c.motif__c = 'PCL';
        }
      }
      caseUpdated.add(c);
    }
    try {
      update caseUpdated;
    } catch (Exception e) {
      System.debug('error = ' + e);
    }
  }

  global void finish(Database.BatchableContext bc) {
      System.debug('objToinsert size:'+objToinsert.size());
     // BatchContratCaseCampaignClose closeAlert = new BatchContratCaseCampaignClose();
      //closeAlert.numOfAlertCreated = numOfAlertCreatedToday;//objToinsert != null ? String.ValueOf(objToinsert.size()):'0';
      Database.executeBatch(new BatchContratCaseCampaignClose(), 1000);
  }
}