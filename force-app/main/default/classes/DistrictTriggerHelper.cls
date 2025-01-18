public without sharing class DistrictTriggerHelper {

     /**
     * This method is used to assign access type to
     * secondary DM/DSM/DPSM/GMM for Hyundai and genesis district.
     * This method will run only for create/update scenario of 
     * secondary district changes in district record.
     * @param newList new List of District record.
     * @param oldMap old Map of District record.
     * @return none.
     */
    public static void secondaryDistrictApproverAccess(List<District__c> newList, Map<Id, District__c> oldMap) {


        Map<Id,Set<String>> mapOfUserToDC = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapOfUserToAT = new Map<Id,Set<String>>();
        List<String> listOfAT = getAccessTypeName();

        for (District__c district : newList) {

            //District Manager
           /* if ((oldMap != NULL && district.DistrictManagerAlt__c != NULL 
                && district.DistrictManagerAlt__c != oldMap.get(district.Id).DistrictManagerAlt__c 
                && district.DistrictManagerAlt__c != district.DistrictManager__c)                 
                || (oldMap == NULL && district.DistrictManagerAlt__c != NULL && district.DistrictManagerAlt__c != district.DistrictManager__c )) {

                    String ATName = 'DPM_DM_'+district.DistrictCode__c;

                    if (listOfAT != NULL && listOfAT.contains(ATName)) {

                        if (!mapOfUserToDC.containsKey(district.DistrictManagerAlt__c)) {
                            mapOfUserToDC.put(district.DistrictManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToDC.get(district.DistrictManagerAlt__c).add(district.DistrictCode__c);

                        if (!mapOfUserToAT.containsKey(district.DistrictManagerAlt__c)) {
                            mapOfUserToAT.put(district.DistrictManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToAT.get(district.DistrictManagerAlt__c).add(ATName);
                    }

                    
            }

            //District Sales Manager
            if ((oldMap != NULL && district.DistrictSalesManagerAlt__c != NULL 
                && district.DistrictSalesManagerAlt__c != oldMap.get(district.Id).DistrictSalesManagerAlt__c 
                && district.DistrictSalesManagerAlt__c != district.SalesManager__c)
                || (oldMap == NULL && district.DistrictSalesManagerAlt__c != NULL && district.DistrictSalesManagerAlt__c != district.SalesManager__c)) {

                    String ATName = 'DPM_DSM_'+district.DistrictCode__c;

                    if (listOfAT != NULL && listOfAT.contains(ATName)) {

                        if (!mapOfUserToDC.containsKey(district.DistrictSalesManagerAlt__c)) {
                            mapOfUserToDC.put(district.DistrictSalesManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToDC.get(district.DistrictSalesManagerAlt__c).add(district.DistrictCode__c);

                        if (!mapOfUserToAT.containsKey(district.DistrictSalesManagerAlt__c)) {
                            mapOfUserToAT.put(district.DistrictSalesManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToAT.get(district.DistrictSalesManagerAlt__c).add(ATName);
                    }
                    
                    
            }

            //District Part Sales Manager
            if ((oldMap != NULL && district.DistrictPartsServiceManagerAlt__c != NULL 
                && district.DistrictPartsServiceManagerAlt__c != oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c
                && district.DistrictPartsServiceManagerAlt__c != district.DistrictPartsServiceManager__c)
                || (oldMap == NULL && district.DistrictPartsServiceManagerAlt__c != NULL && district.DistrictPartsServiceManagerAlt__c != district.DistrictPartsServiceManager__c)) {

                    String ATName = 'DPM_DPSM_'+district.DistrictCode__c;

                    if (listOfAT != NULL && listOfAT.contains(ATName)) {

                        if (!mapOfUserToDC.containsKey(district.DistrictPartsServiceManagerAlt__c)) {
                            mapOfUserToDC.put(district.DistrictPartsServiceManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToDC.get(district.DistrictPartsServiceManagerAlt__c).add(district.DistrictCode__c);

                        if (!mapOfUserToAT.containsKey(district.DistrictPartsServiceManagerAlt__c)) {
                            mapOfUserToAT.put(district.DistrictPartsServiceManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToAT.get(district.DistrictPartsServiceManagerAlt__c).add(ATName);
                    }
                    
                    
            }*/
 
            //Genesis Market Manager
            if ((oldMap != NULL && district.GenesisMarketManagerAlt__c != NULL 
                && district.GenesisMarketManagerAlt__c != oldMap.get(district.Id).GenesisMarketManagerAlt__c
                && district.GenesisMarketManagerAlt__c != district.MarketManager__c) 
                || (oldMap == NULL && district.GenesisMarketManagerAlt__c != NULL && district.GenesisMarketManagerAlt__c != district.MarketManager__c)) {
					
                    String ATName = 'DPM_GMM_'+district.DistrictCode__c;
                  
                    if (listOfAT != NULL && listOfAT.contains(ATName)) {

                        if (!mapOfUserToDC.containsKey(district.GenesisMarketManagerAlt__c)) {
                            mapOfUserToDC.put(district.GenesisMarketManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToDC.get(district.GenesisMarketManagerAlt__c).add(district.DistrictCode__c);

                        if (!mapOfUserToAT.containsKey(district.GenesisMarketManagerAlt__c)) {
                            mapOfUserToAT.put(district.GenesisMarketManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToAT.get(district.GenesisMarketManagerAlt__c).add(ATName);
                    }

            }
        }

        if (mapOfUserToDC.size() > 0 && mapOfUserToAT.size() > 0) {
            updateUserRec(mapOfUserToDC,mapOfUserToAT);
        }   
        
    }

    /**
     * This method is used to return Access Types developer Name.
     * @return List of Access type name.
     */
    public static List<String> getAccessTypeName() {
        
        List<String> listOfAT = new List<String>();

            for (AccessType__mdt ACT : AccessType__mdt.getAll().values()) {
                
                if (String.isNotBlank(ACT.developerName)) {
                    listOfAT.add(ACT.developerName);
                }
            }

            return listOfAT;
    }  

    /**
     * This method is used to update User Records.
     * @param mapOfUserToDC map of User to District Code.
     * @param mapOfUserToAT map of User to Access Types.
     * @return none.
     */
    public static void updateUserRec(Map<Id,Set<String>> mapOfUserToDC, Map<Id,Set<String>> mapOfUserToAT) {

        Map<Id,User> finalMap = new Map<Id,User>();
        for (User usr : [SELECT Id,District_Codes_Alt__c,AccessTypes__c FROM User WHERE Id=: mapOfUserToDC.keySet()]) {

            if (usr.District_Codes_Alt__c != NULL) {
                List<String> tmpList = (usr.District_Codes_Alt__c).split(',');
                for (String key : mapOfUserToDC.get(usr.Id)) {
                    if (!tmpList.contains(key)) {
                        User usrRec = new User();
                        usrRec.Id = usr.Id;
                        usrRec.AccessTypes__c = usr.AccessTypes__c;
                        usrRec.District_Codes_Alt__c = finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id).District_Codes_Alt__c+','+ key : usr.District_Codes_Alt__c +','+ key;

                        finalMap.put(usr.Id,usrRec);
                    }
                }
            } else {
                User usrRec = new User();
                usrRec.Id = usr.Id;
                usrRec.AccessTypes__c = usr.AccessTypes__c;
                usrRec.District_Codes_Alt__c = mapOfUserToDC.get(usr.Id) != NULL && mapOfUserToDC.get(usr.Id).size() > 0 ? String.join(new List<String>(mapOfUserToDC.get(usr.Id)),',') : '';

                finalMap.put(usr.Id,usrRec);
            }
        }


        for (User usr : [SELECT Id,AccessTypes__c,Autoprovision__c FROM User WHERE Id=: mapOfUserToAT.keySet()]) {

            if (usr.AccessTypes__c != NULL) {

                List<String> tmpList = (usr.AccessTypes__c).split(',');
                for (String key : mapOfUserToAT.get(usr.Id)) {

                    if (!tmpList.contains(key)) {

                        User usrRec = (finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id) : new User());
                        usrRec.Id =  (finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id).Id : usr.Id);
                        usrRec.AccessTypes__c = finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id).AccessTypes__c+','+ key : usr.AccessTypes__c +','+ key;
                        usrRec.Autoprovision__c = TRUE;

                        finalMap.put(usr.Id,usrRec);
                    }
                }
            } else {

                User usrRec = (finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id) : new User());
                usrRec.Id =  (finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id).Id : usr.Id);
                usrRec.AccessTypes__c = mapOfUserToAT.get(usr.Id) != NULL && mapOfUserToAT.get(usr.Id).size() > 0 ? String.join(new List<String>(mapOfUserToAT.get(usr.Id)),',') : '';
                usrRec.Autoprovision__c = TRUE;

                finalMap.put(usr.Id,usrRec);
            }
        }

        if (finalMap != NULL && finalMap.size() > 0) {
            update finalMap.values();
        }
    }
   /**
     * This method is used to Remove access type to
     * secondary DM/DSM/DPSM/GMM for Hyundai and genesis district.
     * This method will run only for update scenario of 
     * secondary district changes in district record.
     * @param newList new List of District record.
     * @param oldMap old Map of District record.
     * @return none.
     */
    public static void removeSecondaryDistrictApproverAccess(List<District__c> newList, Map<Id, District__c> oldMap) {
        Map<Id,Set<String>> mapOfUserToDC = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapOfUserToAT = new Map<Id,Set<String>>();
        List<String> listOfAT = getAccessTypeName();

        for (District__c district : newList) {

            //District Manager
           /* if ((oldMap != NULL  && district.DistrictManagerAlt__c != oldMap.get(district.Id).DistrictManagerAlt__c
                && oldMap.get(district.Id).DistrictManagerAlt__c != district.DistrictManager__c)) {

                    String ATName = 'DPM_DM_'+district.DistrictCode__c;

                    if (listOfAT != NULL && listOfAT.contains(ATName)) {

                        if (!mapOfUserToDC.containsKey(oldMap.get(district.Id).DistrictManagerAlt__c)) {
                            mapOfUserToDC.put(oldMap.get(district.Id).DistrictManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToDC.get(oldMap.get(district.Id).DistrictManagerAlt__c).add(district.DistrictCode__c);

                        if (!mapOfUserToAT.containsKey(oldMap.get(district.Id).DistrictManagerAlt__c)) {
                            mapOfUserToAT.put(oldMap.get(district.Id).DistrictManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToAT.get(oldMap.get(district.Id).DistrictManagerAlt__c).add(ATName);
                    }

                    
            }

            //District Sales Manager
            if ((oldMap != NULL && district.DistrictSalesManagerAlt__c != oldMap.get(district.Id).DistrictSalesManagerAlt__c
                && oldMap.get(district.Id).DistrictSalesManagerAlt__c != district.SalesManager__c)) {

                    String ATName = 'DPM_DSM_'+district.DistrictCode__c;

                    if (listOfAT != NULL && listOfAT.contains(ATName)) {

                        if (!mapOfUserToDC.containsKey(oldMap.get(district.Id).DistrictSalesManagerAlt__c)) {
                            mapOfUserToDC.put(oldMap.get(district.Id).DistrictSalesManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToDC.get(oldMap.get(district.Id).DistrictSalesManagerAlt__c).add(district.DistrictCode__c);

                        if (!mapOfUserToAT.containsKey(oldMap.get(district.Id).DistrictSalesManagerAlt__c)) {
                            mapOfUserToAT.put(oldMap.get(district.Id).DistrictSalesManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToAT.get(oldMap.get(district.Id).DistrictSalesManagerAlt__c).add(ATName);
                        System.debug('mapOfUserToDC IN '+mapOfUserToDC);
                        System.debug('mapOfUserToAT IN '+mapOfUserToAT);
                    }
                
                    
            }

            //District Part Sales Manager
            if ((oldMap != NULL && district.DistrictPartsServiceManagerAlt__c != oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c
                 && oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c != district.DistrictPartsServiceManager__c)) {

                    String ATName = 'DPM_DPSM_'+district.DistrictCode__c;

                    if (listOfAT != NULL && listOfAT.contains(ATName)) {

                        if (!mapOfUserToDC.containsKey(oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c)) {
                            mapOfUserToDC.put(oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToDC.get(oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c).add(district.DistrictCode__c);

                        if (!mapOfUserToAT.containsKey(oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c)) {
                            mapOfUserToAT.put(oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToAT.get(oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c).add(ATName);
                    }
                    
                    
            }*/

            //Genesis Market Manager
            if ((oldMap != NULL && district.GenesisMarketManagerAlt__c != oldMap.get(district.Id).GenesisMarketManagerAlt__c
                && oldMap.get(district.Id).GenesisMarketManagerAlt__c != district.MarketManager__c)) {

                    String ATName = 'DPM_GMM_'+district.DistrictCode__c;
                   
                    if (listOfAT != NULL && listOfAT.contains(ATName)) {

                        if (!mapOfUserToDC.containsKey(oldMap.get(district.Id).GenesisMarketManagerAlt__c)) {
                            mapOfUserToDC.put(oldMap.get(district.Id).GenesisMarketManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToDC.get(oldMap.get(district.Id).GenesisMarketManagerAlt__c).add(district.DistrictCode__c);

                        if (!mapOfUserToAT.containsKey(oldMap.get(district.Id).GenesisMarketManagerAlt__c)) {
                            mapOfUserToAT.put(oldMap.get(district.Id).GenesisMarketManagerAlt__c, new Set<String>());
                        }
                        mapOfUserToAT.get(oldMap.get(district.Id).GenesisMarketManagerAlt__c).add(ATName);
                    }
                }
        }

        if (mapOfUserToDC.size() > 0 && mapOfUserToAT.size() > 0) {
            System.debug('mapOfUserToDC '+mapOfUserToDC);
            System.debug('mapOfUserToAT '+mapOfUserToAT);
            updateUserRecToRemoveAccess(mapOfUserToDC,mapOfUserToAT);
        }   
           

    }
    /**
     * This method is used to update User Records for removing access type.
     * @param mapOfUserToDC map of User to District Code.
     * @param mapOfUserToAT map of User to Access Types.
     * @return none.
     */
    public static void updateUserRecToRemoveAccess(Map<Id,Set<String>> mapOfUserToDC, Map<Id,Set<String>> mapOfUserToAT) {
        Map<Id,User> finalMap = new Map<Id,User>();
        for (User usr : [SELECT Id,District_Codes_Alt__c,AccessTypes__c FROM User WHERE Id=: mapOfUserToDC.keySet()]) {

            if (usr.District_Codes_Alt__c != NULL) {
                List<String> tmpList = (usr.District_Codes_Alt__c).split(',');
                for (String key : mapOfUserToDC.get(usr.Id)) {
                    if (tmpList.contains(key)) {
                        User usrRec = new User();
                        usrRec.Id = usr.Id;
                        usrRec.AccessTypes__c = usr.AccessTypes__c;
                        String districtCode= finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id).District_Codes_Alt__c : usr.District_Codes_Alt__c;
                        if(String.isNotBlank(districtCode)){
                            List<String> districtCodeList =  (districtCode).split(',');
                            districtCodeList.remove(districtCodeList.indexOf(key));
                            usrRec.District_Codes_Alt__c =String.join(districtCodeList,',');
                        }
                        finalMap.put(usr.Id,usrRec);
                    }
                }
            } 
        }


        for (User usr : [SELECT Id,AccessTypes__c,Autoprovision__c FROM User WHERE Id=: mapOfUserToAT.keySet()]) {

            if (usr.AccessTypes__c != NULL) {

                List<String> tmpList = (usr.AccessTypes__c).split(',');
                for (String key : mapOfUserToAT.get(usr.Id)) {

                    if (tmpList.contains(key)) {

                        User usrRec = (finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id) : new User());
                        usrRec.Id =  (finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id).Id : usr.Id);
                        String accessType= finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id).AccessTypes__c : usr.AccessTypes__c;
                        if(String.isNotBlank(accessType)){
                            List<String> accessTypeList =  (accessType).split(',');
                            accessTypeList.remove(accessTypeList.indexOf(key));
                            usrRec.AccessTypes__c =String.join(accessTypeList,',');
                            usrRec.Autoprovision__c = TRUE;
                        }
                        // usrRec.AccessTypes__c = finalMap.containsKey(usr.Id) ? finalMap.get(usr.Id).AccessTypes__c+','+ key : usr.AccessTypes__c +','+ key;
                        finalMap.put(usr.Id,usrRec);
                    }
                }
            }
        }

        if (finalMap != NULL && finalMap.size() > 0) {
            update finalMap.values();
        }
    }

    /**
     * This method is used to update secondary
     * DM/DSM/DPSM/GMM for Hyundai and genesis to related Eval, AP, Accounts.
     * This method will run only for update scenario of 
     * secondary district changes in district record.
     * @param newList new List of District record.
     * @param oldMap old Map of District record.
     * @return none.
     */
    public static void updateRelatedEvalAPAccount(List<District__c> newList, Map<Id, District__c> oldMap) {
                
        Map<Id,Id> mapOfDistrictToDM = new Map<Id,Id>();
        Map<Id,Id> mapOfDistrictToDSM = new Map<Id,Id>();
        Map<Id,Id> mapOfDistrictToDPSM = new Map<Id,Id>();
        Map<Id,Id> mapOfDistrictToGMM = new Map<Id,Id>();
        

        for (District__c district : newList) {

            //District Manager
           /* if ((oldMap != NULL && district.DistrictManagerAlt__c != oldMap.get(district.Id).DistrictManagerAlt__c) 
                || (oldMap == NULL && district.DistrictManagerAlt__c != NULL )) {

                        mapOfDistrictToDM.put(district.Id,district.DistrictManagerAlt__c);
                     
            }

            //District Sales Manager
            if ((oldMap != NULL && district.DistrictSalesManagerAlt__c != oldMap.get(district.Id).DistrictSalesManagerAlt__c) 
                || (oldMap == NULL && district.DistrictSalesManagerAlt__c != NULL )) {
                        mapOfDistrictToDSM.put(district.Id,district.DistrictSalesManagerAlt__c);
                    
            }

            //District Part Sales Manager
            if ((oldMap != NULL &&  district.DistrictPartsServiceManagerAlt__c != oldMap.get(district.Id).DistrictPartsServiceManagerAlt__c) 
                || (oldMap == NULL && district.DistrictPartsServiceManagerAlt__c != NULL )) {

                    mapOfDistrictToDPSM.put(district.Id,district.DistrictPartsServiceManagerAlt__c);
                    
            }*/

            //Genesis Market Manager
            if ((oldMap != NULL && district.GenesisMarketManagerAlt__c != oldMap.get(district.Id).GenesisMarketManagerAlt__c) 
                || (oldMap == NULL && district.GenesisMarketManagerAlt__c != NULL )) {

                    mapOfDistrictToGMM.put(district.Id,district.GenesisMarketManagerAlt__c);

            }
        }

        updateAccout(mapOfDistrictToDM,mapOfDistrictToDSM,mapOfDistrictToDPSM,mapOfDistrictToGMM);
        updateEvaluations(mapOfDistrictToDM,mapOfDistrictToDSM,mapOfDistrictToDPSM,mapOfDistrictToGMM);
        updateActionPlans(mapOfDistrictToDM,mapOfDistrictToDSM,mapOfDistrictToDPSM,mapOfDistrictToGMM);
    }

    /**
     * This method is used to update related Account Records
     * @param mapOfDistrictToDM map of district to DM.
     * @param mapOfDistrictToDSM map of district to DSM.
     * @param mapOfDistrictToDPSM map of district to DPSM.
     * @param mapOfDistrictToGMM map of district to GMM.
     * @return none.
     */
    @Future
    public static void updateAccout(Map<Id,Id> mapOfDistrictToDM, Map<Id,Id> mapOfDistrictToDSM, Map<Id,Id> mapOfDistrictToDPSM, Map<Id,Id> mapOfDistrictToGMM){

        Set<Id> setOfDistrictIds = new Set<Id>();
        List<Account> listAccToUpdate = new List<Account>();

       /* if (mapOfDistrictToDM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDM.keySet());
        }

        if (mapOfDistrictToDSM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDSM.keySet());
        }

        if (mapOfDistrictToDPSM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDPSM.keySet());
        }*/

        if (mapOfDistrictToGMM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToGMM.keySet());
        }
        

        for (Account acc : [SELECT Id, DistrictManagerAlt__c, DistrictSalesManagerAlt__c, DistrictPartsServiceManagerAlt__c, GenesisMarketManagerAlt__c, SalesDistrict__c, ServiceDistrict__c,Market__c 
                            FROM Account 
                            WHERE Market__c IN:setOfDistrictIds /*OR (SalesDistrict__c IN:setOfDistrictIds 
                            AND ServiceDistrict__c IN:setOfDistrictIds)*/]) {

                               /* if (mapOfDistrictToDM.containsKey(acc.SalesDistrict__c)) {
                                    acc.DistrictManagerAlt__c = mapOfDistrictToDM.get(acc.SalesDistrict__c);
                                }
                                if (mapOfDistrictToDSM.containsKey(acc.SalesDistrict__c)) {
                                    acc.DistrictSalesManagerAlt__c = mapOfDistrictToDSM.get(acc.SalesDistrict__c);
                                }
                                if (mapOfDistrictToDPSM.containsKey(acc.SalesDistrict__c)) {
                                    acc.DistrictPartsServiceManagerAlt__c = mapOfDistrictToDPSM.get(acc.SalesDistrict__c);
                                }*/
                                if (mapOfDistrictToGMM.containsKey(acc.Market__c)) {
                                    acc.GenesisMarketManagerAlt__c = mapOfDistrictToGMM.get(acc.Market__c);
                                }
                                listAccToUpdate.add(acc);

                            }

                            if (listAccToUpdate.size() > 0) {
                                update listAccToUpdate;
                            }
    }

    
    /**
     * This method is used to update related Evaluation Records
     * @param mapOfDistrictToDM map of district to DM.
     * @param mapOfDistrictToDSM map of district to DSM.
     * @param mapOfDistrictToDPSM map of district to DPSM.
     * @param mapOfDistrictToGMM map of district to GMM.
     * @return none.
     */
    @Future
    public static void updateEvaluations(Map<Id,Id> mapOfDistrictToDM, Map<Id,Id> mapOfDistrictToDSM, Map<Id,Id> mapOfDistrictToDPSM, Map<Id,Id> mapOfDistrictToGMM){

        Set<Id> setOfDistrictIds = new Set<Id>();
        List<Evaluation__c> listEvalToUpdate = new List<Evaluation__c>();
        List<SObject> listSObj = new List<SObject>();

       /* if (mapOfDistrictToDM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDM.keySet());
        }

        if (mapOfDistrictToDSM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDSM.keySet());
        }

        if (mapOfDistrictToDPSM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDPSM.keySet());
        }*/

        if (mapOfDistrictToGMM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToGMM.keySet());
        }
        

        for (Evaluation__c eval : [SELECT Id, DistrictManagerAlt__c, DistrictSalesManagerAlt__c, DistrictPartsServiceManagerAlt__c, GenesisMarketManagerAlt__c, SalesDistrict__c, ServiceDistrict__c, MarketRef__c 
                                    FROM Evaluation__c 
                                    WHERE MarketRef__c IN:setOfDistrictIds /*OR (SalesDistrict__c IN:setOfDistrictIds 
                                    AND ServiceDistrict__c IN:setOfDistrictIds)*/]) {

                               /* if (mapOfDistrictToDM.containsKey(eval.SalesDistrict__c)) {
                                    eval.DistrictManagerAlt__c = mapOfDistrictToDM.get(eval.SalesDistrict__c);
                                    if (mapOfDistrictToDM.get(eval.SalesDistrict__c) != NULL) {
                                      SObject sh = manualShareEdit(eval.Id, eval.DistrictManagerAlt__c, 'Evaluation__Share');
                                      listSObj.add(sh);
                                    }
                                }
                                if (mapOfDistrictToDSM.containsKey(eval.SalesDistrict__c)) {
                                    eval.DistrictSalesManagerAlt__c = mapOfDistrictToDSM.get(eval.SalesDistrict__c);
                                    if (mapOfDistrictToDSM.get(eval.SalesDistrict__c) != NULL) {
                                        SObject sh =  manualShareEdit(eval.Id, eval.DistrictSalesManagerAlt__c, 'Evaluation__Share');
                                        listSObj.add(sh);
                                    }
                                }
                                if (mapOfDistrictToDPSM.containsKey(eval.SalesDistrict__c)) {
                                    eval.DistrictPartsServiceManagerAlt__c = mapOfDistrictToDPSM.get(eval.SalesDistrict__c);
                                    if (mapOfDistrictToDPSM.get(eval.SalesDistrict__c) != NULL) {
                                        SObject sh =  manualShareEdit(eval.Id, eval.DistrictPartsServiceManagerAlt__c, 'Evaluation__Share');
                                        listSObj.add(sh);
                                    }
                                }*/
                                if (mapOfDistrictToGMM.containsKey(eval.MarketRef__c)) {
                                    eval.GenesisMarketManagerAlt__c = mapOfDistrictToGMM.get(eval.MarketRef__c);
                                    if (mapOfDistrictToGMM.get(eval.MarketRef__c) != NULL) {
                                        SObject sh =  manualShareEdit(eval.Id, eval.GenesisMarketManagerAlt__c, 'Evaluation__Share');
                                        listSObj.add(sh);
                                    }
                                }
                                listEvalToUpdate.add(eval);

                            }

                            if (listEvalToUpdate.size() > 0) {
                                update listEvalToUpdate;

                                if (listSObj.size() > 0) {
                                    Database.insert(listSObj,false);
                                }

                               
                            }
    }

    
    /**
     * This method is used to update related Action Plan Records
     * @param mapOfDistrictToDM map of district to DM.
     * @param mapOfDistrictToDSM map of district to DSM.
     * @param mapOfDistrictToDPSM map of district to DPSM.
     * @param mapOfDistrictToGMM map of district to GMM.
     * @return none.
     */
    @Future
    public static void updateActionPlans(Map<Id,Id> mapOfDistrictToDM, Map<Id,Id> mapOfDistrictToDSM, Map<Id,Id> mapOfDistrictToDPSM, Map<Id,Id> mapOfDistrictToGMM){

        Set<Id> setOfDistrictIds = new Set<Id>();
        List<Action_Plan__c> listAPToUpdate = new List<Action_Plan__c>();
        List<SObject> listSObj = new List<SObject>();

       /* if (mapOfDistrictToDM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDM.keySet());
        }

        if (mapOfDistrictToDSM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDSM.keySet());
        }

        if (mapOfDistrictToDPSM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToDPSM.keySet());
        }*/

        if (mapOfDistrictToGMM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToGMM.keySet());
        }
        

        for (Action_Plan__c ap : [SELECT Id, DistrictManagerAlt__c, DistrictSalesManagerAlt__c, DistrictPartsServiceManagerAlt__c, GenesisMarketManagerAlt__c, SalesDistrict__c, ServiceDistrict__c,MarketRef__c 
                                    FROM Action_Plan__c 
                                    WHERE MarketRef__c IN:setOfDistrictIds /*OR (SalesDistrict__c IN:setOfDistrictIds 
                                    AND ServiceDistrict__c IN:setOfDistrictIds)*/]) {

                               /* if (mapOfDistrictToDM.containsKey(ap.SalesDistrict__c)) {
                                    ap.DistrictManagerAlt__c = mapOfDistrictToDM.get(ap.SalesDistrict__c);
                                    if (mapOfDistrictToDM.get(ap.SalesDistrict__c) != NULL) {
                                        SObject sh = manualShareEdit(ap.Id, ap.DistrictManagerAlt__c, 'Action_Plan__Share');
                                        listSObj.add(sh);
                                    }
                                    
                                }
                                if (mapOfDistrictToDSM.containsKey(ap.SalesDistrict__c)) {
                                    ap.DistrictSalesManagerAlt__c = mapOfDistrictToDSM.get(ap.SalesDistrict__c);
                                    if (mapOfDistrictToDSM.get(ap.SalesDistrict__c) != NULL) {
                                        SObject sh =manualShareEdit(ap.Id, ap.DistrictSalesManagerAlt__c, 'Action_Plan__Share');
                                        listSObj.add(sh);
                                    }
                                }
                                if (mapOfDistrictToDPSM.containsKey(ap.SalesDistrict__c)) {
                                    ap.DistrictPartsServiceManagerAlt__c = mapOfDistrictToDPSM.get(ap.SalesDistrict__c);
                                    if (mapOfDistrictToDPSM.get(ap.SalesDistrict__c) != NULL) {
                                        SObject sh =manualShareEdit(ap.Id, ap.DistrictPartsServiceManagerAlt__c, 'Action_Plan__Share');
                                        listSObj.add(sh);
                                    }
                                }*/
                                if (mapOfDistrictToGMM.containsKey(ap.MarketRef__c)) {
                                    ap.GenesisMarketManagerAlt__c = mapOfDistrictToGMM.get(ap.MarketRef__c);
                                    if (mapOfDistrictToGMM.get(ap.MarketRef__c) != NULL) {
                                        SObject sh =manualShareEdit(ap.Id,ap.GenesisMarketManagerAlt__c, 'Action_Plan__Share');
                                        listSObj.add(sh);
                                    }
                                }
                                listAPToUpdate.add(ap);

                            }

                            if (listAPToUpdate.size() > 0) {
                                update listAPToUpdate;
                                if (listSObj.size() > 0) {
                                    Database.insert(listSObj,false);
                                }
                            }
    }

    /**
     * This update Alt Districts values.
     * @param newList new List of District record.
     * @param oldMap old Map of District record.
     * @return none.
     */
    public static void updateAltDistricts(List<District__c> newList, Map<Id, District__c> oldMap){

        for (District__c district : newList) {

           /* if (district.DistrictManagerAlt__c == NULL && district.DistrictManager__c != NULL) {
                district.DistrictManagerAlt__c = district.DistrictManager__c;
            }

            if (district.DistrictSalesManagerAlt__c == NULL && district.SalesManager__c != NULL) {
                district.DistrictSalesManagerAlt__c = district.SalesManager__c;
            }

            if (district.DistrictPartsServiceManagerAlt__c == NULL && district.DistrictPartsServiceManager__c != NULL) {
                district.DistrictPartsServiceManagerAlt__c = district.DistrictPartsServiceManager__c;
            }*/

            if (district.GenesisMarketManagerAlt__c == NULL && district.MarketManager__c != NULL) {
                district.GenesisMarketManagerAlt__c = district.MarketManager__c;
            }
        }
    }
    
    public static void updateAftersalesMarketmanager(List<District__c> newList, Map<Id, District__c> oldMap){
        
        Map<Id,Id> mapOfDistrictToAMM = new Map<Id,Id>();
        Set<Id> setOfDistrictIds = new Set<Id>();
        
		
        
        for(District__c district : newlist){
            if (district.Aftersales_Market_Manager__c != NULL) {
                mapOfDistrictToAMM.put(district.Id,district.Aftersales_Market_Manager__c);
                //district.GenesisMarketManagerAlt__c = district.Aftersales_Market_Manager__c;
            } else if (district.Aftersales_Market_Manager__c == NULL && oldMap != NULL &&
            oldMap.get(district.Id).Aftersales_Market_Manager__c != district.Aftersales_Market_Manager__c) {
                mapOfDistrictToAMM.put(district.Id,NULL);
            }
        }
        
        if (mapOfDistrictToAMM.size() > 0) {
            setOfDistrictIds.addAll(mapOfDistrictToAMM.keySet());
        }
        
        updateAMMInAccounts(setOfDistrictIds,mapOfDistrictToAMM);
        updateAMMInActionPlans(setOfDistrictIds,mapOfDistrictToAMM);
        updateAMMInEvaluations(setOfDistrictIds,mapOfDistrictToAMM);
    				
        
    }

    @Future
    public static void updateAMMInAccounts(Set<Id> setOfDistrictIds,Map<Id,Id> mapOfDistrictToAMM){

        List<Account> listAccToUpdate = new List<Account>();
        for (Account acc : [SELECT Id, Market__c
                            FROM Account 
                            WHERE Market__c IN:setOfDistrictIds]) {
                                
							if (mapOfDistrictToAMM.containsKey(acc.Market__c)) {
                        		acc.Aftersales_Market_Manager__c = mapOfDistrictToAMM.get(acc.Market__c);
                            	}
								listAccToUpdate.add(acc);
            				}
        
                        	if (listAccToUpdate.size() > 0) {
                                update listAccToUpdate;
                        	}
    }

    @Future
    public static void updateAMMInActionPlans(Set<Id> setOfDistrictIds,Map<Id,Id> mapOfDistrictToAMM){

            
        List<Action_Plan__c> listAPToUpdate = new List<Action_Plan__c>();
       
        List<SObject> listSObjAP = new List<SObject>();
        for (Action_Plan__c ap : [SELECT Id, MarketRef__c
                                    FROM Action_Plan__c 
                                    WHERE MarketRef__c IN:setOfDistrictIds]) {

                                if (mapOfDistrictToAMM.containsKey(ap.MarketRef__c)) {
                                    ap.Aftersales_Market_Manager__c = mapOfDistrictToAMM.get(ap.MarketRef__c);
                                    if (mapOfDistrictToAMM.get(ap.MarketRef__c) != NULL) {
                                        SObject sh = manualShareEdit(ap.Id,ap.Aftersales_Market_Manager__c, 'Action_Plan__Share');
                                        listSObjAP.add(sh);
                                    }
                                }
                                listAPToUpdate.add(ap);

                            }

                            if (listAPToUpdate.size() > 0) {
                                update listAPToUpdate;
                                
    System.debug('listSObjAP '+listSObjAP);
                                if (listSObjAP.size() > 0) {
                                    Database.insert(listSObjAP,false);
                                    System.debug('listSObjAP after '+listSObjAP);
                                }
                            }
    }

    @Future
    public static void updateAMMInEvaluations(Set<Id> setOfDistrictIds,Map<Id,Id> mapOfDistrictToAMM){
        List<Evaluation__c> listEvalToUpdate = new List<Evaluation__c>();  
        List<SObject> listSObj = new List<SObject>();
        for (Evaluation__c eval : [SELECT Id, MarketRef__c
                                   FROM Evaluation__c 
                                   WHERE MarketRef__c IN:setOfDistrictIds]) {
                                
							if (mapOfDistrictToAMM.containsKey(eval.MarketRef__c)) {
                        		eval.Aftersales_Market_Manager__c = mapOfDistrictToAMM.get(eval.MarketRef__c);
                            	}
								listEvalToUpdate.add(eval);
            				
        
                          	if (mapOfDistrictToAMM.containsKey(eval.MarketRef__c)) {
                                eval.Aftersales_Market_Manager__c = mapOfDistrictToAMM.get(eval.MarketRef__c);
                                if (mapOfDistrictToAMM.get(eval.MarketRef__c) != NULL) {
                                    SObject sh =  manualShareEdit(eval.Id, eval.Aftersales_Market_Manager__c, 'Evaluation__Share');
                                    listSObj.add(sh);
                                   }
                            	}
							}

                            if (listEvalToUpdate.size() > 0) {
                                update listEvalToUpdate;

                                if (listSObj.size() > 0) {
                                    Database.insert(listSObj,false);
                                }  
                            }
    }
        

    
   public static SObject manualShareEdit(Id recordId, Id userOrGroupId, String objectName) {
    String objName = recordId.getSObjectType().getDescribe().getName();
    SObject sh;
    Id parentId = recordId;
    sh = Schema.getGlobalDescribe().get(objectName).newSObject();
    sh.put('AccessLevel', 'Edit');
    sh.put('ParentId', parentId);  
    sh.put('UserOrGroupId', userOrGroupId);
    if (objectName == 'Action_Plan__Share') {
        
        sh.put('RowCause', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
    } else if (objectName == 'Evaluation__Share') {
        sh.put('RowCause', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
    }
 
    return sh;
 }

 
}