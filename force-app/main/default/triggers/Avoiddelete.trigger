trigger Avoiddelete on Request__c (before delete) {
for (Request__c req: trigger.old) {
        if(req.Integrity_Check_EAI__c == true){
            trigger.old[0].addError('Delete Request is not permitted because it has already sent to SIMS');
        }
    }

}