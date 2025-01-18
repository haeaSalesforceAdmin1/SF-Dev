public without sharing class DNAMSFileBannerController {

    @AuraEnabled
    public static ReturnWP fetchFields(String recordId, String objectName) {
        system.debug('recordId: '+recordId);
        system.debug('objectName: '+objectName);
        ReturnWP res = new ReturnWP();
        try {
            // Querying Name Field
            if(String.isBlank(recordId)) {
                res.message = 'Invalid Id';
                return res;
            }
            //List<sObject> objectList = Database.query('SELECT id, title,FileType,FileExtension FROM ' + objectName + ' WHERE ContentDocumentid =: recordId');
            List<sObject> recordlist = Database.query('SELECT id, title,FileType,Contentsize,FileExtension,Owner.Name,Ownerid FROM ' + objectName + ' WHERE Id =: recordId');
            List<Contentdocumentlink> condoclinklist = [Select id,linkedEntityid from contentdocumentlink where contentdocumentid =: recordId];
            system.debug('objectList: '+recordlist);
            String objname = '';
            Boolean isHideowner = true;
            for(Contentdocumentlink conlink : condoclinklist){
                objname = conlink.linkedEntityid.getSObjectType().getDescribe().getName();
                if(objname == 'Action_Plan__c' || objname == 'Evaluation__c'){
                    isHideowner = false;
                }
            }
            res.nameField = String.valueof(recordlist[0].get('title'));
            res.conversionId = String.valueof(recordlist[0].get('id'));
            res.isHideowner = isHideowner;
            res.fileResult = recordlist;
            return res;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class ReturnWP {
        @AuraEnabled public String message;
        @AuraEnabled public String nameField;
        @AuraEnabled public String conversionId;
        @AuraEnabled public Boolean isHideowner;
        @AuraEnabled public List<sObject> fileResult;
    }
}