({
    doInit : function(component, event, helper) {
        var modalBody;
        var modalFooter;
        

        $A.createComponents([
            ["c:surveySubmittedModal", {}],
            ["c:surveySubmittedModalFooter", {}]
        ], function(components, status) {
            //component.set("v.showSpinner", false);
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];

                    component.set("v.modalBody", modalBody);
                    component.set("v.modalFooter", modalFooter);
                }
                else {
                }
        });

        console.log('do init');
        component.set("v.isMobile", $A.get("$Browser.isPhone"));
        //helper.getEvaluationDetails(component, event, helper);
        //helper.getRecordAccess(component, event, helper);
        //helper.getSurveySize(component, event, helper); //changed to comment by MH


        //Dhiraj Warranty Review DPM-4390
        //temporary annotation by Soyeon for deploy DPM-4602

        var action = component.get("c.retrieveEvaluationDetails");
        var recordId = component.get("v.recordId");

        action.setParams({"recordId": recordId, launchedFromEval : component.get("v.launchedFromEval")});
        action.setCallback(this, function(response) {
        //Spinner value to true
        //component.set("v.showSpinner", true);

        var evaluation = response.getReturnValue();
            
        component.set("v.warrantyReview22", evaluation.Survey__r.X22_Warranty_Review__c);

        if(component.get("v.warrantyReview22")){
            var action = component.get("c.getHasEditAccessToRecord");
            //var recordId = component.get("v.recordId");
            var recordId = evaluation.Survey__c;
             // var recordId ='';
            action.setParams({"recordId": recordId});
            action.setCallback(this, function(response) {
                var result = response.getReturnValue();
                component.set("v.hasEditAccess", result);
               // helper.getEvaluationDetails(component, event, helper);
            });
            $A.enqueueAction(action);

            helper.getWarrantySurveyQuestions(component,event,helper);
        }else if(evaluation.Evaluation_Type__c.includes('Warranty RO Review')){ /**Start : DPM-5871 added else if by Minhee Kim 01.21.2025 */
            component.set("v.customError", []);
            helper.getWarrantySurveyQuestions(component,event,helper);
        } /**End : DPM-5871 added else if by Minhee Kim 01.21.2025 */
        else{

            if(component.get("v.launchedFromEval")) {
                helper.getEvaluationDetails(component, event, helper);
            }
            else {
                helper.getSurveyQuestions(component, event, helper);
            }
        }

        });
        
        $A.enqueueAction(action);

        //Old code
        /*
        if(component.get("v.launchedFromEval")) {
            helper.getEvaluationDetails(component, event, helper);
        }
        else {
            helper.getSurveyQuestions(component, event, helper);
        }*/
        
        //helper.getSurveyQuestions(component, event, helper);
        
    },
    
    //Dhiraj Warranty Review DPM-4390 Edit button
    handleEditButonClickRecordOpen : function(component, event, helper) {
        component.set("v.showReadonlyPage", false);
        component.set("v.hasEditAccess", true);
        //$A.get('e.force:refreshView').fire();
    },

    //Dhiraj Warranty Review Save Button  DPM-4390        
    handleWarrantySaveClick:function(component,event,helper){
        component.set("v.showSpinner", true);
        var warrantyStatus ='Saved';
        helper.saveWarrantyData(component,event,helper,warrantyStatus);
    },
    
    //Dhiraj Warranty Review Save Button  DPM-4390        
    handleWarrantyCompleteSurvey:function(component,event,helper){
        component.set("v.showSpinner", true);
        component.set('v.showReadonlyPage',false);
        var warrantyStatus ='Completed';
        helper.saveWarrantyData(component,event,helper,warrantyStatus);
    },
    
    handleToggleSection : function(component, event, helper) {

    },

    handleResubmitClick : function(component, event, helper) {
        var evaluationId = component.get("v.evaluation.Id");

        var action = component.get("c.resubmitForApproval");
        action.setParams({"evaluationId": evaluationId});
        action.setCallback(this, function(response) { 
            helper.getEvaluationDetails(component, event, helper); 
            component.set("v.hasEditAccess", false);
        });
        $A.enqueueAction(action);
    },

    handleSaveEvaluationDetailsClick : function(component, event, helper) {

        component.set("v.showSpinner", true);
        // var evalObject = {};
        // evalObject.Id = component.get("v.evaluation.Id");
        // evalObject.PrimaryContactName__c = component.get("v.primaryContactName");
        // evalObject.PrimaryContactDate__c = component.get("v.primaryContactDate");
        // evalObject.PrimaryContact__c = component.get("v.primaryContact");
        // evalObject.No_Review_Needed__c = component.get("v.noReviewNeeded");

        //DPM-5069 added condition to check survey completed - by MH - 2023.10.25
        // var action = component.get("c.saveEvaluationDetails");
        // action.setParams({"evaluationJSONString": JSON.stringify(evalObject)});
        // action.setCallback(this, function(response) { 
        //     $A.get('e.force:refreshView').fire();
        //     helper.getEvaluationDetails(component, event, helper);
        // });
        // $A.enqueueAction(action);              
        helper.checkContactSaved(component, event, helper);
    },

    handleDocumentUploadFinished : function(component, event, helper) {
        var documentIds = event.getParam("documentIds");
        var parentId = event.getParam("parentId");

        var surveyQuestionsToUpdate = [];
        var currentSection = component.get("v.currentOpenSection");
        var surveySections = component.get("v.surveySections");
        var indexOfCurrentSection = surveySections.indexOf(currentSection);
        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var surveyQuestionsForSection = surveySectionQuestionsMapData[indexOfCurrentSection].values;

        surveyQuestionsForSection.forEach(question => {

            if(parentId == question.id) {
                var relatedDocuments = question.relatedDocuments;
                documentIds.forEach(documentId => {
                    relatedDocuments.push(documentId);
                });
                question.relatedDocuments = relatedDocuments;
            }
        });
        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData);
    },

    handleNextClicked : function(component, event, helper) {
        helper.saveSectionQuestions(component, event, helper);
    },

    /**
    @description : Add yes/no action to all Survey Questions
    @lastModifiedby : yc.park@solomontech.net
    @lastModifiedDate : 23/07/24
    */
    handleAllRadioOptionChanged : function(component, event, helper){
        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var value = event.getSource().get('v.name');
        if(!$A.util.isEmpty(surveySectionQuestionsMapData)){
            var i = 0;
            var TotalArray = surveySectionQuestionsMapData[0].values;

            for(var i = 0; i<TotalArray.length; i++){
                // Set Parent Question to params

                TotalArray[i].response = value;

                // Set Inline Question to params
                var inlinequestions = TotalArray[i].inlinequestions;
                if(!$A.util.isEmpty(inlinequestions)){
                    for(var j = 0; j<inlinequestions.length;j++){
                        inlinequestions[j].response = value;
                    }
                }
            }
        }

        component.set('v.surveySectionQuestionsMapData', surveySectionQuestionsMapData);
    },

    /*
    @Description : Parent Question Radio Button Action
    @Last Modified by : yc.park@solomontech.net
    @Last Modified Date : -
    @Logs

    **/
    handleRadioOptionChanged : function(component, event, helper) {
        //isRadioChanged: function(component, event) {
            //component.set("v.radioValue", );
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var questionToUpdate = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];
        questionToUpdate.response = event.getParam("value");

        var dependentSurveyQuestionsMap = component.get("v.dependentSurveyQuestionsMap");

        //Dhiraj already commented code starts here
        /*if(dependentSurveyQuestionsMap[questionToUpdate.id]) {
            var dependquestions = dependentSurveyQuestionsMap[questionToUpdate.id];
            dependquestions.forEach(dependentquestion => {
                dependentquestion.showquestion = !dependentquestion.showquestion;
            });
        }*/
        
        //Dhiraj commented code ends here

        component.set("v.dependentSurveyQuestionsMap", dependentSurveyQuestionsMap);

        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData);
        //},
    },

    /*
    @Description : Child Question Radio Button Action
    @Last Modified by : yc.park@solomontech.net
    @Last Modified Date : 23/08/02
    @Logs
        1) 23/08/02 :  Child Question Radio Button Click Action 추가 -> Ticket 4754

    **/
    handleInlineRadioOptionChanged : function(component, event, helper) {
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');
        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var parentquestion = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];
        var questionToUpdate = parentquestion.inlinequestions[sectionQuestionArray[2]];
        questionToUpdate.response = event.getParam("value");
        var remarkId = sectionQuestionArray[0]+'-'+sectionQuestionArray[1]+'-remark';
        
        var incomplete = false;
        var failed = false;
        var meetAllCriteriaCheck = false;

        if(parentquestion.iscalculated) {

            if(questionToUpdate.response != "Other") {
                questionToUpdate.otherresponsetext = "";
            }

            for(var i=0; i < parentquestion.inlinequestions.length; i++) {
                var inlinequestion = parentquestion.inlinequestions[i];

                if(inlinequestion.response == undefined || inlinequestion.response == null || inlinequestion.response == "") {
                    incomplete = true;
                }
                else if(inlinequestion.response == inlinequestion.failvalue) {
                    failed = true;
                }
                else if(inlinequestion.response == "Other" && (inlinequestion.otherresponsetext == null || inlinequestion.otherresponsetext == "")) {
                    incomplete = true;
                }
                else if(inlinequestion.meetAllCriteriaCheck &&inlinequestion.response != inlinequestion.failvalue) {
                    meetAllCriteriaCheck = true;
                }
            }

            for(var i=0; i < parentquestion.inlinequestionstablular.length; i++) { 
                var inlinequestion = parentquestion.inlinequestionstablular[i];

                if(!inlinequestion.iscalculated){
                    if(inlinequestion.responsenumber1 == undefined || inlinequestion.responsenumber1 == null || inlinequestion.responsenumber1 == "" && !inlinequestion.iscalculated) {
                        incomplete = true;
                    }
    
                    if(inlinequestion.responsenumber2 == undefined || inlinequestion.responsenumber2 == null || inlinequestion.responsenumber2 == "" && !inlinequestion.iscalculated) {
                        incomplete = true;
                    }
    
                    if(parentquestion.tabularheader3 != null) {
                        if(inlinequestion.responsenumber3 == undefined || inlinequestion.responsenumber3 == null || inlinequestion.responsenumber3 == "" && !inlinequestion.iscalculated) {
                            incomplete = true;
                        }
                    }
                }
            }

            if(failed) {
                parentquestion.response = 'No';
            }
            else if(incomplete) {
                parentquestion.response = '';
            }
            else {
                parentquestion.response = 'Yes';
            }
            if(meetAllCriteriaCheck){
                parentquestion.response = 'Yes';
            }

        }

        // Ticket - 4754
        if(!$A.util.isEmpty(parentquestion.inlinequestions)){
            var isAllYes = true;

            parentquestion.inlinequestions.forEach(e=>{
                if(e.response == 'No') isAllYes = false;
            })

            // All Child Question is 'Yes' -> Parent Question Set 'Yes'
            if(isAllYes){
                parentquestion.response = 'Yes';
            }
            // Any Child Question is 'No' -> Parent Question Set 'No'
            if(!isAllYes){
                parentquestion.response = 'No';
            }
        }

        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData);
        //questionToUpdate.response = event.getParam("value");
    },

    handleOtherTextValueChanged : function(component, event, helper) {
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var parentquestion = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];

        var questionToUpdate = parentquestion.inlinequestions[sectionQuestionArray[2]];

        var incomplete = false;
        var failed = false;
        if(parentquestion.iscalculated) {

            for(var i=0; i < parentquestion.inlinequestions.length; i++) {
                var inlinequestion = parentquestion.inlinequestions[i];

                if(inlinequestion.response == undefined || inlinequestion.response == null || inlinequestion.response == "") {
                    incomplete = true;
                }
                else if(inlinequestion.response == inlinequestion.failvalue) {
                    failed = true;
                }
                else if(inlinequestion.response == "Other" && (inlinequestion.otherresponsetext == null || inlinequestion.otherresponsetext == "")) {
                    incomplete = true;
                }
            }
            
            if(failed) {
                parentquestion.response = 'No';
            }
            else if(incomplete) {
                parentquestion.response = '';
            }
            else {
                parentquestion.response = 'Yes';
            }
        }
        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData);

    },

    numericTabularChange : function(component, event, helper) {
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var parentquestion = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];

        var questionToUpdate = parentquestion.inlinequestionstablular[sectionQuestionArray[2]];

        var total1 = 0;
        var total2 = 0;
        var total3 = 0
        var calculatedrow;

        var hasIncompleteQuestions = false;
        var hasFailedQuestions = false;

        for(var i=0; i < parentquestion.inlinequestionstablular.length; i++) {
            var inlinequestion = parentquestion.inlinequestionstablular[i];

            if(!inlinequestion.iscalculated){
                if(inlinequestion.responsenumber1 == undefined || inlinequestion.responsenumber1 == null || inlinequestion.responsenumber1 == "" && !inlinequestion.iscalculated) {
                    hasIncompleteQuestions = true;
                    //alert('1');
                }

                if(inlinequestion.responsenumber2 == undefined || inlinequestion.responsenumber2 == null || inlinequestion.responsenumber2 == "" && !inlinequestion.iscalculated) {
                    hasIncompleteQuestions = true;
                    //alert('2');
                }

                if(parentquestion.tabularheader3 != null) {
                    if(inlinequestion.responsenumber3 == undefined || inlinequestion.responsenumber3 == null || inlinequestion.responsenumber3 == "" && !inlinequestion.iscalculated) {
                        hasIncompleteQuestions = true;
                        //alert('3');
                    }
                }
            }

            if(!inlinequestion.iscalculated) {
                if(inlinequestion.responsenumber1 != undefined && inlinequestion.responsenumber1 != null && inlinequestion.responsenumber1 != "" ) {
                    total1 = total1 + parseFloat(inlinequestion.responsenumber1);
                }
                if(inlinequestion.responsenumber2 != undefined && inlinequestion.responsenumber2 != null && inlinequestion.responsenumber2 != "") {
                    total2 = total2 + parseFloat(inlinequestion.responsenumber2);
                }
                
                if (inlinequestion.responsenumber1 != null && inlinequestion.responsenumber1 != undefined && inlinequestion.responsenumber2 != null && inlinequestion.responsenumber2 != undefined && /^\d+$/.test(inlinequestion.responsenumber1) && /^\d+$/.test(inlinequestion.responsenumber2) && inlinequestion.responsenumber2 >= inlinequestion.responsenumber1) {
                    inlinequestion.responsenumber3 = ((inlinequestion.responsenumber1 * 100) / inlinequestion.responsenumber2).toFixed(2);
                }
                
                if(parentquestion.tabularheader3 != null) {
                    if(inlinequestion.responsenumber3 != undefined && inlinequestion.responsenumber3 != null && inlinequestion.responsenumber3 != "") {
                        //total3 = total3 + parseFloat(inlinequestion.responsenumber3);
                    }
                }
            }
            else {
                calculatedrow = inlinequestion;
            }
        }

        for(var i=0; i < parentquestion.inlinequestions.length; i++) {
            var inlinequestion = parentquestion.inlinequestions[i];

            if(inlinequestion.response == undefined || inlinequestion.response == null || inlinequestion.response == "") {
                hasIncompleteQuestions = true;
            }
            else if(inlinequestion.response == inlinequestion.failvalue) {
                hasFailedQuestions = true;
            }
            else if(inlinequestion.response == "Other" && (inlinequestion.otherresponsetext == null || inlinequestion.otherresponsetext == "")) {
                hasIncompleteQuestions = true;
            }
        }

        if(parentquestion.iscalculated && hasFailedQuestions) {
            parentquestion.response = 'No';
            parentquestion.responsetext = 'No';
        }
        else if(parentquestion.iscalculated && !hasIncompleteQuestions && !hasFailedQuestions) {
            parentquestion.response = 'Yes';
            parentquestion.responsetext = 'Yes';
        }
        else if (parentquestion.iscalculated && hasIncompleteQuestions){
            parentquestion.response = '';
            parentquestion.responsetext = '';
        }

        if(calculatedrow != undefined && calculatedrow != null) {
            calculatedrow.responsenumber1 = total1;
            calculatedrow.responsenumber2 = total2;
            if (total1 != null && total1 != undefined && total2 != null && total2 != undefined && /^\d+$/.test(total1) && /^\d+$/.test(total2) && total2 >= total1) {
                calculatedrow.responsenumber3 =  ((total1 * 100) / total2).toFixed(2);
            }
            
            if(parentquestion.tabularheader3 != null) {
                //calculatedrow.responsenumber3 = total3;
            }
        }
        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData);
    },

    handleMultiSelectChange : function(component, event, helper) {
        let fieldName = event.getParam("name");
        let selectedValues = event.getParam("values");

        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var questionToUpdate = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];
        //questionToUpdate.response = event.getParam("values");
        questionToUpdate.options = event.getParam("options");
        
        var newresponse = '';
        var newresponsearray = [];
        if(selectedValues) {
            selectedValues.forEach(element => {

                newresponse = newresponse + element + ';';
                newresponsearray.push(element);
            });
        }
        questionToUpdate.response = newresponse;
        questionToUpdate.responseArray = newresponsearray;

        var dependentSurveyQuestionsMap = component.get("v.dependentSurveyQuestionsMap");

        if(dependentSurveyQuestionsMap[questionToUpdate.id]) {
            var dependquestions = dependentSurveyQuestionsMap[questionToUpdate.id];
            dependquestions.forEach(dependentquestion => {
                dependentquestion.showquestion = !dependentquestion.showquestion;
            });
        }
        component.set("v.dependentSurveyQuestionsMap", dependentSurveyQuestionsMap);
        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData);
    },


    openModal: function(component, event, helper) {
        // Set isModalOpen attribute to true
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var selectedQuestion = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];

        component.set("v.instructions", selectedQuestion.instructions);
        component.set("v.isModalOpen", true);
    },
    openDueDateModal: function(component, event, helper) {
        // Set isModalOpen attribute to true
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var selectedQuestion = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];

        component.set("v.dueDate", selectedQuestion.dueDate);
        component.set("v.isDueDateModalOpen", true);
    },

    openBenefitsModal: function(component, event, helper) {
        // Set isModalOpen attribute to true
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var selectedQuestion = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];

        component.set("v.benefits", selectedQuestion.benefits);
        component.set("v.isBenefitsModalOpen", true);
    },
    
    closeModal: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },

    closeDueDateModal: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isDueDateModalOpen", false);
    },

    closeBenefitsModal: function(component, event, helper) {
        component.set("v.isBenefitsModalOpen", false);
    },

    handleShowHideInsructions : function(component, event, helper) {
        //var strNumberRemove = event.currentTarget.dataset.id.split('-')[1]
        //var numberValue =  strNumberRemove.replace(/[^0-9\.]+/g, '');

        //var index = numberValue;
        //var index = numberValue -1;

        var section = event.currentTarget.dataset.id.split('-')[0];
        var index = event.currentTarget.dataset.id.split('-')[1];

        helper.helperFun(component, event, section, index);
    },
    handleShowHideChildInsructions : function(component, event, helper) {
        var section = event.currentTarget.dataset.id.split('-')[0];
        var index = event.currentTarget.dataset.id.split('-')[1];
        var inlineIndex = event.currentTarget.dataset.id.split('-')[2];
        helper.handlerChildInstructions(component, event, section, index, inlineIndex);
    },

    handleShowHideDueDate : function(component, event, helper) {
        var section = event.currentTarget.dataset.id.split('-')[0];
        var index = event.currentTarget.dataset.id.split('-')[1];
        helper.handlerChildInstructions(component, event, section, index);
    },

    handleShowHideBenefits : function(component, event, helper) {
        var section = event.currentTarget.dataset.id.split('-')[0];
        var index = event.currentTarget.dataset.id.split('-')[1];
        helper.helperFun(component, event, section, index, event.currentTarget.dataset.id);
    },

    handleSubittedPageCloseClick : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
        window.location = '/' + component.get("v.recordId");
    },

    handleRadioReadonlyChange : function(component, event, helper) {
        return false;
    },

    handleSaveClick : function(component, event, helper) {
    //    var name = event.getSource().get('v.name');
    //    var isUpdate = name == 'UpdateSave' ? true : false;
    //    component.set("v.showSpinner", true);
    //    helper.saveSectionQuestions(component, event, helper, false, isUpdate);

        component.set("v.showSpinner", true);
        //DPM-5149 Changed parameter to false where is updateSave by MH - 2023.11.20
        helper.getCompleteAccess(component, event, helper, false, false); //test to DPM-5279 (Original: false, false)


    },

    handleCloseButtonClick : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.saveSectionQuestions(component, event, helper, false, false);
    }, 

    handleNextButtonClick : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.validateForm(component, event, helper);
    }, 
    
    handlePreviousButonClick : function(component, event, helper) {
        component.set("v.showReadonlyPage", false);
    }, 

    handleSubmitButonClick : function(component, event, helper) { 
        // component.set("v.submitSurveyConfirmModal", true);
        component.set("v.showSpinner", true);
        //helper.getSurveySize(component, event, helper); // DPM - 5610 by JH //changed to comment by MH
        helper.handleShowSubmitModal(component, event, helper);
    }, 

    handleConfirmSubmitSurveyCancel : function(component, event, helper) {
        component.set("v.submitSurveyConfirmModal", false);
    },

    submitSurveyEventHandler : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.submitSurvey(component, event, helper);
    },

    handleCloseErrorModalAndReturnToSurvey : function(component, event, helper) { 
        component.set("v.showErrorsModal", false);
    },

    handleCloseErrorModalAndContinue  : function(component, event, helper) { 
        component.set("v.showErrorsModal", false);
        component.set("v.showReadonlyPage", true);

    },

    //handleGenerateWIPDF Dhiraj changes for PDF Without Image starts here
    handleGenerateWIPDF:function(component,event,helper){
        var action = component.get("c.getNetworkId");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();        
            //window.open(result + '/apex/SurveyQuestionCompWImagePDF?id=' + component.get("v.surveyId"), '_blank');
            window.open(result + '/apex/SurveyPDF_wo_image?id=' + component.get("v.surveyId"), '_blank');
        });
        $A.enqueueAction(action);
    },

    //handleGenerateWIPDF Dhiraj changes for PDF Without Image ends here
    handleGeneratePDF : function(component, event, helper) {
        //alert('This functionality is currently in progress');
        var action = component.get("c.getNetworkId");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();        
            //window.open(result + '/apex/SurveyQuestionCompPDF?id=' + component.get("v.surveyId"), '_blank');
            window.open(result + '/apex/SurveyPDF_w_image?id=' + component.get("v.surveyId"), '_blank');
        });
        $A.enqueueAction(action);
    }, 

    handleInlineTextChange : function(component, event, helper) {
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var parentquestion = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];

        var questionToUpdate = parentquestion.inlinequestions[sectionQuestionArray[2]];
        //questionToUpdate.response = event.getParam("value");
        
        var incomplete = false;
        var failed = false;
    
        if(parentquestion.iscalculated) {

            if(questionToUpdate.response != "Other") {
                questionToUpdate.otherresponsetext = "";
            }

            for(var i=0; i < parentquestion.inlinequestions.length; i++) {
                var inlinequestion = parentquestion.inlinequestions[i];

                if(inlinequestion.response == undefined || inlinequestion.response == null || inlinequestion.response == "") {
                    incomplete = true;
                }
                else if(inlinequestion.response == inlinequestion.failvalue) {
                    failed = true;
                }
                else if(inlinequestion.response == "Other" && (inlinequestion.otherresponsetext == null || inlinequestion.otherresponsetext == "")) {
                    incomplete = true;
                }
            }
            
            if(failed) {
                parentquestion.response = 'No';
            }
            else if(incomplete) {
                parentquestion.response = '';
            }
            else {
                parentquestion.response = 'Yes';
            }
        }
        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData);
    },

    handleInlineNumericChange : function(component, event, helper) {
        let fieldName = event.getSource().get('v.name');
        let sectionQuestionArray = fieldName.split('-');

        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var parentquestion = surveySectionQuestionsMapData[sectionQuestionArray[0]].values[sectionQuestionArray[1]];

        var questionToUpdate = parentquestion.inlinequestions[sectionQuestionArray[2]];
        //questionToUpdate.response = event.getParam("value");
        
        var incomplete = false;
        var failed = false;
    
        if(parentquestion.iscalculated) {

            if(questionToUpdate.response != "Other") {
                questionToUpdate.otherresponsetext = "";
            }

            for(var i=0; i < parentquestion.inlinequestions.length; i++) {
                
                var inlinequestion = parentquestion.inlinequestions[i];
                if(!inlinequestion.iscalculated) {
                    if(inlinequestion.response == undefined || inlinequestion.response == null || inlinequestion.response == "") {
                        incomplete = true;
                    }
                    else if(inlinequestion.response == inlinequestion.failvalue) {
                        failed = true;
                    }
                    else if(inlinequestion.response == "Other" && (inlinequestion.otherresponsetext == null || inlinequestion.otherresponsetext == "")) {
                        incomplete = true;
                    }
                }
            }
            
            if(failed) {
                parentquestion.response = 'No';
            }
            else if(incomplete) {
                parentquestion.response = '';
            }
            else {
                parentquestion.response = 'Yes';
            }
        }
        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData); 
    },

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-01-17] for [DPM-5264]
    */    
    handleFileDeletedEvent : function(component, event, helper) {
        // DPM-5264 Added to save deleted fileId by MH - 2024.01.16
        var fileId = event.getParam("deletedfileId");
        var parentId = event.getParam("deletedFileparentId");
        var deletedFileMapData = component.get("v.deletedFileMapData");
        // var fileId = event.getParam("fileId");
        // var parentId = event.getParam("parentId"); //DPM-5264 End

        var surveyQuestionsToUpdate = [];
        var currentSection = component.get("v.currentOpenSection");
        var surveySections = component.get("v.surveySections");
        var indexOfCurrentSection = surveySections.indexOf(currentSection);
        var surveySectionQuestionsMapData = component.get("v.surveySectionQuestionsMapData");
        var surveyQuestionsForSection = surveySectionQuestionsMapData[indexOfCurrentSection].values;

        surveyQuestionsForSection.forEach(question => {
            if(parentId == question.id) {
                var relatedDocuments = question.relatedDocuments;
                for (var i = 0; i < relatedDocuments.length; i++) {
                    if (relatedDocuments[i] === fileId) {
                        relatedDocuments.splice(i, 1);
                        deletedFileMapData.push(fileId); // DPM-5264 Added to save deleted fileId by MH - 2024.01.16
                        break;
                    }
                }
            }
        });
        component.set("v.surveySectionQuestionsMapData", surveySectionQuestionsMapData);
        component.set("v.deletedFileMapData", deletedFileMapData);
        console.log("deletedFileMapData: "+component.get("v.deletedFileMapData"));
        if (component.get("v.warrantyReview2022")){
            helper.getContentDocumentIDs(component, event, helper);
        }



    },
    picklistValChange : function(component, event, helper){
        if (component.get("v.warrantyReview2022")){
            if (component.get("v.isTheWarrantyCEEROReviewComplete") == 'YES') {
                component.set("v.isTheWarrantyCEEROReviewCompleteFlag", true);
            } else {
                component.set("v.isTheWarrantyCEEROReviewCompleteFlag", false);
            }
        }
    },

    handleUploadFinished : function(component, event, helper){
        
        if (component.get("v.warrantyReview2022")){
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        
        var documentIds = [];
        uploadedFiles.forEach(uploadedFile => {
            documentIds.push(uploadedFile.documentId);
        });

            
        var action = component.get("c.updateContentVersion");
        action.setParams({ "documentIds" : documentIds, "fieldAPIName" : "Warranty_CEE_RO_Review_Excel_File__c" }); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                helper.getContentDocumentIDs(component, event, helper);
                
            }
        });

        $A.enqueueAction(action);
    }

    },
    handleUploadFinished2nd : function(component, event, helper){
        if (component.get("v.warrantyReview2022")){
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        
        var documentIds = [];
        uploadedFiles.forEach(uploadedFile => {
            documentIds.push(uploadedFile.documentId);
        });

        
        var action = component.get("c.updateContentVersion");
        action.setParams({ "documentIds" : documentIds, "fieldAPIName" : "RO_Review_Action_Plan__c" }); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                helper.getContentDocumentIDs(component, event, helper);
                
            }
        });

        $A.enqueueAction(action);
    }

    },
    handleUploadFinished3rd : function(component, event, helper){
        if (component.get("v.warrantyReview2022")){
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        
        var documentIds = [];
        uploadedFiles.forEach(uploadedFile => {
            documentIds.push(uploadedFile.documentId);
        });

        
        var action = component.get("c.updateContentVersion");
        action.setParams({ "documentIds" : documentIds, "fieldAPIName" : "WOPR_Action_Plan_WOPR_score_below_avg__c" });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                helper.getContentDocumentIDs(component, event, helper);
                
            }
            
        });
        $A.enqueueAction(action);
    }

    },
    handleUploadFinished4th : function(component, event, helper){
        if (component.get("v.warrantyReview2022")){
            // Get the list of uploaded files
            var uploadedFiles = event.getParam("files");

            var documentIds = [];
            uploadedFiles.forEach(uploadedFile => {
                documentIds.push(uploadedFile.documentId);
            });

            var action = component.get("c.updateContentVersion");
            action.setParams({ "documentIds" : documentIds, "fieldAPIName" : "Other_WOPR_Action_Plan__c" });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    helper.getContentDocumentIDs(component, event, helper);
                }
            });
            $A.enqueueAction(action);
        }
    }
})