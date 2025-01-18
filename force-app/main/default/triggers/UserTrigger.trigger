/**
* @date 09/28/2020
* @description Trigger for User actions
*/
trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	Trigger_Framework.createHandler(User.sObjectType);
}