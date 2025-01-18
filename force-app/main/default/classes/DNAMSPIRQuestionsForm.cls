/*
 * Solution Name: Creating PIR Record
 * Created Name : Sadwika
 * Created Date : 10/3/2024
 * Description  : To create a PIR Record with Responses entered and associate Related PIR Elements as well.This will be called from LWC.
*/
public class DNAMSPIRQuestionsForm {
    
    // Class to represent section data containing a section name and associated questions
    public class SectionData{
        @AuraEnabled public String SectionName;
        @AuraEnabled public List<QuestionData> QuesData;
    }
    
     // Class to represent individual question data
    public class QuestionData{
        
        @AuraEnabled public String QuestionText;
        @AuraEnabled public String QuestionId;
       // @AuraEnabled public String QuestionFieldName;
        @AuraEnabled public Boolean IsTextType;
        @AuraEnabled public Boolean IsDateType;
        @AuraEnabled public Boolean IsSelectType;
        @AuraEnabled public Boolean IsCheckBoxType;
         @AuraEnabled public Boolean IsTextAreaType;
        @AuraEnabled public Boolean IsReadOnly;
        @AuraEnabled public Boolean IsRequired;
        @AuraEnabled public List<OptionsData> QnOptions;
        //List<String> ResponseOptions;
        @AuraEnabled public String Response;        
    }
    
    // Class to represent options for Picklist type questions
   public class OptionsData {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
    }

    // Method to retrieve sections and their associated questions based on account ID and PIR types
    @AuraEnabled(cacheable=true)
    public static List<SectionData> getSections (String AccountId, List<String> PIRTypesList){
        System.debug('AccountId - '+AccountId);
        System.debug('PIRTypesList - '+PIRTypesList);
        String qry = 'select id, Section__c, Question__c, Type__c, PIR_Type__c, Is_Readonly__c, Sequence__c,Options__c,Is_Required__c from PIR_Questions__c' ;
        
       
        
        Account accountdetails;
        List<Account> account = [Select DealerCode__c,Name,New_Vehicle_Planning_Guide__c,Dealer_Principal_Full_Name__c From Account
                                  where Id =:AccountId];
        if(!account.isEmpty()){
            accountdetails = account[0];
        }
        
        Provision__c provisiondetails;
        List<Provision__c> provisions = [SELECT Provision_Description__c, Effective_From_Date__c, Effective_To_Date__c 
                                         FROM Provision__c 
                                         WHERE Dealer__c = :AccountId AND Provision_Type__c = '*****' 
                                         ORDER BY Effective_From_Date__c DESC LIMIT 1];
        if (!provisions.isEmpty()) {
            provisiondetails = provisions[0];
        }
        
        Address__c addressdetails;
        List<Address__c> addresses = [SELECT Address_Name__c 
                                      FROM Address__c 
                                      WHERE Address_Type__c = 'Headquarter Address' AND Dealer__c = :AccountId];
        if (!addresses.isEmpty()) {
            addressdetails = addresses[0];
        }
        System.debug('Account Details:'+ accountdetails);
        System.debug('Provision Details: ' + provisiondetails);
        System.debug('Address Details: ' + addressdetails);
        
        if(PIRTypesList.size()>0){            
            String pirTypes = '';
            for(String pirType: PIRTypesList){
                pirTypes = pirTypes + '\''+pirType+'\','; 
            }
            if(pirTypes.endsWith(',')){
                pirTypes = pirTypes.subString(0,pirTypes.length()-1);
            }
            pirTypes = '(' + pirTypes + ')';
            System.debug('pirTypes - '+pirTypes);
            qry = qry + '  where PIR_Type__c includes ';
            qry = qry + pirTypes;
        }
        qry += ' ORDER BY Sequence__c';
        System.debug('qry - '+qry);
        
        
        
        
        List<PIR_Questions__c> qns = (List<PIR_Questions__c>)Database.query(qry);
        System.debug('qns.size - '+qns.size());
        
        Map<String, List<PIR_Questions__c>> sectionsMap = new Map<String, List<PIR_Questions__c>>();
        
       
        Account accData = new Account();
      
        
        for(PIR_Questions__c qnData: qns){
            String secName = qnData.Section__c;
            if(sectionsMap.containsKey(secName)){
                sectionsMap.get(secName).add(qnData);
            }
            else{
                sectionsMap.put(secName, new List<PIR_Questions__c>{qnData});
            }
            
           
        }
        
        
        List<SectionData> secDataList = new List<SectionData>();
        
        for(String eachSection: sectionsMap.keySet()){
            system.debug('eachSection - '+eachSection);
            SectionData secData = new SectionData();
            secData.SectionName = eachSection;
            List<QuestionData> qnsDataList = new List<QuestionData>();
            for(PIR_Questions__c qn: sectionsMap.get(eachSection)){                
                QuestionData qnData = new QuestionData();
                //PIR_Questions__c qn = qns[i];
                qnData.QuestionText = qn.Question__c;
                qnData.Response = '';
                qnData.IsTextType = false;
                qnData.IsDateType = false;
                qnData.IsSelectType = false;
                qnData.IsCheckBoxType = false;
                qnData.IsTextAreaType = false;
                qnData.IsReadOnly = qn.Is_Readonly__c;
                qnData.IsRequired = qn.Is_Required__c;
              
                
                String questionText = qnData.QuestionText.trim();
                
                if (questionText.equalsIgnoreCase('Dealer Code')) {
                    System.debug('Dealer Code: ' + accountdetails.DealerCode__c);
                    qnData.Response = accountdetails.DealerCode__c; 
                }
                if (questionText.equalsIgnoreCase('Dealer Name')) {
                    System.debug('Dealer Name: ' + accountdetails.Name);
                    qnData.Response = accountdetails.Name; 
                }
                if (questionText.equalsIgnoreCase('NV Planning Guide')) {
                    System.debug('NV Planning Guide: ' + accountdetails.New_Vehicle_Planning_Guide__c);
                    qnData.Response = accountdetails.New_Vehicle_Planning_Guide__c; 
                }
                if (questionText.equalsIgnoreCase('Dealer Principal')) {
                    System.debug('Dealer Principal: ' + accountdetails.Dealer_Principal_Full_Name__c);
                    qnData.Response = accountdetails.Dealer_Principal_Full_Name__c; 
                }
                if (questionText.equalsIgnoreCase('current dssa term') && provisiondetails != null) {
                    System.debug('Current DSSA Term Found: ' + provisiondetails.Provision_Description__c);
                    qnData.Response = provisiondetails.Provision_Description__c; 
                }
                
                if(questionText.equalsIgnoreCase('Expiration date.') && provisiondetails !=null ){
                    System.debug('Expiration Date: '+String.valueOf(provisiondetails.Effective_To_Date__c));
                    qnData.Response = String.valueOf(provisiondetails.Effective_To_Date__c);
                }



                if(questionText.equalsIgnoreCase('Selling Entity (full legal name)') && addressdetails !=null){
                    System.debug('Selling Entity: '+ addressdetails.Address_Name__c);
                    qnData.Response = addressdetails.Address_Name__c;
                }
                
                
                qnData.QuestionId = qn.Id;
                //qnData.QuestionFieldName = qn.PIR_Field_Name__c;
                
                if(qn.Type__c == 'Text')
                    qnData.IsTextType = true;
                else if(qn.Type__c == 'Date')
                    qnData.IsDateType = true;
               
                else if (qn.Type__c == 'Text Area')
                    qnData.IsTextAreaType = true;
                else if(qn.Type__c == 'Picklist'){
                    System.debug(qn.Question__c+ ': Type - '+qn.Type__c);
                    qnData.IsSelectType = true;
                    String options = qn.Options__c;
                    List<String> optionsList = options.split(',');
                    List<OptionsData> optDataList = new List<OptionsData>();
                    
                    for(String option: optionsList){
                        System.debug('options -'+option);
                        option = option.trim();
                        OptionsData optData = new OptionsData();
                        optData.value = option;
                        optData.label = option;
                        optDataList.add(optData);
                    }
                    qnData.QnOptions = optDataList;
                }
                
                qnsDataList.add(qnData);
            }
            secData.QuesData = qnsDataList;
            secDataList.add(secData);
        }
        System.debug('secDataList - '+secDataList);
        return secDataList;
    }
    
      // Method to retrieve questions based on account ID and PIR types
    @AuraEnabled(cacheable=true)
    public static List<QuestionData> getQuestions (String AccountId, List<String> PIRTypesList){
        System.debug('AccountId - '+AccountId);
        System.debug('PIRTypesList - '+PIRTypesList);
        
        String qry = 'select id, Question__c, Type__c, PIR_Type__c, Is_Readonly__c,Sequence__c,Options__c,Is_Required__c from PIR_Questions__c' ;
        
        if(PIRTypesList.size()>0){            
            String pirTypes = '';
            for(String pirType: PIRTypesList){
                pirTypes = pirTypes + '\''+pirType+'\','; 
            }
            if(pirTypes.endsWith(',')){
                pirTypes = pirTypes.subString(0,pirTypes.length()-1);
            }
            pirTypes = '(' + pirTypes + ')';
            System.debug('pirTypes - '+pirTypes);
            qry = qry + '  where PIR_Type__c includes ';
            qry = qry + pirTypes;
        }
        
      
        qry += ' ORDER BY Sequence__c';
        System.debug('qry - '+qry);
        
        List<PIR_Questions__c> qns = (List<PIR_Questions__c>)Database.query(qry);
        System.debug('qns.size - '+qns.size());
        
        QuestionData qnData;
        List<QuestionData> qnsDataList = new List<QuestionData>();
        for(PIR_Questions__c qn: qns){
            qnData = new QuestionData();
            //PIR_Questions__c qn = qns[i];
            qnData.QuestionText = qn.Question__c;
            qnData.Response = '';
            qnData.IsTextType = false;
            qnData.IsDateType = false;
            qnData.IsSelectType = false;
            qnData.IsCheckBoxType = false;
            qnData.IsReadOnly = qn.Is_Readonly__c;
            qnData.IsRequired = qn.Is_Required__c;
            
            qnData.QuestionId = qn.Id;
            //qnData.QuestionFieldName = qn.PIR_Field_Name__c;
            System.debug('Type - '+qn.Type__c);
            if(qn.Type__c == 'Text')
                qnData.IsTextType = true;
            else if(qn.Type__c == 'Date')
                qnData.IsDateType = true;
           /* else if(qn.Type__c == 'Checkbox')
                qnData.IsCheckBoxType = true;*/
            else if(qn.Type__c == 'Picklist'){
                System.debug(qn.Question__c+ ': Type - '+qn.Type__c);
                qnData.IsSelectType = true;
                String options = qn.Options__c;
                List<String> optionsList = options.split(',');
                List<OptionsData> optDataList = new List<OptionsData>();
                
                for(String option: optionsList){
                    System.debug('options -'+option);
                    option = option.trim();
                    OptionsData optData = new OptionsData();
                    optData.value = option;
                    optData.label = option;
                    optDataList.add(optData);
                }
                qnData.QnOptions = optDataList;
            }
            qnsDataList.add(qnData);
        }

        System.debug('qnsDataList: '+qnsDataList);
        return qnsDataList;
        
        
    }
 //  ==================================
 


    public class PIRTypeData{
        
        @AuraEnabled public String AccountName;
       
        @AuraEnabled public List<PIROptionsData> PIRTypesList;
        
    }
    public class PIROptionsData{
        @AuraEnabled public String value;
        @AuraEnabled public String label;
    }
    
    @AuraEnabled(cacheable=true)
    public static PIRTypeData getPIRTypes(String AccountId){
        system.debug('AccountId - '+AccountId);
        Account Acc = [select Name, DealerCode__c, Dealer_Principal_Full_Name__c,New_Vehicle_Planning_Guide__c from Account where id =:AccountId limit 1];
         
        system.debug('Acct Name - '+ Acc.Name);
        System.debug('Dealer Code - ' + Acc.DealerCode__c);
        System.debug('Dealer Principal - ' + Acc.Dealer_Principal_Full_Name__c);
        System.debug('Planning Guide - '+Acc.New_Vehicle_Planning_Guide__c);
       
        List<PIR_Type__mdt> pirTypeList = [select Label, DeveloperName from PIR_Type__mdt];
        List<PIROptionsData> pirOptsDataList = new List<PIROptionsData>();
        
        PIROptionsData pirOptsData;
        for(PIR_Type__mdt pirType: pirTypeList){
            pirOptsData = new PIROptionsData();
            pirOptsData.value = pirType.Label;
            pirOptsData.label = pirType.Label;
            
            pirOptsDataList.add(pirOptsData);
        }
        
        PIRTypeData pirData = new PIRTypeData();
        pirData.AccountName = Acc.Name;
       
        
        pirData.PIRTypesList = pirOptsDataList;
        
        system.debug('pirData - '+pirData);
        return pirData;
        
    }

    //=======================================
   
    @AuraEnabled
    public static String saveResponses(String accID, String pirTypes, String responses) {
        
        System.debug('Received accID: ' + accID);
        System.debug('Received pirTypes: ' + pirTypes);
        System.debug('Received responses: ' + responses);
      
        try{
	
        Map<String, object> myMap = (Map<String, object>) JSON.deserializeUntyped(responses);
        system.debug('myMap - '+myMap);
       
          Map<String, String> questionSections = new Map<String, String>();
        List<PIR_Questions__c> questions = [SELECT Id, Section__c FROM PIR_Questions__c WHERE Id IN :myMap.keySet()];
        for (PIR_Questions__c question : questions) {
            questionSections.put(question.Id, question.Section__c);
        }

    	
        
        pirTypes = pirTypes.subString(1,pirTypes.length()-1);
        pirTypes = pirTypes.replaceAll('"','');
        pirTypes = pirTypes.replaceAll(',',';');
        System.debug('pirTypes - '+pirTypes);
        
        String qryPIRTypes = pirTypes;
        
        List<String> pirTypesLst = new List<String>();
        if(qryPIRTypes.contains(';'))
        {
            pirTypesLst = qryPIRTypes.split(';');
        }
        else{
            pirTypesLst.add(qryPIRTypes);
        }
        System.debug('PIT TYPES LIST '+pirTypesLst);
        qryPIRTypes = 'select Label, DeveloperName, Strategy_Approval__c, DND_Agreement_Approval__c from PIR_Type__mdt where Label in :pirTypesLst';
        System.debug('qryPIRTypes - '+qryPIRTypes);
        
        List<PIR_Type__mdt> pirTypesList = (List<PIR_Type__mdt>)Database.query(qryPIRTypes);
        System.debug('pirTypesList.size - '+pirTypesList.size());
        
        Boolean strategyApproval = false;
        Boolean DNDApproval = false;
        
        for(PIR_Type__mdt pirType: pirTypesList){
            if(pirType.Strategy_Approval__c == true){
                strategyApproval = true;
            }
            if(pirType.DND_Agreement_Approval__c == true){
                DNDApproval = true;
            }
        }
        
        System.debug('strategyApproval - '+strategyApproval);
        System.debug('DNDApproval - '+DNDApproval);
        
        Package_Initiation__c pirRecord = new Package_Initiation__c();
        pirRecord.Dealer_Name__c = accID;
        pirRecord.PIR_Type__c = pirTypes;
        pirRecord.Strategy_Approval__c = strategyApproval;
        pirRecord.DND_Agreement_Approval__c = DNDApproval;
        pirRecord.PIR_Status__c = 'Draft';
        pirRecord.Name = 'test';
        insert pirRecord;
        
        system.debug('Types - '+pirRecord.PIR_Type__c);
        String pirRecId = pirRecord.Id;
        
        List<PIR_Element__c> pirElementsToInsert = new List<PIR_Element__c>();
       
               
        Set<String> uniqueElementNames = new Set<String>();
        List<PIR_Element__c> elementConfigs = [SELECT Name, Instructions__c,Mapped_Package_Element__c FROM PIR_Element__c WHERE PIR__r.RecordType.DeveloperName  = 'PIR_Docs_and_Approval_Template' and PIR__r.PIR_Type__c IN :pirTypesLst];
		System.debug('elements for '  + ': ' + elementConfigs);
        
        for (PIR_Element__c config : elementConfigs) {
            if (!uniqueElementNames.contains(config.Name)) {
                PIR_Element__c newPIR = new PIR_Element__c();
                newPIR.PIR__c = pirRecord.Id;
                newPIR.Name = config.Name;
                newPIR.Instructions__c = config.Instructions__c;
                newPIR.Mapped_Package_Element__c = config.Mapped_Package_Element__c;

                System.debug('inserted elements -'+newPIR);
                System.debug('elements inserted size - '+pirElementsToInsert.size());
               	pirElementsToInsert.add(newPIR);
                uniqueElementNames.add(config.Name);
                System.debug('config name : '+config.Name);
              }
            else {
            System.debug('Duplicate element not added: ' + config.Name);
              }
        }
        
        
        // Insert PIR Element records
        if (!pirElementsToInsert.isEmpty()) {
            insert pirElementsToInsert;
        }
        
        
        List<PIRQnResponse__c> responsesToInsert = new List<PIRQnResponse__c>();  
        
        for(String quesId :myMap.keySet()){
            System.debug('quesId -'+quesId);
            String value = String.valueOf(myMap.get(quesId));
            System.debug('value -'+value);
            PIRQnResponse__c response = new PIRQnResponse__c();
            response.Package_Initiation_Request__c = pirRecId;
            response.PIR_Question__c = quesId;
            response.Response__c = value;
            response.Answered__c= (value == null || value == '' )?false:true ;
            if (questionSections.containsKey(quesId)) {
                response.Section__c = questionSections.get(quesId); 
            }
            responsesToInsert.add(response);
        }
        if (!responsesToInsert.isEmpty()) {
           insert responsesToInsert;
        }
        
        return pirRecord.Id;
        }
         catch (Exception e) {
            String errorMessage = 'Error occurred during PIR record creation. Details: ' + e.getMessage();
            
            
            String queueName = 'DNA_PIR_Error_Notifications'; 
            
           
            Group queue = [SELECT Id FROM Group WHERE DeveloperName  = :queueName AND Type = 'Regular' LIMIT 1];
            System.debug('Queue found: ' + queue);
            
            List<Id> loggedInUserList = new List<Id>{UserInfo.getUserId()};
             System.debug('Logged in User: '+loggedInUserList);
           
            List<User> queueMembers = [SELECT Email,Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queue.Id)];
            System.debug('queueMembers : '+queueMembers);
            
            List<String> emailAddresses = new List<String>();
          
            User loggedInUser = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            emailAddresses.add(loggedInUser.Email); 
			
            for (User user : queueMembers) {
                emailAddresses.add(user.Email); 
            }
             
                          string[] cc = new string[] {'sadwika.reddyshetty@egen.ai'};

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(emailAddresses);  
            system.debug('email id:'+emailAddresses);
                        mail.setCcAddresses(cc);

            mail.setSubject('Error in PIR Record Creation');
            mail.setPlainTextBody('Dear User ' + ',\n\nThere was an error in the PIR record creation: ' + errorMessage);
            
            System.debug('Sending email to: ' +emailAddresses);
            System.debug('Email subject: ' + mail.getSubject());
            System.debug('Email body: ' + mail.getPlainTextBody());
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('mail : '+mail);
            
            if (results != null && results.size() > 0) {
                for (Messaging.SendEmailResult result : results) {
                    if (result.isSuccess()) {
                        System.debug('Email sent successfully!');
                    } else {
                        System.debug('Email failed: ' + result.getErrors());
                    }
                }
            }
       
            return  errorMessage;
        
    }
    
      
        
    }

}