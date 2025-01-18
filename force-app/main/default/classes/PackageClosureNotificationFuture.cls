global class PackageClosureNotificationFuture {
    @future
    public static void processPackageCloserNotifications(Set<Id> setPackageids){  
        
        List<Id> ContentDocumentids = new List<Id>();
        Map<Id,List<ContentDocumentLink>> mapPackageContentLink = new Map<Id,List<ContentDocumentLink>>();
        Map<Id,ContentVersion> mapContentversion = new Map<Id,ContentVersion>();
        List<Messaging.SingleEmailMessage> lstSingleEmailmsg = new List<Messaging.SingleEmailMessage>();
        Map<String,Id> mapOwdAdrs = new Map<String,Id>();
        //Getting random contact 
        Contact cnt = [select id, Email from Contact where email != null limit 1];
        //Getting email Template if Name eqauals 'DNA Package Closure Notification1' and also removed the ':'
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name = 'DNA Package Closure Notification1'];
        //Getting org wide email addresses basis on the Displayname 
        List<OrgWideEmailAddress> lstEmailAddress = [select Id,Displayname from OrgWideEmailAddress WHERE Displayname in ('Hyundai DNAMS Notifications','Genesis DNAMS Notifications')];
        for(OrgWideEmailAddress OwdAdrs : [select Id,Displayname from OrgWideEmailAddress WHERE Displayname in ('Hyundai DNAMS Notifications','Genesis DNAMS Notifications')]){
            mapOwdAdrs.put(OwdAdrs.Displayname,OwdAdrs.id);
        }
        //Query on PE to get the records where Send_Email_Flag__c set to true and parent records is Package record
        List<PackageElement__c> peList= new List<PackageElement__c>();
        peList = [SELECT Id,Package__r.Dealer_Brand_Code__c,Email_List__c, (Select id,LinkedEntityid, ContentDocumentid from ContentDocumentLinks) FROM PackageElement__c where Send_Email_Flag__c = True and Package__c in: setPackageids];
        if(peList.size() > 0){//If we don't get the peList then will not execute the logic
            for(PackageElement__c pacEle : peList){
                mapPackageContentLink.put(pacEle.id,pacEle.ContentDocumentLinks);
                for(ContentDocumentLink conlink : pacEle.ContentDocumentLinks){
                    ContentDocumentids.add(conlink.ContentDocumentid);
                }
            }
            for(ContentVersion cversion : [SELECT ContentDocumentId,title,PathOnClient, FileType,FileExtension, versiondata FROM contentversion WHERE ContentDocumentId IN :ContentDocumentids]){
                mapContentversion.put(cversion.ContentDocumentId,cversion);
            }
            
            for(PackageElement__c pacEle : peList){
                String[] receipients = new String[]{};
                String Emaillist = pacEle.Email_List__c.deleteWhitespace();
                for(String adr : Emaillist.split(',')){
                    if(adr != null && adr !=''&& adr != ' '){
                        receipients.add(adr);
                    }
                }
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setWhatId(pacEle.Id); //This is important for the merge fields in template to work
                if(pacEle.Package__r.Dealer_Brand_Code__c == 'H'){
                    message.setOrgWideEmailAddressId(mapOwdAdrs.get('Hyundai DNAMS Notifications'));
                }else{
                    message.setOrgWideEmailAddressId(mapOwdAdrs.get('Genesis DNAMS Notifications'));
                }
                message.setBccSender(false); 
                message.setTreatTargetObjectAsRecipient(false);
                message.setTargetObjectId(cnt.id); 
                message.setTemplateID(emailTemplate.Id);
                
                message.setToAddresses(receipients);
                Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{};
                    for(ContentDocumentLink conlink : pacEle.ContentDocumentLinks){
                        if(mapContentversion.containskey(conlink.ContentDocumentId)){
                            ContentVersion cversion = mapContentversion.get(conlink.ContentDocumentId);
                            blob WOCFbody = cversion.versiondata;
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            //efa.setFileName(cversion.title +'.'+ cversion.FileType);
                            //Start-DNA-980
                            System.debug('DNA-980=****cversion.title='+cversion.title);
                            System.debug('DNA-980=****cversion.FileType='+cversion.FileType);
                            System.debug('DNA-980=****cversion.FileExtension='+cversion.FileExtension);
                            System.debug('DNA-980=Before==efa.getFileName()='+efa.getFileName());
                            System.debug('DNA-980=Before==efa.getContentType()='+efa.getContentType());
                            efa.setFileName(cversion.title+'.'+cversion.FileExtension);
                            efa.setContentType('application/' + cversion.FileExtension);//DNA-980:Setting Content Type
                            System.debug('DNA-980=After==efa.getFileName()='+efa.getFileName());
                            System.debug('DNA-980=After==efa.getContentType()='+efa.getContentType());
                            //End-DNA-980
                            efa.setBody(WOCFbody);
                            fileAttachments.add(efa);
                        } 
                    }
                message.setFileAttachments(fileAttachments);
                lstSingleEmailmsg.add(message);
                System.debug('lstSingleEmailmsg'+lstSingleEmailmsg);
            }
            if(!lstSingleEmailmsg.IsEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstSingleEmailmsg);
            }
        }
    }
}