trigger SodasAlert on Case (before insert, before update)
{
    //20230807 Bitna Seong : Comment out for refactoring
    
    // if(Trigger.isBefore)
    // {
    //     if(Trigger.IsInsert)
    //     {
    //         If( trigger.new[0].SODAS_Alert_ID__c != null)
    //            {

    //              trigger.new[0].SODAS_Multiple_Alerts__c = trigger.new[0].SODAS_Alert_ID__c ;
    //            }
    //     }
    //     else if(Trigger.IsUpdate)
    //     {
    //         If( trigger.new[0].SODAS_Alert_ID__c != trigger.old[0].SODAS_Alert_ID__c)
    //                 {
    //                    String test = trigger.old[0].SODAS_Multiple_Alerts__c;
    //                    If(test==null){
    //                                    trigger.new[0].SODAS_Multiple_Alerts__c = trigger.new[0].SODAS_Alert_ID__c ;
    //                                  }
    //                    else          {
    //                                    trigger.new[0].SODAS_Multiple_Alerts__c = test+';'+trigger.new[0].SODAS_Alert_ID__c ;
    //                                  }
    //                 }
    //     }
    // }
}