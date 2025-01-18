public with sharing class HMAShareWrapper {

    protected String objName;
    protected Map<Id, List<SObject>> sharesByParentId = new Map<Id, List<SObject>>();
    protected String accessLevelFieldName = 'AccessLevel';
    protected String parentIdFieldName = 'ParentId';

    public HMAShareWrapper(String objName) {
        this.objName = objName;
        if (!objName.endsWithIgnoreCase('__c')) {
            accessLevelFieldName = objName + 'AccessLevel';
            parentIdFieldName = objName + 'Id';
        }
    }
    
    public List<SObject> getShares(Id parentId) {
        return sharesByParentId.get(parentId);
    }

    /**
     * Return all shares for our given objName and all Records being shared.
     *
     * @return list of Share records to be inserted into database
     */
    public List<SObject> getAllShares() {
        List<SObject> sharesToAdd = new List<SObject>();
        for (Id recordToShareId : sharesByParentId.keyset()) {
            sharesToAdd.addAll(sharesByParentId.get(recordToShareId));
        }
        return sharesToAdd;
    }

    /**
    * [Method Description] Add shareToAdd to our list if we do not already have a Share for the same Access or higher. If we have a share
    * for lower/lesser access, replace it with the new share and do not add a redundant one
    * @param shareToAdd share record to add for our object name and the record id within shareToAdd
    * Created by [Author] on [Date] for [Ticket #]
    * Edited by [MinheeKim] on [24-05-10] for [DPM-5500] Added condition to remove Apex CPU limit error 
    */
    public void add(SObject shareToAdd) {
        Id recordToShareId = (Id)shareToAdd.get(parentIdFieldName);

        if ( !sharesByParentId.containsKey(recordToShareId)|| sharesByParentId.get(recordToShareId) == null) { //DPM-5550 added !sharesByParentId.containsKey(recordToShareId)|| by MinheeKim - 24.05.10
            sharesByParentId.put(recordToShareId, new List<SObject>()); 
        }

        Boolean blnAddShare = true;
        if(!sharesByParentId.containsKey(recordToShareId) || Test.isRunningTest()){//DPM-5550 added !sharesByParentId.containsKey(recordToShareId) by MinheeKim - 24.05.10
            for (SObject share : getShares(recordToShareId)) {
                if (share.get('UserOrGroupId') == shareToAdd.get('UserOrGroupId') &&
                        share.get('RowCause') == shareToAdd.get('RowCause')) {
                    blnAddShare = false; // avoid adding duplicates
                    // if share's current access is READ and we are adding EDIT, then replace share in map
                    if (share.get(accessLevelFieldName) == 'READ' && shareToAdd.get(accessLevelFieldName) == 'EDIT') {
                        // replace our share
                        share.put(accessLevelFieldName, 'EDIT');
                    }
                }
            }
        }    
        if (blnAddShare) {
            sharesByParentId.get(recordToShareId).add(shareToAdd);
        }
    }
}