import { LightningElement, api, wire, track} from 'lwc';
import getSurveyQuestions from '@salesforce/apex/SurveyQuestionController.getSurveyQuestions';

export default class SurveyQuestionComponent extends LightningElement {

    @api recordId;
    @track surveyQuestions;

    @track surveySections;
    @track surveySectionQuestionsMapData = [];
    @track dependentQuestions;

    @wire(getSurveyQuestions, {surveyId: '$recordId'})
    surveyQuestionsCallback(results) {
        this.surveyQuestions = results.data;
        let surveySectionsTemp = [];
        let surveySectionQuestionsMapDataTemp = [];
        if(results.data) {
            results.data.forEach(record => {
                let sectionDescription;
                let sectionMap = {};
                let question = {};
                if(record.Section_Number__c != undefined && record.Section_Number__c != null) {
                    sectionDescription = 'Section ' + record.Section_Number__c
                }
                else {
                    sectionDescription = 'No Section';
                }
                question.singleOptionSelection = false;
                question.section = sectionDescription;
                question.id = record.Id;
                question.question = record.Question_Text__c;
                question.questionNumber = record.Question_Number__c;
                question.inputType = record.Input_Type__c;
                
                if(record.Input_Type__c == 'Picklist (Single Selection)') {
                    question.singleOptionSelection = true;
                }
                question.response = "";
                question.options = [{ label: 'Yes', value: 'Yes' },{ label: 'No', value: 'No' }];
                

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
                
            }); 
        }
       
        this.surveySections = surveySectionsTemp;
        this.surveySectionQuestionsMapData = surveySectionQuestionsMapDataTemp;
        console.error(JSON.stringify(surveySectionQuestionsMapDataTemp));
        console.error(JSON.stringify(this.surveySectionQuestionsMapData));
    }

}