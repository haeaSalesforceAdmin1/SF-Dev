trigger WorkOrderTrigger on WorkOrder (before insert, before update, after insert, after update) {
    Trigger_Framework.createHandler(WorkOrder.sObjectType);
}