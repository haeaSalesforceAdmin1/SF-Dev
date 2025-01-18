trigger PackageElementBothTrigger on PackageElement__c (after insert, before insert, before update, after update, before delete, after delete) { 
   System.debug('Hello World!');
    FSTR.COTriggerHandler.handleBothTrigger();
}