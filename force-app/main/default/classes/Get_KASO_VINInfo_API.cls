/**
* @class : Get_KASO_VINInfo_API.cls
* @Author : JIHYE
* @Date : 2023-04-25, 화 오전 9:50
* @Version : 1.0
* @Method :
*
* @Modified
* ---------------------------------------------
* NO | Date | Modifier | Description
* ---------------------------------------------
* 1. | 2023-04-25 | JIHYE | 최초작성
**/

public with sharing class Get_KASO_VINInfo_API {

    @AuraEnabled
    public static Map<String, String> Get_KASO_VINInfo(String vinNumber){

        Map<String, String> selectedVinData = new Map<String, String>();

        List<KASO_VIN__c> vinInfo = [ SELECT Id, KASOVINNAME__c 
                                        FROM KASO_VIN__c 
                                       WHERE KASOVINNAME__c = :vinNumber ];                     

        if(vinInfo.size()>0){
            selectedVinData.put('Id', vinInfo[0].Id);    
            selectedVinData.put('Name', vinInfo[0].KASOVINNAME__c);    
            System.debug(vinInfo[0].KASOVINNAME__c);
            return selectedVinData; 
        }else{
            return Get_KASO_VINInterface(vinNumber);
        }
    }

    public static Map<String, String> Get_KASO_VINInterface(String vinNumber) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        req.setHeader('referer', 'https://hmausa.lightning.force.com');
        req.setEndpoint('https://openapi.sqim.hmckmc.co.kr/openApi/globalCmt/vin/vehicle/info?vin='+vinNumber);
        req.setHeader('Authorization', 'VL7sTefURWOjfrGbwWg/ysubG5ix2U7RxbIUa6/roLFAgaQyisFoIPVQTkxRIb1P25+8j9OFQPngICT/eFhk9caVWuOPlJis3j5YraLpmvPeoM41THTPPBhE87/dKBhK');
        req.setMethod('GET');
        req.setTimeout(60000);
        
        Map<String, String> resVinData = new Map<String, String>();

        try { 
            res = http.send(req);
            System.debug(res.getBody());
            System.debug(res.getStatusCode());
            Integer statusCode = res.getStatusCode();

            if (statusCode == 200) {
                Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
                if(!((List<Object>)deserialized.get('data')).isEmpty()){
                    List<Map<String, Object>> Data = new List<Map<String, Object>>();
                    
                    for (Object instance : (List<Object>)deserialized.get('data'))
                        Data.add((Map<String, Object>)instance);   

                    System.debug('res.getBody ==== ' + res.getBody());
                    System.debug(Data[0].get('vin'));


                    // insert kaso_vin
                    KASO_VIN__c insertKasoVin = new KASO_VIN__c();

                    insertKasoVin.Name = '*****************';                                                 // Mapping column : Masking Source VIN
                    insertKasoVin.KASOVINNAME__c = (String)Data[0].get('vin');


                    String productionDate = (String)Data[0].get('prdnDt');                                    // Mapping column : Source VIN
                    Date convertProductionDate = Date.valueOf(productionDate.substring(0, 4) + '-' 
                                                 + productionDate.substring(4, 6) + '-' 
                                                 + productionDate.substring(6, 8) );
                    insertKasoVin.Production_Date__c = convertProductionDate;                                 // Mapping column : Production_Date__c

                    String soldDate = (String)Data[0].get('saleDt');                                         
                    Date convertSoldDate = Date.valueOf(soldDate.substring(0, 4) + '-' 
                                                + soldDate.substring(4, 6) + '-' 
                                                + soldDate.substring(6, 8) );
                    insertKasoVin.SoldDate__c = convertSoldDate;                                              // Mapping column : SoldDate__c

                    insertKasoVin.CountryofOrgin__c = (String)Data[0].get('natNm');                           // Mapping column : CountryofOrgin__c
                    insertKasoVin.RegionName__c = (String)Data[0].get('saleNatNm');                           // Mapping column : RegionName__c
                    insertKasoVin.PQMSModelCode__c = (String)Data[0].get('prjVehlCd');                                    // Mapping column : PQMSModelCode__c                 
                    insertKasoVin.PlantCode__c = (String)Data[0].get('trimPlntCd');                           // Mapping column : PlantCode__c
                    insertKasoVin.ManufName__c = (String)Data[0].get('plant');                                // Mapping column : ManufName__c
                    insertKasoVin.PQMSModelDesc__c = (String)Data[0].get('stdVehlNm');                        // Mapping column : PQMSModelDesc__c                   
                    insertKasoVin.FuelType__c = (String)Data[0].get('engScnCd');                              // Mapping column : FuelType__c              
                    insertKasoVin.ModelYear__c = ((String)(Data[0].get('mdyY'))).substring(0, 4);             // Mapping column : ModelYear__c  

                    if(Data[0].get('saleBlndCd') == 'H'){
                        insertKasoVin.Make__c = 'Hyundai'; 
                    }else if(Data[0].get('saleBlndCd') == 'G'){
                        insertKasoVin.Make__c = 'Genesis'; 
                    }else if(Data[0].get('saleBlndCd') == 'K'){
                        insertKasoVin.Make__c = 'Kia'; 
                    }else{
                        insertKasoVin.Make__c = (String)Data[0].get('saleBlndCd');                            // Mapping column : Make__c
                    }

                    insertKasoVin.TransmissionCD__c = (String)Data[0].get('transmissionCd');                  // Mapping column : TransmissionCD__c
                    insertKasoVin.TransmissionDesc__c = (String)Data[0].get('tmPrjCd');                       // Mapping column : TransmissionDesc__c
                    insertKasoVin.EngineCode__c = (String)Data[0].get('engTymaCd');                           // Mapping column : EngineCode__c  
                    insertKasoVin.EngineDesc__c = (String)Data[0].get('pqmsEngNm');                           // Mapping column : EngineDesc__c
                    insertKasoVin.EngineNumber__c = (String)Data[0].get('engNo');                             // Mapping column : EngineNumber__c
                    insertKasoVin.RegionCD__c = (String)Data[0].get('saleNatCd');                             // Mapping column : RegionCD__c
                    //insertKasoVin.EngineDesciption__c = (String)Data[0].get('engTymaCd');                   // Mapping column : EngineDesciption__c
                    insertKasoVin.EngineDesciption__c = (String)Data[0].get('pqmsEngNm');                     // Mapping column : EngineDesciption__c
                    insertKasoVin.ModelDesc__c = (String)Data[0].get('vehicleModel');                         // Mapping column : ModelDesc__c
                    //insertKasoVin.VIN_External_ID__c = (String)Data[0].get('vin');                          // Mapping column : VIN_External_ID__c
                    insertKasoVin.CBU_CKD__c = (String)Data[0].get('ckdScnCd');                               // Mapping column : CBU_CKD__c
                    insertKasoVin.ProdCorp__c = (String)Data[0].get('prdnPlntNm') + '(' + (String)Data[0].get('prdnCorpANm') + ')';     // Mapping column : ProdCorp__c

                    String strQLTY_CAR_TYPE_CD = '';
                    if(Data[0].get('qltyCarTypeCd') == 'P'){
                        strQLTY_CAR_TYPE_CD = '승용(Passenger)';
                    }
                    else if(Data[0].get('qltyCarTypeCd') == 'S'){
                        strQLTY_CAR_TYPE_CD = '소상(Small Commercial)';
                    }
                    else if(Data[0].get('qltyCarTypeCd') == 'V'){
                        strQLTY_CAR_TYPE_CD = 'MPV';
                    }
                    else if(Data[0].get('qltyCarTypeCd') == 'B'){
                        strQLTY_CAR_TYPE_CD = '버스(Bus)';
                    }
                    else if(Data[0].get('qltyCarTypeCd') == 'T'){
                        strQLTY_CAR_TYPE_CD = '트럭(Truck)';
                    }
                    else if(Data[0].get('qltyCarTypeCd') == 'M'){
                        strQLTY_CAR_TYPE_CD = '군용(Military)';
                    }
                    else if(Data[0].get('qltyCarTypeCd') == 'Z'){
                        strQLTY_CAR_TYPE_CD = 'ETC';
                    }
                    else if(Data[0].get('qltyCarTypeCd') == 'U'){
                        strQLTY_CAR_TYPE_CD = 'SUV';
                    }
                    insertKasoVin.VehicleType__c = strQLTY_CAR_TYPE_CD;                                       // Mapping column : VehicleType__c

                    insert insertKasoVin;
            
                    List<KASO_VIN__c> inserVinInfo = [ SELECT Id, Name 
                                                         FROM KASO_VIN__c 
                                                        WHERE KASOVINNAME__c = :vinNumber ];        

                    resVinData.put('Id', inserVinInfo[0].Id);
                    resVinData.put('Name', vinNumber);

                    return resVinData;
                }  
            }
            return resVinData;
           
        } catch (System.CalloutException e) {
            System.debug('Callout error: ' + e);
            System.debug(res.toString());
            System.debug('statusCode error: ' + e.getMessage());
            return resVinData;
            
        } catch (System.JSONException j) {
            System.debug('Callout error: ' + j);
            System.debug(res.toString());
            System.debug('statusCode error: ' + j.getMessage());
            return resVinData;
        }    
    }

}