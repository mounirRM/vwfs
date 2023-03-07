public without sharing class TMTRework {
    @future
    public static void TMT(List<Id> ids){
        System.debug('ids:'+ids);
      List<case> caseup = [
      SELECT
        Id,
        OwnerId,
        status,
        IsClosed,
        ParentId,
        Tempspassenfiledattente__c,
        Tempspasssenstatutdattentejour__c,
        Tempspassepourtraitement__c,
        CreatedDate,
        ClosedDate
      FROM case
      WHERE id IN :ids
    ];
        System.debug('caseup:'+caseup);
    List<casehistory> casehistorOwner = [
      SELECT
        Id,
        case.Tempspasssenstatutdattentejour__c,
        case.Tempspassenfiledattente__c,
        case.Tempspassepourtraitement__c,
        case.closeddate,
        case.Owner.Type,
        caseid,
        newvalue,
        oldvalue,
        field,
        createddate
      FROM casehistory
      WHERE caseid IN :caseup AND field = 'Owner'
      ORDER BY createddate ASC
    ];
	System.debug('casehistorOwner:'+casehistorOwner);
    List<casehistory> casehistorStat = [
      SELECT
        Id,
        case.Tempspassenfiledattente__c,
        case.Tempspassepourtraitement__c,
        case.Tempspasssenstatutdattentejour__c,
        case.closeddate,
        case.Owner.Type,
        caseid,
        newvalue,
        oldvalue,
        field,
        createddate
      FROM casehistory
      WHERE caseid IN :caseup AND field = 'Status'
      ORDER BY createddate ASC
    ];
	System.debug('casehistorStat:'+casehistorStat);
    List<Group> Queue = [SELECT id FROM Group WHERE Type = 'Queue'];
    List<id> idQueue = new List<id>();
    for (Group qu : Queue) {
      idQueue.add(qu.id);
    }

    List<User> User = [SELECT id FROM User];
    List<id> idUser = new List<id>();
    for (User us : User) {
      idUser.add(us.id);
    }

    BusinessHours bh = [SELECT id FROM businesshours WHERE IsDefault = TRUE];
     TMT(caseup, casehistorOwner, casehistorStat, idQueue, idUser, bh);
    }
    
    
    public static void TMT(
        List<case> caseup,
        List<casehistory> casehistorOwner,
        List<casehistory> caseStatusHistory,
        List<id> idQueue,
        List<id> idUser,
        BusinessHours bh
    ) {
        System.debug('enter TMT Rework:');
        
        System.debug('casehistorOwner:'+casehistorOwner);
        System.debug('caseStatusHistory:'+caseStatusHistory);
        Datetime startmiseEnAttente;
        Datetime EndMiseEnAttente;
        Datetime DateTimeResolue;
        
        Datetime exitEnAttente;
        Datetime enterEnAttente;
        Integer exitEnAttenteIndex;
        
        Integer Tempspasssenstatutdattente = 0;
        Integer Tempspassepourtraitement = 0;
        Integer Tempspassenfiledattente = 0;
        
        Map<String,List<casehistory>> caseEnAttenteMap = new Map<String,List<casehistory>>();
        Map<String,List<casehistory>> caseNePlusEnAttenteMap = new Map<String,List<casehistory>>();
        Map<String,List<casehistory>> caseResolueMap = new Map<String,List<casehistory>>();
        List<String> statusList = new List<String>();
        
        Map<String,List<casehistory>> newStatusMap = new Map<String,List<casehistory>>();
        Map<String,List<casehistory>> oldStatusMap = new Map<String,List<casehistory>>();
        List<Case> CaseListToUpdate = new List<Case>();
        
        for(Case cs : caseup){
            System.debug('cs :'+cs);
            List<casehistory> currentCaseStatusHistory = new List<casehistory>();
            for(casehistory ch0 : caseStatusHistory){
                if(ch0.caseid == cs.Id){
                  currentCaseStatusHistory.add(ch0);
                }
            }
            if(casehistorOwner.size() == 0){
                System.debug('casehistorOwner empty');
                Tempspassenfiledattente = Integer.ValueOf(CalculNbJours(cs.CreatedDate, Datetime.now(), bh));//Date.today()
                if(Tempspassenfiledattente > 0){
                    cs.Tempspassenfiledattente__c = Tempspassenfiledattente - 1;
                }else{
                    cs.Tempspassenfiledattente__c = Tempspassenfiledattente;
                }
                
            }else{
                for(casehistory csOwnr : casehistorOwner){
                    System.debug('enter csOwnr:'+csOwnr);
                    System.debug('case owner:'+Case.Owner.Type);
                    if(csOwnr.caseid == cs.Id && csOwnr.oldvalue!=csOwnr.newvalue){//csOwnr.Case.Owner.Type =='Queue'
                        System.debug('enter change owner');
                        Tempspassenfiledattente = Integer.ValueOf(CalculNbJours(cs.CreatedDate, csOwnr.CreatedDate, bh));
                        System.debug('cs.CreatedDate :'+cs.CreatedDate);
                        System.debug('csOwnr.CreatedDate :'+csOwnr.CreatedDate);
                        System.debug('Tempspassenfiledattente :'+Tempspassenfiledattente);
                        if(Tempspassenfiledattente > 0){
                            cs.Tempspassenfiledattente__c = Tempspassenfiledattente - 1;
                        }else{
                            cs.Tempspassenfiledattente__c = Tempspassenfiledattente; 
                        }
                        break;
                    }else{
                        System.debug('enter else');
                        Tempspassenfiledattente = Integer.ValueOf(CalculNbJours(cs.CreatedDate, Datetime.now(), bh));
                        if(Tempspassenfiledattente > 0){
                            cs.Tempspassenfiledattente__c = Tempspassenfiledattente - 1;
                        }else{
                            cs.Tempspassenfiledattente__c = Tempspassenfiledattente; 
                        }
                    }
                }
            }

            if(currentCaseStatusHistory.size()<1){
                Tempspassepourtraitement = Integer.ValueOf(CalculNbJours(cs.CreatedDate,Datetime.now(), bh));
            }else {
                for(casehistory ch : currentCaseStatusHistory){
                    System.debug('enter ch :'+ch);
                    if(ch.NewValue == 'En attente' && !cs.IsClosed){
                        Tempspasssenstatutdattente += Integer.ValueOf(CalculNbJours(ch.CreatedDate,Datetime.now(),bh));
                    }
                    if(ch.OldValue == 'En attente'){
                        System.debug('enter En attente :');
                        exitEnAttente = ch.CreatedDate;
                        System.debug('exitEnAttente :'+exitEnAttente);
                        exitEnAttenteIndex = currentCaseStatusHistory.indexOf(ch);
                        System.debug('exitEnAttenteIndex :'+exitEnAttenteIndex);
                        enterEnAttente = currentCaseStatusHistory.size()>1?currentCaseStatusHistory.get(exitEnAttenteIndex-1).CreatedDate : ch.CreatedDate;
                        System.debug('enterEnAttente :'+enterEnAttente);
                        Tempspasssenstatutdattente += Integer.ValueOf(CalculNbJours(enterEnAttente,exitEnAttente,bh));
                        //Tempspasssenstatutdattente = Tempspasssenstatutdattente - 1;
                        System.debug('Tempspasssenstatutdattente :'+Tempspasssenstatutdattente);
                        System.debug('Tempspassepourtraitement :'+Tempspassepourtraitement);
                    }else if(cs.IsClosed){
                        System.debug('enter IsClosed :'+cs.IsClosed);
                        Tempspassepourtraitement = Integer.ValueOf(CalculNbJours(cs.CreatedDate, cs.ClosedDate, bh));
                        if(Tempspassepourtraitement > 0){
                            Tempspassenfiledattente = Tempspassenfiledattente - 1;
                        }
                    }else{
                        Tempspassepourtraitement = Integer.ValueOf(CalculNbJours(cs.CreatedDate,Datetime.now(), bh));
                        if(Tempspassepourtraitement > 0){
                            Tempspassenfiledattente = Tempspassenfiledattente - 1;
                        }
                    }
                } 
            }

            cs.Tempspassepourtraitement__c = Tempspassepourtraitement-Tempspasssenstatutdattente;
            cs.Tempspasssenstatutdattentejour__c = Tempspasssenstatutdattente;
            System.debug('Tempspassepourtraitement__c :'+cs.Tempspassepourtraitement__c);
            System.debug('Tempspasssenstatutdattentejour__c :'+cs.Tempspasssenstatutdattentejour__c);
            CaseListToUpdate.add(cs);
        }
            update CaseListToUpdate;
    }
    
    public static Long CalculNbJours(
        Datetime startDate,
        Datetime endDate,
        BusinessHours bh
    ) {
        Long nbJours;
        //Diff donne un résultat en ms qu'il faut convertir en jour
        Long diff = BusinessHours.diff(bh.id, startDate, endDate);
        //Les journées dans business hours sont définies sur 24h. Si jamais c'est changé, il faut modifier par le nombre d'heure travaillées par jour
        nbJours = diff / (3600000 * 24);
        System.debug('nbJours = ' + nbJours);
        Return nbJours;
    }
}