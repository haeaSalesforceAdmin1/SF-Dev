Trigger JSONTrigger on Case (after insert) {
    //20230807 Bitna Seong : Comment out for refactoring
    
    // for (Case c: trigger.new){
    // List<CaseVehicle__c> cv = new List<CaseVehicle__c>();
    // List<AggregateResult> ag = new List<AggregateResult>();
    // if(c.FirstReportSource__c!=null && (c.FirstReportSource__c =='SIMS' || c.FirstReportSource__c =='Shared KIA Common Issue') ){
    // String s = c?.MY__c;
    // String Engine = c?.Engine__c;
    // String fuel =c?.Fuel_Type__c;
    // String m = c?.Make__c;
    // String mo = c?.ModelCode__c;
    // List<string> e= null != Engine ? Engine.split(';') : new List<String>();
    // List<string> f= null != fuel ? fuel.split(';') : new List<String>();
    // List<string> st= null != s ? s.split(';') : new List<String>();
    // List<string> st1= null != m ? m.split(';') : new List<String>();
    // List<string> st2= null != mo ? mo.split(';') : new List<String>();
    // String str = null!= null && st.size() >0 ? st[0] : '';
    // if(c.VIN_Text_Field__c!=null && c.VIN_Text_Field__c!='test' && c.VIN_Text_Field__c!='test1' ){
    // if(st.size()>0){
          
    // List<AggregateResult> hm = [SELECT  Make__c,Year__c,VehicleModel__c,FuelType__c,EngineDescription__c FROM HMAReferenceData__c WHERE Make__c IN : st1 AND FuelType__c IN : f AND EngineDescription__c IN : e AND ModelCode__c IN : st2 AND Year__c IN : st and VehicleModel__c != NULL GROUP BY Make__c,Year__c,VehicleModel__c,FuelType__c,EngineDescription__c];
    // if(hm.size()>0){ for(AggregateResult h:hm){
    // CaseVehicle__c cvh = new CaseVehicle__c();cvh.Case__c= c.Id;cvh.EngineDescription__c=String.valueof(h.get('EngineDescription__c'));cvh.FuelType__c=String.valueof(h.get('FuelType__c'));cvh.Make__c = String.valueof(h.get('Make__c'));cvh.ModelCode__c = c.ModelCode__c;cvh.HasModelCode__c=true;
    // cvh.VehicleYear__c =String.valueof(h.get('Year__c'));cvh.Model__c = String.valueof(h.get('VehicleModel__c'));cv.add(cvh);
    // }
    // }
    // }
    // }
    // if(c.VIN_Text_Field__c=='test'){
    
    // if(st.size()>0){
          
    // List<AggregateResult> hm = [SELECT  Make__c,VehicleModel__c,FuelType__c,EngineDescription__c FROM HMAReferenceData__c WHERE Make__c IN : st1 AND FuelType__c IN : f AND EngineDescription__c IN : e AND ModelCode__c IN : st2 AND Year__c IN : st and VehicleModel__c != NULL GROUP BY Make__c,VehicleModel__c,FuelType__c,EngineDescription__c];
    // List<AggregateResult> vin = new List<AggregateResult>();
    // List<CaseVehicle__c> cv2 = new List<CaseVehicle__c>();
    // vin = [SELECT Id,Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c FROM VIN__c where VIN_External_ID__c IN (:c.CaseID__c) and ModelDesc__c != NULL GROUP BY Id,Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c];
    
    // if(hm.size()>0){
    // for(AggregateResult h:hm){
    // CaseVehicle__c cvh = new CaseVehicle__c(); cvh.Case__c= c.Id;cvh.EngineDescription__c=String.valueof(h.get('EngineDescription__c'));cvh.FuelType__c=String.valueof(h.get('FuelType__c')); cvh.Make__c = String.valueof(h.get('Make__c')); cvh.ModelCode__c = c.ModelCode__c; cvh.VehicleYear__c =c.MY__c;cvh.HasModelCode__c=true;
    
    // cvh.Model__c = String.valueof(h.get('VehicleModel__c'));
    
    // cv.add(cvh);
    // //if(vin.isEmpty()){List<case> csae = [SELECT VIN_Text_Field__c,CaseID__c FROM Case WHERE Id IN :trigger.new];for(case aaa : csae){ aaa.VIN_Text_Field__c = aaa.CaseID__c;aaa.CaseID__c=''; } UPDATE csae;}
    // if(!cv.isEmpty()){
    //     List<case> cse = [SELECT VIN_Text_Field__c,CaseID__c FROM Case WHERE Id IN :trigger.new];
    //     for(case aa : cse){ aa.VIN_Text_Field__c = aa.CaseID__c;aa.CaseID__c=''; } UPDATE cse;}
    //     if(!vin.isEmpty()){
    //     for(AggregateResult agg:vin){
    //     List<case> csee = [SELECT VIN_Text_Field__c,CaseID__c FROM Case WHERE Id IN :trigger.new];
    //     for(case aaa : csee){ aaa.VIN__c = agg.Id;aaa.VIN_Text_Field__c='';} UPDATE csee;
    //      CaseVehicle__c cvh2 = new CaseVehicle__c();
    // cvh2.Case__c= c.Id;cvh2.Model__c = String.valueof(agg.get('ModelDesc__c'));cvh2.DrivetrainDescription__c=String.valueof(agg.get('DrivetrainDesc__c'));cvh2.FuelType__c=String.valueof(agg.get('FuelType__c'));cvh2.EngineDescription__c=String.valueof(agg.get('EngineDesc__c'));cvh2.TransmissionDescription__c=String.valueof(agg.get('TransmissionDesc__c'));cvh2.ModelCode__c=String.valueof(agg.get('PQMSModelcode__c'));cvh2.VehicleYear__c=String.valueof(agg.get('ModelYear__c'));cvh2.HasModelCode__c=true;cvh2.Make__c=String.valueof(agg.get('Make__c'));cv2.add(cvh2);
     
    //      }
    //      }
    //      insert cv2;
    // }
    // }else{List<case> csae = [SELECT VIN_Text_Field__c,CaseID__c FROM Case WHERE Id IN :trigger.new];for(case aaa : csae){ aaa.VIN_Text_Field__c = aaa.CaseID__c;aaa.CaseID__c=''; } UPDATE csae;}
    // }
    // }
    
    
    //  insert cv; 
    
    //     }
        
    // if(c.FirstReportSource__c!=null && (c.FirstReportSource__c =='SIMS' || c.FirstReportSource__c =='Shared KIA Common Issue') ){
    
    // List<AggregateResult> vin = new List<AggregateResult>();
    // List<CaseVehicle__c> cv1 = new List<CaseVehicle__c>();
    // if(c.VIN_Text_Field__c!=null){ 
    // vin = [SELECT Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c FROM VIN__c where VIN_External_ID__c IN (:c.VIN_Text_Field__c) and ModelDesc__c != NULL GROUP BY Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c];
    
        
    // if(!vin.isEmpty()){ for(AggregateResult h:vin){
    // CaseVehicle__c cvh1 = new CaseVehicle__c();cvh1.Case__c= c.Id;cvh1.Model__c = String.valueof(h.get('ModelDesc__c'));
    // cvh1.DrivetrainDescription__c=String.valueof(h.get('DrivetrainDesc__c'));cvh1.FuelType__c=String.valueof(h.get('FuelType__c'));cvh1.EngineDescription__c=String.valueof(h.get('EngineDesc__c'));cvh1.TransmissionDescription__c=String.valueof(h.get('TransmissionDesc__c'));cvh1.ModelCode__c=String.valueof(h.get('PQMSModelcode__c'));cvh1.VehicleYear__c=String.valueof(h.get('ModelYear__c'));cvh1.Make__c=String.valueof(h.get('Make__c'));cvh1.HasModelCode__c=true;
    // cv1.add(cvh1);
    //  if(!cv1.isEmpty()){List<case> cs = [SELECT VIN_Text_Field__c FROM Case WHERE Id IN :trigger.new];for(case a : cs){a.VIN_Text_Field__c = '';} UPDATE cs;
    //     }
    // }
    // }
    // }
    
    //  insert cv1; 
    
    //     }
       
    //     }
        
    }