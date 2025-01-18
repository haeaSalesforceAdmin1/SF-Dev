trigger CaseDuplicate on Case (before insert) {
    //20230807 Bitna Seong : Comment out for refactoring
    
    // Set<String> TrackingId = new Set<String>();
    
    // for(Case c: trigger.new){
    //             TrackingId.add(c.SIMS_GSI_Number__c);
                
    // List<CaseVehicle__c> cv = new List<CaseVehicle__c>();
    // List<AggregateResult> ag = new List<AggregateResult>();
    // String FirstReportSource=c.FirstReportSource__c;
    // if(FirstReportSource!=null && (FirstReportSource =='HMC' || FirstReportSource =='Drum for Safety' || FirstReportSource =='Common SEL' || FirstReportSource =='SIMS' || FirstReportSource =='Shared KIA Common Issue') ){
    // if(FirstReportSource =='HMC' || FirstReportSource =='Drum for Safety' || FirstReportSource =='SIMS'){c.FirstReportSource__c='SIMS';}
    // if(FirstReportSource =='Common SEL' || FirstReportSource =='Shared KIA Common Issue'){c.FirstReportSource__c='Shared KIA Common Issue';}
    // String s = c?.MY__c;
    // String Engine = c?.Engine__c;
    // String fuel =c?.Fuel_Type__c;
    // String m = c?.Make__c;
    // String mo = c?.ModelCode__c;
    // List<string> e = Engine != null ? Engine.split(';') : new List<String>();
    // List<string> f = fuel != null ? fuel.split(';')  : new List<String>();
    // List<string> st = s != null ? s.split(';')  : new List<String>();
    // List<string> st1 = m != null ? m.split(';') : new List<String>();
    // List<string> st2 = mo != null ? mo.split(';')  : new List<String>();
    // Set<String> sStrings = new Set<String>(st);
    // Set<String> eng = new Set<String>(e);
    // Set<String> fl = new Set<String>(f);
    // if(st.size()>0){
    // List<AggregateResult> hm = [SELECT  Make__c,ModelCode__c,Year__c,VehicleModel__c,FuelType__c,EngineDescription__c FROM HMAReferenceData__c WHERE Make__c IN : st1 AND FuelType__c IN : f AND EngineDescription__c IN : e AND ModelCode__c IN : st2 AND Year__c IN : st and VehicleModel__c != NULL GROUP BY Make__c,ModelCode__c,Year__c,VehicleModel__c,FuelType__c,EngineDescription__c];
    // Set<String> sg1 = new Set<String>();
    // Set<String> sg2 = new Set<String>();
    // Set<String> sg3 = new Set<String>();
    // Set<String> sg4 = new Set<String>();
    // Set<String> sg5 = new Set<String>();
    // Set<String> sg6 = new Set<String>();
    // Set<String> sg7 = new Set<String>();
    // Set<String> sg8 = new Set<String>();
    // Set<String> sg9 = new Set<String>();
    // Set<String> sg10 = new Set<String>();
    // for(AggregateResult ar:hm){
    // sg1.add((String.valueof(ar.get('Make__c'))?.toLowerCase()));
    // sg2.add(String.valueof(ar.get('Year__c')));
    // sg7.add((String.valueof(ar.get('FuelType__c'))?.toLowerCase()));
    // sg8.add(String.valueof(ar.get('EngineDescription__c')));
    // sg3.add(String.valueof(ar.get('ModelCode__c')));
    // }
    // c.Subject= 'GSI'+ ' (' + c.SIMS_GSI_Number__c +') ' +c.Subject;
    // List<VIN__c> vin = new List<VIN__c>();
    // if(c.VIN_Text_Field__c!=null){
    // vin = [SELECT Make__c,PQMSModelcode__c,ModelYear__c,ModelDesc__c,EngineDesc__c,FuelType__c,DrivetrainDesc__c,TransmissionDesc__c,VIN_External_ID__c FROM VIN__c where VIN_External_ID__c IN (:c.VIN_Text_Field__c)];
    // for(VIN__c arr:vin){
    // sg4.add((arr.Make__c)?.toLowerCase());
    // sg5.add(arr.ModelYear__c);
    // sg6.add(arr.PQMSModelcode__c);
    // sg9.add((arr.FuelType__c)?.toLowerCase());
    // sg10.add(arr.EngineDesc__c);
    // }
    // Boolean one = sg4.containsAll(sg1);
    // Boolean two = sg5.containsAll(sg2);
    // Boolean three = sg6.containsAll(sg3);
    // Boolean four = sg2.containsAll(sStrings);
    // Boolean five = sg9.containsAll(fl);
    // Boolean six = sg10.containsAll(eng);
    
    
    // if(hm.isEmpty() && vin!=null && !vin.isEmpty()){
    // for(VIN__c vi: vin){
    // c.VehicleModel__c = vi.ModelDesc__c;c.VIN__c = vi.Id;c.VIN_Text_Field__c='';c.Drivetrain__c=vi.DrivetrainDesc__c;c.Fuel_Type__c=vi.FuelType__c;c.Engine__c=vi.EngineDesc__c;c.Trans__c=vi.TransmissionDesc__c;c.ModelCode__c=vi.PQMSModelcode__c;c.MY__c=vi.ModelYear__c;c.Make__c=vi.Make__c;
    // }
    // }
    // else if(!hm.isEmpty() && vin.isEmpty()){
    // if(four){
    // system.debug('inside else if');
    // c.CaseID__c=c.VIN_Text_Field__c;
    // c.VIN_Text_Field__c='test';
    // }
    // else {
    // system.debug('inside else if');
    // c.VIN_Text_Field__c=c.VIN_Text_Field__c;
    // }
    // }
    // else if(!hm.isEmpty() && !vin.isEmpty() && one && two && three && five && six){
    // for(VIN__c vi: vin){
    // c.VehicleModel__c = vi.ModelDesc__c;c.VIN__c = vi.Id;c.VIN_Text_Field__c='';c.Drivetrain__c=vi.DrivetrainDesc__c;c.Fuel_Type__c=vi.FuelType__c;c.Engine__c=vi.EngineDesc__c;c.Trans__c=vi.TransmissionDesc__c;c.ModelCode__c=vi.PQMSModelcode__c;c.MY__c=vi.ModelYear__c;c.Make__c=vi.Make__c;
    // }
    // }
    // else if(!hm.isEmpty() && !vin.isEmpty() && one && two && three &&!five && !six){
    // c.CaseID__c=c.VIN_Text_Field__c;c.VIN_Text_Field__c='test';
    // }else if(!hm.isEmpty() && !vin.isEmpty() && two && three){/*c.CaseID__c=c.VIN_Text_Field__c;c.VIN_Text_Field__c='test';*/for(VIN__c vi: vin){c.VIN__c = vi.Id;c.VIN_Text_Field__c='';}}
    // else if(!hm.isEmpty() && !vin.isEmpty() && three){c.CaseID__c=c.VIN_Text_Field__c;c.VIN_Text_Field__c='test';}
    // else{
    // /*for(VIN__c vi: vin){
    // //c.VehicleModel__c = vi.ModelDesc__c;
    // c.VIN__c = vi.Id;
    // //c.VIN_Text_Field__c=c.VIN_Text_Field__c;
    // //c.Drivetrain__c=vi.DrivetrainDesc__c;
    // //c.Fuel_Type__c=vi.FuelType__c;
    // //c.Engine__c=vi.EngineDesc__c;
    // //c.Trans__c=vi.TransmissionDesc__c;
    // //c.ModelCode__c=c.ModelCode__c+';'+vi.PQMSModelcode__c;
    // //c.MY__c=c.MY__c+';'+vi.ModelYear__c;
    // //c.Make__c=c.Make__c+';'+vi.Make__c;
    // c.VIN_Text_Field__c=c.VIN_Text_Field__c;
    // }
    // */
    // c.CaseID__c=c.VIN_Text_Field__c;
    // c.VIN_Text_Field__c='test';
    // }
    // }
    
    
    // //String str = st[0];
    
          
    // //List<AggregateResult> hm = [SELECT  Make__c, Year__c,VehicleModel__c FROM HMAReferenceData__c WHERE Make__c IN (:c.Make__c) AND ModelCode__c IN (:c.ModelCode__c) AND Year__c IN : st and VehicleModel__c != NULL GROUP BY Make__c, Year__c,VehicleModel__c];
    // if(hm.isEmpty() && vin.isEmpty()){Trigger.new[0].addError('Case not created in Salesforce due to invalid model code or invalid year or invalid fuel type');
    // }
    // }
    // }
    // }
    //         if(TrackingId.size() > 0 && !TrackingId.isEmpty()){
    //         List<case> duplicateCase = [SELECT id,SIMS_GSI_Number__c FROM Case where SIMS_GSI_Number__c IN :TrackingId]; 
    //         if(duplicateCase.size()>0){
    //         for(Case ca: duplicateCase){
    //             if(duplicateCase.size()!=0 && ca.SIMS_GSI_Number__c!=null){ Trigger.new[0].addError('Case cannot be inserted because a case is already present with this Tracking ID:'+ca.SIMS_GSI_Number__c);
    //             }
    //         }
        
    // }
    // }
    
    
    }