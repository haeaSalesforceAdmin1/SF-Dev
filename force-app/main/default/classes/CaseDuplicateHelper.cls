/**
 * @description       : Case trigger to check Dupliate with HMAReference__c and VIN__c objects
 * @author            : bseong@haeaus.com(refactoring)
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : bseong@haeaus.com
 * Modifications Log
 * Ver   Date         Author                     Modification
 *       2023-08-18   Bitna Seong                Refactoring   
**/
public with sharing class CaseDuplicateHelper {

    private static List<String> firstReportSourceListForSIMS = new List<String>{'HMC','Drum for Safety','SIMS'};
    private static List<String> firstReportSourceListForKIA = new List<String>{'Common SEL','Shared KIA Common Issue'};

    /*** 
     * @description : check Case duplication
     * @param newCaseList
    **/
    public static void checkCaseDupl(List<Case> newCaseList){
        Set<String> simsGsiNumberSet = new Set<String>();
        Set<String> kasoRecordTypeId = new Set<String>();

        for(RecordType obj : [
            SELECT 	Id
            FROM	RecordType
            WHERE	SobjectType = 'Case'
            AND		DeveloperName like 'KA%'  
        ]){
            kasoRecordTypeId.add(obj.Id);
        }


        for(Case caseObj: newCaseList){

            simsGsiNumberSet.add(caseObj.SIMS_GSI_Number__c);

            List<CaseVehicle__c> caseVehicle = new List<CaseVehicle__c>();
            List<KASOCaseVehicle__c> kasoCaseVehicle = new List<KASOCaseVehicle__c>();
            List<AggregateResult> aggregateResult = new List<AggregateResult>();

            String firstReportSource= caseObj.FirstReportSource__c;


            if(!caseObj.Is_GIR_Cloned__c){

                if(kasoRecordTypeId.contains(caseObj.RecordTypeId)){

                    if(firstReportSource!=null && (firstReportSourceListForSIMS.contains(firstReportSource) || firstReportSourceListForKIA.contains(firstReportSource)) ){

                        //////////////
                        //checkFirstReportSource(firstReportSource, caseObj);

                        String make = caseObj?.Make__c?.toLowerCase();
                        String modelCode = caseObj?.ModelCode__c;

                        List<string> makeList = make != null ? make.split(';') : new List<String>();
                        List<string> modelCodeList = modelCode != null ? modelCode.split(';')  : new List<String>();

                        ///////////////////////////////
                        if(modelCodeList.size()>0){

                            List<AggregateResult> hMCReferenceDataAggList = CaseTriggerUtil.queryHMCReference(
                                                                                                                'Make__c,ModelCode__c,VehicleModel__c',
                                                                                                                'Make__c,ModelCode__c,VehicleModel__c',
                                                                                                                makeList,
                                                                                                                modelCodeList
                                                                                                            );
                            ///////////////////
                            //String str = st[0];
                            //List<AggregateResult> hm = [SELECT  Make__c, Year__c,VehicleModel__c FROM HMAReferenceData__c WHERE Make__c IN (:c.Make__c) AND ModelCode__c IN (:c.ModelCode__c) AND Year__c IN : st and VehicleModel__c != NULL GROUP BY Make__c, Year__c,VehicleModel__c];
                            if(hMCReferenceDataAggList.isEmpty()){
                                //////////////
                                Trigger.new[0].addError('Case not created in Salesforce due to invalid model code or invalid year or invalid fuel type');
                            }
                        }
                    }

                }else{

                    if(firstReportSource!=null && (firstReportSourceListForSIMS.contains(firstReportSource) || firstReportSourceListForKIA.contains(firstReportSource)) ){

                        //////////////
                        checkFirstReportSource(firstReportSource, caseObj);


                        //////////////////////
                        String my = caseObj?.MY__c;
                        String engine = caseObj?.Engine__c;
                        String fuelType =caseObj?.Fuel_Type__c?.toLowerCase();
                        String make = caseObj?.Make__c?.toLowerCase();
                        String modelCode = caseObj?.ModelCode__c;

                        ////////////////////////
                        List<string> engineList = engine != null ? engine.split(';') : new List<String>();
                        List<string> fuelTypeList = fuelType != null ? fuelType.split(';')  : new List<String>();
                        List<string> myList = my != null ? my.split(';')  : new List<String>();
                        List<string> makeList = make != null ? make.split(';') : new List<String>();
                        List<string> modelCodeList = modelCode != null ? modelCode.split(';')  : new List<String>();

                        //////////////////////////
                        Set<String> mySet = new Set<String>(myList);
                        Set<String> engineSet = new Set<String>(engineList);
                        Set<String> fuelTypeSet = new Set<String>(fuelTypeList);

                        ///////////////////////////////
                        if(modelCodeList.size()>0){

                            List<AggregateResult> hMAReferenceDataAggList = CaseTriggerUtil.queryHMAReference(
                                                                                                                'Make__c,ModelCode__c,Year__c,VehicleModel__c,FuelType__c,EngineDescription__c',
                                                                                                                'Make__c,ModelCode__c,Year__c,VehicleModel__c,FuelType__c,EngineDescription__c',
                                                                                                                makeList,
                                                                                                                fuelTypeList,
                                                                                                                engineList,
                                                                                                                modelCodeList,
                                                                                                                myList
                                                                                                            );
                            Set<String> hMAReferenceMakeSet = new Set<String>();
                            Set<String> hMAReferenceYearSet = new Set<String>();
                            Set<String> hMAReferenceFuelTypeSet = new Set<String>();
                            Set<String> hMAReferenceEngineDescriptionSet = new Set<String>();
                            Set<String> hMAReferenceModelCodeSet = new Set<String>();
                            Set<String> vinMakeSet = new Set<String>();
                            Set<String> vinModelyearSet = new Set<String>();
                            Set<String> vinPQMSModelCodeSet = new Set<String>();
                            Set<String> vinFuelTypeSet = new Set<String>();
                            Set<String> vinEngineDescSet = new Set<String>();

                            ////////////////////////////////
                            setHMAReferenceData(hMAReferenceDataAggList, 
                                                hMAReferenceMakeSet,
                                                hMAReferenceYearSet,
                                                hMAReferenceFuelTypeSet,
                                                hMAReferenceEngineDescriptionSet,
                                                hMAReferenceModelCodeSet);
                            ////////////////////////////////
                            caseObj.Subject= 'GSI'+ ' (' + caseObj.SIMS_GSI_Number__c +') ' +caseObj.Subject;

                            List<VIN__c> vinObjList = new List<VIN__c>();

                            if(caseObj.VIN_Text_Field__c!=null){ 

                                vinObjList = [SELECT Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c,VIN_External_ID__c 
                                                FROM VIN__c 
                                                WHERE VIN_External_ID__c IN (:caseObj.VIN_Text_Field__c)];

                                setVinData(vinObjList,
                                            vinMakeSet,
                                            vinModelyearSet,
                                            vinPQMSModelCodeSet,
                                            vinFuelTypeSet,
                                            vinEngineDescSet
                                            );
                                ////////////////////////////////////////////
                                Boolean isDupMake = vinMakeSet.containsAll(hMAReferenceMakeSet);
                                Boolean isDupYear = vinModelyearSet.containsAll(hMAReferenceYearSet);
                                Boolean isDupModelCode = vinPQMSModelCodeSet.containsAll(hMAReferenceModelCodeSet);
                                // Boolean isDupMy = vinModelyearSet.containsAll(mySet);
                                Boolean isDupMy = hMAReferenceYearSet.containsAll(mySet);
                                Boolean isDupFuelType = vinFuelTypeSet.containsAll(fuelTypeSet);
                                Boolean isDupEngine = vinEngineDescSet.containsAll(engineSet);

                                /////////////////
                                if(hMAReferenceDataAggList.isEmpty() && vinObjList!=null && !vinObjList.isEmpty()){
                                    updateCaseByVin(caseObj, vinObjList, true);
                                } else if(!hMAReferenceDataAggList.isEmpty() && vinObjList.isEmpty()){
                                    //////////////////////////
                                    if(isDupMy){
                                        system.debug('inside else if');
                                        updateCaseToTest(caseObj);
                                    } else {
                                        system.debug('inside else if');
                                        caseObj.VIN_Text_Field__c=caseObj.VIN_Text_Field__c;
                                    }

                                } else if(!hMAReferenceDataAggList.isEmpty() && !vinObjList.isEmpty() && isDupMake && isDupYear && isDupModelCode && isDupFuelType && isDupEngine){
                                    updateCaseByVin(caseObj, vinObjList, true);
                                } else if(!hMAReferenceDataAggList.isEmpty() && !vinObjList.isEmpty() && isDupMake && isDupYear && isDupModelCode &&!isDupFuelType && !isDupEngine){
                                    updateCaseToTest(caseObj); 
                                } else if(!hMAReferenceDataAggList.isEmpty() && !vinObjList.isEmpty() && isDupYear && isDupModelCode){
                                    /*c.CaseID__c=c.VIN_Text_Field__c;c.VIN_Text_Field__c='test';*/
                                    updateCaseByVin(caseObj, vinObjList, false);
                                } else if(!hMAReferenceDataAggList.isEmpty() && !vinObjList.isEmpty() && isDupModelCode){
                                    updateCaseToTest(caseObj); 
                                } else{
                                    /*for(VIN__c vi: vin){
                                    //c.VehicleModel__c = vi.ModelDesc__c;
                                    c.VIN__c = vi.Id;
                                    //c.VIN_Text_Field__c=c.VIN_Text_Field__c;
                                    //c.Drivetrain__c=vi.DrivetrainDesc__c;
                                    //c.Fuel_Type__c=vi.FuelType__c;
                                    //c.Engine__c=vi.EngineDesc__c;
                                    //c.Trans__c=vi.TransmissionDesc__c;
                                    //c.ModelCode__c=c.ModelCode__c+';'+vi.PQMSModelcode__c;
                                    //c.MY__c=c.MY__c+';'+vi.ModelYear__c;
                                    //c.Make__c=c.Make__c+';'+vi.Make__c;
                                    c.VIN_Text_Field__c=c.VIN_Text_Field__c;
                                    }
                                    */
                                    updateCaseToTest(caseObj);
                                }
                            }

                            ///////////////////
                            //String str = st[0];
                            //List<AggregateResult> hm = [SELECT  Make__c, Year__c,VehicleModel__c FROM HMAReferenceData__c WHERE Make__c IN (:c.Make__c) AND ModelCode__c IN (:c.ModelCode__c) AND Year__c IN : st and VehicleModel__c != NULL GROUP BY Make__c, Year__c,VehicleModel__c];
                            if(hMAReferenceDataAggList.isEmpty() && vinObjList.isEmpty()){
                                //////////////
                                Trigger.new[0].addError('Case not created in Salesforce due to invalid model code or invalid year or invalid fuel type');
                            }
                        }
                    }



                }
            }
        }
        if(simsGsiNumberSet.size() > 0 && !simsGsiNumberSet.isEmpty()){

            /////////
            List<case> duplicateCaseList = [SELECT id,SIMS_GSI_Number__c FROM Case where SIMS_GSI_Number__c IN :simsGsiNumberSet];
            if(duplicateCaseList.size()>0){
                for(Case duplicateCase: duplicateCaseList){
                    if(duplicateCase.SIMS_GSI_Number__c!=null){
                        Trigger.new[0].addError('Case cannot be inserted because a case is already present with this Tracking ID:'+duplicateCase.SIMS_GSI_Number__c);
                    }
                }
            }
        }
    }
    
    /*** 
     * @description : check First Report Source of Case
     * @param firstReportSource, caseObj
    **/
    public static void checkFirstReportSource(String firstReportSource, Case caseObj){

        if(firstReportSourceListForSIMS.contains(firstReportSource)){
            caseObj.FirstReportSource__c='SIMS';
        }

        ///////////////
        if(firstReportSourceListForKIA.contains(firstReportSource)){
            caseObj.FirstReportSource__c='Shared KIA Common Issue';
        }

    }
    
    /*** 
     * @description : set HMAReferencData
     * @param hMAReferenceDataAggList, hMAReferenceMakeSet, hMAReferenceYearSet, hMAReferenceFuelTypeSet, hMAReferenceEngineDescriptionSet, hMAReferenceModelCodeSet
    **/
    public static void setHMAReferenceData(List<AggregateResult> hMAReferenceDataAggList, 
                                            Set<String> hMAReferenceMakeSet, 
                                            Set<String> hMAReferenceYearSet, 
                                            Set<String> hMAReferenceFuelTypeSet, 
                                            Set<String> hMAReferenceEngineDescriptionSet, 
                                            Set<String> hMAReferenceModelCodeSet
                                            )
    {
        for(AggregateResult hMAReferenceDataAgg : hMAReferenceDataAggList){
            hMAReferenceMakeSet.add((String.valueof(hMAReferenceDataAgg.get('Make__c'))?.toLowerCase()));
            hMAReferenceYearSet.add(String.valueof(hMAReferenceDataAgg.get('Year__c')));
            hMAReferenceFuelTypeSet.add((String.valueof(hMAReferenceDataAgg.get('FuelType__c'))?.toLowerCase()));
            hMAReferenceEngineDescriptionSet.add(String.valueof(hMAReferenceDataAgg.get('EngineDescription__c')));
            hMAReferenceModelCodeSet.add(String.valueof(hMAReferenceDataAgg.get('ModelCode__c')));
        }
    }

    /*** 
     * @description : set VIN data
     * @param vinObjList, vinMakeSet, vinModelyearSet, vinPQMSModelCodeSet, vinFuelTypeSet, vinEngineDescSet
    **/
    public static void setVinData( List<VIN__c> vinObjList,
                                    Set<String> vinMakeSet,
                                    Set<String> vinModelyearSet,
                                    Set<String> vinPQMSModelCodeSet,
                                    Set<String> vinFuelTypeSet,
                                    Set<String> vinEngineDescSet
                                 )
    {
        for(VIN__c vinObj: vinObjList){
            vinMakeSet.add((vinObj.Make__c)?.toLowerCase());
            vinModelyearSet.add(vinObj.ModelYear__c);
            vinPQMSModelCodeSet.add(vinObj.PQMSModelcode__c);
            vinFuelTypeSet.add((vinObj.FuelType__c)?.toLowerCase()); 
            vinEngineDescSet.add(vinObj.EngineDesc__c);
        }
    }

    /*** 
     * @description : update case for test
     * @param caseObj
    **/
    public static void updateCaseToTest(Case caseObj){
        caseObj.CaseID__c=caseObj.VIN_Text_Field__c;
        caseObj.VIN_Text_Field__c='test';
    }
    
    /*** 
     * @description : update case by vin
     * @param caseObj, vinObjList, updateOtherFields
    **/    
    public static void updateCaseByVin(Case caseObj, List<VIN__c> vinObjList, Boolean updateOtherFields){
        for(VIN__c vinObj: vinObjList){
            caseObj.VIN__c = vinObj.Id;
            caseObj.VIN_Text_Field__c='';

            if(updateOtherFields){
                caseObj.VehicleModel__c = vinObj.ModelDesc__c;
                caseObj.Drivetrain__c=vinObj.DrivetrainDesc__c;
                caseObj.Fuel_Type__c=vinObj.FuelType__c;
                caseObj.Engine__c=vinObj.EngineDesc__c;
                caseObj.Trans__c=vinObj.TransmissionDesc__c;
                caseObj.ModelCode__c=vinObj.PQMSModelcode__c;
                caseObj.MY__c=vinObj.ModelYear__c;
                caseObj.Make__c=vinObj.Make__c;
            }

        }
    }
}