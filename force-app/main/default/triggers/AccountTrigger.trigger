trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Framework.createHandler(Account.sObjectType);
}