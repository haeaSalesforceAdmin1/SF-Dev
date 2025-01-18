import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getPIRType from '@salesforce/apex/DNAMSPIR_EDIT.getPIRType';
import getSelectedPIRType from '@salesforce/apex/DNAMSPIR_EDIT.getSelectedPIRType';
import { getRecord } from 'lightning/uiRecordApi';
import STATUS from '@salesforce/schema/Package_Initiation__c.PIR_Status__c';
import SectionsData from '@salesforce/apex/DNAMSPIR_EDIT.getSections';
import saveResponses from '@salesforce/apex/DNAMSPIR_EDIT.saveResponses';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
export default class DNAMSEditPIRType extends NavigationMixin(LightningElement){

    
    @track pirtypes;
    @track sections = [];
    @track questions = [];
    @track SelectedPIRTypes = [];
    @track responses = {};

    @track sectionNames = [];
    multiple = true;
    @track isModalOpen= false;
    @track optionsList=[];
    @track selectedValue;
    @track isLocked = false;
    @track isQuestionsFormOpen = true;
    
    @track qnresponse= new Map();
    @api recordId;
    @track status;
    @track error;
    @track isQuestionsFormOpen = true;
    @track firstScreen = true;
    @track options;
    @track selectedValues;
    @track SelectedPIRTypes;
    @track sections=[];
    @track sectionNames = [];


    @wire(IsConsoleNavigation) isConsoleNavigation;

    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        await closeTab(tabId);
      
    }

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS] })
    wiredPackageInitiation({ error, data }) {
        if (data) {
            this.status = data.fields.PIR_Status__c.value;
            console.log(data, ' Data : ',this.status);
            this.loadPicklistValues();
            this.loadSelectedValues();
            
            this.error = undefined;
        } else if (error) {
            console.log('error ', error);
            this.error = error;
            this.status = undefined;
        }
    }

    connectedCallback() {
        this.addRedBordersToRequiredFields();
    }

    loadPicklistValues() {
        getPIRType()
            .then(data1 => {
                console.log('OUTPUT : ',data1);
                this.options = data1.map(value => ({
                    label: value,
                    value: value
                }));
            })
            .catch(error => {
                console.error('Error fetching picklist values', error);
            });
    }

    loadSelectedValues() {
        getSelectedPIRType({ PIRID: this.recordId })
            .then(data2 => {
                console.log('OUTPUT2 : ',data2);
                this.selectedValues = data2; // Set the selected values as default
                this.SelectedPIRTypes = data2;
                this.checkStatus();
            })
            .catch(error => {
                console.error('Error fetching selected PIR Type', error);
            });
    }

    checkStatus(){
        if(this.status == 'Draft'){
            console.log('statusdraft : ',this.status);
            
        }
        else{
            console.log('status : ',this.status);
           
            this.pirSelectNext();
        }
    }

    selectedTypesEdit(event) {
        this.selectedValues = event.detail.value;
        this.SelectedPIRTypes = this.selectedValues;
    }

    pirSelectNext() {
        console.log('OUTPUT SelectedPIRTypes : ', this.SelectedPIRTypes);
        this.SelectedPIRTypes = this.selectedValues;
        console.log('Selected PIR Types :'+this.SelectedPIRTypes);
         if (this.SelectedPIRTypes.length === 0) {
            this.showToast('Error', 'Please select at least one PIR Type.', 'error');
            return;
        }
        else{
           
            this.firstScreen = false;
             let pirSelDiv = this.template.querySelector('[data-id="pirTypeSelectDiv"]');
            pirSelDiv.classList.add('slds-hide');

            let pirQnFormDiv = this.template.querySelector('[data-id="pirQuestionFormDiv"]');
            pirQnFormDiv.classList.remove('slds-hide');
            this.loadSections();
        }

        let pirSelDiv = this.template.querySelector('[data-id="pirTypeSelectDiv"]');
        pirSelDiv.classList.add('slds-hide');

        let pirQnFormDiv = this.template.querySelector('[data-id="pirQuestionFormDiv"]');
        pirQnFormDiv.classList.remove('slds-hide');

        let selectedPIRTypesDisplay = this.template.querySelector('[data-id="selectedPIRTypesDisplay"]');
        selectedPIRTypesDisplay.textContent = this.SelectedPIRTypes.join(', ');

        this.loadSections();
        
    }


    addRedBordersToRequiredFields(questionId, responseValue) {
    
        const inputField = this.template.querySelector(`[data-id="${questionId}"]`);
    
        if (inputField) {
            // Check if it's required and if the response is empty
            if (inputField.required && !responseValue) {
                // Apply a red border if the field is required and empty
                inputField.style.border = '2px solid red';
            } else {
                // Reset the border if the field has a value
                inputField.style.border = '';
            }
        }
        
    }

    handleInputChange(event) {
        const questionId = event.target.dataset.id;
        const responseValue = event.target.value;

        this.responses[questionId] = responseValue; 
        console.log('this.respones :'+JSON.stringify(this.responses));
        
        console.log('responses :'+  this.responses[questionId] + ' question ID '+ questionId);
        this.addRedBordersToRequiredFields(questionId, responseValue);
    }



    loadSections(){
        this.SelectedPIRTypes = this.selectedValues;
        SectionsData({ PIRID: this.recordId, PIRTypesList: this.SelectedPIRTypes })
            .then(result => {
                this.sections = result;
                console.log('sections  - :'+ result);
                console.log("sections stringfied - " + JSON.stringify(this.sections));
                this.sectionNames = this.sections.map(section => section.SectionName);
                console.log('OUTPUT : ',this.sectionNames);
                const questionsAndResponses = [];
               this.sections.forEach(section => {
                    section.QuesData.forEach(question => {
                        this.responses[question.QuestionId] = question.Response;
                        const questionObj = {
                                QuestionId: question.QuestionId,
                                Response: question.Response
                               
                                };
                        questionsAndResponses.push(questionObj);
                        this.addRedBordersToRequiredFields(question.QuestionId, question.Response);
                    });
                    });        

                 console.log('questionsAndResponsesString : '+JSON.stringify(questionsAndResponses));
                
                 console.log('responses  : '+this.responses);
                 console.log('responses string   : '+JSON.stringify(this.responses));
                 
            })
            .catch(error => {
            console.error("Error loading sections: ", error);
            });
    }


    submitResponses() {
    
        this.isModalOpen = true;
        const responsesString = JSON.stringify(this.responses);
        console.log("Response String -", responsesString);

       
    }

    handleConfirm() {

            
        const responsesString = JSON.stringify(this.responses);
       
        saveResponses({ PIRID: this.recordId, pirTypes: JSON.stringify(this.SelectedPIRTypes), responses: responsesString})
            .then((result) => {
                this.recordId1 = result
                console.log('result - '+ result);
                if(this.recordId1.indexOf('Error') == -1){
                this.isQuestionsFormOpen = false;

                this.closeTab();
                this.navigateToRecordPage(this.recordId);
                setTimeout(() => {
               
                window.location.reload();
                console.log('record nav - :'+this.recordId);
                }, 300);
            }
            else{
                this.showToast('Error', 'There was an error saving your responses. '+this.recordId1 , 'error');
            }
            })
            .catch(error => {
                console.error("Error saving responses: ", error);
                this.showToast('Error', 'There was an error saving your responses.', 'error');
            });
        
        this.isModalOpen = false; 
    }

    

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId:this.recordId,
                objectApiName: 'Package_Initiation__c',
                actionName: 'view'
            }
        });
    }
}