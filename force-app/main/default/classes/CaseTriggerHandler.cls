/**
 * @author Yves RUMURI
 * @date Creation 10/05/2021
 * @description CaseTrigger
 * Ver   Date         Author                               Modification
 * 1.0   10-05-2021   YRU                             Initial Version [P002156-1609]
 */
public with sharing class CaseTriggerHandler {
  public static void handleTrigger(
      List<Case> caseList,
      System.TriggerOperation triggerEvent,
      Map<Id,Case> oldMap,
      Map<Id,Case> newMap
  ) {
      switch on triggerEvent {
          when BEFORE_UPDATE {
              handleBeforeUpdate(oldMap,newMap);
          }
    when AFTER_INSERT {
    }
    when AFTER_UPDATE {
      if (checkRecursive.firstcall) {
        checkRecursive.firstcall = false;
        handleAfterUpdate(caseList);
      }
    }
  }
}
  
  public static void handleBeforeUpdate(Map<Id,Case> oldMap,Map<Id,Case> newMap) {
      Set<Id> caseOwnerIdSet = new Set<Id>();
      Set<Id> userIdstoAllows = new Set<Id>();
      Set<Id> queuesIdstoAllows = new Set<Id>();
      Id extAgentRleId;
      Id extSuperviseurRleId;
      List<ExternalRoleSharingConfig__mdt> allowedQueues = [SELECT Id,Label FROM ExternalRoleSharingConfig__mdt];
      System.debug('allowedQueues:'+allowedQueues);
      List<UserRole> extRoleList = [SELECT Id,Name FROM UserRole WHERE (Name='agent_RC_ext' OR Name='superviseur_RC_ext')];
      System.debug('extRoleList:'+extRoleList);
      for(UserRole usr : extRoleList){
          if(usr.Name == 'agent_RC_ext'){
              extAgentRleId = usr.Id;
          }else if(usr.Name == 'superviseur_RC_ext'){
              extSuperviseurRleId = usr.Id;
          }  
      }
      System.debug('extAgentRleId:'+extAgentRleId);
      System.debug('extSuperviseurRleId:'+extSuperviseurRleId);
      if(UserInfo.getUserRoleId()==extAgentRleId || UserInfo.getUserRoleId()==extSuperviseurRleId){
          for(Id ids : newMap.keyset()){
               caseOwnerIdSet.add(newMap.get(ids).ownerId);
          }
      }
      System.debug('caseOwnerIdSet:'+caseOwnerIdSet);
      List<User> caseOwnerUser = [SELECT id,UserRoleId,Equipe__c from USER where id =:caseOwnerIdSet];
      System.debug('caseOwnerUser:'+caseOwnerUser);
      if(caseOwnerUser.size()>0){
          for(User usr : caseOwnerUser){
              for(ExternalRoleSharingConfig__mdt ext : allowedQueues){
                  if(usr.equipe__c == ext.Label){
                      userIdstoAllows.add(usr.Id); 
                  }  
              }
          }
      }
      System.debug('userIdstoAllows:'+userIdstoAllows);
      List<Group> myQueues = [SELECT id,Name from Group where id =:caseOwnerIdSet];
      if(myQueues.size()>0){
          for(Group que : myQueues){
              for(ExternalRoleSharingConfig__mdt ext : allowedQueues){
                  if(que.Name == ext.Label){
                      queuesIdstoAllows.add(que.Id); 
                  }
              }
          }
      }
      System.debug('queuesIdstoAllows:'+queuesIdstoAllows);
      if(caseOwnerIdSet.size()>0){
          for(Case cs : newMap.values()){
              Boolean displayError = true;
              if(userIdstoAllows.size()>0){
                  for(Id ids : userIdstoAllows){
                      if(cs.OwnerId == ids){
                          displayError = false;
                      }
                  }
              }
              if(queuesIdstoAllows.size()>0){
                  for(Id ids : queuesIdstoAllows){
                      System.debug('OwnerId:'+cs.OwnerId);
                      system.debug('ids:'+ids);
                      if(cs.OwnerId == ids){
                          system.debug('enter if ');
                          displayError = false;
                          system.debug('displayError');
                      }
                  }
              }
              if(displayError == true){
                  cs.addError(System.label.extRoleRestrictionError);
              }
          }  
      }
      ParentCase.caseUpdate(oldMap, newMap);
  }
public static void handleAfterInsert(List<Case> caseList) {
 
}

public static void handleAfterUpdate(List<Case> caseList) {
    
    List<Id> idList = new List<Id>();
    for(Case cs : caseList){
        idList.add(cs.id);
    }
    
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
    WHERE id IN :caseList
  ];
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

  //TMT.TMT(caseup, casehistorOwner, casehistorStat, idQueue, idUser, bh);
  //TMTRework.TMT(caseup, casehistorOwner, casehistorStat, idQueue, idUser, bh);
      if(System.isFuture() == false && System.isBatch() == false){ 
        TMTRework.TMT(idList);
    }
}
}