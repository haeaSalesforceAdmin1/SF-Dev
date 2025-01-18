public with sharing class RelatedCaseTriggerHandler extends Trigger_Framework.baseHandler {

    public override void beforeDelete(Map<Id,Sobject> oldMapGeneric) {
        system.debug('Entered before Delete');
        
        Map<Id, RelatedCase__c> oldMap = (Map<Id, RelatedCase__c>) oldMapGeneric; 
        
		List < Case > poList = new List < Case > ();
        Set < Id > Po_Idss = new Set < Id > ();
        map<id,case> cmap = new map<id,case>();
		for (RelatedCase__c childObj: oldMap.values())
		{
              Po_Idss.add(childObj.Case__c);
        }
        system.debug('id set'+Po_Idss);
		List < Case > po = [Select Id, Related_Cases__c from Case where Id IN: Po_Idss];
        system.debug('case list'+po);
        //List < RelatedCase__c > rc = [SELECT RelatedCaseSafetyNumber__c FROM RelatedCase__c where Case__c IN:Po_Idss];
        //system.debug('rc is'+rc);
        
        for(Case p : po){
            for (RelatedCase__c c: oldMap.values()){
            if(p.Related_Cases__c !=null){
                p.Related_Cases__c +=+' '+ c.RelatedCaseSafetyNumber__c +';'; 
                poList.add(p);
               cmap.putall(poList);
                }
                else{
                p.Related_Cases__c = c.RelatedCaseSafetyNumber__c +';';
                poList.add(p);
               cmap.putall(poList);
                }

            }
        }
		
        //update poList;
        if(cmap.size()>0){
        update cmap.values();
           }
	}
    
}