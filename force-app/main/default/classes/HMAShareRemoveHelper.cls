public with sharing class HMAShareRemoveHelper {

    public String objName {get; set;}
    public String shareObjectName {get; set;}
    public String parentIdFieldName {get; set;}
    public String shareLevelFieldName {get; set;}
    public Map<String, SObject> shares {get; set;}
    public Set<String> granteeIds {get; set;}
    public Set<String> parentIds {get; set;}
    public Set<String> shareLevels {get; set;}

    public HMAShareRemoveHelper(String objName) {
        this.objName = objName;
        this.shareObjectName = objName.endsWith('__c') ?
                objName.replace('__c', '__Share') : (objName + 'Share');
        this.parentIdFieldName = objName.endsWith('__c') ? 'ParentId' : (objName + 'Id') ;
        this.shareLevelFieldName = objName.endsWith('__c') ? 'AccessLevel' : (objName + 'AccessLevel');
        this.granteeIds = new Set<String>();
        this.parentIds = new Set<String>();
        this.shareLevels = new Set<String>();
        this.shares = new Map<String, SObject>();
    }

    public String add(SObject record) {
        String parentId = (String)record.get(parentIdFieldName);
        String shareLevel = (String)record.get(shareLevelFieldName);
        granteeIds.add((String)record.get('UserOrGroupId'));
        parentIds.add((String)parentId);
        shareLevels.add((String)shareLevel);
        String key = parentId + '_' + (record.get('RowCause') == null ? 'Manual' : record.get('RowCause')) +
                '_' + record.get('UserOrGroupId') + '_' + shareLevel;
        key = key.toLowerCase();
        shares.put(key, record);
        return key;
    }

    public String getGranteeIds() {
        return getQueryString(granteeIds);
    }

    public String getParentIds() {
        return getQueryString(parentIds);
    }

    public String getShareLevels() {
        return getQueryString(shareLevels);
    }

    private String getQueryString(Set<String> values) {
        String queryString = '';
        for (String value : values) {
            queryString += '\'' + value + '\',';
        }
        queryString = queryString.substringBeforeLast(',');
        return queryString;
    }
}