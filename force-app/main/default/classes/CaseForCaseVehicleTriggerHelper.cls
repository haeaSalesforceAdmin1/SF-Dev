/**
 * @description       : Case trigger to create CaseVehicle
 * @author            : bseong@haeaus.com(refactoring)
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : bseong@haeaus.com
 * Modifications Log
 * Ver   Date         Author                     Modification
 *       2023-08-08   Bitna Seong                Refactoring   
**/
public with sharing class CaseForCaseVehicleTriggerHelper {
    

    private static List<String> engineList;
    private static List<String> fuelTypeList;
    private static List<String> myList;
    private static List<String> makeList;
    private static List<String> modelCodeList;

    /*** 
     * @description : case trigger main logic to create CaseVehicle
     * @param caseMap
    **/
    public static void caseForCaseVehicle(Map<Id, Case> casesMap){

        List<CaseVehicle__c> caseVehicleList = new List<CaseVehicle__c>();

        Set<String> nasoRecordTypeId = new Set<String>();

        for(RecordType obj : [
            SELECT 	Id
            FROM	RecordType
            WHERE	SobjectType = 'Case'
            AND		(NOT DeveloperName like 'KA%')  
        ]){
            nasoRecordTypeId.add(obj.Id);
        }

        for(Case caseObj:casesMap.values()){
            if(nasoRecordTypeId.contains(caseObj.RecordTypeId)){

            //create CaseVehicle record after insert Case which is from external source with HMAReferenceData__c or VIN__c object.
            if(caseObj.FirstReportSource__c!=null&&(caseObj.FirstReportSource__c=='SIMS'||caseObj.FirstReportSource__c=='Shared KIA Common Issue')){
                String my        = caseObj?.MY__c;
                String engine    = caseObj?.Engine__c;
                String fuelType  = caseObj?.Fuel_Type__c;
                String make      = caseObj?.Make__c;
                String modelCode = caseObj?.ModelCode__c;
                
                engineList     = null!=engine?engine.split(';'):new List<String>();
                fuelTypeList   = null!=fuelType?fuelType.split(';'):new List<String>();
                myList         = null!=my?my.split(';'):new List<String>();
                makeList       = null!=make?make.split(';'):new List<String>();
                modelCodeList  = null!=modelCode?modelCode.split(';'):new List<String>();

                //VIN__c X , test X  : create CaseVehicle by HMAReferenceData__c record 
                if(caseObj.VIN_Text_Field__c!=null && caseObj.VIN_Text_Field__c!='test' && caseObj.VIN_Text_Field__c!='test1'){
                    if(myList.size()>0) caseWithHMA(caseObj, caseVehicleList); 
                }

                //VIN__c, test : create CaseVehicle by HMAReferenceData__c and VIN_c
                if(caseObj.VIN_Text_Field__c=='test'){  //this condition is found on Stage org but not found on Production

                    if(myList.size()>0){
                        List<AggregateResult> hMAReferenceDataAggList = CaseTriggerUtil.queryHMAReference(
                                                                                                            'Make__c,VehicleModel__c,FuelType__c,EngineDescription__c',
                                                                                                            'Make__c,VehicleModel__c,FuelType__c,EngineDescription__c',
                                                                                                            makeList,
                                                                                                            fuelTypeList,
                                                                                                            engineList,
                                                                                                            modelCodeList,
                                                                                                            myList
                                                                                                        );
                        List<AggregateResult> vinObjListForTest = new List<AggregateResult>();
                        List<CaseVehicle__c> caseVehicleForTest = new List<CaseVehicle__c>();
                        vinObjListForTest= [
                                        SELECT Id,Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c 
                                        FROM VIN__c
                                        WHERE VIN_External_ID__c IN(:caseObj.CaseID__c) 
                                        AND ModelDesc__c!=NULL
                                        GROUP BY Id,Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c
                                    ];

                        if(hMAReferenceDataAggList.size()>0){

                            for(AggregateResult hMAReferenceDataAgg : hMAReferenceDataAggList){
                                caseVehicleForTest.add(createCaseVehicle( hMAReferenceDataAgg, caseObj, null) );


                                //if(vin.isEmpty()){List<case> csae = [SELECT VIN_Text_Field__c,CaseID__c FROM Case WHERE Id IN :casesMap.values()];for(case aaa : csae){ aaa.VIN_Text_Field__c = aaa.CaseID__c;aaa.CaseID__c=''; } UPDATE csae;}
                                if(!caseVehicleForTest.isEmpty()){
                                    updateCase(casesMap.values(), null, false);
                                }
                                if(!vinObjListForTest.isEmpty()){

                                    for(AggregateResult vinObj : vinObjListForTest){
                                        updateCase(casesMap.values(), vinObj, true);
                                        caseVehicleForTest.add(createCaseVehicle(vinObj, caseObj, true));
                                    }
                                }
                                // insert caseVehicleList2;
                                caseVehicleList.addAll(caseVehicleForTest);

                            }
                        }else{
                            updateCase(casesMap.values(), null, false);
                        }
                    }
                }
                // insert caseVehicleList;
            }

            if(caseObj.FirstReportSource__c!=null&&(caseObj.FirstReportSource__c=='SIMS'||caseObj.FirstReportSource__c=='Shared KIA Common Issue')){
                //Create CaseVehicle by VIN__c 
                caseWithVin(caseObj, caseVehicleList, casesMap);
            }
        }
    }

        if(caseVehicleList.size() > 0){
            insert caseVehicleList;
        } 

    }

    /*** 
     * @description : create CaseVehicle from Case with HMAreference object
     * @param caseObj, caseVehicleList
    **/
    public static void caseWithHMA(Case caseObj, List<CaseVehicle__c> caseVehicleList){

        List<AggregateResult> hMAReferenceDataAggList = CaseTriggerUtil.queryHMAReference(
                                                                                            'Make__c,Year__c,VehicleModel__c,FuelType__c,EngineDescription__c',
                                                                                            'Make__c,Year__c,VehicleModel__c,FuelType__c,EngineDescription__c',
                                                                                            makeList,
                                                                                            fuelTypeList,
                                                                                            engineList,
                                                                                            modelCodeList,
                                                                                            myList
                                                                                        );
            if(hMAReferenceDataAggList.size()>0){
                for(AggregateResult hMAReferenceDataAgg : hMAReferenceDataAggList){
                    caseVehicleList.add(createCaseVehicle(hMAReferenceDataAgg, caseObj, false));
                }
            }
    }

    /*** 
     * @description : create CaseVehicle from Case with VIN object
     * @param caseObj, caseVehicleList, casesMap
    **/
    public static void caseWithVin(Case caseObj, List<CaseVehicle__c> caseVehicleList, Map<Id, Case> casesMap){

        List<AggregateResult> vinObjList = new List<AggregateResult>();
        List<CaseVehicle__c> caseVehicleListFromVin = new List<CaseVehicle__c>();

        //VIN__c, Test X => create CaseVehicle by VIN__c
        if(caseObj.VIN_Text_Field__c != null){
            vinObjList=[SELECT Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c 
                        FROM VIN__c
                        WHERE VIN_External_ID__c IN(:caseObj.VIN_Text_Field__c) AND ModelDesc__c!=NULL
                        GROUP BY Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c];

            if(!vinObjList.isEmpty()){
                for(AggregateResult vinObj:vinObjList){
                    caseVehicleListFromVin.add(createCaseVehicle(vinObj, caseObj, true));

                    if(!caseVehicleListFromVin.isEmpty()) updateCase(casesMap.values(), null, null);
                }
            }
        }
        // insert caseVehicleList2;
        caseVehicleList.addAll(caseVehicleListFromVin);
    }

    /*** 
     * @description : update Case after create CaseVehicle object
     * @param caseList, vinObj, isVin
    **/
    public static void updateCase(List<Case> caseList, AggregateResult vinObj, Boolean isVin){
        List<Case> caseObjListToUpdate =[SELECT VIN_Text_Field__c,CaseID__c FROM Case WHERE Id IN:caseList];
        for(case caseToUpdate : caseObjListToUpdate){

            if(isVin == false) caseToUpdate.CaseID__c  = '';
            if(isVin == true)  caseToUpdate.VIN__c     = vinObj.Id;

            caseToUpdate.VIN_Text_Field__c = isVin == false ? caseToUpdate.CaseID__c : '';
        }
        update caseObjListToUpdate;

    }

    /*** 
     * @description : create CaseVehicle 
     * @param aggObj, caseObj, isVin
    **/
    public static CaseVehicle__c createCaseVehicle(AggregateResult aggObj, Case caseObj, Boolean isVin){
        CaseVehicle__c caseVehicle = new CaseVehicle__c();
        caseVehicle.Case__c                    = caseObj.Id;
        if(isVin == true){
            caseVehicle.DrivetrainDescription__c   = String.valueof(aggObj.get('DrivetrainDesc__c'));
            caseVehicle.TransmissionDescription__c = String.valueof(aggObj.get('TransmissionDesc__c'));
        }
        caseVehicle.EngineDescription__c       = isVin == true? String.valueof(aggObj.get('EngineDesc__c')) : String.valueof(aggObj.get('EngineDescription__c'));
        caseVehicle.FuelType__c                = String.valueof(aggObj.get('FuelType__c'));
        caseVehicle.HasModelCode__c            = true;
        caseVehicle.Make__c                    = String.valueof(aggObj.get('Make__c'));
        caseVehicle.Model__c                   = isVin == true? String.valueof(aggObj.get('ModelDesc__c')) : String.valueof(aggObj.get('VehicleModel__c'));
        caseVehicle.ModelCode__c               = isVin == true? String.valueof(aggObj.get('PQMSModelcode__c')) : caseObj.ModelCode__c;
        caseVehicle.VehicleYear__c             = isVin == true? String.valueof(aggObj.get('ModelYear__c')) : isVin == false? String.valueof(aggObj.get('Year__c')) : caseObj.MY__c;

        return caseVehicle;
    }


}