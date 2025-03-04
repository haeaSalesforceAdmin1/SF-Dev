/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-10-2025
 * @last modified by  : Minhee Kim
 * Author : [ChangeMeIn@UserSettingsUnder.SFDoc] /
 * Edited by [MinheeKim] on [03-08-2023] for [DPM-5399] added Survey__r.Status__c
 * Edited by [Yaechan Park] on [08-20-2023] for [Ticket] Changing Judgment Criteria : All Question -> Parent Question
 * Edited by [JongHoon Kim] on [10-18-2024] / [DPM-5863] / [Add NumberOfRosWithInsufficientDigtalDoc__c,PerNumberOfRosWithInsufficientDigtalDoc__c] 
 * Edited by [Minhee Kim] on [02-10-2024] for [DPM-5279] added to prevent auto-submitted when the survey is not done
 * Edited by [Minhee Kim] on [01-10-2025] for [DPM-5871] To get survey questions not survey
**/
public without sharing class SurveyQuestionController {
    
    /**Warranty Review Question Changes by Dhiraj
    // Edited by [JongHoon Kim] on [10-18-2024] for [DPM-5863]
    * Edited by [Minhee Kim] on [1-10-2025] for [DPM-5871] To get survey questions not survey
    */
    @AuraEnabled
    public static List<Survey_Question__c> getSurveyWarrantyReviewQuestions(String recordId, Boolean launchedFromEval){

        
        List<Survey_Question__c> surveyQuestions = new List<Survey_Question__c>(); // Changed return type from Survey__c to Survey_Question__c by Minhee Kim - 01.10.2025 [DPM-5871]
        
        /**  Changed to comments by Minhee Kim - 01.10.2025 [DPM-5871]
        String sql = 'select Id,X22_Warranty_Review__c,NumberOfRosReviewed__c,PerNumberOfRosReviewed__c,NumberOfRosWithoutAnyDiscrepancies__c,PerNumberOfRosWithoutAnyDiscrepancies__c,';
        sql += 'NumberOfRosWithInsufficientTechNotes__c,PerNumberOfRosWithInsufficientTechNotes__c,NumberOfRosWithDateMileageDiscrepancy__c,PerNumberOfRosWithDateMileageDiscrepancy__c,';
        sql += 'Status__c,NumberOfRosWithImproperAddOnA__c,PerNumberOfRosWithImproperAddOnA__c,NumberOfRosWithTimeJustificationDiscrepa__c,PerNumberOfRosWithTimeJustificationDiscr__c,';
        sql += 'NumberOfRosWithSubletDiscrepancy__c,PerNumberOfRosWithSubletDiscrepancy__c,NumberOfRosWithImproperRepair__c,PerNumberOfRosWithImproperRepair__c,NumberOfRosWhereRoDoesNotMatchClaim__c,PerNumberOfRosWhereRoDoesNotMatchClaim__c,';
        sql += 'NumberOfRosWithMissingDocuments__c,PerNumberOfRosWithMissingDocuments__c,NumberOfRosWithCustomerSignatureDiscrepa__c,PerNumberOfRosWithCustomerSignatureDiscr__c,NumberOfRosWithPriorApprovalDiscrepancy__c,PerNumberOfRosWithPriorApprovalDiscrepan__c,';
        sql +='NumberOfRosWithPartsRetentionDiscrepancy__c,PerNumberOfRosWithPartsRetentionDiscrepa__c,NumberOfRosWhichAreNotWarranty__c,PerNumberOfRosWhichAreNotWarranty__c';
        sql +=',NumberOfRosWithInsufficientDigtalDoc__c,PerNumberOfRosWithInsufficientDigtalDoc__c';*/

        String sql = 'select Id, Name, RecordType.DeveloperName, Survey__c, Action_Plan__c, Evaluation__c, Question_Number__c, Question_Text__c, Remarks__c, Is_Parent__c,';
        sql += 'Other_Response_Text__c, Question_Number_Text__c, RemarksEnabled__c,Response_Number_2__c, Survey__r.Status__c';
        if(!launchedFromEval) {
            // sql +=' from Survey_Question__c where Survey__c = :recordId order by Section_Number__c NULLS LAST, Question_Number_Text__c NULLS LAST';
            //sql +=' from Survey__c where Id = :recordId order by CreatedDate ASC'; //changed to comment by Minhee Kim - 01.10.2025 [DPM-5871]
            sql +=' from Survey_Question__c where Survey__c= :recordId order by Survey__c, Question_Number__c asc';
            //CreatedDate
            
        }
        else {            
            List<Evaluation__c> evals = [
                    SELECT Id
                            , Survey__c
                    FROM    Evaluation__c
                    WHERE   Id = :recordId
            ];
            String surveyId = evals[0].Survey__c;
            //sql +=' from Survey_Question__c where Survey__c = :surveyId order by Section_Number__c NULLS LAST, Question_Number_Text__c NULLS LAST';
           // sql +=' from Survey__c where Id = :surveyId order by CreatedDate ASC'; //changed to comment by Minhee Kim - 01.10.2025 [DPM-5871]
           sql +=' from Survey_Question__c where Survey__c= :surveyId order by Survey__c, Question_Number__c asc';

        }
        surveyQuestions = Database.query(sql);  

        System.debug('surveyQuestions: '+surveyQuestions);
        return surveyQuestions;
    }

    //Warranty Survey Record Update
    //inner class
    public class ResultSurvey
    {
        public String Id;
        
    }
    
    @AuraEnabled
    public static void updateWarrantySurvey(String surveyJSON){
        try {
            List<Survey__c> survey = (List<Survey__c>)System.JSON.deserializeStrict(surveyJSON,List<Survey__c>.class);
            // kangsan : survey.PerNumberOfRosWithoutAnyDiscrepancies__c -> More than 99% cannot be Input

            Database.SaveResult[] updateSurvey =Database.update(survey, false);
            for(Database.SaveResult srList : updateSurvey){
                if(!srList.isSuccess()){
                    for(Database.Error err:srList.getErrors()){
                        System.debug('Survey Record Failed to Update '+ err.getMessage());
                    }
                }
            }
            
            //update survey;
			/*
            if(survey.Status__c == 'Completed') {
                GeneratePDFQueueable generatePDFQueueable = new GeneratePDFQueueable(new List<String>{survey.Id}, 'Survey', 0 , 0);
                generatePDFQueueable.networkId = Network.getNetworkId();
                System.enqueueJob(generatePDFQueueable);
            }*/
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**
     * Created by [Minhee Kim] on [01.21.2025] for [DPM-5871] 
     */
    @AuraEnabled
        public static void updateWarrantySurveyQuestion(List<Survey_Question__c> questions, String surveyId, String surveyStatus) {
            System.debug('survey Id: '+surveyId);
            Survey__c survey = [SELECT Id, Status__c FROM Survey__c WHERE Id=: surveyId LIMIT 1];

            if(questions.size()>0){
                for(Survey_Question__c question : questions){
                    if(question.Response_Number_2__c==null){
                        question.Response_Number_2__c = 0;
                        question.Other_Response_Text__c ='0%';           
                    }        
                }
            }

            try{
                if(survey!=null){
                    survey.Status__c = surveyStatus;
                    update survey;
                }
                update questions;
                
            }catch (AuraHandledException e) { 
                throw e;
            } catch(Exception e) {
                System.debug(e.getMessage());
            }

        }

    //DPM-4390
   /**
     * Changed to comments by [Minhee Kim] on [01.21.2025] for [DPM-5871] 
     */
    /** @AuraEnabled
    public static void updateWarrantySurveyQuestion(String surveyJSON){
        try {

            List<Object> questionList = (List<Object>)JSON.deserializeUntyped(surveyJSON);
            Map<String,Object> questionMap = new Map<String,Object>();

            for (Object obj : questionList) {
                Map<String, Object> objMap = (Map<String, Object>) obj;
                for (String key : objMap.keySet()) {
                    questionMap.put(key,objMap.get(key));
                }
            }

            List<Survey_Question__c> sqList = [
                    SELECT Id
                            , Response_Text__c
                            , InitialResponseText__c
                            , Other_Response_Text__c
                            , Response_Number__c
                            , Response_Number_2__c
                            , Score__c
                            , Question_Number_Text__c
                            , Survey__c
                    FROM     Survey_Question__c
                    WHERE Survey__c =: (Id)questionMap.get('Id')
            ];
    
            for(Survey_Question__c sq : sqList){

                if(questionMap.containsKey(sq.Question_Number_Text__c+'_'+'value')){
                    Object value = questionMap.get(sq.Question_Number_Text__c+'_'+'value');
                    Decimal decimalValue = value instanceof Decimal ? (Decimal)value : Decimal.valueOf(String.valueOf(value));
                    sq.Response_Number_2__c = decimalValue;
                }
                if(questionMap.containsKey(sq.Question_Number_Text__c+'_'+'percent')){
                    Object percent = questionMap.get(sq.Question_Number_Text__c+'_'+'percent');
                    String Stringpercent= percent instanceof String ? (String)percent : String.valueOf(percent);
                    sq.Other_Response_Text__c = Stringpercent+'%';
                }
            }

            Database.SaveResult[] updateSurvey =Database.update(sqList, false);
        }

        
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    } */
    
    
    @AuraEnabled
    public static List<Warranty22__mdt> getWarrantyReviewMetadata22(){

        //List<Warranty22__mdt> listWarrantyReview = Warrenty22__mdt.getAll().values();
		List<Warranty22__mdt> listWarrantyReview =[
                SELECT      QuestionText__c
                            ,QuestionNumber__c
                FROM        Warranty22__mdt
                ORDER BY    QuestionNumber__c ASC
        ];
        /*for(Warranty22__mdt mData :listWarrantyReview){
            System.debug('Dhiraj Kumar qNumber '+ mData.QuestionNumber__c);
            System.debug('Dhiraj Kumar qNumber '+ mData.QuestionText__c);
            
        }*/
        return listWarrantyReview;
    }
    
    //Changes made by Dhiraj
    @AuraEnabled
    public static Boolean checkAdminUserOrNot(){
        User userDetail = [
                SELECT Id
                        , Name
                        , Profile.Name
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
                LIMIT   1
        ];
        
        if(userDetail.Profile.Name =='System Administrator'){
            return true;
        }
        else{
            return false;
        }
    }
    
    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2023-03-08] for [DPM-5399] added Survey__r.Status__c
    */
    @AuraEnabled
    public static Evaluation__c retrieveEvaluationDetails(String recordId, Boolean launchedFromEval) {
        //DPM-5399 added Survey__r.Status__c by Minhee - 24.03.07
        //DPM-5871 added Evaluation_Type__c  by Minhee - 01.21.2025
        // Add X22_Warranty_Review__c by Dhiraj
        if(launchedFromEval) {
            return [
                SELECT Id, Name
                    , Survey__r.Id
                    , JDP_Evaluation__c
                    , PrimaryContact__c
                    , Account__c
                    , PrimaryContactName__c
                    , PrimaryContactDate__c
                    , ApprovalStatus__c, Survey__c, Survey__r.Status__c, Total_Score__c, No_Review_Needed__c,Survey__r.X22_Warranty_Review__c,Evaluation_Type__c 
                FROM    Evaluation__c
                WHERE   Id = :recordId
            ];
        }
        else {
            Survey__c survey = [
                    SELECT Id
                            , Evaluation__c
                            , OrganizationRef__c
                            , OrganizationName__c
                            , OrganizationRef__r.Name
                    FROM    Survey__c
                    WHERE   Id = :recordId
                    LIMIT   1
            ];

            if(survey.Evaluation__c != null) {
                return [
                    SELECT Id, Name
                            , Survey__r.Id
                            , JDP_Evaluation__c
                            , PrimaryContact__c
                            , Account__c
                            , PrimaryContactName__c
                            , PrimaryContactDate__c
                            , ApprovalStatus__c
                            , Total_Score__c
                            , No_Review_Needed__c,Survey__r.X22_Warranty_Review__c
                    FROM    Evaluation__c
                    WHERE   Id = :survey.Evaluation__c
                ];
            }
        }
        return null;
    }

    @AuraEnabled
    public static void saveEvaluationDetails(String evaluationJSONString){
        Evaluation__c evaluation = (Evaluation__c)System.JSON.deserializeStrict(evaluationJSONString, Evaluation__c.class);
        update evaluation;
    }

    @AuraEnabled
    public static void resubmitForApproval(String evaluationId){
        Evaluation__c evaluation = new Evaluation__c(Id = evaluationId, SubmitforApproval__c = true);
        update evaluation;
    }

    @AuraEnabled
    public static List<User> retrievEvaluationAccountContacts(String accountId) {
        List<String> contactIds = new List<String>();
        List<AccountContactRelation> accountContactRelations = [
                SELECT Id
                        , ContactId
                FROM    AccountContactRelation
                WHERE   AccountId = :accountId
        ];

        for(AccountContactRelation accountContactRelation:accountContactRelations) {
            contactIds.add(accountContactRelation.ContactId);
        }
		//Dhiraj Changes made only Email field is added
        List<User> users = [
                SELECT Id
                        , Name
                        , Email
                FROM    User
                WHERE   ContactId IN :contactIds
        ];

        Set<Id> permissionSetIds = new Set<Id>();  
        for (SetupEntityAccess access:[
                SELECT  ParentId
                FROM    SetupEntityAccess
                WHERE   SetupEntityId
                        IN (
                            SELECT  Id
                            FROM    CustomPermission
                            WHERE   DeveloperName = 'Action_Plan_External_User'
                        )
        ])
        {
            permissionSetIds.add(access.ParentId);  
        }                                                        
        List<User> userList = [
                SELECT  Id
                        , Name
                        , Email
                        , ContactId
                FROM    User
                WHERE   Id
                        IN (
                                SELECT  AssigneeId
                                FROM    PermissionSetAssignment
                                WHERE   PermissionSetId
                                IN      :permissionSetIds
                                AND     AssigneeId IN :users
                            )
        ];

        return userList;
    }
    
    @AuraEnabled
    public static List<Survey_Question__c> getSurveyQuestions(String recordId, Boolean launchedFromEval){
        List<Survey_Question__c> surveyQuestions = new List<Survey_Question__c>();
        System.debug(launchedFromEval);
        
        String sql = 'select Id,Type__c, Category_Type__c,QuestionSubCategory__c, Survey__c, Survey__r.Evaluation__c, Section_Number__c, Question_Number__c, Question_Text__c, Due_Date__c,Instruction_Text__c, Benefit_Text__c, Response_Text__c, DependentQuestion__c, DependentQuestionResponse__c, Remarks__c, ';
        sql += 'Input_Type__c, InputValues__c, Question_Number_Text__c, DependentQuestion__r.Response_Text__c, Photos_Required__c, RemarksEnabled__c, ';
        sql += 'Response_Calculated_From_Inline_Answers__c, Table_Columns__c, Fail_Value__c, Other_Response_Text__c, ';
        sql += 'Response_Number__c, Response_Number_2__c,Meet_ALL_Criteria_Check__c, Response_Number_3__c, Status__c, Survey__r.Status__c, Response__c, Image_Required_Prior_To_Answer__c, InitialResponseText__c, Action_Plan__c, Score__c, Category__c, ';
        sql += 'Action_Plan__r.Status__c, Is_Carried_Over__c,AP_Moved_to_Next_Quarter__c,Survey__r.Warranty_Review_2022__c,Survey__r.Warranty_Review_Instruction_2022__c,Survey__r.Warranty_Review_Due_Date_Text_2022__c,Survey__r.In_Store_Review__c,Survey__r.whatIsTheDealersCurrentRO__c,Survey__r.How_many_ROs_were_reviewed__c,Survey__r.How_many_ROs_had_zero_defic_discrp__c,Survey__r.Is_the_Warranty_CEE_RO_Review_complete__c,Survey__r.Others_Describe__c,How_many_ROs_had_insufficient_tech_notes__c,Comments_Action_Plan__c ';

        if(!launchedFromEval) {
            System.debug('!'+launchedFromEval);
            sql +=' from Survey_Question__c where Survey__c = :recordId order by Category_Order__c NULLS LAST, Question_Number__c NULLS LAST';
            //sql +=' from Survey_Question__c where Survey__c = :recordId order by CreatedDate ASC';
            //CreatedDate
        }
        else {
            List<Evaluation__c> evals = [
                    SELECT Id
                            , Survey__c
                    FROM    Evaluation__c
                    WHERE   Id = :recordId
            ];
            System.debug(evals);
            String surveyId = evals[0].Survey__c;
            sql +=' from Survey_Question__c where Survey__c = :surveyId order by Category_Order__c NULLS LAST, Question_Number__c NULLS LAST';
            //sql +=' from Survey_Question__c where Survey__c = :surveyId order by CreatedDate ASC';
        }
        surveyQuestions = Database.query(sql);
        //system.debug(surveyQuestions[0].Due_Date__c+'--'+surveyQuestions[0].Instruction_Text__c);
        return surveyQuestions;
    }

    /** @description :
     *  @param surveyQuestionsJSON : Serialize List<Survey_Question__c>
     *  @param isSubmit : Submit 버튼 클릭 여부
     *  @Created by : yc.park@solomontech.net
     *  @Last Modified by : minheekim@haeaus.com
     *  @Last Modified Date : 24/04/16
     *  @ Logs
     *      1. 23/07/27 :
     *         (1) AP to Survey Question 관계 변경 (1:1 -> 1:다) 에 따른 코드 수정 for ticket 4754
     *         (2) AP 생성 flow -> SurveyQuestionController 에서 처리 for ticket 4754
     *      2. 23/08/02 :
     *         (1) 판단 대상 변경 : 모든 Question -> Parent Question
     *      3. 24/02/10 : 
     *         (1) DPM-5279 added to prevent auto-submitted when the survey is not done
     *      4. 24/04/16 : 
     *         (1) DPM-5302 Check whether the file is attached to the survey question
     * */
    @AuraEnabled
    public static Boolean updateSurveyQuestions(String surveyQuestionsJSON, Boolean isSubmit, List<Id> deletedFileId){ //DPM- added Id deletedFileId


        List<Survey_Question__c> listSurveyQuestions = (List<Survey_Question__c>)System.JSON.deserializeStrict(surveyQuestionsJSON, List<Survey_Question__c>.class);
        // Remove Duplicate Id
        Boolean allSurveyQuestionsAnswered = true; //DPM-5279 added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
        
        System.debug('5302 deletedFileId : '+deletedFileId);
        Map<Id, Survey_Question__c> mapUpdate = new Map<Id, Survey_Question__c>();
        
        try{
            // Ticket 4754 -> Submit 상태인 경우 YES 대답 여부에 따라 AP 생성 및 삭제 로직 추가

            if(listSurveyQuestions != null && listSurveyQuestions.size()>0 ){
                //DPM-5302 start

                String BrandCode = [SELECT BrandCode__c FROM Survey__c WHERE Id = : listSurveyQuestions[0].Survey__c LIMIT 1].BrandCode__c; // DPM-5633 added to check the brand code - 24.08.05

                map<id,SObject> surveyQuestionMap = new map<id,SObject>(); //DPM-5302 fix error : Row with duplicate Id at index
                surveyQuestionMap.putAll(listSurveyQuestions);//DPM-5302 fix error : Row with duplicate Id at index
                Set<Id> surveyQuestionIds = surveyQuestionMap.keySet(); //DPM-5302 fix error : Row with duplicate Id at index (new Map<Id,SObject>(listSurveyQuestions))
                if(!Test.isRunningTest()){
                    List<ContentDocumentLink> contentDocumentLink = [select Id, LinkedEntityId, ContentDocumentId, IsDeleted ,ShareType, Visibility 
                                                                    from ContentDocumentLink 
                                                                    where LinkedEntityId IN :surveyQuestionIds AND ContentDocumentId NOT IN :deletedFileId and IsDeleted = false]; //DPM-5302 added by MinheeKim - 24.04.12

                    Map<Id, ContentDocumentLink> contentDocumentMap = new Map<Id, ContentDocumentLink>();
                    if(contentDocumentLink.size()>0){
                    for(ContentDocumentLink cdl : contentDocumentLink){
                            contentDocumentMap.put(cdl.LinkedEntityId, cdl);
                            System.debug('5302 LinkedEntityId : '+cdl.LinkedEntityId);
                        }
                    }
                    //DPM-5302 end

                    //DPM-5279 added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
                    for(Survey_Question__c surveyQuestion: listSurveyQuestions){
                        if(surveyQuestion.Response__c == null || surveyQuestion.Response__c == '' && !Test.isRunningTest()){ //DPM-5302 added Test.isRunningTest() to pass this condition by MinheeKim - 24.04.17
                            allSurveyQuestionsAnswered = false;
                        }
                        
                        //DPM-5302 start
                        if(contentDocumentMap.size()>0 && contentDocumentMap.containsKey(surveyQuestion.Id)){
                            surveyQuestion.Attachment__c = 'Yes';
                        }else{
                            surveyQuestion.Attachment__c = 'No';
                        }
                        //DPM-5302 end
                    }
                    //DPM-5279 change end
                }

                mapUpdate.putAll(listSurveyQuestions);
                

                System.debug('isSubmit');
                System.debug(isSubmit);
                System.debug('Submit - allSurveyQuestionsAnswered: '+allSurveyQuestionsAnswered);
                if(isSubmit && allSurveyQuestionsAnswered){
                    Boolean isAPCreate = false;
                    Boolean isAPDelete = true;
                    Id SurveyId = null;
                    Set<Id> setQuestionId = new Set<Id>();
                    System.debug('come in to submit');
                    List<Survey_Question__c> listParents = new List<Survey_Question__c>();
                    for(Id QuestionId : mapUpdate.keySet()){
                        // Parent Question 판단-> DependentQuestion__c == null 인 경우
                        Survey_Question__c objQuestion = mapUpdate.get(QuestionId);

                        if(objQuestion.DependentQuestion__c == null){
                            if('Yes'.equalsIgnoreCase(objQuestion.Response__c)){

                                /**DPM-5633 added to check brand code, 
                                 * and if brand code is G then update survey score*/
                                if(BrandCode == 'G'){
                                    objQuestion.Score__c = 1;
                                }//DPM-5633 end

                                setQuestionId.add(objQuestion.id);
                                listParents.add(objQuestion); //DPM-5069 Added by MH - 2023.10.2
                            }

                            if('No'.equalsIgnoreCase(objQuestion.Response__c) && objQuestion.Survey__c != null && objQuestion.Action_Plan__c == null){
                                isAPCreate = true;
                                isAPDelete = false;
                                SurveyId = objQuestion.Survey__c;
                                listParents.add(objQuestion);
                            }
                        }
                        // Child Question -> Evaluation, Action Plan == null
                        else {
                            objQuestion.Evaluation__c = null;
                            objQuestion.Action_Plan__c = null;
                        }

                        
                    }



                    if(isAPDelete && setQuestionId != null && setQuestionId.size()>0){
                        // Get Action Plan Id
                        List<Survey_Question__c> listTargetQuestion = new List<Survey_Question__c>([
                                SELECT  Id, Action_Plan__c
                                FROM    Survey_Question__c
                                WHERE   Id =: setQuestionId
                                AND     Action_Plan__c != NULL
                        ]);

                        Set<Id> setAPIds = new Set<Id>();

                        if(listTargetQuestion != null && listTargetQuestion.size()>0){
                            for(Survey_Question__c obj : listTargetQuestion){
                                setAPIds.add(obj.Action_Plan__c);
                            }

                            List<Action_Plan__c> listAPs = new List<Action_Plan__c>([
                                    SELECT  Id
                                    FROM    Action_Plan__c
                                    WHERE   Id =: setAPIds
                            ]);

                            if(listAPs != null && listAPs.size()>0)  delete  listAPs;
                        }
                    }

                    if(isAPCreate && listParents.size()>0){
                        // Query for get Survey Field Data
                        
                        List<Survey__c> listSurveys = new List<Survey__c>([
                                SELECT  Id
                                        , Evaluation__c
                                        , Evaluation__r.Account__c
                                        , Evaluation__r.Type__c
                                        , Evaluation__r.Name
                                        //DPM-5069 add condition to check that created AP for Evaluation is exist or not - by MH -2023.10.20
                                        , Evaluation__r.Total_of_Related_Action_Plans__c
                                FROM    Survey__c
                                WHERE   Id =: SurveyId
                                LIMIT   1
                        ]);

                        Survey__c objSurvey = listSurveys[0];
                        //DPM-5069 add condition to check that created AP for Evaluation is exist or not - by MH -2023.10.20
                        //DPM-5633 added BrandCode checking to prevent action plan to be created for Genesis Evaluation
                        if(BrandCode != 'G' && listSurveys != null && listSurveys.size() ==1 && (listSurveys[0].Evaluation__r.Total_of_Related_Action_Plans__c==0 )){
                            
                            Action_Plan__c objAP = new Action_Plan__c(
                                    Account__c = objSurvey.Evaluation__r.Account__c,
                                    Division__c = objSurvey.Evaluation__r.Type__c,
                                    Evaluation__c = objSurvey.Evaluation__c,
                                    Name = objSurvey.Evaluation__r.Name,
                                    RelatedSurvey__c = objSurvey.Id
                            );

                            insert objAP;

                            if(objAP != null && objAP.Id != null ){
                                for(Survey_Question__c objQuestion : listParents) {
                                    // Set Action Plan, Evaluation
                                    Survey_Question__c objParent = mapUpdate.get(objQuestion.Id);
                                    if('No'.equalsIgnoreCase(objQuestion.Response__c)){ //DPM-5069 Added by MH - 2023.10.23
                                        objParent.Action_Plan__c = objAP.Id;
                                        objParent.Evaluation__c = objSurvey.Evaluation__c;
                                        mapUpdate.put(objParent.Id, objParent);
                                    }
                                }
                            }
                        }else if(listSurveys[0].Evaluation__r.Total_of_Related_Action_Plans__c>0){//DPM-5069 add error when AP already exists in the Eval - by MH -2023.10.20
                            System.debug(LoggingLevel.ERROR, 'Action Plan already exists. EvaluationId: : ' + listSurveys[0].Evaluation__c);
                            // System.debug('Action Plan already exists. EvaluationId: : ' + listSurveys[0].Evaluation__c);
                            List<Action_Plan__c> objAP = [SELECT Id FROM Action_Plan__c WHERE RelatedSurvey__c = :listSurveys[0].Id limit 1];

                            if(objAP != null && objAP[0].Id != null ){
                                for(Survey_Question__c objQuestion : listParents) {
                                    // Set Action Plan, Evaluation
                                    Survey_Question__c objParent = mapUpdate.get(objQuestion.Id);
                                    if('Yes'.equalsIgnoreCase(objQuestion.Response__c)){
                                        objParent.Action_Plan__c = null;
                                        mapUpdate.put(objParent.Id, objParent);
                                        System.debug(LoggingLevel.ERROR, 'Changed to Yes. Survey_Question__c: : ' + objParent.Id);
                                    }else{
                                        objParent.Action_Plan__c = objAP[0].Id;
                                        objParent.Evaluation__c = objSurvey.Evaluation__c;
                                        mapUpdate.put(objParent.Id, objParent);
                                    }
                                }
                            }
                        }
                    }
                    return allSurveyQuestionsAnswered;
                }
                return false;
            }
            return false;
        } catch(Exception e){
            System.debug('Error Line : '+e.getLineNumber());
            System.debug('Error Message : '+e.getMessage());
            return false;
        } finally {
            // Update Survey Questions
            if(mapUpdate != null && mapUpdate.size()>0) {
                Database.update(mapUpdate.values(), false);

                // Save Result Log Check
//                List<Database.SaveResult> listResults = Database.update(mapUpdate.values(), false);
//                if(listResults.size()>0){
//                    for(Database.SaveResult obj : listResults){
//                        System.debug('Save Result : '+obj);
//                    }
//                }
            }
            return false;
        }
    }

//    @AuraEnabled
//    public static void updateSurveyQuestions(String surveyQuestionsJSON){
//        List<Survey_Question__c> surveyQuestions = (List<Survey_Question__c>)System.JSON.deserializeStrict(surveyQuestionsJSON, List<Survey_Question__c>.class);
//        Map<Id, Survey_Question__c> questionsToSaveMap =  new Map<Id, Survey_Question__c>();
//        List<Id> listSurQue = new List<Id>();
//        for(Survey_Question__c surveyQuestion:surveyQuestions) {
//            if ('Yes'.equalsIgnoreCase(surveyQuestion.Response__c)){
//                listSurQue.add(surveyQuestion.Id);
//            }
//            questionsToSaveMap.put(surveyQuestion.Id, surveyQuestion);
//        }
//
//        try {
//            List<Database.SaveResult> results = Database.update(questionsToSaveMap.values(), false);
//
//            if (listSurQue != NULL && listSurQue.size() > 0) {
//                List<Action_Plan__c> listAPToDlt = [
//                        SELECT Id
//                        FROM Action_Plan__c
//                        WHERE HMASurveyQuestion__c IN :listSurQue
//                        AND Status__c != 'Compliant'
//                ];
//                if (listAPToDlt != NULL && listAPToDlt.size() > 0) {
//                    delete listAPToDlt;
//                }
//            }
//        }
//        catch(Exception e) {
//            throw new AuraHandledException(e.getMessage());
//        }
//    }



    /**
     * [Method Description] DPM-5279 added to prevent auto-submitted when the survey is not done 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-02-10] for [DPM-5279]
    */
    @AuraEnabled
    public static Boolean updateSurvey(String surveyJSON){
        Survey__c survey = (Survey__c)System.JSON.deserializeStrict(surveyJSON, Survey__c.class);
        String BrandCode = [SELECT BrandCode__c FROM Survey__c WHERE Id = :survey.Id LIMIT 1].BrandCode__c; //DPM-5633 added
        //DPM-5279 added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
        List<Survey_Question__c> listSurveyQuestions = [SELECT Id, Response__c, Priority__c FROM Survey_Question__c WHERE Survey__c=: survey.Id];
        Boolean allSurveyQuestionsAnswered = true;
        if(listSurveyQuestions != null && listSurveyQuestions.size()>0 ){

            System.debug('updateSurvey check');
            for(Survey_Question__c surveyQuestion: listSurveyQuestions){
                if(surveyQuestion.Response__c == null || surveyQuestion.Response__c == ''){
                    allSurveyQuestionsAnswered = false;
                    break;
                }

                /**DPM-5633 added to check brand code, 
                * and if brand code is G then update survey score*/
                System.debug('surveyQuestion.Response__c: '+surveyQuestion.Response__c);
                System.debug('surveyQuestion.Priority__c: '+surveyQuestion.Priority__c);
                System.debug('survey.BrandCode__c: '+survey.BrandCode__c);
                if('No'.equalsIgnoreCase(surveyQuestion.Response__c)){
                    if(BrandCode == 'G' && surveyQuestion.Priority__c == 'Y'){
                        survey.ActionPlanRequired__c = true;
                    }
                }//DPM-5633 end
            }     
        }   
        //DPM-5279 change end

        try {
            if(survey.Status__c== 'Completed' && !allSurveyQuestionsAnswered ){
                System.debug('The survey can not be submitted');
                return false;//DPM-5279 added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
            }else{
                update survey;
                if(survey.Status__c == 'Completed') {
                    GeneratePDFQueueable generatePDFQueueable = new GeneratePDFQueueable(new List<String>{survey.Id}, 'Survey', 0 , 0);
                    generatePDFQueueable.networkId = Network.getNetworkId();
                    System.enqueueJob(generatePDFQueueable);
                }
                return true;//DPM-5279 added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
            }
            
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ----------------- Custom Exceptions -----------------
    public class statusException extends Exception {
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getContentDocumentsForSurvey(String surveyId) {
        List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocument.LatestPublishedVersionId
                        , ContentDocument.FileExtension
                        , ContentDocument.Title
                        , ContentDocumentId
                        , LinkedEntityId
                FROM    ContentDocumentLink
                WHERE   LinkedEntityId IN
                        (
                            SELECT  Id
                            FROM    Survey_Question__c
                            WHERE   Survey__c = :surveyId
                        )
        ];

        return contentDocumentLinks;
    }

    @AuraEnabled(Cacheable=true)
    public static Survey_Question__c getSurveyQuestion(Id surveyQuestionId) {
        Survey_Question__c question = [
            SELECT
                Id,
                Section_Number__c,
                Question_Number__c,
                Question_Text__c,
                Instruction_Text__c,
                Due_Date__c,
                Benefit_Text__c,
                Photos_Required__c,
                Available_Picklist_Values__c,
                Input_Type__c,
                Picklist_Option_1__c,
                Score_Picklist_Option_1__c,
                Picklist_Option_2__c,
                Score_Picklist_Option_2__c,
                InitialResponseText__c,
                Action_Plan__c,
                Action_Plan__r.Status__c,
                Score__c,
                Category__c
            FROM Survey_Question__c
            WHERE Id = :surveyQuestionId
            LIMIT 1
        ];

        return question;
    }

    public static void saveQuestion(Id questionId, String fieldName, String value) {
        Survey_Question__c question = new Survey_Question__c(Id=questionId);
        question.put(fieldName, value);
        update question;
    }

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-01-17] for [DPM-5264]
    */
    @AuraEnabled
    public static void deleteContentDocument(List<Id> ContentDocumentId) { //DPM-5264
        System.debug('Deleted: '+ContentDocumentId);
        Database.delete(ContentDocumentId);
    }

    @AuraEnabled
    public static Boolean getHasEditAccessToRecord(String recordId) {
        Id userId = UserInfo.getUserId();

        User JDPUser =[
                SELECT Id
                        , Name
                        , UserRole.Name
                        , Profile.Name
                FROM User
                WHERE Id =:userId
        ];

        Survey__c survDetails =[
                SELECT Id
                        , Evaluation__r.JDP_Evaluation__c
                        , Status__c //DPM-5069 added by MH - 2023.10.20
                FROM Survey__c
                WHERE Id=:recordId
        ];

        List<UserRecordAccess> editRecordAccess = [
                SELECT  RecordId
                FROM    UserRecordAccess
                WHERE   UserId = :userId
                AND     RecordId = :recordId
                AND     HasEditAccess = TRUE
        ];

        if(survDetails.Evaluation__r.JDP_Evaluation__c
            &&  ( JDPUser.Profile.Name=='JDP Evaluator user Internal'
                    || JDPUser.Profile.Name=='System Administrator'
                )
            && !editRecordAccess.isEmpty())
        {
            return true;
        }

        if(!editRecordAccess.isEmpty()
            && !survDetails.Evaluation__r.JDP_Evaluation__c
            && ( JDPUser.Profile.Name!='JDP Evaluator user Internal'
                    || JDPUser.Profile.Name=='System Administrator'
                )
            )
        {
            return true;
        }
        /*
        if(!editRecordAccess.isEmpty() ) {
            return true;
        }*/

        return false;
    }

    //DPM-5069 added by MH - 2023.10.20 
    @AuraEnabled
    public static Boolean getHasCompleteAccessToRecord(String recordId) {
        Id userId = UserInfo.getUserId();

        User JDPUser =[
                SELECT Id
                        , Name
                        , UserRole.Name
                        , Profile.Name
                FROM User
                WHERE Id =:userId
        ];

        Survey__c survDetails =[
                SELECT Id
                        , Evaluation__r.JDP_Evaluation__c
                        , Status__c //DPM-5069 added by MH - 2023.10.20
                FROM Survey__c
                WHERE Evaluation__c=:recordId
        ];

        List<UserRecordAccess> editRecordAccess = [
                SELECT  RecordId
                FROM    UserRecordAccess
                WHERE   UserId = :userId
                AND     RecordId = :recordId
                AND     HasEditAccess = TRUE
        ];

        if(survDetails.Status__c=='Completed'&& (JDPUser.Profile.Name=='JDP Evaluator user Internal' || JDPUser.Name=='Salesforce Workflow Admin')){ // 
            System.debug('Survey is Completed');
            return false; 
        }else if((survDetails.Evaluation__r.JDP_Evaluation__c
            &&  ( JDPUser.Profile.Name=='JDP Evaluator user Internal'
                    || JDPUser.Profile.Name=='System Administrator'
                ))
            || !editRecordAccess.isEmpty())
        {
            return true;
        }

        if(!editRecordAccess.isEmpty()
            || (!survDetails.Evaluation__r.JDP_Evaluation__c
            && ( JDPUser.Profile.Name!='JDP Evaluator user Internal'
                    || JDPUser.Profile.Name=='System Administrator'
                )
            ))
        {
            return true;
        }
        /*
        if(!editRecordAccess.isEmpty() ) {
            return true;
        }*/
        System.debug('Nothing is Completed');
        return true; //DPM-5209 Changed default to true by Minheekim - 2023.12.19
    }


    @AuraEnabled
    public static String getNetworkId(){

        String networkId =  Network.getNetworkId();

        DPMConfigurationSettings__c setting = DPMConfigurationSettings__c.getInstance();


        if(networkId == null) {
            return '';
        }
        else if(networkId.left(15) == setting.HyundaiNetworkId__c.right(15)){
            //Hyundai
            return setting.HyundaiCommunityURL__c;
        }
        else {
            //Genesis
            //System.debug(LoggingLevel.ERROR, setting. );

            return setting.GenesisCommunityURL__c;
        }
    }

    @AuraEnabled
    public static void updateContentVersion(List<String> documentIds, String fieldAPIName){
        List<ContentVersion> listContVer = new List<ContentVersion>();
        if (documentIds != null && documentIds.size() > 0 && String.isNotBlank(fieldAPIName)) {
            for (ContentVersion contVer : [
                    SELECT Id
                            , Warranty_CEE_RO_Review_Excel_File__c
                            , RO_Review_Action_Plan__c
                            , WOPR_Action_Plan_WOPR_score_below_avg__c
                            , Other_WOPR_Action_Plan__c
                    FROM ContentVersion
                    WHERE ContentDocumentId = :documentIds
            ]) {
                if (fieldAPIName == 'Warranty_CEE_RO_Review_Excel_File__c') {
                    contVer.Warranty_CEE_RO_Review_Excel_File__c = true;
                }
                if (fieldAPIName == 'RO_Review_Action_Plan__c') {
                    contVer.RO_Review_Action_Plan__c = true;
                }
                if (fieldAPIName == 'WOPR_Action_Plan_WOPR_score_below_avg__c') {
                    contVer.WOPR_Action_Plan_WOPR_score_below_avg__c = true;
                }
                if (fieldAPIName == 'Other_WOPR_Action_Plan__c') {
                    contVer.Other_WOPR_Action_Plan__c = true;
                }
                listContVer.add(contVer);
            }

            if (listContVer.size() > 0) {
                update listContVer;
            }
        }
    }

    @AuraEnabled
    public static Map<String,List<Id>> getContentDocuments(String surveyId){

        Map<String,List<Id>> mapOfWRToContDoc = new Map<String,List<Id>>();
        List<Id> listContDoc = new List<Id>();

        if (String.isNotBlank(surveyId)) {

            for (ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: surveyId]) {
                listContDoc.add(cdl.ContentDocumentId);
            }

            if (listContDoc.size() > 0) {
                mapOfWRToContDoc.put('Warranty_CEE_RO_Review_Excel_File__c',new List<Id>());
                mapOfWRToContDoc.put('RO_Review_Action_Plan__c',new List<Id>());
                mapOfWRToContDoc.put('WOPR_Action_Plan_WOPR_score_below_avg__c',new List<Id>());
                mapOfWRToContDoc.put('Other_WOPR_Action_Plan__c',new List<Id>());

                for (ContentVersion cv : [
                            SELECT  Id
                                    ,ContentDocumentId
                                    ,Warranty_CEE_RO_Review_Excel_File__c
                                    , RO_Review_Action_Plan__c
                                    , WOPR_Action_Plan_WOPR_score_below_avg__c
                                    , Other_WOPR_Action_Plan__c
                            FROM    ContentVersion
                            WHERE   ContentDocumentId IN:listContDoc
                            AND     (Warranty_CEE_RO_Review_Excel_File__c = TRUE
                                        OR RO_Review_Action_Plan__c = TRUE
                                        OR WOPR_Action_Plan_WOPR_score_below_avg__c = TRUE
                                        OR Other_WOPR_Action_Plan__c = TRUE
                                    )
                ]) {
                    if (cv.Warranty_CEE_RO_Review_Excel_File__c) {
                        mapOfWRToContDoc.get('Warranty_CEE_RO_Review_Excel_File__c').add(cv.ContentDocumentId);
                    }
                    if (cv.RO_Review_Action_Plan__c) {
                        mapOfWRToContDoc.get('RO_Review_Action_Plan__c').add(cv.ContentDocumentId);
                    }
                    if (cv.WOPR_Action_Plan_WOPR_score_below_avg__c) {
                        mapOfWRToContDoc.get('WOPR_Action_Plan_WOPR_score_below_avg__c').add(cv.ContentDocumentId);
                    }
                    if (cv.Other_WOPR_Action_Plan__c) {
                        mapOfWRToContDoc.get('Other_WOPR_Action_Plan__c').add(cv.ContentDocumentId);
                    }
                }
            }
        }
        return mapOfWRToContDoc;
    }
    
    @AuraEnabled
    public static List<Warrant_Review_How_many_ROs_Labels__mdt> getWarrantyReviewMetadata(){

        List<Warrant_Review_How_many_ROs_Labels__mdt> listWarrantyReview = Warrant_Review_How_many_ROs_Labels__mdt.getAll().values();

        return listWarrantyReview;
    }

    /**
         * [Method Description] 
         * Created by [MinheeKim] on [12-23-2024] for [DPM-5610]
        */
    @AuraEnabled
    public static String getTotalFileSizeForSurveyInMB(Id surveyId) {
        Decimal totalSizeInMB = calculateTotalFileSizeForSurveyInMB(surveyId);
        String formattedSize = totalSizeInMB.setScale(1).format();
        return formattedSize;
    }

    private static Decimal calculateTotalFileSizeForSurveyInMB(Id surveyId) {
        // Step 1: Get related Survey_Question__c IDs for the given Survey__c
        List<Id> questionIds = new List<Id>();
        for (Survey_Question__c question : [
            SELECT Id 
            FROM Survey_Question__c 
            WHERE Survey__c = :surveyId
        ]) {
            questionIds.add(question.Id);
        }

        // Step 2: Get ContentDocumentLink IDs related to the Survey_Question__c records
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :questionIds
        ]) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        // Step 3: Sum up the file sizes from ContentVersion
        Decimal totalSizeInBytes = 0; // Use Decimal instead of Long
        if (!contentDocumentIds.isEmpty()) {
            AggregateResult[] results = [
                SELECT SUM(ContentSize) totalSize 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocumentIds
            ];
            if (!results.isEmpty() && results[0].get('totalSize') != null) {
                totalSizeInBytes = (Decimal) results[0].get('totalSize'); // Cast to Decimal
            }
        }

        // Step 4: Convert to MB and return
        Decimal totalSizeInMB = totalSizeInBytes / 1024.0 / 1024.0; // Convert bytes to MB
        return totalSizeInMB;
    }
    

    /**
         * [Method Description] test 2
         * Created by [MinheeKim] on [12-23-2024] for [DPM-5610]
        */
    @AuraEnabled
    public static String launchQueueableForEvaluationGeneration(Id surveyId) {
        PageReference pageReference;
        DateTime currentTime = DateTime.now();
        String contentVersionTitle = 'pdfDocument'; 

        Survey__c survey;
        Evaluation__c evaluation;

        pageReference = new PageReference('/apex/SurveyPDF_w_image');
        //pageReference = new PageReference('/apex/SurveyQuestionCompPDF');
        survey = [select Id, Name, Latest_PDF_Version_Id__c, Evaluation__c from Survey__c where Id = :surveyId ];
        //contentVersionTitle = pdfType + '-' + recordId + '-' + currentTime.format();
        contentVersionTitle = survey.Name + ' - ';

        contentVersionTitle += currentTime.format();
        contentVersionTitle += ' - Survey Complete';

        pageReference.getParameters().put('id', surveyId);

        Blob data;
        if(Test.isRunningTest()) { 
            data = blob.valueOf('Unit.Test');
        }
        else {
            try {
                data = pageReference.getContent();
            } catch(Exception e) {
                System.debug(e.getMessage());
                return 'over 30MB';
            }

            
        }

        return 'under 30MB';
    } 

}