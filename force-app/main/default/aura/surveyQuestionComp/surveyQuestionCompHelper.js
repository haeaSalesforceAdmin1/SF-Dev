({
    getRecordAccess: function(component, event, helper) {
        var action = component.get("c.getHasEditAccessToRecord");
        var recordId = component.get("v.recordId");
        
        action.setParams({"recordId": recordId});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.hasEditAccess", result);
            helper.getEvaluationDetails(component, event, helper);
        });
        $A.enqueueAction(action);
    },

    // DPM-5610 by jonghoonKim //changed to comment by MH
    //Check Survey Size Check
    // getSurveySize: function(component, event, helper) {
    //     component.set("v.isLimitSize", false);
    //     var recordId = component.get("v.recordId");
    //     var sizeCheckAction = component.get("c.pdfErrorCheck");
    //     sizeCheckAction.setParams({"recordId" : recordId});
    //     sizeCheckAction.setCallback(this, function(res) {
    //         var state = res.getState();
    //         if (state === "SUCCESS") {
    //             var returnValue = res.getReturnValue();
    //             console.log("Returned value from Apex: " + returnValue);
                
    //         } else if (state === "ERROR") {
    //             var errors = res.getError();
    //             if (errors && errors.length > 0) {
    //                 for (var i = 0; i < errors.length; i++) {
    //                     var errorMessage = errors[i].message;
    //                     console.error("Error message: " + errorMessage);
    //                     if (errorMessage.includes('30MB')) {
    //                         // '30MB'가 포함된 경우 isLimitSize를 true로 설정
    //                         component.set("v.isLimitSize", true);
    //                     }
    //                 }
    //             }
    //             // if (errors) {
    //             //     for (var i = 0; i < errors.length; i++) {
    //             //         console.error("Error message: " + errors[i].message);
    //             //     }
    //             // }
    //         }
    //     });
    //     $A.enqueueAction(sizeCheckAction);
    // },

    //DPM-5069
    //Check if the survey is completed or not    
    getCompleteAccess: function(component, event, helper, gotonext, submit) {
        var actionAccess = component.get("c.getHasCompleteAccessToRecord");
        var recordId = component.get("v.recordId");
        console.log("Started getCompleteAccess v.isSubmitted>>> "+component.get("v.isSubmitted"));
        console.log("Started getCompleteAccess v.hasEditAccess>>> "+component.get("v.hasEditAccess"));

        actionAccess.setParams({"recordId": recordId});
        actionAccess.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.hasCompleteAccess", result);
            console.log("v.hasCompleteAccess >>> "+component.get("v.hasCompleteAccess"));
            console.log("v.sysUser >>> "+component.get("v.sysUser"));
            
            //DPM-5149 Changed to comments by MH - 2023.11.20
            // if(component.get("v.hasCompleteAccess") && component.get("v.sysUser")){
            //     helper.saveSectionQuestions(component, event, helper, gotonext, true);

            // }else //DPM-5149 end
            if(component.get("v.hasCompleteAccess")){
                helper.saveSectionQuestions(component, event, helper, gotonext, submit);
            }else{
                 console.log('Already Completed Survey.');
                
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     "title": "Error",
                     "message":$A.get("$Label.c.ActionPlanDuplicateError") ,
                     "type": "error"
                 }); 
                 toastEvent.fire()
                 
                 window.setTimeout(
                    $A.getCallback(function() {
                        window.location.reload()
                    }), 4000
                );
                 
            }

        });
        $A.enqueueAction(actionAccess);

        console.log("End getCompleteAccess v.isSubmitted>>> "+component.get("v.isSubmitted"));
        console.log("End getCompleteAccess v.hasEditAccess>>> "+component.get("v.hasEditAccess"));
    },

    //DPM-5069
    //Check if the survey is completed or not before saving a primary contact 
    checkContactSaved : function(component, event, helper){
        var actionAccess = component.get("c.getHasCompleteAccessToRecord");
        var recordId = component.get("v.recordId");
        
        actionAccess.setParams({"recordId": recordId});
        actionAccess.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.hasCompleteAccess", result);
            console.log("v.hasCompleteAccess ::: "+component.get("v.hasCompleteAccess"));
            console.log("v.sysUser >>> "+component.get("v.sysUser"));
            
            if(component.get("v.hasCompleteAccess")){
                var evalObject = {};
                evalObject.Id = component.get("v.evaluation.Id");
                evalObject.PrimaryContactName__c = component.get("v.primaryContactName");
                evalObject.PrimaryContactDate__c = component.get("v.primaryContactDate");
                evalObject.PrimaryContact__c = component.get("v.primaryContact");
                evalObject.No_Review_Needed__c = component.get("v.noReviewNeeded");
                var action = component.get("c.saveEvaluationDetails");
                action.setParams({"evaluationJSONString": JSON.stringify(evalObject)});
                action.setCallback(this, function(response) { 
                    $A.get('e.force:refreshView').fire();
                    helper.getEvaluationDetails(component, event, helper);
                });
                $A.enqueueAction(action);
            }else{
                 console.log('Already Completed Survey.');
                
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     "title": "Error",
                     "message":$A.get("$Label.c.ActionPlanDuplicateError") ,
                     "type": "error"
                 }); 
                 toastEvent.fire()
                 
                 window.setTimeout(
                    $A.getCallback(function() {
                        window.location.reload()
                    }), 4000
                );
                 
            }

        });
        $A.enqueueAction(actionAccess);

    },
    
	getEvaluationDetails : function(component, event, helper) {

        var actionGetNeworkId = component.get("c.getNetworkId");

        actionGetNeworkId.setCallback(this, function(responseNetworkId) {
            var networkId = responseNetworkId.getReturnValue();

            component.set("v.networkId", responseNetworkId.getReturnValue());
            
            var action = component.get("c.retrieveEvaluationDetails");
            var recordId = component.get("v.recordId");
            
            action.setParams({"recordId": recordId, launchedFromEval : component.get("v.launchedFromEval")});
            action.setCallback(this, function(response) {
                var evaluation = response.getReturnValue();

                if(evaluation != null && evaluation.Survey__c != null) {
                    var actionRecordAccess = component.get("c.getHasEditAccessToRecord");
                    actionRecordAccess.setParams({"recordId": evaluation.Survey__c});
                    actionRecordAccess.setCallback(this, function(responseAccess) {
                        component.set("v.hasEditAccess", responseAccess.getReturnValue());
                        component.set("v.evaluation", evaluation);
                        component.set("v.noReviewNeeded", evaluation.No_Review_Needed__c);


                        if (evaluation.Total_Score__c == 100) {
                            component.set("v.evalTotalScore", true); 
                        } else {
                            component.set("v.evalTotalScore", false); 
                        }
                        
                        //Changes made by Dhiraj starts here
                        component.set("v.JdpEvaluationCheckbox",evaluation.JDP_Evaluation__c);
                        //Changes made by Dhiraj ends here

                        //DPM-5399 change
                        if(networkId == '' && evaluation.Survey__r.Status__c!='Completed' && ((evaluation.PrimaryContact__c == undefined || evaluation.PrimaryContact__c == null) && (evaluation.PrimaryContactName__c == undefined || evaluation.PrimaryContactName__c == null) || (evaluation.PrimaryContactDate__c == undefined || evaluation.PrimaryContactDate__c == null))) { // DPM-5399 
                          
                            component.set("v.missingEvaluationFields", true);
                            component.set("v.showReadonlyPage", true);

                            if(evaluation.PrimaryContact__c != undefined) {
                                component.set("v.primaryContact", evaluation.PrimaryContact__c);
                            }

                            if(evaluation.PrimaryContactDate__c != undefined) {
                                component.set("v.primaryContactDate", evaluation.PrimaryContactDate__c);
                            }

                            if(evaluation.PrimaryContactName__c != undefined) {
                                component.set("v.primaryContactName", evaluation.PrimaryContactName__c);
                            }

                            helper.getEvaluationAccountContacts(component, event, helper, evaluation.Account__c);
                        }//DPM-5399 end
                        else {
                            component.set("v.missingEvaluationFields", false);
                            component.set("v.showReadonlyPage", false);

                            //Dhiraj Edit Button wiht Generate pdf button 
                            if(evaluation.ApprovalStatus__c != 'Submitted for District Approval' &&  evaluation.ApprovalStatus__c != 'Submitted for Regional Approval'  && evaluation.ApprovalStatus__c != 'Region Approved' && evaluation.ApprovalStatus__c != 'District Approved') {
                           /* if(evaluation.ApprovalStatus__c != 'Submitted for District Approval' && evaluation.ApprovalStatus__c != 'Submitted for Genesis Area Approval' && evaluation.ApprovalStatus__c != 'Submitted for Regional Approval' && evaluation.ApprovalStatus__c != 'Genesis Area Approved' && evaluation.ApprovalStatus__c != 'Region Approved' && evaluation.ApprovalStatus__c != 'District Approved') {
                             */   component.set("v.allowEditForCompletedSurvey", true);
                            }
                            else {
                                component.set("v.allowEditForCompletedSurvey", false);
                            }

                            if(evaluation.ApprovalStatus__c == 'Sent Back' && evaluation.Total_Score__c == 100) {
                                component.set("v.showResubmitButton", true);
                            }
                            else {
                                component.set("v.showResubmitButton", false);
                            }

                            helper.getSurveyQuestions(component, event, helper);
                            //changes made by Dhiraj starts here
				        	 //helper.getSurveyQuestionCategories(component,event,helper);
        					//changes made by Dhiraj ends here
                        }
                    });
                    $A.enqueueAction(actionRecordAccess);

                }
                else if(evaluation.Survey__c == null) {
                    component.set("v.showNoSurveyMessage", true);
                    component.set("v.showSpinner", false);
                }
                else {
                    component.set("v.missingEvaluationFields", false);
                    component.set("v.showReadonlyPage", false);
                    helper.getSurveyQuestions(component, event, helper);
                }
            });
            $A.enqueueAction(action);
        });
        $A.enqueueAction(actionGetNeworkId);
    },

    /**
     * Edited by [Minhee Kim] on [01.21.2025] for [DPM-5871] 
     */
     saveWarrantyData:function(component,event,helper,warrantyStatus){        
        var isSave = helper.validateWarrantyData(component,event,helper);

        if(isSave){
        
            var surveyWarrantyQuestionsToUpdate = [];
            var surveySectionQuestionsList = component.get("v.surveyWarrantyQuestionList");

            var surveyQuestion={};
            surveyQuestion.Id = component.get("v.surveyId");
            surveyQuestion.Status__c =warrantyStatus;
           	surveyWarrantyQuestionsToUpdate.push(surveyQuestion);


            //Updating the Survey
            var action = component.get("c.updateWarrantySurveyQuestion");
        	action.setParams({"questions": surveySectionQuestionsList, "surveyId" : surveyQuestion.Id, "surveyStatus": surveyQuestion.Status__c});
        	action.setCallback(this, function(response) { 
        		
                if(response.getState()==="SUCCESS"){
                    
                    component.set("v.showSpinner", false);
                    helper.getWarrantySurveyQuestions(component,event,helper);
                    //location.reload();
                    //getWarrantySurveyQuestions(component,event,helper);
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isSubmitted", true);

                    component.set("v.showReadonlyPage", true);
                    if(warrantyStatus=='Completed'){
                        component.set("v.hasEditAccess", false);
                    }
                }else{
                    console.log('Something wrong happen');
                }
            });
            $A.enqueueAction(action);
        }else{
    		component.set("v.showSpinner", false);
		}
  
    },

  
    //Dhiraj Warranty Warranty Review DPM-4390
    /**
     * Changed to comments by [Minhee Kim] on [01.21.2025] for [DPM-5871] 
     */
    /**
     * saveWarrantyData:function(component,event,helper,warrantyStatus){
        helper.validateWarrantyData(component,event,helper);
        var isSave = false;
        if(component.get("v.showQ15")) {  //  Edited by [JongHoon Kim] on [10-18-2024] for [DPM-5863]
            if(component.find('customeError1').get('v.value')=="" && component.find('customeError2').get('v.value')=="" && component.find('customeError3').get('v.value')=="" && component.find('customeError4').get('v.value')==""
            && component.find('customeError5').get('v.value')=="" && component.find('customeError6').get('v.value')=="" && component.find('customeError7').get('v.value')=="" && component.find('customeError8').get('v.value')==""
            && component.find('customeError9').get('v.value')=="" && component.find('customeError10').get('v.value')=="" && component.find('customeError11').get('v.value')=="" && component.find('customeError12').get('v.value')==""
            && component.find('customeError13').get('v.value')=="" && component.find('customeError14').get('v.value')==""&&  component.find('customeError15').get('v.value')=="") {
                isSave = true;
            }
        } else {
             if(component.find('customeError1').get('v.value')=="" && component.find('customeError2').get('v.value')=="" && component.find('customeError3').get('v.value')=="" && component.find('customeError4').get('v.value')==""
            && component.find('customeError5').get('v.value')=="" && component.find('customeError6').get('v.value')=="" && component.find('customeError7').get('v.value')=="" && component.find('customeError8').get('v.value')==""
            && component.find('customeError9').get('v.value')=="" && component.find('customeError10').get('v.value')=="" && component.find('customeError11').get('v.value')=="" && component.find('customeError12').get('v.value')==""
            && component.find('customeError13').get('v.value')=="" && component.find('customeError14').get('v.value')=="") {
                isSave = true;
            }
        }
        

        if(isSave){
        
            var surveyWarrantyQuestionsToUpdate = [];
            var surveySectionQuestionsMapData = component.get("v.surveyWarrantySectionQuestionsMapData");
            surveySectionQuestionsMapData.forEach(record=>{
                var surveyQuestion={};
                surveyQuestion.Id = component.get("v.surveyId");
   				         
            	surveyQuestion.NumberOfRosReviewed__c=record.values.NUMBEROFROSREVIEWED;
                
            	surveyQuestion.NumberOfRosWithoutAnyDiscrepancies__c=record.values.NUMBEROFROSWITHOUTANYDISCREPANCIES;
                surveyQuestion.PerNumberOfRosWithoutAnyDiscrepancies__c=component.get('v.PercentageNUMBEROFROSWITHOUTANYDISCREPANCIES');
                
            	if(record.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES==undefined || record.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES==''){
                	surveyQuestion.NumberOfRosWithInsufficientTechNotes__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithInsufficientTechNotes__c=record.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES;
                }
            	surveyQuestion.PerNumberOfRosWithInsufficientTechNotes__c=component.get('v.PercentageNUMBEROFROSWITHINSUFFICIENTTECHNOTES');
            
            	if(record.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY==undefined || record.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY==''){
                	surveyQuestion.NumberOfRosWithDateMileageDiscrepancy__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithDateMileageDiscrepancy__c=record.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY;
                }
                surveyQuestion.PerNumberOfRosWithDateMileageDiscrepancy__c=component.get('v.PercentageNUMBEROFROSWITHDATEMILEAGEDISCREPANCY');
				
				if(record.values.NUMBEROFROSWITHIMPROPERADDON==undefined || record.values.NUMBEROFROSWITHIMPROPERADDON==''){
                	surveyQuestion.NumberOfRosWithImproperAddOnA__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithImproperAddOnA__c=record.values.NUMBEROFROSWITHIMPROPERADDON;
                }            
                surveyQuestion.PerNumberOfRosWithImproperAddOnA__c=component.get('v.PercentageNUMBEROFROSWITHIMPROPERADDON');
            
            	if(record.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY==undefined || record.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY==''){
                	surveyQuestion.NumberOfRosWithTimeJustificationDiscrepa__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithTimeJustificationDiscrepa__c=record.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY;
                }
                surveyQuestion.PerNumberOfRosWithTimeJustificationDiscr__c=component.get('v.PercentageNUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY');
                
            	if(record.values.NUMBEROFROSWITHSUBLETDISCREPANCY==undefined || record.values.NUMBEROFROSWITHSUBLETDISCREPANCY==''){
                	surveyQuestion.NumberOfRosWithSubletDiscrepancy__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithSubletDiscrepancy__c=record.values.NUMBEROFROSWITHSUBLETDISCREPANCY;
                }
                surveyQuestion.PerNumberOfRosWithSubletDiscrepancy__c=component.get('v.PercentageNUMBEROFROSWITHSUBLETDISCREPANCY');
            	
            	if(record.values.NUMBEROFROSWITHIMPROPERREPAIR==undefined || record.values.NUMBEROFROSWITHIMPROPERREPAIR==''){
                	surveyQuestion.NumberOfRosWithImproperRepair__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithImproperRepair__c=record.values.NUMBEROFROSWITHIMPROPERREPAIR;
                }
                surveyQuestion.PerNumberOfRosWithImproperRepair__c=component.get('v.PercentageNUMBEROFROSWITHIMPROPERREPAIR');
            	
            	if(record.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM==undefined || record.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM==''){
                	surveyQuestion.NumberOfRosWhereRoDoesNotMatchClaim__c=0;
                }else{
                	surveyQuestion.NumberOfRosWhereRoDoesNotMatchClaim__c=record.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM;
                }
                surveyQuestion.PerNumberOfRosWhereRoDoesNotMatchClaim__c=component.get('v.PercentageNUMBEROFROSWHERERODOESNOTMATCHCLAIM');
            
            	if(record.values.NUMBEROFROSWITHMISSINGDOCUMENTS==undefined || record.values.NUMBEROFROSWITHMISSINGDOCUMENTS==''){
                	surveyQuestion.NumberOfRosWithMissingDocuments__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithMissingDocuments__c=record.values.NUMBEROFROSWITHMISSINGDOCUMENTS;
                }
                surveyQuestion.PerNumberOfRosWithMissingDocuments__c=component.get('v.PercentageNUMBEROFROSWITHMISSINGDOCUMENTS');
            
            	
            	if(record.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY==undefined || record.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY==''){
                	surveyQuestion.NumberOfRosWithCustomerSignatureDiscrepa__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithCustomerSignatureDiscrepa__c=record.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY;
                }
                surveyQuestion.PerNumberOfRosWithCustomerSignatureDiscr__c=component.get('v.PercentageNUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY');
            
            	if(record.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA==undefined || record.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA==''){
                	surveyQuestion.NumberOfRosWithPriorApprovalDiscrepancy__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithPriorApprovalDiscrepancy__c=record.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA;
                }
                surveyQuestion.PerNumberOfRosWithPriorApprovalDiscrepan__c=component.get('v.PercentageNUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA');
            	
            	if(record.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION==undefined || record.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION==''){
                	surveyQuestion.NumberOfRosWithPartsRetentionDiscrepancy__c=0;
                }else{
                	surveyQuestion.NumberOfRosWithPartsRetentionDiscrepancy__c=record.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION;
                }
                surveyQuestion.PerNumberOfRosWithPartsRetentionDiscrepa__c=component.get('v.PercentageNUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION');
				
				
            	if(record.values.NUMBEROFROSWHICHARENOTWARRANTY==undefined || record.values.NUMBEROFROSWHICHARENOTWARRANTY==''){
                	surveyQuestion.NumberOfRosWhichAreNotWarranty__c=0;
                }else{
                	surveyQuestion.NumberOfRosWhichAreNotWarranty__c=record.values.NUMBEROFROSWHICHARENOTWARRANTY;
                }            
                surveyQuestion.PerNumberOfRosWhichAreNotWarranty__c=component.get('v.PercentageNUMBEROFROSWHICHARENOTWARRANTY');

                if(component.get("v.showQ15")) { //  Edited by [JongHoon Kim] on [10-18-2024] for [DPM-5863]
                    if(record.values.NumberOfRosWithInsufficientDigtalDoc==undefined || record.values.NumberOfRosWithInsufficientDigtalDoc==''){  //DPM-5863
                	    surveyQuestion.NumberOfRosWithInsufficientDigtalDoc__c=0;
                    }else{
                        surveyQuestion.NumberOfRosWithInsufficientDigtalDoc__c=record.values.NumberOfRosWithInsufficientDigtalDoc;
                    }            
                    surveyQuestion.PerNumberOfRosWithInsufficientDigtalDoc__c=component.get('v.PercentageNumberOfRosWithInsufficientDigtalDoc');
                }
                
            	//surveyQuestion.Status__c = 'Completed';
            	  surveyQuestion.Status__c =warrantyStatus;
               	  //component.set("v.hasEditAccess",true);
            	//Push all question in List
           		surveyWarrantyQuestionsToUpdate.push(surveyQuestion);
            });
        	
            component.set("v.SurveyRecord",surveyWarrantyQuestionsToUpdate);
        	var SurRec = component.get("v.SurveyRecord");

        	var surJson = JSON.stringify(SurRec,null,5);

            //Updating the Survey
            var action = component.get("c.updateWarrantySurvey");
        	action.setParams({"surveyJSON": surJson});
        	action.setCallback(this, function(response) { 
        		
                if(response.getState()==="SUCCESS"){
                    
                    component.set("v.showSpinner", false);
                    helper.getWarrantySurveyQuestions(component,event,helper);
            
                    //location.reload();
                    //getWarrantySurveyQuestions(component,event,helper);
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isSubmitted", true);

                    component.set("v.showReadonlyPage", true);
                    if(warrantyStatus=='Completed'){
                        component.set("v.hasEditAccess", false);
                        //DPM-4390
                        helper.updateSurveyQuestion(component,event,helper);
                    }
                    //component.set("v.hasEditAccess", false);
                }else{
                    console.log('Something wrong happen');
                }
            });
            $A.enqueueAction(action);
        }else{
    		component.set("v.showSpinner", false);
		}
  
    },*/
    

    //DPM-4390
    updateSurveyQuestion : function(component, event, helper) {
        var surveyWarrantyQuestion = component.get("v.SurveyRecord");

        var surveyQuestionTemp = [];
        surveyWarrantyQuestion.forEach(record=>{
            var questionsList={};
            
            questionsList.Id = component.get("v.surveyId");
            questionsList.Q1_value = record.NumberOfRosReviewed__c;
            
            questionsList.Q2_value = record.NumberOfRosWithoutAnyDiscrepancies__c;           
            questionsList.Q2_percent = record.PerNumberOfRosWithoutAnyDiscrepancies__c;           
            
            questionsList.Q3_value = record.NumberOfRosWithInsufficientTechNotes__c;
            questionsList.Q3_percent = record.PerNumberOfRosWithInsufficientTechNotes__c;
            
            questionsList.Q4_value  = record.NumberOfRosWithDateMileageDiscrepancy__c;
            questionsList.Q4_percent  = record.PerNumberOfRosWithDateMileageDiscrepancy__c;
            
            questionsList.Q5_value = record.NumberOfRosWithImproperAddOnA__c;           
            questionsList.Q5_percent = record.PerNumberOfRosWithImproperAddOnA__c;           
            
            questionsList.Q6_value = record.NumberOfRosWithTimeJustificationDiscrepa__c;
            questionsList.Q6_percent = record.PerNumberOfRosWithTimeJustificationDiscr__c;
            
            questionsList.Q7_value = record.NumberOfRosWithSubletDiscrepancy__c;
            questionsList.Q7_percent = record.PerNumberOfRosWithSubletDiscrepancy__c;
            
            questionsList.Q8_value = record.NumberOfRosWithImproperRepair__c;           
            questionsList.Q8_percent = record.PerNumberOfRosWithImproperRepair__c;           
            
            questionsList.Q9_value = record.NumberOfRosWhereRoDoesNotMatchClaim__c;
            questionsList.Q9_percent = record.PerNumberOfRosWhereRoDoesNotMatchClaim__c;           
            
            questionsList.Q10_value = record.NumberOfRosWithMissingDocuments__c;
            questionsList.Q10_percent = record.PerNumberOfRosWithMissingDocuments__c;           
            
            questionsList.Q11_value = record.NumberOfRosWithCustomerSignatureDiscrepa__c;
            questionsList.Q11_percent = record.PerNumberOfRosWithCustomerSignatureDiscr__c;           
            
            questionsList.Q12_value = record.NumberOfRosWithPriorApprovalDiscrepancy__c;
            questionsList.Q12_percent = record.PerNumberOfRosWithPriorApprovalDiscrepan__c;           
            
            questionsList.Q13_value = record.NumberOfRosWithPartsRetentionDiscrepancy__c;
            questionsList.Q13_percent = record.PerNumberOfRosWithPartsRetentionDiscrepa__c;           
            
            questionsList.Q14_value = record.NumberOfRosWhichAreNotWarranty__c;
            questionsList.Q14_percent = record.PerNumberOfRosWhichAreNotWarranty__c;

            questionsList.Q15_value = record.NumberOfRosWithInsufficientDigtalDoc__c; //  Edited by [JongHoon Kim] on [10-18-2024] for [DPM-5863]
            questionsList.Q15_percent = record.PerNumberOfRosWithInsufficientDigtalDoc__c;
            surveyQuestionTemp.push(questionsList);


        });
        	var surJson = JSON.stringify(surveyQuestionTemp,null,5);
            var action = component.get("c.updateWarrantySurveyQuestion");
        	action.setParams({"surveyJSON": surJson});
        	action.setCallback(this, function(response) { 
        		
                if(response.getState()==="SUCCESS"){
                    console.log('state => Success');
                }else{
                    console.log('state => Failed');
                }
            });
        $A.enqueueAction(action);	 
   },

    /**
     * [Method Description] 
     * Created by [MinheeKim] on [2024-01-17] for [DPM-5264]
     * Edited by [MinheeKim] on [2024-02-13] for [DPM-5352]
    */
   saveDeletedFile: function(component, event, helper){
        var action = component.get("c.deleteContentDocument");
        var deletedFileMapData = component.get("v.deletedFileMapData");
        console.log('saveDeletedFile : '+deletedFileMapData);
        if(deletedFileMapData!=null && deletedFileMapData!=''){ //DPM-5352 added condition to prevent error by MH - 2024.02.13
            action.setParams({"ContentDocumentId": deletedFileMapData});
            action.setCallback(this, function(response) { 
                
                if(response.getState()==="SUCCESS"){
                    // console.log(deletedFile+ ' deleted.'); //deletedFileMapData
                }else{
                    console.log('Something wrong happen when deleted file saved');
                }
            });
            $A.enqueueAction(action);
        }
   },


 	//Dhiraj Warranty Review DPM-4390 Edit button
 	handleEditButonClickRecordOpen : function(component, event, helper) {
    	component.set("v.showReadonlyPage", false);
    	component.set("v.hasEditAccess", true);
    	$A.get('e.force:refreshView').fire();
    },
   
    //Dhiraj Warranty Review DPM-4390
    /**
     * Edited by [Minhee Kim] on [01.21.2025] for [DPM-5871] To use dynamic variable for survey questions
     */
    validateWarrantyData:function(component,event,helper){
        var warrantyQuestionList =component.get("v.surveyWarrantyQuestionList");
        var customError = component.get("v.customError");
        customError.length = surveyWarrantyQuestionList.length;
        customError.fill("");
        let firstNum = warrantyQuestionList[0].Response_Number_2__c;
        let secInput = (warrantyQuestionList[1].Response_Number_2__c!==''||  warrantyQuestionList[1].Response_Number_2__c!==undefined) ? firstNum - warrantyQuestionList[1].Response_Number_2__c : firstNum;
        var inputCompare = 0;
            
    	warrantyQuestionList.forEach((warQuestions, index)=>{
            
                if(firstNum>=0 && firstNum!='' && firstNum!=undefined){
                    if(index==1){
                        if(secInput>=0 && warQuestions.Response_Number_2__c>=0 && warQuestions.Response_Number_2__c!=='' && warQuestions.Response_Number_2__c!=undefined){
                            warQuestions.Other_Response_Text__c = ((warQuestions.Response_Number_2__c/firstNum)*100).toString()+'%';
                            //component.set('v.warQuestions.values.PercentageNUMBEROFROSWITHDATEMILEAGEDISCREPANCY',(warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES/warQuestions.values.NUMBEROFROSREVIEWED)*100);
                        }else{
                            customError[index] ="Value must be less than Q1";
                        }
                        //Compare value    	                Q1                                          Q2
                        inputCompare =  (warrantyQuestionList[1].Response_Number_2__c!==''||  warrantyQuestionList[1].Response_Number_2__c!==undefined) ?  firstNum-warrantyQuestionList[1].Response_Number_2__c : firstNum;
                    }else if(index!==1 || index!==0){
                        let tempInput=0; 
                        if(warQuestions.Response_Number_2__c ==undefined ||warQuestions.Response_Number_2__c ==''){
                            tempInput =inputCompare;
                        }else{                                      //Q3
                            tempInput =inputCompare - warQuestions.Response_Number_2__c;
                        }
                        if(tempInput>=0){
                            if(warQuestions.Response_Number_2__c ==undefined || warQuestions.Response_Number_2__c==''){
                                warQuestions.Other_Response_Text__c ='0%';
                                }
                            else{
                                let percent = (warQuestions.Response_Number_2__c/firstNum)*100;
                                warQuestions.Other_Response_Text__c =percent.toString()+'%';
                                
                            }
                            customError[index] = ""; 
                        }else{
                            customError[index] = `Value must be less than or equal ${inputCompare}`;
                        }
                    }

                }
                else{
                    customError[0] = "Please Enter Value";                     
            }
    
        });

        component.set("v.surveyWarrantyQuestionList" , warrantyQuestionList);
        component.set("v.customError",customError);

        let noError=true;
        customError.forEach(error=>{
            if(error!=""){
                noError=false;
            }else if(!noError){
                return noError;
            }
        });		
        return noError;
	},

    //Dhiraj Warranty Review DPM-4390
    /**
     * Changed to comments by [Minhee Kim] on [01.21.2025] for [DPM-5871] 
     */
    /**validateWarrantyData:function(component,event,helper){
        var warrantyQuestionList =component.get("v.surveyWarrantySectionQuestionsMapData");

    		warrantyQuestionList.forEach(warQuestions=>{
    
            //base input
            let NUMBEROFROSREVIEWED =warQuestions.values.NUMBEROFROSREVIEWED;
                
            if(warQuestions.values.NUMBEROFROSREVIEWED>=0 && warQuestions.values.NUMBEROFROSREVIEWED!='' && warQuestions.values.NUMBEROFROSREVIEWED!=undefined){
                //                               Q1                                         Q2
				var secInput = warQuestions.values.NUMBEROFROSREVIEWED - warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES;
                //   0                                  Q2                          
                //DPM-4390
                // if(secInput>=0 && warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES>=0 && warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES!='' && warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES!=undefined){
                if(secInput>=0 && warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES>=0 && warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES!=='' && warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES!=undefined){
            		component.set('v.PercentageNUMBEROFROSWITHOUTANYDISCREPANCIES',(warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES/warQuestions.values.NUMBEROFROSREVIEWED)*100);
                    //component.set('v.warQuestions.values.PercentageNUMBEROFROSWITHDATEMILEAGEDISCREPANCY',(warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					
                //Compare value    	                Q1                                          Q2
                var inputCompare = warQuestions.values.NUMBEROFROSREVIEWED - warQuestions.values.NUMBEROFROSWITHOUTANYDISCREPANCIES;
                
                //Input 3
                let input3=0;                   //Q3
            	if(warQuestions.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES ==undefined ||warQuestions.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES ==''){
                	input3 =inputCompare;
            	}else{                                      //Q3
                	input3 =inputCompare - warQuestions.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES;
            	}
                if(input3>=0){
            		if(warQuestions.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES ==undefined || warQuestions.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES==''){
                		component.set('v.PercentageNUMBEROFROSWITHINSUFFICIENTTECHNOTES',0);
 		           	}
                    else{
                    	component.set('v.PercentageNUMBEROFROSWITHINSUFFICIENTTECHNOTES',(warQuestions.values.NUMBEROFROSWITHINSUFFICIENTTECHNOTES/warQuestions.values.NUMBEROFROSREVIEWED)*100);    
                    }
					component.find('customeError3').set('v.value',"");
        		}else{
            		component.find('customeError3').set('v.value',"Value must be less than or equal " + inputCompare);
        		}

        	  	//Input 4
        		let input4 =0;
        		if(warQuestions.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY ==undefined ||warQuestions.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY ==''){
                	input4 =inputCompare;
            	}else{
                	input4 =inputCompare - warQuestions.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY;
            	}
                if( input4>=0){
                    if(warQuestions.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY ==undefined || warQuestions.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY==''){
                		component.set('v.PercentageNUMBEROFROSWITHDATEMILEAGEDISCREPANCY',0);
                    }else{
                        component.set('v.PercentageNUMBEROFROSWITHDATEMILEAGEDISCREPANCY',(warQuestions.values.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY/warQuestions.values.NUMBEROFROSREVIEWED)*100);
                    }
					component.find('customeError4').set('v.value',"");
        		}else{
            		component.find('customeError4').set('v.value',"Value must be less than or equal " + inputCompare);
        		}            	

        		//Input 5
				let input5=0;	
        		if(warQuestions.values.NUMBEROFROSWITHIMPROPERADDON ==undefined ||warQuestions.values.NUMBEROFROSWITHIMPROPERADDON ==''){
                	input5 =inputCompare;
            	}else{
                	input5 =inputCompare - warQuestions.values.NUMBEROFROSWITHIMPROPERADDON;
            	}

        		if( input5>=0){
                    if(warQuestions.values.NUMBEROFROSWITHIMPROPERADDON ==undefined || warQuestions.values.NUMBEROFROSWITHIMPROPERADDON==''){
                		component.set('v.PercentageNUMBEROFROSWITHIMPROPERADDON',0);
                    }else{
                     component.set('v.PercentageNUMBEROFROSWITHIMPROPERADDON',(warQuestions.values.NUMBEROFROSWITHIMPROPERADDON/warQuestions.values.NUMBEROFROSREVIEWED)*100);   
                    }
					component.find('customeError5').set('v.value',"");
           		}else{
            		component.find('customeError5').set('v.value',"Value must be less than or equal " + inputCompare);
        		}        		
        
        
        		//Input 6
        		let input6=0;
				if(warQuestions.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY ==undefined ||warQuestions.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY ==''){
                	input6 =inputCompare;
            	}else{
                	input6 =inputCompare - warQuestions.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY;
            	}
        		if( input6>=0){
                    if(warQuestions.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY ==undefined || warQuestions.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY==''){
                		component.set('v.PercentageNUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY',0);
					}else{
                    	component.set('v.PercentageNUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY',(warQuestions.values.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
					component.find('customeError6').set('v.value',"");
        		}else{
            		component.find('customeError6').set('v.value',"Value must be less than or equal " + inputCompare);
        		}

        		//Input 7
        		let input7 =0;
				if(warQuestions.values.NUMBEROFROSWITHSUBLETDISCREPANCY ==undefined ||warQuestions.values.NUMBEROFROSWITHSUBLETDISCREPANCY ==''){
                	input7 =inputCompare;
            	}else{
                	input7 =inputCompare - warQuestions.values.NUMBEROFROSWITHSUBLETDISCREPANCY;
            	}
        		if( input7>=0){
                    if(warQuestions.values.NUMBEROFROSWITHSUBLETDISCREPANCY ==undefined || warQuestions.values.NUMBEROFROSWITHSUBLETDISCREPANCY==''){
                		component.set('v.PercentageNUMBEROFROSWITHSUBLETDISCREPANCY',0);
					}else{
                    	component.set('v.PercentageNUMBEROFROSWITHSUBLETDISCREPANCY',(warQuestions.values.NUMBEROFROSWITHSUBLETDISCREPANCY/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
					component.find('customeError7').set('v.value',"");
        		}else{
            		component.find('customeError7').set('v.value',"Value must be less than or equal " + inputCompare);
        		}
            
        		//Input 8
				let input8 =0;
        		if(warQuestions.values.NUMBEROFROSWITHIMPROPERREPAIR ==undefined ||warQuestions.values.NUMBEROFROSWITHIMPROPERREPAIR ==''){
                	input8 =inputCompare;
            	}else{
                	input8 =inputCompare - warQuestions.values.NUMBEROFROSWITHIMPROPERREPAIR;
            	}
        		if(input8>=0){
            		if(warQuestions.values.NUMBEROFROSWITHIMPROPERREPAIR ==undefined || warQuestions.values.NUMBEROFROSWITHIMPROPERREPAIR==''){
                		component.set('v.PercentageNUMBEROFROSWITHIMPROPERREPAIR','0');
					}else{
                    	component.set('v.PercentageNUMBEROFROSWITHIMPROPERREPAIR',(warQuestions.values.NUMBEROFROSWITHIMPROPERREPAIR/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
					component.find('customeError8').set('v.value',"");
        		}else{
            		component.find('customeError8').set('v.value',"Value must be less than or equal " + inputCompare);
        		}
            
        		//Input 9
        		let input9 =0;
            	if(warQuestions.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM ==undefined ||warQuestions.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM ==''){
                	input9 =inputCompare;
            	}else{
                	input9 =inputCompare - warQuestions.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM;
            	}
        		if( input9>=0){
            		if(warQuestions.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM ==undefined || warQuestions.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM==''){
                		component.set('v.PercentageNUMBEROFROSWHERERODOESNOTMATCHCLAIM',0);
					}else{
                    	component.set('v.PercentageNUMBEROFROSWHERERODOESNOTMATCHCLAIM',(warQuestions.values.NUMBEROFROSWHERERODOESNOTMATCHCLAIM/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
                   component.find('customeError9').set('v.value',"");
        		}else{
            		component.find('customeError9').set('v.value',"Value must be less than or equal " + inputCompare);
        		}
           
				let input10 =0;
            	if(warQuestions.values.NUMBEROFROSWITHMISSINGDOCUMENTS ==undefined ||warQuestions.values.NUMBEROFROSWITHMISSINGDOCUMENTS ==''){
                	input10 =inputCompare;
            	}else{
                	input10 =inputCompare - warQuestions.values.NUMBEROFROSWITHMISSINGDOCUMENTS;
            	}
        		if( input10>=0){
            		if(warQuestions.values.NUMBEROFROSWITHMISSINGDOCUMENTS ==undefined || warQuestions.values.NUMBEROFROSWITHMISSINGDOCUMENTS==''){
                		component.set('v.PercentageNUMBEROFROSWITHMISSINGDOCUMENTS',0);
					}else{
                    	component.set('v.PercentageNUMBEROFROSWITHMISSINGDOCUMENTS',(warQuestions.values.NUMBEROFROSWITHMISSINGDOCUMENTS/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
					component.find('customeError10').set('v.value',"");
        		}else{
            		component.find('customeError10').set('v.value',"Value must be less than or equal " + inputCompare);
        		}
            	
				let input11 =0;
            	if(warQuestions.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY ==undefined ||warQuestions.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY ==''){
                	input11 =inputCompare;
            	}else{
                	input11 =inputCompare - warQuestions.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY;
            	}
        		if( input11>=0){
            		if(warQuestions.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY ==undefined || warQuestions.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY==''){
                		component.set('v.PercentageNUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY',0);
					}else{
                    	component.set('v.PercentageNUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY',(warQuestions.values.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
					component.find('customeError11').set('v.value',"");
        		}else{
            		component.find('customeError11').set('v.value',"Value must be less than or equal " + inputCompare);
        		}
            
				let input12 =0 ;
            	if(warQuestions.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA ==undefined ||warQuestions.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA ==''){
                	input12 =inputCompare;
            	}else{
                	input12 =inputCompare - warQuestions.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA;
            	}
        		if( input12>=0){
            		if(warQuestions.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA ==undefined || warQuestions.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA==''){
                		component.set('v.PercentageNUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA',0);
					}else{
                    	component.set('v.PercentageNUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA',(warQuestions.values.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
					component.find('customeError12').set('v.value',"");
        		}else{
            		component.find('customeError12').set('v.value',"Value must be less than or equal " + inputCompare);
        		}
            	
				let input13 =0;
            	if(warQuestions.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION ==undefined ||warQuestions.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION ==''){
                	input13 =inputCompare;
            	}else{
                	input13 =inputCompare - warQuestions.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION;
            	}
        		if( input13>=0){
            		if(warQuestions.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION ==undefined || warQuestions.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION==''){
                		component.set('v.PercentageNUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION',0);
					}else{
                    	component.set('v.PercentageNUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION',(warQuestions.values.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
                    component.find('customeError13').set('v.value',"");
        		}else{
            		component.find('customeError13').set('v.value',"Value must be less than or equal " + inputCompare);
        		}
            
				let input14 =0;
            	if(warQuestions.values.NUMBEROFROSWHICHARENOTWARRANTY ==undefined ||warQuestions.values.NUMBEROFROSWHICHARENOTWARRANTY ==''){
                	input14 =inputCompare;
            	}else{
                	input14 =inputCompare - warQuestions.values.NUMBEROFROSWHICHARENOTWARRANTY;
            	}
        		if( input14>=0){
            		if(warQuestions.values.NUMBEROFROSWHICHARENOTWARRANTY ==undefined || warQuestions.values.NUMBEROFROSWHICHARENOTWARRANTY==''){
                		component.set('v.PercentageNUMBEROFROSWHICHARENOTWARRANTY',0);
					}else{
                    	component.set('v.PercentageNUMBEROFROSWHICHARENOTWARRANTY',(warQuestions.values.NUMBEROFROSWHICHARENOTWARRANTY/warQuestions.values.NUMBEROFROSREVIEWED)*100);
					}
					component.find('customeError14').set('v.value',"");
        		}else{
            		component.find('customeError14').set('v.value',"Value must be less than or equal " + inputCompare);
        		}
                if(component.get("v.showQ15")) { //  Edited by [JongHoon Kim] on [10-18-2024] for [DPM-5863]
                    let input15 =0; 
                    if(warQuestions.values.NumberOfRosWithInsufficientDigtalDoc ==undefined ||warQuestions.values.NumberOfRosWithInsufficientDigtalDoc ==''){
                        input15 =inputCompare;
                    }else{
                        input15 =inputCompare - warQuestions.values.NumberOfRosWithInsufficientDigtalDoc;
                    }
                    if( input15>=0){
                        if(warQuestions.values.NumberOfRosWithInsufficientDigtalDoc ==undefined || warQuestions.values.NumberOfRosWithInsufficientDigtalDoc==''){
                            component.set('v.PercentageNumberOfRosWithInsufficientDigtalDoc',0);
                        }else{
                            component.set('v.PercentageNumberOfRosWithInsufficientDigtalDoc',(warQuestions.values.NumberOfRosWithInsufficientDigtalDoc/warQuestions.values.NUMBEROFROSREVIEWED)*100);
                        }
                        component.find('customeError15').set('v.value',"");
                    }else{
                        component.find('customeError15').set('v.value',"Value must be less than or equal " + inputCompare);
                    }
                }
                
            	//Error msg for 2nd input
            	component.find('customeError2').set('v.value',"");
                }else{
            		component.find('customeError2').set('v.value',"Value must be less than Q1");
        			component.find('customeError3').set('v.value',"");
                    component.find('customeError4').set('v.value',"");
                    component.find('customeError5').set('v.value',"");
                    component.find('customeError6').set('v.value',"");
                    component.find('customeError7').set('v.value',"");
                    component.find('customeError8').set('v.value',"");
                    component.find('customeError9').set('v.value',"");
                    component.find('customeError10').set('v.value',"");
                    component.find('customeError11').set('v.value',"");
                    component.find('customeError12').set('v.value',"");
                    component.find('customeError13').set('v.value',"");
                    component.find('customeError14').set('v.value',"");
                    component.find('customeError15').set('v.value',"");
                }
            	
            	
            component.find('customeError1').set('v.value',"");
        	}
            else{
            	component.find('customeError1').set('v.value',"Please Enter Value");                     
            }
        });
 				
	},*/
   
    //Dhiraj Warranty review DPM-4390
    /**
     * Edited by [Minhee Kim] on [01.21.2025] for [DPM-5871] To use dynamic variable for survey questions
     */
    getWarrantySurveyQuestions:function(component,event,helper){
       
        var action = component.get("c.getSurveyWarrantyReviewQuestions");
        var recordId = component.get("v.recordId");

        action.setParams({"recordId": recordId, launchedFromEval : component.get("v.launchedFromEval")});
        action.setCallback(this, function(response) {
            
            var results = response.getReturnValue();
            var surveyId = results[0].Id;
            component.set("v.surveyId", surveyId);
            
            //Show Read Only permission checking
            var results = response.getReturnValue();
            if(results.length > 0) {
                if(results[0].Status__c == 'Completed') {
                    component.set("v.showReadonlyPage", true); 
                    component.set("v.isSurveyCompletion",true);
                }
            }
            component.set("v.surveyWarrantyQuestionList", results);
            console.log('surveyWarrantyQuestionList: '+ component.get("v.surveyWarrantyQuestionList"));
            component.set("v.showSpinner", false);

        });
        $A.enqueueAction(action);
    },

    /**
     * Changed to comments by [Minhee Kim] on [01.21.2025] for [DPM-5871] 
     */
    /**
     *getWarrantySurveyQuestions:function(component,event,helper){
       
        var action = component.get("c.getSurveyWarrantyReviewQuestions");
        var recordId = component.get("v.recordId");

        //component.set('v.EvaluationId',recordId);

        action.setParams({"recordId": recordId, launchedFromEval : component.get("v.launchedFromEval")});
        action.setCallback(this, function(response) {
            
            var results = response.getReturnValue();
            var surveyId = results[0].Id;
            component.set("v.surveyId", surveyId);
            
            //Show Read Only permission checking
            var results = response.getReturnValue();
            if(results.length > 0) {
                if(results[0].Status__c == 'Completed') {
                    component.set("v.showReadonlyPage", true); 
                    component.set("v.isSurveyCompletion",true);
                }
            }
            
            
            //Handling Questions
            let surveyWarrantySectionTemp=[];
            let surveyWarrantySectionQuestionsMapDataTemp=[];
            var surveyWarrantyQuestionMap={};
            var inputQuestionList={};
            if(results.length > 0) {
                results.forEach(record => {
                    
                    let questionsList={};
                    questionsList.NUMBEROFROSREVIEWED = record.NumberOfRosReviewed__c;

                    questionsList.NUMBEROFROSWITHOUTANYDISCREPANCIES = record.NumberOfRosWithoutAnyDiscrepancies__c;
                    questionsList.PercentageNUMBEROFROSWITHOUTANYDISCREPANCIES = record.PerNumberOfRosWithoutAnyDiscrepancies__c;

                    questionsList.NUMBEROFROSWITHINSUFFICIENTTECHNOTES = record.NumberOfRosWithInsufficientTechNotes__c;
                    questionsList.PercentageNUMBEROFROSWITHINSUFFICIENTTECHNOTES = record.PerNumberOfRosWithInsufficientTechNotes__c;

                    questionsList.NUMBEROFROSWITHDATEMILEAGEDISCREPANCY = record.NumberOfRosWithDateMileageDiscrepancy__c;
                    questionsList.PercentageNUMBEROFROSWITHDATEMILEAGEDISCREPANCY = record.PerNumberOfRosWithDateMileageDiscrepancy__c;

                    questionsList.NUMBEROFROSWITHIMPROPERADDON = record.NumberOfRosWithImproperAddOnA__c;
                    questionsList.PercentageNUMBEROFROSWITHIMPROPERADDON = record.PerNumberOfRosWithImproperAddOnA__c;

                    questionsList.NUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY = record.NumberOfRosWithTimeJustificationDiscrepa__c;
                    questionsList.PercentageNUMBEROFROSWITHTIMEJUSTIFICATIONDISCREPANCY = record.PerNumberOfRosWithTimeJustificationDiscr__c;

                    questionsList.NUMBEROFROSWITHSUBLETDISCREPANCY = record.NumberOfRosWithSubletDiscrepancy__c;
                    questionsList.PercentageNUMBEROFROSWITHSUBLETDISCREPANCY = record.PerNumberOfRosWithSubletDiscrepancy__c;

                    questionsList.NUMBEROFROSWITHIMPROPERREPAIR = record.NumberOfRosWithImproperRepair__c;
                    questionsList.PercentageNUMBEROFROSWITHIMPROPERREPAIR = record.PerNumberOfRosWithImproperRepair__c;

                    questionsList.NUMBEROFROSWHERERODOESNOTMATCHCLAIM = record.NumberOfRosWhereRoDoesNotMatchClaim__c;
                    questionsList.PercentageNUMBEROFROSWHERERODOESNOTMATCHCLAIM = record.PerNumberOfRosWhereRoDoesNotMatchClaim__c;

                    questionsList.NUMBEROFROSWITHMISSINGDOCUMENTS = record.NumberOfRosWithMissingDocuments__c;
                    questionsList.PercentageNUMBEROFROSWITHMISSINGDOCUMENTS = record.PerNumberOfRosWithMissingDocuments__c;

                    questionsList.NUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY = record.NumberOfRosWithCustomerSignatureDiscrepa__c;
                    questionsList.PercentageNUMBEROFROSWITHCUSTOMERSIGNATUREDISCREPANCY = record.PerNumberOfRosWithCustomerSignatureDiscr__c;

                    questionsList.NUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA = record.NumberOfRosWithPriorApprovalDiscrepancy__c;
                    questionsList.PercentageNUMBEROFROSWITHPRIORAPPROVALDISCREPANCYinctimeStampbeforePA = record.PerNumberOfRosWithPriorApprovalDiscrepan__c;

                    questionsList.NUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION = record.NumberOfRosWithPartsRetentionDiscrepancy__c;
                    questionsList.PercentageNUMBEROFROSWITHPARTSRETENTIONDISCREPANCYRODOCUMENTATION = record.PerNumberOfRosWithPartsRetentionDiscrepa__c;

                    questionsList.NUMBEROFROSWHICHARENOTWARRANTY = record.NumberOfRosWhichAreNotWarranty__c;
                    questionsList.PercentageNUMBEROFROSWHICHARENOTWARRANTY = record.PerNumberOfRosWhichAreNotWarranty__c;

                    //  Edited by [JongHoon Kim] on [10-18-2024] for [DPM-5863]
                    questionsList.NumberOfRosWithInsufficientDigtalDoc = record.NumberOfRosWithInsufficientDigtalDoc__c;
                    questionsList.PercentageNumberOfRosWithInsufficientDigtalDoc = record.PerNumberOfRosWithInsufficientDigtalDoc__c;

                    //inputQuestionList.push(questionsList);


                    //inputQuestionList=questionList;
                    surveyWarrantyQuestionMap.values=questionsList;
                    surveyWarrantySectionQuestionsMapDataTemp[0]=surveyWarrantyQuestionMap;
                    component.set("v.showSpinner", false);
                });
            }
               
			  component.set("v.surveyWarrantySectionQuestionsMapData", surveyWarrantySectionQuestionsMapDataTemp);
        });
        $A.enqueueAction(action);
    },
     */


    
    
    getEvaluationAccountContacts : function(component, event, helper, accountId) {

        var evalContacts = [];
        
        var blankContact = {};
        blankContact.label = '--None--';
        blankContact.value = null;
        evalContacts.push(blankContact);

        var action = component.get("c.retrievEvaluationAccountContacts");
        
        action.setParams({"accountId": accountId });
        action.setCallback(this, function(response) {
            var evaluationContacts = response.getReturnValue();

            evaluationContacts.forEach(evalContact => {
                var contactObject = {};
                //Dhiraj Changes added for Primary contact with Email                     
                contactObject.label = evalContact.Name +' '+evalContact.Email;
                contactObject.value = evalContact.ContactId;
                evalContacts.push(contactObject);
            });
            component.set("v.evaluationAccountContacts", evalContacts);
            helper.getSurveyQuestions(component, event, helper);
        });
        $A.enqueueAction(action);
    },

    getSurveyQuestions : function(component, event, helper){
        var dependentSurveyQuestionsMap = component.get("v.dependentSurveyQuestionsMap");
		var action = component.get("c.getSurveyQuestions");
        var recordId = component.get("v.recordId");

        action.setParams({"recordId": recordId, launchedFromEval : component.get("v.launchedFromEval")});
        action.setCallback(this, function(response) {

            //Logged In user is Admin User of not starts here
            
            var actionSysuser = component.get("c.checkAdminUserOrNot");
            actionSysuser.setCallback(this,function(responseUser){
               component.set("v.sysUser", responseUser.getReturnValue());
            });
            $A.enqueueAction(actionSysuser);

            //Logged In user is Admin User of not ends here
            
            var results = response.getReturnValue();
            var surveyId = results[0].Survey__c;
            component.set("v.surveyId", surveyId);

            // var isAllQuestionsAnswered = component.get("v.isAllQuestionsAnswered"); //DPM-5279 added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
            // console.log('getSurveyQuestions isAllQuestionsAnswered: '+isAllQuestionsAnswered); //DPM-5279 added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
            if(results.length > 0) {
                if(results[0].Survey__r.Status__c == 'Completed') { //DPM-5279 isAllQuestionsAnswered==true: added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
                    component.set("v.isSubmitted", true);
                    component.set("v.showReadonlyPage", true);     
                } 
            }
            var actionDocuments = component.get("c.getContentDocumentsForSurvey");
            actionDocuments.setParams({"surveyId": surveyId});
            actionDocuments.setCallback(this, function(responseDocuments) {

                var resultsDocuments = responseDocuments.getReturnValue();
                var surveyQuestionDocumentsMap = {};
                resultsDocuments.forEach(resultDocument => {
                    surveyQuestionDocumentsMap[resultDocument.LinkedEntityId] = surveyQuestionDocumentsMap[resultDocument.LinkedEntityId] || [];
                    surveyQuestionDocumentsMap[resultDocument.LinkedEntityId].push(resultDocument.ContentDocumentId);
                });

                component.set("v.surveyQuestions", results);
                //this.surveyQuestions = results.data;
                
                let surveySectionsTemp = [];
                let surveySectionQuestionsMapDataTemp = [];
                var surveyQuestionMap = {};
                if(results.length  > 0) {
                    results.forEach(record => {
                        let sectionDescription;
                        let sectionMap = {};
                        let question = {};
                        if(record.Section_Number__c != undefined && record.Section_Number__c != null) {
                            sectionDescription = 'Section ' + record.Section_Number__c
                        }
                        else {
                            sectionDescription = '';
                        }
                    	
                    	question.dependentquestionid = null;
                    	if(record.DependentQuestion__c != undefined && record.DependentQuestion__c != null) {
                            question.dependentquestionid = record.DependentQuestion__c;
                             
                            if(!record.Input_Type__c.includes('Inline Entry')) {                          
                                if(record.DependentQuestion__r.Response_Text__c != null && record.DependentQuestion__r.Response_Text__c != "") {
                                    if(record.DependentQuestionResponse__c != undefined && record.DependentQuestionResponse__c != "") {
                                        question.showquestion = true;
                                        let dependentQuestionAnswersRequiredToShow = record.DependentQuestionResponse__c.split(';');
                                        for(var i=0; i < dependentQuestionAnswersRequiredToShow.length; i++ ) {
                                            var dependendthquestionvalue = dependentQuestionAnswersRequiredToShow[i];

                                            if(!record.DependentQuestion__r.Response_Text__c.includes(dependendthquestionvalue)) {
                                                
                                                question.showquestion = false;
                                            }
                                        }
                                    }
                                    else {
                                        question.showquestion = true;
                                    }
                                }
                                else {
                                    if(record.DependentQuestionResponse__c != undefined && record.DependentQuestionResponse__c != "") {
                                        
                                        question.showquestion = false;
                                    }
                                    else {
                                        question.showquestion = false;
                                    }
                                }
                            }
                            else {
                                question.showquestion = false;
                            }
                        }
                        else {
                            question.showquestion = true;
                        }
                        question.singleOptionSelection = false;
                        question.singleOptionSelectionWithOther = false;
                        question.multipleOptionSelection = false;
                        question.textquestiontype = false;
                        question.numberquestiontype = false;
                        question.singlecheckboxwithentry = false;
                        question.multiselectwithinlineentry = false;
                        question.numerictabular = false;

                    //JDP Changes
                    	question.type = record.Type__c;
                    	
                    	
                    	question.category=record.Category_Type__c;
                    	question.subCategory=record.QuestionSubCategory__c;

                    //JDP Changes Ends here
                        question.section = sectionDescription;
                        question.id = record.Id;
                        question.question = record.Question_Text__c;
                        question.questionNumber = record.Question_Number_Text__c;
                        question.isCarriedOver = record.Is_Carried_Over__c;
                        question.inputType = record.Input_Type__c;
                        question.remarks = record.Remarks__c;
                        question.instructions = record.Instruction_Text__c;
                        
                    
                    	//Warranty Checkbox
                    	question.warrantyReview2022 = record.Survey__r.Warranty_Review_2022__c;
                        //question.warrantyReview2022 = 'True';
                        
                    	component.set("v.warrantyReview2022",question.warrantyReview2022);
                        if (component.get("v.warrantyReview2022")){
                            
                            question.inStoreReview = record.Survey__r.In_Store_Review__c;
                            question.whatIsTheDealersCurrentRO = record.Survey__r.whatIsTheDealersCurrentRO__c;
                            question.howManyROsWereReviewed = record.Survey__r.How_many_ROs_were_reviewed__c;
                            question.howManyROsHadZeroDeficienciesDiscrepancies = record.Survey__r.How_many_ROs_had_zero_defic_discrp__c;
                            question.othersDescribe = record.Survey__r.Others_Describe__c;
                            question.isTheWarrantyCEEROReviewComplete = record.Survey__r.Is_the_Warranty_CEE_RO_Review_complete__c;
                            question.howManyROsHadInsufficientTechNotes = record.How_many_ROs_had_insufficient_tech_notes__c;
                            question.commentsActionPlan = record.Comments_Action_Plan__c;
                        }
                            
                        question.warrantyReviewInstruction2022 = record.Survey__r.Warranty_Review_Instruction_2022__c;
                        question.warrantyReviewDueDateText2022 = record.Survey__r.Warranty_Review_Due_Date_Text_2022__c;
                        question.dueDate = record.Due_Date__c;

                        question.benefits = record.Benefit_Text__c;
                        question.requiredimages = record.Photos_Required__c;
                        question.failvalue = record.Fail_Value__c;
                        question.otherresponsetext = record.Other_Response_Text__c;
                        question.imagerequiredpriortoanswer = record.Image_Required_Prior_To_Answer__c;
                        
                        question.tabularheader1 = '';
                        question.tabularheader2 = '';
                        question.tabularheader3 = null;
                        if(record.Table_Columns__c != undefined && record.Table_Columns__c != null && record.Table_Columns__c != '') {
                            var tabularfields = record.Table_Columns__c.split(';');
                            question.tabularheader1 = tabularfields[0];
                            question.tabularheader2 = tabularfields[1];
                            if(tabularfields.length == 3) {
                                question.tabularheader3 = tabularfields[2];
                            }
                        }
                        
                        question.readonly = false;
                        question.iscalculated = false;
                        //question.
                        if(record.Response_Calculated_From_Inline_Answers__c) {
                            question.readonly = true;
                            question.iscalculated = true;
                        }
                        else if(record.Status__c == 'Submitted') {
                            question.readonly = false;
                        }
                        
                        if(question.instructions != null && question.instructions != "") {
                            question.showinstructions = true;
                        }
                        else {
                            question.showinstructions = false;
                        }

                    
                        if(question.dueDate != null && question.dueDate != "") {
                            question.showdueDate = true;
                        }
                        else {
                            question.showdueDate = false;
                        }

                        if(question.benefits != null  && question.benefits != "") {
                            question.showbenefits = true;
                        }
                        else {
                            question.showbenefits = false;
                        }

                        if(record.RemarksEnabled__c != null) {
                            question.showremarks = true;
                        }
                        else {
                            question.showremarks = false;
                        }
                        
                        if(record.Input_Type__c == 'Picklist (Single Selection)') {
                            question.singleOptionSelection = true;
                            question.options = helper.buildSurveyQuestionOptions(record.InputValues__c, false, record.Response_Text__c); //[{ label: 'Yes', value: 'Yes' },{ label: 'No', value: 'No' }];
                            if(question.iscalculated){
                                question.options.unshift({ label: 'Pending', value: '' })
                            }
                        }
                        else if(record.Input_Type__c == 'Picklist (Single Selection) with Inline Entry with Other Text') {
                            question.singleOptionSelectionWithOther = true;
                            question.options = helper.buildSurveyQuestionOptions(record.InputValues__c, false, record.Response_Text__c);
                            if(question.iscalculated){
                                question.options.unshift({ label: 'Pending', value: '' })
                            }
                        }
                        else if(record.Input_Type__c == 'Picklist (Single Selection) with Inline Entry') {
                            question.singleOptionSelection = true;
                            question.options = helper.buildSurveyQuestionOptions(record.InputValues__c, false, record.Response_Text__c);
                            if(question.iscalculated){
                                question.options.unshift({ label: 'Pending', value: '' })
                            }
                        }
                        else if(record.Input_Type__c == 'Numeric') {
                            question.numberquestiontype = true;
                        }
                        else if(record.Input_Type__c == 'Text') {
                            question.textquestiontype = true;
                        }
                        else if(record.Input_Type__c == 'Multi-Select Picklist') {
                            question.multipleOptionSelection = true;
                            question.options = helper.buildSurveyQuestionOptions(record.InputValues__c, true, record.Response_Text__c);
                            question.question += '(Select All That Apply)';
                        }
                        else if(record.Input_Type__c == 'Multi-Select Picklist with Inline Entry') {
                            question.multiselectwithinlineentry = true;
                            question.options = helper.buildSurveyQuestionOptions(record.InputValues__c, true, record.Response_Text__c);
                        }
                        else if(record.Input_Type__c == 'Single Checkbox Selection with Entry'){
                            question.singlecheckboxwithentry = true;
                        }
                        else if(record.Input_Type__c == 'Numeric Tabular with Inline Entry') {
                            question.numerictabular = true;
                        }
                        if(record.Meet_ALL_Criteria_Check__c) {
                            question.meetAllCriteriaCheck = record.Meet_ALL_Criteria_Check__c;
                        }

                        if(record.Response_Text__c != null) {
                            question.response = record.Response_Text__c;
                        }
                        else {
                            question.response = "";
                        }
                        let responseArray = [];
                        if(question.response != null) {
                            question.response.split(';').forEach(value => {
                                if(value != null && value != "") {
                                    responseArray.push(value);
                                }
                            })
                        }

                        question.responseArray = responseArray;

                        if(surveyQuestionDocumentsMap[question.id]) {
                            question.relatedDocuments = surveyQuestionDocumentsMap[question.id];
                        }
                        else {
                            question.relatedDocuments = [];
                        }

                        if(question.showquestion) {
                            let sectionIndex = surveySectionsTemp.indexOf(sectionDescription);
                            if(sectionIndex == -1) {
                                surveySectionsTemp.push(sectionDescription);
                                sectionMap.key = sectionDescription;
                                sectionMap.values = [];
                                //sectionMap[sectionDescription] = [];
                                sectionMap.values.push(question);
                                surveySectionQuestionsMapDataTemp.push(sectionMap);
								
                            }
                            else {
                            	sectionMap = surveySectionQuestionsMapDataTemp[sectionIndex];
                               	sectionMap.values.push(question);
                                surveySectionQuestionsMapDataTemp[sectionIndex] = sectionMap;
                            }
                        }

                        question.inlinequestions = [];
                        question.inlinequestionstablular = [];
                        question.responsenumber1 = null;
                        question.responsenumber2 = null;
                        question.responsenumber3 = null;
                        if(record.Response_Number__c != null && record.Response_Number__c != undefined && record.Response_Number__c != ""){
                            question.responsenumber1 = record.Response_Number__c;
                        }
                        if(record.Response_Number_2__c != null && record.Response_Number_2__c != undefined && record.Response_Number_2__c != ""){
                            question.responsenumber2 = record.Response_Number_2__c;
                        }

                        if(record.Response_Number_3__c != null && record.Response_Number_3__c != undefined && record.Response_Number_3__c != ""){
                            question.responsenumber3 = record.Response_Number_3__c;
                        }
						
            
			            if(question.dependentquestionid != null) {

                            if(record.Input_Type__c.includes('Inline Entry') || record.Input_Type__c == 'Text' || record.Input_Type__c == 'Numeric' || record.Input_Type__c == 'Date' || record.Input_Type__c == 'Percent'|| record.Input_Type__c == 'Picklist (Single Selection)') {
                                question.showquestion = false;
                                let tempSurveyQuestion = surveyQuestionMap[question.dependentquestionid];

                                if(record.Input_Type__c.includes('Tabular')) {
                                    tempSurveyQuestion.inlinequestionstablular.push(question);
                                }
                                else {
                                    tempSurveyQuestion.inlinequestions.push(question);
                                }
                            }
                            dependentSurveyQuestionsMap[question.dependentquestionid] = dependentSurveyQuestionsMap[question.dependentquestionid] || [];
                            dependentSurveyQuestionsMap[question.dependentquestionid].push(question);
                        }
                        else {
                            surveyQuestionMap[question.id] = question;
                        }
            console.log(question.questionNumber);
            console.log(question);
                    }); 
                }
						
                helper.getContentDocumentIDs(component, event, helper);
                helper.getWarrantyReviewMetadata(component, event, helper);

                component.set("v.surveySections", surveySectionsTemp);
                component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapDataTemp);
                component.set("v.dependentSurveyQuestionsMap", dependentSurveyQuestionsMap);

				
                component.set("v.showSpinner", false);

				//JDP Evaluation Changes start here Getting Category
				var surveyQuestionData = component.get("v.surveySectionQuestionsMapData");
				var categoryList=[];
				var categorySubList=[];

				//getting questionCategory
				for(var i= 0; i < surveyQuestionData.length; i++) {
                	var questionList = surveyQuestionData[i].values;
                    let field='questionNumber';
                    //Sort data

                    Object.values(questionList).forEach(recCategory =>{

                        
                        
                        if(categoryList.length>0){
                        	if(!categoryList.includes(recCategory.category)){
                        		categoryList.push(recCategory.category);
                    		}
                        	
                    		}
                        else{
                        	categoryList.push(recCategory.category);
                    	}
                    });
                    
                }
                
                //getting questionSubCategory
                for(var i= 0; i < surveyQuestionData.length; i++) {
                	var questionList = surveyQuestionData[i].values;
                    Object.values(questionList).forEach(recCategory =>{
                        if(categorySubList.length>0){
                        	if(!categorySubList.includes(recCategory.subCategory)){
                        		categorySubList.push(recCategory.subCategory);
                    		}
                        	
                    	}else{
                            categorySubList.push(recCategory.subCategory);
                    	}
                    });
                    
                }//for loop
                
                
                
                
                component.set("v.surveyCategory",categoryList);
				component.set("v.surveySubCategory",categorySubList);
				
				//JDP Evaluation changes  ends here
				
				
                if(surveySectionsTemp.length > 0) {
                    component.set("v.currentOpenSection", surveySectionsTemp[0]);
                }
                $A.get('e.force:refreshView').fire();

            });
            $A.enqueueAction(actionDocuments);
        });
        $A.enqueueAction(action);
    },
    
    buildSurveyQuestionOptions : function(options, isMulti, selectedValues) {

        var optionValues = options.split(';');
        var returnOptions = [];
        var isPhone = $A.get("$Browser.isPhone");
        optionValues.forEach(option => {
            let returnOption = {};
            returnOption.label = option.trim();
            returnOption.value = option.trim();
            if(isMulti) {
                if(selectedValues != null && selectedValues.includes(option)) {
                    if(isPhone) {
                        returnOption.classVal = 'slds-button slds-button_brand';
                    }
                }
                else {
                    returnOption.classVal = 'slds-button slds-button_neutral';
                }
                if(isPhone) {
                    returnOption.classVal += ' slds-button_stretch';
                }

            }
            returnOptions.push(returnOption);

        });
        return returnOptions;
    },

    validateForm : function(component, event, helper) {

        var errorquestions = [];
        var surveyQuestionsToUpdate = [];
        var currentSection = component.get("v.currentOpenSection");
        var surveySections = component.get("v.surveySections");
        var indexOfCurrentSection = surveySections.indexOf(currentSection);
        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var surveyQuestionsForSection = surveySectionQuestionsMapData[indexOfCurrentSection].values;
       
        var validationerrorsmaplist = [];
        //var validationerrorsmap = {}; 

        var warrantyReviewFileMissingFlag = false;
        var howManyROsWereReviewedMissingFlag = false;
        var howManyROsHadZeroDeficienciesDiscrepanciesFlag = false;
        var otherDescribeMandatoryCheck = false;

        for(var i= 0; i < surveySectionQuestionsMapData.length; i++) {
            
            surveyQuestionsForSection = surveySectionQuestionsMapData[i].values;

            
            surveyQuestionsForSection.forEach(surveyQuestion => {

                var key = surveyQuestion.questionNumber + "-" + surveyQuestion.question;

                if(surveyQuestion.dependentquestionid == null) {
                //Warranty Review 2022 Start
                
                if (component.get("v.warrantyReview2022")) {
                    if (surveyQuestion.response != "" && surveyQuestion.response != null 
                        && surveyQuestion.response != undefined && surveyQuestion.response == 'Yes' && !warrantyReviewFileMissingFlag) {
                            warrantyReviewFileMissingFlag = true;
                    }

                    if ((component.get("v.howManyROsWereReviewed") == null || component.get("v.howManyROsWereReviewed") == undefined
                    || component.get("v.howManyROsWereReviewed") == '') && !howManyROsWereReviewedMissingFlag) {
                        howManyROsWereReviewedMissingFlag = true;
                    }
                    if ((component.get("v.howManyROsHadZeroDeficienciesDiscrepancies") == null || component.get("v.howManyROsHadZeroDeficienciesDiscrepancies") == undefined
                    || component.get("v.howManyROsHadZeroDeficienciesDiscrepancies") == '') && !howManyROsHadZeroDeficienciesDiscrepanciesFlag) {
                        howManyROsHadZeroDeficienciesDiscrepanciesFlag = true;
                    }
                    if ((component.get("v.othersDescribe") == null || component.get("v.othersDescribe") == undefined
                    || component.get("v.othersDescribe") == '') && component.get("v.whatIsTheDealersCurrentRO") == 'Manual filing. No separate VIN Service File. Others – Describe.' 
                   && !otherDescribeMandatoryCheck) {
                        otherDescribeMandatoryCheck = true;
                    } 
                    
                if(surveyQuestion.howManyROsHadInsufficientTechNotes === '' || surveyQuestion.howManyROsHadInsufficientTechNotes === null
                || surveyQuestion.howManyROsHadInsufficientTechNotes === undefined) {
                    var validationerrorsmap = {};
                    var indexoferrorquestion = errorquestions.indexOf(surveyQuestion.id);
                    if(indexoferrorquestion == -1) {
                        errorquestions.push(surveyQuestion.id);
                        validationerrorsmap.key = key;
                        validationerrorsmap.values = ['Missing '+component.get("v.warrantyReviewQuestionsMapTmp")[surveyQuestion.questionNumber]+' Value for ' + surveyQuestion.questionNumber + "-" + surveyQuestion.question];;
                        validationerrorsmaplist.push(validationerrorsmap);
                    }
                    else {
                        validationerrorsmap = validationerrorsmaplist[indexoferrorquestion];
                        var errors = validationerrorsmap[key].values;
                        errors.push('Missing '+component.get("v.warrantyReviewQuestionsMapTmp")[surveyQuestion.questionNumber]+' Value for ' + surveyQuestion.questionNumber + "-" + surveyQuestion.question);
                        validationerrorsmap[key].values = errors;
                        validationerrorsmaplist[indexoferrorquestion] = validationerrorsmap;
                    }
                }
            }

                //Warranty Review 2022 End
                    if((surveyQuestion.response == "" || surveyQuestion.response == null || surveyQuestion.response == undefined) && surveyQuestion.dependentquestionid == null ) {
                        var validationerrorsmap = {};
                        var indexoferrorquestion = errorquestions.indexOf(surveyQuestion.id);
                        if(indexoferrorquestion == -1) {
                            errorquestions.push(surveyQuestion.id);
                            validationerrorsmap.key = key;
                            validationerrorsmap.values = ['Missing Value for ' + surveyQuestion.questionNumber + "-" + surveyQuestion.question];
                            validationerrorsmaplist.push(validationerrorsmap);
                        }
                        else {
                            validationerrorsmap = validationerrorsmaplist[indexoferrorquestion];
                            var errors = validationerrorsmap[key].values;
                            errors.push('Missing Value for ' + surveyQuestion.questionNumber + "-" + surveyQuestion.question);
                            validationerrorsmap[key].values = errors;
                            validationerrorsmaplist[indexoferrorquestion] = validationerrorsmap;
                        }
                    }

                    // added by Soyeon Kim for DPM-4873 remarks error starts / added surveyQuestion.showremarks==true&& by MinheeKim - 2024-08-20 DPM-5633
                    if(surveyQuestion.response == "No" && surveyQuestion.showremarks==true&& (surveyQuestion.remarks == undefined || surveyQuestion.remarks == "" || surveyQuestion.remarks == null)){
                        var validationerrorsmap = {};
                        var indexoferrorquestion = errorquestions.indexOf(surveyQuestion.id);
                        if(indexoferrorquestion == -1) {
                            errorquestions.push(surveyQuestion.id);
                            validationerrorsmap.key = key;
                            validationerrorsmap.values = ['Missing Value for ' + surveyQuestion.questionNumber + "-Remarks"];
                            validationerrorsmaplist.push(validationerrorsmap);
                        }
                        else {
                            validationerrorsmap = validationerrorsmaplist[indexoferrorquestion];
                            var errors = validationerrorsmap[key].values;
                            errors.push('Missing Value for ' + surveyQuestion.questionNumber + "-Remarks");
                            validationerrorsmap[key].values = errors;
                            validationerrorsmaplist[indexoferrorquestion] = validationerrorsmap;
                        }
                    }
                    // added by Soyeon Kim for DPM-4873 remarks error ends

                    if(surveyQuestion.relatedDocuments.length < surveyQuestion.requiredimages  && surveyQuestion.requiredimages != undefined && surveyQuestion.requiredimages != null && surveyQuestion.requiredimages > 0 && surveyQuestion.failvalue != null && surveyQuestion.response != surveyQuestion.failvalue) {
                        var validationerrorsmap = {};
                        var indexoferrorquestion = errorquestions.indexOf(surveyQuestion.id);
                        if(indexoferrorquestion == -1) {
                            errorquestions.push(surveyQuestion.id);
                            validationerrorsmap.key = key;
                            validationerrorsmap.values = ['Missing '+surveyQuestion.requiredimages+' File to Upload for question ' + surveyQuestion.questionNumber + "-" + surveyQuestion.question];;
                            validationerrorsmaplist.push(validationerrorsmap);
                        }
                        else {
                            validationerrorsmap = validationerrorsmaplist[indexoferrorquestion];
                            var errors = validationerrorsmap.values;
                            errors.push('Missing '+surveyQuestion.requiredimages+' File to Upload for ' + surveyQuestion.questionNumber + "-" + surveyQuestion.question);
                            validationerrorsmap.values = errors;
                            validationerrorsmaplist[indexoferrorquestion] = validationerrorsmap;
                        }
            }


                    if(surveyQuestion.inlinequestions != undefined && surveyQuestion.inlinequestions != null && surveyQuestion.inlinequestions.length > 0) {

                        surveyQuestion.inlinequestions.forEach(inlinequestion => {

                            var validationerrorsmap = {};

                            if(inlinequestion.response == undefined || inlinequestion.response == null || inlinequestion.response == "") {

                                var indexoferrorquestion = errorquestions.indexOf(surveyQuestion.id);

                                if(indexoferrorquestion == -1) {
                                    errorquestions.push(surveyQuestion.id);
                                    validationerrorsmap.key = key;

                                    validationerrorsmap.values = ['Missing Value for inline question ' + surveyQuestion.questionNumber + '-' + inlinequestion.question];
                                    validationerrorsmaplist.push(validationerrorsmap);
                                }
                                else {
                                    validationerrorsmap = validationerrorsmaplist[indexoferrorquestion];

                                    var errors = validationerrorsmap.values;

                                    errors.push('Missing Value for inline question ' + surveyQuestion.questionNumber + '-' + inlinequestion.question);

                                    validationerrorsmap.values = errors;
                                    validationerrorsmaplist[indexoferrorquestion] = validationerrorsmap;
                                }
                            }

                        });

                    }


                    if(surveyQuestion.inlinequestionstablular != undefined && surveyQuestion.inlinequestionstablular != null && surveyQuestion.inlinequestionstablular.length > 0) {

                        surveyQuestion.inlinequestionstablular.forEach(inlinequestion => {
                            var validationerrorsmap = {};

                            if(!inlinequestion.iscalculated) {
            
                                if(inlinequestion.responsenumber1 == undefined || inlinequestion.responsenumber1 == null || inlinequestion.responsenumber1 == "" || inlinequestion.responsenumber2 == undefined || inlinequestion.responsenumber2 == null || inlinequestion.responsenumber2 == "") {
                                    var indexoferrorquestion = errorquestions.indexOf(surveyQuestion.id);

                                    if(indexoferrorquestion == -1) {

                                        errorquestions.push(surveyQuestion.id);
                                        validationerrorsmap.key = key;
                                        validationerrorsmap.values = ['Missing Value for inline question ' + surveyQuestion.questionNumber + '-' + inlinequestion.question];
                                        validationerrorsmaplist.push(validationerrorsmap);

                                    }
                                    else {
                                        validationerrorsmap = validationerrorsmaplist[indexoferrorquestion];


                                        var validationerrors = validationerrorsmap.values;

                                        validationerrors.push('Missing Value for inline question ' + surveyQuestion.questionNumber + '-' +  inlinequestion.question);
                                        validationerrorsmap.values = validationerrors;
                                        validationerrorsmaplist[indexoferrorquestion] = validationerrorsmap;

                                    }
                                } 
                            }
                        });
                    }  
                }
            });

            if (component.get("v.warrantyReview2022")) {
                var validationerrorsmap = {};

                if (component.get("v.isTheWarrantyCEEROReviewCompleteFlag") 
                && component.get("v.warrantyCEEROReviewExcelFileDocuments").length == 0) {
                    validationerrorsmap = {};
                    //validationerrorsmap.key = 'Warranty CEE RO Review Excel File';
                    validationerrorsmap.values = ['Missing file for Warranty RO Review Excel File '];
                    validationerrorsmaplist.push(validationerrorsmap);
                }
                if (warrantyReviewFileMissingFlag) {

                    if (component.get("v.ROReviewActionPlan").length == 0 && !component.get("v.hasCommentsActionPlan")) {
                        validationerrorsmap = {};
                        //validationerrorsmap.key = 'RO Review Action Plan';
                        validationerrorsmap.values = ['Missing file for RO Review Action Plan '];
                        validationerrorsmaplist.push(validationerrorsmap);
                    }
                   /* if (component.get("v.WOPRActionPlanWOPRScoreBelowAvg").length == 0) {
                        validationerrorsmap = {};
                        validationerrorsmap.values = ['Missing file for WOPR Action Plan, WOPR score below average '];
                        validationerrorsmaplist.push(validationerrorsmap);
                    }
                    if (component.get("v.otherWOPRActionPlan").length == 0) {
                        validationerrorsmap = {};
                        validationerrorsmap.values = ['Missing file for Other WOPR Action Plan '];
                        validationerrorsmaplist.push(validationerrorsmap);
                    }*/
                 }

                 if (howManyROsWereReviewedMissingFlag) {
                    validationerrorsmap = {};
                    validationerrorsmap.values = ['Missing Value for How Many ROs Were Reviewed '];
                    validationerrorsmaplist.push(validationerrorsmap);
                 }

                 if (howManyROsHadZeroDeficienciesDiscrepanciesFlag) {
                    validationerrorsmap = {};
                    validationerrorsmap.values = ['Missing Value for How many ROs had zero (0) deficiencies/discrepancies? '];
                    validationerrorsmaplist.push(validationerrorsmap);
                 }
                  if (otherDescribeMandatoryCheck) {
                    validationerrorsmap = {};
                    validationerrorsmap.values = ['Missing Value for Others-Describe '];
                    validationerrorsmaplist.push(validationerrorsmap);
                  }
   
				
            }
            if(validationerrorsmaplist.length > 0) {

                component.set("v.validationErrorsMapList", validationerrorsmaplist);
                
                helper.handleShowErrorsModal(component, event, helper);
                //component.set("v.showErrorsModal", true);
                //component.set("v.showSpinner", false);
            }
            else {
                component.set("v.showSpinner", false);
                component.set("v.showReadonlyPage", true);
                component.set("v.validationErrorsMapList", []);
                component.set("v.showErrorsModal", false);
                //helper.saveSectionQuestions(component, event, helper, true, false);
            }
        }
        //
    },

    submitSurvey : function(component, event, helper) {
        //component.set("v.showSpinner", false);
        // helper.saveSectionQuestions(component, event, helper, false, true);
        helper.getCompleteAccess(component, event, helper, false, true);

    },

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-01-17] for [DPM-5264]
     * Edited by [MinheeKim] on [2024-02-21] for [DPM-5381] added error message for the situation that auto-completion occured
     * 
    */
    saveSectionQuestions : function(component, event, helper, gotonext, submit) {
        var surveyQuestionsToUpdate = [];
        var currentSection = component.get("v.currentOpenSection");
        var surveySections = component.get("v.surveySections");
        var indexOfCurrentSection = surveySections.indexOf(currentSection);
        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var surveyQuestionsForSection = surveySectionQuestionsMapData[indexOfCurrentSection].values;
        component.set("v.hasCommentsActionPlan",false);
        var surveyId = component.get('v.surveyId');

        for(var i= 0; i < surveySectionQuestionsMapData.length; i++) {
            surveyQuestionsForSection = surveySectionQuestionsMapData[i].values;
            surveyQuestionsForSection.forEach(record => {
                var surveyQuestion;
                if(record.inlinequestions.length > 0) {
                    record.inlinequestions.forEach(inlinequestion => {
                        surveyQuestion = {};
                        surveyQuestion.Id = inlinequestion.id;
                        surveyQuestion.Response_Text__c = inlinequestion.response;
                        surveyQuestion.Response__c = inlinequestion.response;
                        surveyQuestion.Other_Response_Text__c = inlinequestion.otherresponsetext;
                        surveyQuestion.Survey__c = surveyId;
                        surveyQuestion.DependentQuestion__c = inlinequestion.dependentquestionid != null ? inlinequestion.dependentquestionid : null ;

                        if(submit) {
                            surveyQuestion.Status__c = 'Submitted';
                        }
                        surveyQuestionsToUpdate.push(surveyQuestion);
                    });
                }
                if(record.inlinequestionstablular.length > 0) {

                    record.inlinequestionstablular.forEach(inlinequestiontabular => {
                        surveyQuestion = {};

                        surveyQuestion.Id = inlinequestiontabular.id;
                        surveyQuestion.Response_Number__c = inlinequestiontabular.responsenumber1;
                        surveyQuestion.Response_Number_2__c = inlinequestiontabular.responsenumber2;
                        surveyQuestion.Response_Number_3__c = inlinequestiontabular.responsenumber3;
                        if(submit) {
                            surveyQuestion.Status__c = 'Submitted';
                        }
                        surveyQuestionsToUpdate.push(surveyQuestion);
                    });
                }
                surveyQuestion = {};
                surveyQuestion.Id = record.id;
                
                surveyQuestion.Response_Text__c = record.response;
                surveyQuestion.Response__c = record.response;
                surveyQuestion.Remarks__c = record.remarks;
                surveyQuestion.Survey__c = surveyId;
                surveyQuestion.DependentQuestion__c = record.dependentquestionid != null ? record.dependentquestionid : null ;

                if (component.get("v.warrantyReview2022")) {

                    if(record.response != "" && record.response != null 
                        && record.response != undefined && record.response == 'No'){
                            surveyQuestion.How_many_ROs_had_insufficient_tech_notes__c = 0;
                    } else {
                        surveyQuestion.How_many_ROs_had_insufficient_tech_notes__c = record.howManyROsHadInsufficientTechNotes;
                    }
                    surveyQuestion.Comments_Action_Plan__c = record.commentsActionPlan;

                    if (record.response != "" && record.response != null 
                    && record.response != undefined && record.response == 'Yes' 
                    && record.commentsActionPlan != null && record.commentsActionPlan != undefined 
                    && record.commentsActionPlan != '' && !component.get("v.hasCommentsActionPlan")) {
                        component.set("v.hasCommentsActionPlan",true);
                    } 
                    

                }

                if(surveyQuestion.numberquestiontype) {
                    surveyQuestion.Response_Number__c =  record.response;
                }
                if(submit) {
                    surveyQuestion.InitialResponseText__c = record.response;
                    surveyQuestion.Status__c = 'Submitted';
                }
                surveyQuestionsToUpdate.push(surveyQuestion);
            });
        }

        //DPM-5069
        //Check if the survey is completed or not
    
                    var action = component.get("c.updateSurveyQuestions");
                    var deletedFileMapData = component.get("v.deletedFileMapData"); //DPM-5302 Check whether the file is attached to the survey question
                    console.log(submit);
            //        submit = true;
                    action.setParams({
                        "surveyQuestionsJSON": JSON.stringify(surveyQuestionsToUpdate, null, 5)
                        , "isSubmit" : submit
                        ,"deletedFileId" :deletedFileMapData //DPM-5302 added to DPM-5302 Check whether the file is attached to the survey question
                    });
                
                    /*
                    Test for Original Code
                    */
            //        action.setParams({
            //            "surveyQuestionsJSON": JSON.stringify(surveyQuestionsToUpdate, null, 5)
            //        });
                    action.setCallback(this, function(response) {
                        if(submit) { 
                            var survey = {};
                            survey.Id = component.get("v.surveyId");
                            survey.Status__c = 'Completed';
                            if (component.get("v.warrantyReview2022")) {
                                survey.In_Store_Review__c = component.get("v.inStoreReview");
                                survey.whatIsTheDealersCurrentRO__c = component.get("v.whatIsTheDealersCurrentRO");
                                survey.Is_the_Warranty_CEE_RO_Review_complete__c = component.get("v.isTheWarrantyCEEROReviewComplete");
                                survey.How_many_ROs_were_reviewed__c = component.get("v.howManyROsWereReviewed");
                                survey.How_many_ROs_had_zero_defic_discrp__c = component.get("v.howManyROsHadZeroDeficienciesDiscrepancies");
                                survey.Others_Describe__c = component.get("v.othersDescribe");
                            }
                            var actionSubmitSurvey = component.get("c.updateSurvey");
                            actionSubmitSurvey.setParams({"surveyJSON": JSON.stringify(survey, null, 5)});
                            actionSubmitSurvey.setCallback(this, function(responseSurvey) { 
                                var result = responseSurvey.getReturnValue();
                                console.log('updateSurvey result: '+result);
                                component.set("v.showSpinner", false);
                                //DPM-5279 added to prevent auto-submitted when the survey is not done by MH - 2024.02.10
                                component.set("v.isSubmitted", result); //Editted DPM-5279 true --> result
                                component.set("v.isAllQuestionsAnswered", result); //Added DPM-5279
                                component.set("v.hasEditAccess", !result);//Editted DPM-5279 false --> result
                                component.set("v.showReadonlyPage", result);//Added DPM-5279
                                console.log('updateSurvey hasEditAccess: '+component.get("v.hasEditAccess"));
                                console.log('updateSurvey showReadonlyPage: '+component.get("v.showReadonlyPage"));
                                //DPM-5279 changed end

                                //DPM-5381 added error message by Minhee - 24.02.21
                                if(!result){
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Error",
                                        "message":$A.get("$Label.c.AutoCompletedError") ,
                                        "type": "error"
                                    }); 
                                    toastEvent.fire()
                                                                        
                                }//DPM-5381 added error message


                                //closes the modal or popover from the component
                                //component.find("overlayLib").notifyClose();
                                //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                //dismissActionPanel.fire();
                                if (component.get("v.warrantyReview2022")) {
                                helper.getEvaluationDetails(component, event, helper);
                                helper.getSurveyQuestions(component,event,helper);
                                }
                                $A.get('e.force:refreshView').fire();

                            });
                            $A.enqueueAction(actionSubmitSurvey);
                        }
                        else {
                            helper.saveDeletedFile(component, event, helper); //DPM-5264
                            helper.validateForm(component, event, helper);

                            //if(gotonext) {
                            //    component.set("v.showReadonlyPage", gotonext);
                        // }
                            //else {
                                //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                //dismissActionPanel.fire();
                            //    $A.get('e.force:refreshView').fire();
                                //window.location = '/' + component.get("v.recordId");
                            //}
                        }
                        /*if((indexOfCurrentSection + 1) == surveySections.length) {
                            alert("Finished");
                        }
                        else {
                            var nextIndex = indexOfCurrentSection + 1;
                            var nextSection = surveySections[nextIndex];
                            component.set("v.currentOpenSection", nextSection);
                        }
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();*/
                    });
                    $A.enqueueAction(action);
                    component.set("v.hasCompleteAccess", false);
               
          
        
    },

    // added by Soyeon Kim for DPM-4874
    helperFun : function(component,event,sectionName, sectionIndex) {
        var sectionText = sectionName + 'text' + sectionIndex;
        var addComp = sectionName + 'add' + sectionIndex;
        var dashComp = sectionName + 'dash' + sectionIndex;
        var childSectionText = document.querySelector('[data-id="'+sectionText+'"]');
        var childAddComp = document.querySelector('[data-id="'+addComp+'"]');
        var childDashComp = document.querySelector('[data-id="'+dashComp+'"]');

        if(childSectionText){
            childSectionText.classList.toggle('slds-show');
            childSectionText.classList.toggle('slds-hide');
        }
        if(childAddComp){
            childAddComp.classList.toggle('slds-show');
            childAddComp.classList.toggle('slds-hide');
        }
        if(childDashComp){
            childDashComp.classList.toggle('slds-show');
            childDashComp.classList.toggle('slds-hide');
        }

        /*var sectionText = component.find(sectionName + 'text');
        console.log(sectionText);
        if($A.util.isArray(sectionText)) {
            console.log(sectionText);
            $A.util.toggleClass(sectionText[sectionIndex], 'slds-show');
            $A.util.toggleClass(sectionText[sectionIndex], 'slds-hide');
        }
        else {
            $A.util.toggleClass(sectionText, 'slds-show');
            $A.util.toggleClass(sectionText, 'slds-hide');
        }

        var addComp = component.find(sectionName + 'add');

        if($A.util.isArray(addComp)) {
            $A.util.toggleClass(addComp[sectionIndex], 'slds-show');
            $A.util.toggleClass(addComp[sectionIndex], 'slds-hide');
        }

        else {
            $A.util.toggleClass(addComp, 'slds-show');
            $A.util.toggleClass(addComp, 'slds-hide');
        }

        var dashComp = component.find(sectionName + 'dash');

        if($A.util.isArray(dashComp)) {
            $A.util.toggleClass(dashComp[sectionIndex], 'slds-show');
            $A.util.toggleClass(dashComp[sectionIndex], 'slds-hide');
        }
        else {
            $A.util.toggleClass(dashComp, 'slds-show');
            $A.util.toggleClass(dashComp, 'slds-hide');
        }*/
    },

    handlerChildInstructions : function(component,event,sectionName, sectionIndex, inlineIndex) {
        var sectionText = sectionIndex + 'text' + inlineIndex;
        var addComp = sectionIndex+'add'+inlineIndex;
        var dashComp = sectionIndex+'dash'+inlineIndex;
        var childSectionText = document.querySelector('[data-id="'+sectionText+'"]');
        var childAddComp = document.querySelector('[data-id="'+addComp+'"]');
        var childDashComp = document.querySelector('[data-id="'+dashComp+'"]');

        if(childSectionText){
            childSectionText.classList.toggle('slds-show');
            childSectionText.classList.toggle('slds-hide');
        }
        if(childAddComp){
            childAddComp.classList.toggle('slds-show');
            childAddComp.classList.toggle('slds-hide');
        }
        if(childDashComp){
            childDashComp.classList.toggle('slds-show');
            childDashComp.classList.toggle('slds-hide');
        }
    },

    handleShowErrorsModal: function(component, event, helper) {
        var modalBody;
        var modalFooter;
        $A.createComponents([["c:surveyValidationErrors", {validationErrorsMapList : component.get("v.validationErrorsMapList")}], 
                                ["c:surveyValidationErrorsFooter",{}]],
           function(components, status) {
               component.set("v.showSpinner", false);
               if (status === "SUCCESS") {
                   modalBody = components[0];
                   modalFooter = components[1];

                   component.find('overlayLib').showCustomModal({
                       header: "Error(s)",
                       body: modalBody,
                       footer: modalFooter,
                       showCloseButton: true,
                       cssClass: "mymodal",
                       closeCallback: function() {
                          
                       }
                   })
               }
               else {
                    component.set("v.showSpinner", false);
               }
        });
    },

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [Minhee Kim] on [2024-04-17] for [DPM-5507] added to show modal body and footer when re-click the complete survey button.
    */
    handleShowSubmitModal: function(component, event, helper) {
        //DPM-5507 added to show modal body and footer when re-click the complete survey button.
        /**
         * [Method Description] 
         * Created by [Author] on [Date] for [Ticket #]
         * Edited by [JH Kim] on [2024-07-01] for [DPM-5610] createComponents add message
        */
        var recordId = component.get("v.recordId");
        console.log("5610 recordId => "+ recordId);  // Eval Obj

        // $A.createComponents([
        //     ["c:surveySubmittedModal", {"message": "You attached images exceeding 30MB in total, causing a failure to the PDF generation function. Please adjust the file size before you proceed to allow PDF generation."}],
        //     ["c:surveySubmittedModalFooter", {}]
        // ], function(components, status) {
        //     //component.set("v.showSpinner", false);
        //         if (status === "SUCCESS") {
        //             modalBody = components[0];
        //             modalFooter = components[1];

        //             component.set("v.modalBody", modalBody);
        //             component.set("v.modalFooter", modalFooter);
        //         }
        //         else {
        //         }
        // });

            /**DPM-5610 start by MinheeKim */
 
            var action = component.get("c.launchQueueableForEvaluationGeneration");
            action.setParams({ "surveyId" : component.get("v.surveyId")}); 
           
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    const result = response.getReturnValue();
                    var fileSizeMessage = `Total File Size: ${result} MB`;

                    $A.createComponent(
                        "lightning:formattedText",
                        { value: fileSizeMessage },
                        function (modalBody, status, errorMessage) {
                            if (status === "SUCCESS") {
                                // Use the dynamically created component as modal body
                                component.find("overlayLib").showCustomModal({
                                    header: "Confirm Complete Survey",
                                    body: modalBody, // Dynamically created component
                                    footer: component.get("v.modalFooter"), // Footer as is
                                    showCloseButton: true,
                                    cssClass: "mymodal",
                                    closeCallback: function () {
                                        console.log("Modal closed");
                                    },
                                });
                            } else {
                                console.error("Error creating modal body:", errorMessage);
                            }
                        }
                    );
                    component.set("v.showSpinner", false);//DPM-5507 added to prevent infinite loading by MinheeKim

                } else {
                    console.error("Failed to fetch file size:", response.getError());
                }
                
            });
                $A.enqueueAction(action);
            /**DPM-5610 end by MinheeKim */

        //DPM-5507 end
        // var modalBody = component.get("v.modalBody");
        // var modalFooter = component.get("v.modalFooter");

        // component.find('overlayLib').showCustomModal({
        //     header: "Confirm Complete Survey",
        //     body: modalBody,
        //     footer: modalFooter,
        //     showCloseButton: true,
        //     cssClass: "mymodal",
        //     closeCallback: function() {
               
        //     }
        // })

        // component.set("v.showSpinner", false);//DPM-5507 added to prevent infinite loading by MinheeKim

    },


    getContentDocumentIDs : function(component, event, helper){

        if (component.get("v.warrantyReview2022")){

        var action = component.get("c.getContentDocuments");
        action.setParams({ "surveyId" : component.get("v.surveyId")}); 
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {

               var firstList = [];
               var secondList = [];
               var thirdList = [];
               var fourthList = [];
                var contDocsMap = response.getReturnValue();
                for(var key in contDocsMap){
                    firstList = contDocsMap["Warranty_CEE_RO_Review_Excel_File__c"];
                    secondList = contDocsMap["RO_Review_Action_Plan__c"];
                    thirdList = contDocsMap["WOPR_Action_Plan_WOPR_score_below_avg__c"];
                    fourthList = contDocsMap["Other_WOPR_Action_Plan__c"];
                    
                }
                component.set("v.warrantyCEEROReviewExcelFileDocuments",firstList);
                component.set("v.ROReviewActionPlan",secondList);
                component.set("v.WOPRActionPlanWOPRScoreBelowAvg",thirdList);
                component.set("v.otherWOPRActionPlan",fourthList);
                
            }
            
		});
            $A.enqueueAction(action);
        }
    },

    getWarrantyReviewMetadata : function(component,event,helper) {
        if (component.get("v.warrantyReview2022")){
           
            var action = component.get("c.getWarrantyReviewMetadata");
            action.setCallback(this, function(response) {
                var state = response.getState();

                if (state == "SUCCESS") {
                    var quesLabelMap = [];
                    const map1 = new Map();
                    var result = response.getReturnValue();

                    if (result != '' && result != null && result != null) {
                        result.forEach(vals => {
                            var quesLabel = {};
                            quesLabel.key = (vals.Question_Number__c).toString();;
                            quesLabel.values = vals.Question_Label__c;
                            map1[vals.Question_Number__c] = vals.Question_Label__c;
                            quesLabelMap.push(quesLabel);
                        });
                    }

                    component.set("v.warrantyReviewQuestionsMap",quesLabelMap);
                    component.set("v.warrantyReviewQuestionsMapTmp",map1);

                }
            });
            $A.enqueueAction(action);
        }
    }
})