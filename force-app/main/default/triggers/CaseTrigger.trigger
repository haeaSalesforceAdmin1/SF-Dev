trigger CaseTrigger on Case (before insert, before update, after insert, after update, after delete) {
    Trigger_Framework.createHandler(Case.sObjectType);
}