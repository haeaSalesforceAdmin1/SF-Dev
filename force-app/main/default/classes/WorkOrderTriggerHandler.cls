/**
 ************************************************************************************************
 * @classname         : WorkOrderTriggerHandler
 * @description       : [STIL Project] Before/After Insert, Before/After Update trigger for WorkOrder(Lab Request) Object.
 * @author            : San, Kang
 * History
 * Version      Date                Author               Story/Bug         Modification
 * 1.0       th Jul 2024            San, Kang             OU24-            Initial Version
 * 1.0       17th Jul 2024          Hayeon Cho            OU24-109         Numbering process
 * 1.0       25th Jul 2024          Inho Kim              OU24-109         Modified some code to handle null values(list)
 ************************************************************************************************
 **/
public with sharing class WorkOrderTriggerHandler extends Trigger_Framework.baseHandler {
    
    /**
     * @description : STIL Project Add Lab Request Numbering process (07/17/2024)
     * @author Hayeon Cho : hayeoncho@autoeveramerica.com
     */
    public override void beforeInsert(List<SObject> newListGeneric){
        
        /*
         Set New Custom LR Number.
         
        Case 1 - When insert begun, a LR already has a Safety_Case_Number__c && There is a record that has same Safety_Case_Number__c 
             - In this situation, there is no need to generate a serial number from the Lab_Request_Number_Master__c object.
             
        Case 2 - When insert begun, a LR already has a Safety_Case_Number__c && but this is first LR that is related to the specific Safety Case
        
        Case 2-1 If an attempt to generate a serial number based on the current year's records is successful, use that number as the serial number 
                and increment the NextNumber__c field in the Lab_Request_Number_Master__c object by 1.
        Case 2-2 If an attempt to generate a serial number based on the current year's records is unsuccessful, insert new Lab_Request_Number_Master__c for 
                new year (year value is in Name field) , and use that record's number as the serial number. (e.g. {Year}-00001-01)

         */
            
        try{

            // Assumption that LR insertion is one.
            if(newListGeneric.size() == 1){
                WorkOrder lr;    
                //Get Lab Request
                lr = (WorkOrder)newListGeneric.get(0);
                Integer LRMiddleNumber=0; //0000N
                Integer LRLastNumber=0; //01
                String Year = String.valueOf(Date.today().year());                
                //Check if LR from same case exist
                List<WorkOrder> lrs = [SELECT Id, Lab_Request_Number__c, Safety_Case_Number__c FROM WorkOrder 
                                    WHERE Safety_Case_Number__c = :lr.Safety_Case_Number__c
                                    ORDER BY CreatedDate Desc Limit 1];
                
                System.Debug('lrs Debug : '+lrs);
                WorkOrder pLR;
                String pLRNumber;
                if(! lrs.isEmpty()){
                    pLR = lrs.get(0);
                    pLRNumber = pLR.Lab_Request_Number__c;
                    System.Debug('pLR Debug : '+pLR);
                    System.Debug('pLRNumber Debug : '+pLRNumber);
                    
                }
                
                
                // Case 1 - When insert begun, a LR already has a Safety_Case_Number__c && There is a record that has same Safety_Case_Number__c
                if(lrs.size() > 0 && lr.Safety_Case_Number__c!=null && pLRNumber != null){
                    //If exists, set middle Number same as previous LR and increase last number
                    Year = pLRNumber.split('-').get(1);
                    String pLRMiddleNum = pLRNumber.split('-').get(2);
                    String pLRLastNum = pLRNumber.split('-').get(3);
                    LRMiddleNumber = Integer.valueOf(pLRMiddleNum);
                    LRLastNumber = Integer.valueOf(pLRLastNum)+1;

                // Case 2) - When insert begun, a LR already has a Safety_Case_Number__c && but this is first LR that is related to the specific Safety Case
                }else{
                    //If not exists, set middle Number as nextnumber of metadata and set 01 to last number
                    List<Lab_Request_Number_Master__c> numbers = [SELECT Id, NextNumber__c FROM Lab_Request_Number_Master__c WHERE Name = :Year];

                    //Case 2-1)
                    if(numbers.size()>0){
                        //Get number master's Nextnumber and update data
                        Lab_Request_Number_Master__c numdata = numbers.get(0);
                        LRMiddleNumber = Integer.valueOf(numdata.NextNumber__c);
                        LRLastNumber = 1;
                        numdata.NextNumber__c = LRMiddleNumber+1;
                        update numdata;
                    //Case 2-2)
                    }else{
                        // Insert number master for year update
                        LRMiddleNumber = 1;
                        LRLastNumber = 1;
                        Lab_Request_Number_Master__c newdata = new Lab_Request_Number_Master__c();
                        newdata.Name = Year;
                        newdata.NextNumber__c = LRMiddleNumber+1;
                        insert newdata;
                    }
                }
                
                //set LRNumber with proper form
                String LRNumber = 'STIL-'+Year+'-'+String.valueOf(LRMiddleNumber).leftPad(5, '0')+'-'+String.valueOf(LRLastNumber).leftPad(2, '0');
                lr.Lab_Request_Number__c = LRNumber;
            }
        } catch(Exception e){            System.debug('Error Lab Request Trigger Handler: Before Insert ' + e.getMessage());        }
    }
    
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        
    }
    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        
    }
    
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        try{        
            // Field History Tracking init
            RRPFieldHistoryUtil.initReferences(oldMapGeneric.values());
            RRPFieldHistoryUtil.trackUserChanges(newMapGeneric.values());
            
            RRPFieldHistoryUtil.setContext(
                RRPFieldHistoryUtil.CONTEXT_TRIGGER,
            WorkOrder.getSObjectType().getDescribe().getName(),
            WorkOrderTriggerHandler.class.getName()
                );
            
            // Field History Tracking save logs
            RRPFieldHistoryUtil.takeSnapshots(newMapGeneric.keySet());
            RRPFieldHistoryUtil.commitLogs();
            RRPFieldHistoryUtil.resetContext(RRPFieldHistoryUtil.CONTEXT_TRIGGER);

        } catch(Exception e){            System.debug('Error Lab Request Trigger Handler: After Update ' + e.getMessage());        }
    }
    
}