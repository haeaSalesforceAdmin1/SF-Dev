trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Framework.createHandler(Contact.sObjectType);
}