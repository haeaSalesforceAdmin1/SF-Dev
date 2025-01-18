import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import PIRTypeData from '@salesforce/apex/DNAMSPIRQuestionsForm.getPIRTypes';
import SectionsData from '@salesforce/apex/DNAMSPIRQuestionsForm.getSections';
import QuestionsData from '@salesforce/apex/DNAMSPIRQuestionsForm.getQuestions';
import saveResponses from '@salesforce/apex/DNAMSPIRQuestionsForm.saveResponses';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab, CloseTabEvent } from 'lightning/platformWorkspaceApi';


export default class PIRFormDocumentTemplate extends NavigationMixin(LightningElement) {
    @api recordId;
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
    @track closetab;
    
    
    @track qnresponse= new Map();
    @wire(PIRTypeData, { AccountId: '$recordId' }) 
    pirtypes;

    @wire(IsConsoleNavigation) isConsoleNavigation;

    connectedCallback() {
        console.log('recordId - ',this.recordId);
        
    }

    loadSections(){
        SectionsData({ AccountId: this.recordId, PIRTypesList: this.SelectedPIRTypes })
            .then(result => {
                this.sections = result;
                console.log('sections  - :'+ result);
                console.log("sections stringfied - " + JSON.stringify(this.sections));
                this.sectionNames = this.sections.map(section => section.SectionName);
                const questionsAndResponses = [];
               this.sections.forEach(section => {
                    section.QuesData.forEach(question => {
                        this.responses[question.QuestionId] = question.Response;
                        const questionObj = {
                                QuestionId: question.QuestionId,
                                Response: question.Response
                                };
                        questionsAndResponses.push(questionObj);
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
    


    pirSelectNext() {

         if (this.SelectedPIRTypes.length === 0) {
            this.showToast('Error', 'Please select at least one PIR Type.', 'error');
            return;
        }

        console.log('Selected PIR Types :'+this.SelectedPIRTypes);
        
        let pirSelDiv = this.template.querySelector('[data-id="pirTypeSelectDiv"]');
        pirSelDiv.classList.add('slds-hide');

        let pirQnFormDiv = this.template.querySelector('[data-id="pirQuestionFormDiv"]');
        pirQnFormDiv.classList.remove('slds-hide');

        let selectedPIRTypesDisplay = this.template.querySelector('[data-id="selectedPIRTypesDisplay"]');
        selectedPIRTypesDisplay.textContent = this.SelectedPIRTypes.join(', ');

        this.loadSections();
      
    }
    

    selectedTypes(event) {
        this.SelectedPIRTypes = event.detail.value;
    }

    handleInputChange(event) {
        const questionId = event.target.dataset.id;
        const responseValue = event.target.value;

        this.responses[questionId] = responseValue; 
        console.log('this.respones :'+JSON.stringify(this.responses));
        
        console.log('responses :'+  this.responses[questionId] + ' question ID '+ questionId);
         this.checkEditability();
    }

    checkEditability() {
    this.isQuestion2Editable = this.responses['Does proposed ownership structure comply with HMAs policy of 50.1 percent ownership by Dealer Principal'] === 'yes';
}
    handleSelectionChange(event){
        const questionId = event.target.dataset.id;
        const selectedValue = event.detail.value;
        this.responses[questionId] = selectedValue; 
    }
    
    submitResponses() {
    

        this.isModalOpen = true;
        const responsesString = JSON.stringify(this.responses);
        console.log("Response String -", responsesString);

       
    }

   
   
     handleConfirm() {

            
        const responsesString = JSON.stringify(this.responses);
       
        saveResponses({ accID: this.recordId, pirTypes: JSON.stringify(this.SelectedPIRTypes), responses: responsesString})
            .then((result) => {
                this.recordId = result
                console.log('result - '+ result);
                if(this.recordId.indexOf('Error') == -1){
                this.isQuestionsFormOpen = false;
                
                this.closeTab();


                this.navigateToRecordPage(this.recordId);
                console.log('record nav - :'+this.recordId);
               
                this.closeTab();
                let a = window.location.origin + '/' + this.recordId;
                window.open(a,"_self");
                console.log('record nav - :'+this.recordId);
                }
                else{
                    this.showToast('Error', 'There was an error saving your responses. '+this.recordId , 'error');
                }
            })
            .catch(error => {
                console.error("Error saving responses: ", error);
                this.showToast('Error', 'There was an error saving your responses.', 'error');
            });
        
        this.isModalOpen = false; 
       
         
    }

    async closeTab() {
            console.log('inside closeTab --');
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        await closeTab(tabId);
       
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
        })


    }
    
}