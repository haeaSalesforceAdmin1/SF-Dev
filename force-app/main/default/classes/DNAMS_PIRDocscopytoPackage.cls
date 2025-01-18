global class DNAMS_PIRDocscopytoPackage {
    
    @InvocableMethod(label='Copy PIR Element Docs to Package Elements' description='This class is used to Copy Docs from PIR Elements to Package Elemensts' category='PIRElements')
    global static void DNAMS_PIRDocscopytoPackagemethod(List<InputsPassed> inputs ){
        List<InputsPassed> inputlist = inputs;
        List<String> pirElements = new List<String>();
        List<String> packageElements = new List<String>();
        for (InputsPassed input : inputList) {
            // Extract PIRElements and PackageElements from the current InputsPassed object
            pirElements = input.PIRElements;
            packageElements = input.PackageElements;
            
            // Debug to check the values
            System.debug('PIRElements: ' + pirElements);
            System.debug('PackageElements: ' + packageElements);
            
        }
        
        List<PIR_Element__c > PiRlist = new List<PIR_Element__c> ([SELECT Id,Name, Mapped_Package_Element__c,(Select id from ContentDocumentLinks) FROM PIR_Element__c  where id in :pirElements]);
        system.debug('PiRlist '+PiRlist.size());
        List<PIR_Element__c> pirEleRecords = new List<PIR_Element__c>();
        List<Id> PiRlistIds = new List<Id>();
        for(PIR_Element__c  pirEleObj: PiRlist){
            PiRlistIds.add(pirEleObj.Id);
            if(pirEleObj.ContentDocumentLinks.Size()>0){
                system.debug('pirEleObj.ContentDocumentLinks.Size() '+ pirEleObj.ContentDocumentLinks.Size());
                system.debug('pirEleObj.Name '+pirEleObj.Name);
                pirEleRecords.add(pirEleObj);
            }
            
        }
        system.debug('pirEleRecords '+ pirEleRecords);
        
    /*    Map<Id, List<ContentDocumentLink>> cdlMap = new Map<Id, List<ContentDocumentLink>>();
        List<ContentDocumentLink> ContDocLinkList = [Select ContentDocumentId, Id, IsDeleted, LinkedEntityId, ShareType, SystemModstamp, Visibility 
                                                     from ContentDocumentLink 
                                                     where LinkedEntityid IN: PiRlistIds];
        List<String> condocidsList = new List<String>();
        for(ContentDocumentLink c: ContDocLinkList){
            condocidsList.add(c.ContentDocumentId);
            if(cdlMap.containsKey(c.LinkedEntityid)){
                cdlMap.get(c.LinkedEntityid).add(c);
            }
            else{
                cdlMap.put(c.LinkedEntityid, new List<ContentDocumentLink>{c});
            }
            
        }
        system.debug('cdlMap '+ cdlMap);
        
        List<ContentVersion> originalVersion = [SELECT Id, Title, VersionData, ContentDocumentId, PathOnClient FROM ContentVersion 
                                                WHERE ContentDocumentId IN : condocidsList AND IsLatest = TRUE ];
        Map<String, ContentVersion> CVMap = new Map<String, ContentVersion>();
        for(ContentVersion cv : originalVersion){
            CVMap.put(cv.ContentDocumentId, cv);
        }
        
        system.debug('CVMap '+ CVMap); */
        
        Map<Id, List<String>> pirEleMap = new Map<Id, List<String>>();
        for(PIR_Element__c  pirEleObj: pirEleRecords){
            if(pirEleObj.Mapped_Package_Element__c != null){
                List<String> eleNamesList = new List<String>();
                List<String> eleNames = pirEleObj.Mapped_Package_Element__c.split(';');
                for(String TrimeleNames : eleNames){
                    eleNamesList.add(TrimeleNames.trim());
                }
                //eleNamesList.addAll(eleNames);
                pirEleMap.put(pirEleObj.id,eleNamesList);
            }
        }
        System.debug('pirEleMap>>> '+pirEleMap);
        List<PackageElement__c> pkgEleRecords = new List<PackageElement__c> ([select Name, id  FROM PackageElement__c where id in :packageElements]);
        String miscPkgId = '';
        //Map<String,String> PackageDetails_NametoID_Map = new Map<String,String>();
        Map<String,String> PackageDetails_IDtoName_Map = new Map<String,String>();
        List<String> packageNames = new List<String>();
        for(PackageElement__c  pkgEleObj: pkgEleRecords){
            //PackageDetails_NametoID_Map.put(pkgEleObj.Name, pkgEleObj.Id);
            PackageDetails_IDtoName_Map.put(pkgEleObj.Id,pkgEleObj.Name);
            packageNames.add(pkgEleObj.Name.toLowercase());
            if(pkgEleObj.Name == 'Miscellaneous Documents'){
                miscPkgId = pkgEleObj.id;
            }
        }
        Map<String,List<String>> PkgPirEleMap = new Map<String,List<String>>();
        set<String> AddtoMisIds = new set<String>();
        for(PIR_Element__c PE : pirEleRecords){
            if(PE.Mapped_Package_Element__c==null)
                AddtoMisIds.add(PE.id);
        }
        
        for(PIR_Element__c PE : pirEleRecords){
            if(pirEleMap.ContainsKey(PE.id)){
                system.debug('pirEleMap.get(PE.id) '+ pirEleMap.get(PE.id));
                for(String s : pirEleMap.get(PE.id)){
                    integer matched = 0;
                    system.debug('PE.Nameoutside '+ PE.Name +' '+ s+ ' '+ PE.id);
                     String s1 = s.toLowercase();
                    if(packageNames.indexOf(s1) == -1 || s == 'Miscellaneous Documents'){
                        system.debug('PE.Name '+ PE.Name +' '+ s+ ' '+ PE.id);
                        AddtoMisIds.add(PE.id);
                    }
                    /*  for(String s1 : packageNames){
if(s1 == s){
matched = 1;
//return;
}
}

if(matched == 0){
AddtoMisIds.add(PE.id);
}*/
                }
            }
        }
        
        system.debug('AddtoMisIds '+ AddtoMisIds);
        
        for(PackageElement__c  pkgEleObj: pkgEleRecords){            
            List<String> pirElemList = new List<String>();
            for(String pirElemId: pirEleMap.keySet()){
                integer matchfound = 0;
                List<String> packElemList = pirEleMap.get(pirElemId);
                for(String packElName: packElemList){
                    packElName =packElName.trim();
                    if(packElName == pkgEleObj.Name){
                        pirElemList.add(pirElemId);
                        matchfound = 1;
                    }
                }
                if(matchfound == 0){
                    if(miscPkgId != ''){
                        //              AddtoMisIds.add(pirElemId);
                        /*if(PkgPirEleMap.containsKey(miscPkgId)){
PkgPirEleMap.get(miscPkgId).add(pirElemId);
}else{
PkgPirEleMap.put(miscPkgId, new List<String>{pirElemId});
}*/
                        
                    }
                }
                
            }
            if(pirElemList.size()!=0){
                /*if(pkgEleObj.id ==miscPkgId){
PkgPirEleMap.put(pkgEleObj.id,)
}*/
                PkgPirEleMap.put(pkgEleObj.id,pirElemList);
            }
        }
        List<String> MiscPIRIdsList = PkgPirEleMap.remove(miscPkgId);
        List<String> MiscList = new  List<String>();
        for( String Misset:AddtoMisIds){
            MiscList.add(Misset);
        }
        PkgPirEleMap.put(miscPkgId,MiscList);
        
        System.debug('Final Map  '+PkgPirEleMap);
        System.debug('Final PkgPirEleMap  '+PkgPirEleMap.keySet().size());
        List<ContentDocumentLink> CDLtoinsert = new List<ContentDocumentLink>();
        //List<ContentVersion> CVListtoInsert_All = new List<ContentVersion>();
        if(!PkgPirEleMap.isEmpty()){
            
            for(String pkgElemId: PkgPirEleMap.keySet()){
                List<String> pirElemList = PkgPirEleMap.get(pkgElemId);
                System.debug('Final pirElemList  '+pirElemList.size());
                System.debug('Final pirElemList value '+pirElemList);
                for(String pirEleId: pirElemList){
                    
                    System.debug('Clone element >> pirEleId - '+pirEleId+' pkgElemId - '+pkgElemId);
                    List<ContentDocumentLink> cdlListtoInsert = new List<ContentDocumentLink>();
                    List<ContentVersion> CVListtoInsert = new List<ContentVersion>();
                //    CVListtoInsert = prepContVersionstoIns(pirEleId,pkgElemId, CVMap, cdlMap, PackageDetails_IDtoName_Map);
                    //================================================================================//
                  //  if(!CVListtoInsert.isEmpty()){
                  //      System.debug('Calling DNAMS_CopyPIRtoPackageQueueable - '+CVListtoInsert.size());
                  				system.debug( 'Heap size used is ' + limits.getHeapSize() + '  and Total heap size is:   ' + limits.getLimitHeapSize()); //newly added
                        //System.enqueueJob(new DNAMS_CopyPIRtoPackageQueueable(pkgElemId,pirEleId)); //CVListtoInsert
                        if(pkgElemId != null && pirEleId != null){
                    DNAMS_CopyPIRtoPackageBatchable batch = new DNAMS_CopyPIRtoPackageBatchable(pkgElemId, pirEleId);
                    Database.executeBatch(batch, 1);
                        }
                                system.debug( 'Heap size used is ' + limits.getHeapSize() + '  and Total heap size is:   ' + limits.getLimitHeapSize()); //newly added
               //     }
                    
                }
            }

            
        }
        
    }
    global class InputsPassed{
        @InvocableVariable
        public List<String> PIRElements;
        
        @InvocableVariable
        public List<String> PackageElements;
    }
    
 /*   public static List<ContentVersion> prepContVersionstoIns(Id originalDocId, Id newParentId,  Map<String, ContentVersion> CVMap, Map<Id, List<ContentDocumentLink>> cdlMap, Map<String,String> PackageDetails_IDtoName_Map ) {
        
        List<ContentVersion> CVlist = new List<ContentVersion>();
        System.debug('Limits.getQueries()'+Limits.getQueries());        
        
        System.debug('prepContVersionstoIns >> originalDocId - '+originalDocId+' newParentId - '+newParentId);
        
        List<ContentDocumentLink> ContDocLinkList = cdlMap.get(originalDocId);
        system.debug(ContDocLinkList.size()+' ContDocLinkList '+ ContDocLinkList);
        
        //System.debug('ContdocidList - '+ContdocidList);
        
        if(ContDocLinkList.size() > 0){
            for(ContentDocumentLink ContDocLink: ContDocLinkList){
                system.debug('1');
                // Step 1: Retrieve the original ContentVersion related to the ContentDocument
                ContentVersion originalVersion = CVMap.get(ContDocLink.ContentDocumentId); 
                system.debug('originalVersion '+ originalVersion);
                
                // Step 2: Clone the ContentVersion (the actual file data)
                ContentVersion newVersion = new ContentVersion();
                //newVersion.Title = originalVersion.Title + ' $' + PackageDetails_IDtoName_Map.get(newParentId); // Optionally append something to the title
                newVersion.Title = originalVersion.Title;
                newVersion.VersionData = originalVersion.VersionData; // Copy the file data
                // newVersion.ContentDocumentId = originalVersion.ContentDocumentId; // Link to the same ContentDocument
                newVersion.PathOnClient = originalVersion.PathOnClient;
                CVlist.add(newVersion);                
                //insert newLink;
                System.debug('Limits.getQueries()1 '+Limits.getQueries());                                
            }
        }
        return CVlist;        
    }
    */
}