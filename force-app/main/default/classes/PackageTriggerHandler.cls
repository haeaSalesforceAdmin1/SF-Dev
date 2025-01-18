public without sharing class PackageTriggerHandler extends Trigger_Framework.baseHandler {
    
    
    public static Boolean run = true;
    public override void afterUpdate(Map<Id, SObject> oldMapPackage, Map<Id, SObject> newMapPackage) {
        system.debug('after update---enter-------' );
        if(!run) { return; }
        Set<Id> setPackageids = new Set<Id>();
        
        Map<Id, Package__c> newMap = (Map<Id, Package__c>) newMapPackage;
        Map<Id, Package__c> oldMap = (Map<Id, Package__c>) oldMapPackage;
        system.debug('after update---enter--newMap.values---'+ newMap.values());
        system.debug('after update---enter--oldMap---'+ oldMap.values());
        for(Package__c pac : newMap.values()){
            system.debug('after update---enter--pac---'+ pac);
            if(pac.Status__c != oldMap.get(pac.id).Status__c && pac.Status__c == 'Closed'){
                setPackageids.add(pac.id);/// empty for the record taken
                system.debug('after update---enter--oldMap---'+oldMap.get(pac.id).Status__c);
            }
        }
        system.debug('after update---enter----setPackageids---'+ setPackageids);
        if(!setPackageids.IsEmpty()){
            //Calling Future Method
            PackageClosureNotificationFuture.processPackageCloserNotifications(setPackageids);
        }    
    }
    
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric) {
    system.debug('befre update----------' );
    }   

}