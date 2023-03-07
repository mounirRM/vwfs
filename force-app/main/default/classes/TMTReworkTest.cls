@isTest
public class TMTReworkTest {
    
    @isTest static void TestTmtOwner() {
        List<Case> caseup = new List<Case>();
        List<casehistory> casehistorOwner = new List<casehistory>();
        List<casehistory> caseStatusHistory = new List<casehistory>();
        List<Id> idQueue = new List<Id>();
        List<Id> idUser = new List<Id>();
        BusinessHours bh = [SELECT id FROM businesshours WHERE IsDefault = TRUE];
        
        User usr1 = [SELECT Id FROM User LIMIT 1];
        system.debug('usr1:'+usr1);
        idUser.add(usr1.Id);
        
        Case case1 = new Case();
        case1.Origin = 'Email';
        case1.Status = 'A traiter';
        Insert case1;
        
        casehistory ch1 = new casehistory();
        ch1.CaseId = case1.Id;
        ch1.Field = 'Owner';
        Insert ch1;
        
        case1.OwnerId = usr1.Id;
        update case1;
        
        caseup = [SELECT Id,createdDate,Status,OwnerId FROM Case WHERE Id =: case1.Id];
        
        caseStatusHistory = [
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
        
        casehistorOwner = [
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
        TMTRework.TMT(caseup, casehistorOwner, caseStatusHistory, idQueue, idUser, bh);
    }
    
    @isTest static void TestTmt() {
        List<Case> caseup = new List<Case>();
        List<casehistory> casehistorOwner = new List<casehistory>();
        List<casehistory> caseStatusHistory = new List<casehistory>();
        List<Id> idQueue = new List<Id>();
        List<Id> idUser = new List<Id>();
        BusinessHours bh = [SELECT id FROM businesshours WHERE IsDefault = TRUE];
        
        Case case1 = new Case();
        case1.Origin = 'Email';
        case1.Status = 'A traiter';
        Insert case1;
        
        casehistory ch1 = new casehistory();
        ch1.CaseId = case1.Id;
        ch1.Field = 'Created';
        Insert ch1;
        caseup = [SELECT Id,createdDate,Status,OwnerId FROM Case WHERE Id =: case1.Id];
        System.debug('caseup:'+caseup);
        caseStatusHistory = [
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
        
        casehistorOwner = [
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
        TMTRework.TMT(caseup, casehistorOwner, caseStatusHistory, idQueue, idUser, bh);
    }
    @isTest static void TestTmtEnattente() {
        List<Case> caseup = new List<Case>();
        List<casehistory> casehistorOwner = new List<casehistory>();
        List<casehistory> caseStatusHistory = new List<casehistory>();
        List<Id> idQueue = new List<Id>();
        List<Id> idUser = new List<Id>();
        BusinessHours bh = [SELECT id FROM businesshours WHERE IsDefault = TRUE];
        
        Case case1 = new Case();
        case1.Origin = 'Email';
        case1.Status = 'A traiter';
        Insert case1;
        case1.Status = 'En attente';
        update case1;
        casehistory ch1 = new casehistory();
        ch1.Field = 'Status';
        ch1.CaseId = case1.Id;
        Insert ch1;
        
        caseup = [SELECT Id,createdDate,Status,OwnerId,IsClosed FROM Case WHERE Id =: case1.Id];
        System.debug('caseup:'+caseup);
        caseStatusHistory = [
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
        
        casehistorOwner = [
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
        
        TMTRework.TMT(caseup, casehistorOwner, caseStatusHistory, idQueue, idUser, bh);
    }
    
        @isTest static void TestTmtLeaveEnattente() {
        List<Case> caseup = new List<Case>();
        List<casehistory> casehistorOwner = new List<casehistory>();
        List<casehistory> caseStatusHistory = new List<casehistory>();
        List<Id> idQueue = new List<Id>();
        List<Id> idUser = new List<Id>();
        BusinessHours bh = [SELECT id FROM businesshours WHERE IsDefault = TRUE];
        
        Case case1 = new Case();
        case1.Origin = 'Email';
        case1.Status = 'A traiter';
        Insert case1;
        case1.Status = 'En attente';
        update case1;
        case1.Status = 'En cours de traitement';
        update case1;
        casehistory ch1 = new casehistory();
        ch1.Field = 'Status';
        ch1.CaseId = case1.Id;
        Insert ch1;
        
        caseup = [SELECT Id,createdDate,Status,OwnerId,IsClosed FROM Case WHERE Id =: case1.Id];
        System.debug('caseup:'+caseup);
        caseStatusHistory = [
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
        
        casehistorOwner = [
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
        
        TMTRework.TMT(caseup, casehistorOwner, caseStatusHistory, idQueue, idUser, bh);
    }
    
    @isTest static void TestTmtClosed() {
        List<Case> caseup = new List<Case>();
        List<casehistory> casehistorOwner = new List<casehistory>();
        List<casehistory> caseStatusHistory = new List<casehistory>();
        List<Id> idQueue = new List<Id>();
        List<Id> idUser = new List<Id>();
        BusinessHours bh = [SELECT id FROM businesshours WHERE IsDefault = TRUE];
        
        Case case1 = new Case();
        case1.Origin = 'Email';
        case1.Status = 'A traiter';
        Insert case1;
        case1.Status = 'En attente';
        update case1;
        case1.Status = 'Résolue';
        case1.Equipe__c = 'Fleet - RC';
        case1.Motif__c = 'Attestations contrat';
        case1.Sous_motif__c = 'Copie documents contrat';
        update case1;
        casehistory ch1 = new casehistory();
        ch1.CaseId = case1.Id;
        ch1.Field = 'Owner';
        Insert ch1;
        
        caseup = [SELECT Id,createdDate,Status,OwnerId,IsClosed FROM Case WHERE Id =: case1.Id];
        System.debug('caseup:'+caseup);
        caseStatusHistory = [
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
        
        casehistorOwner = [
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
        
        TMTRework.TMT(caseup, casehistorOwner, caseStatusHistory, idQueue, idUser, bh);
    }
}