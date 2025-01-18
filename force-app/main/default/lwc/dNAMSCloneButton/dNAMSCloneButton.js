import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getPIRType from '@salesforce/apex/DNAMSPIR_CLONE.getPIRType';
import getSelectedPIRType from '@salesforce/apex/DNAMSPIR_CLONE.getSelectedPIRType';
import { getRecord } from 'lightning/uiRecordApi';
import STATUS from '@salesforce/schema/Package_Initiation__c.PIR_Status__c';
import SectionsData from '@salesforce/apex/DNAMSPIR_CLONE.getSections';
import saveResponses from '@salesforce/apex/DNAMSPIR_CLONE.saveResponses';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
export default class DNAMSClonePIR extends NavigationMixin(LightningElement){

    
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
    @track selectedValues = [];
    //@track SelectedPIRTypes;
    @track sections=[];
    @track sectionNames = [];


    @wire(IsConsoleNavigation) isConsoleNavigation;


    @wire(getRecord, { recordId: '$recordId', fields: [STATUS] })
    wiredPackageInitiation({ error, data }) {
        if (data) {
           
            console.log(data, ' Data : ',this.status);
           
            
            this.error = undefined;
        } else if (error) {
            console.log('error ', error);
            this.error = error;
            this.status = undefined;
        }
    }

    isFirstModalOpen = false;
    isSecondModalOpen = false;

  
    openFirstModal() {
        this.isFirstModalOpen = true;
    }

   
    handleFirstModalOk() {
        this.isFirstModalOpen = false;
        this.isSecondModalOpen = true; 
    }

   
    handleFirstModalCancel() {
        this.isFirstModalOpen = false; 
    }
    connectedCallback() {
        this.loadSelectedValues();
        console.log('SELECTED VALUES LOAD');
        
       this.loadPicklistValues();
       console.log('PICKLIST VALUES LOAD');
       
      // this.pirSelectNext();
       console.log('Selected pirss : ');
       
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
                this.pirSelectNext();
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
            
        }
    }

    selectedTypesEdit(event) {
        this.selectedValues = event.detail.value;
        this.SelectedPIRTypes = this.selectedValues;
    }

    pirSelectNext() {
        console.log('OUTPUT SelectedPIRTypes : ', this.SelectedPIRTypes);
        this.SelectedPIRTypes = this.selectedValues;
        this.loadSections();
        
    }


    handleInputChange(event) {
        const questionId = event.target.dataset.id;
        const responseValue = event.target.value;

        this.responses[questionId] = responseValue; 
        console.log('this.respones :'+JSON.stringify(this.responses));
        
        console.log('responses :'+  this.responses[questionId] + ' question ID '+ questionId);
         
    }



    loadSections(){
        this.SelectedPIRTypes = this.selectedValues;
        console.log('Sections Today: '+this.selectedValues);
        console.log('PIR TYPES SELECTED : '+this.SelectedPIRTypes);
        
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
                    });
                    });

                 console.log('questionsAndResponsesString : '+JSON.stringify(questionsAndResponses));
                 //this.responses= questionsAndResponses;
                 console.log('responses  : '+this.responses);
                 console.log('responses string   : '+JSON.stringify(this.responses));
                 
            })
            .catch(error => {
            console.error("Error loading sections: ", error);
            });
    }


    submitResponses() {
    

        this.isFirstModalOpen = false;
        this.isSecondModalOpen = true;
        this.isModalOpen = true;
        const responsesString = JSON.stringify(this.responses);
        console.log("Response String -", responsesString);

       
    }

    handleConfirm() {
        this.isSecondModalOpen = false;
        console.log('Selected PIR Types:', this.SelectedPIRTypes);
        const responsesString = JSON.stringify(this.responses);
        console.log('before save clicked');
        saveResponses({ PIRID: this.recordId, pirTypes: JSON.stringify(this.SelectedPIRTypes), responses: responsesString})
            .then((result) => {
                console.log('types added: '+this.SelectedPIRTypes);
                console.log('Responses ::'+this.responsesString);
                
                console.log('save clicked');
                this.recordId = result
                console.log('result - '+ result);
                if(this.recordId.indexOf('Error') == -1){
                this.isQuestionsFormOpen = false;

                //this.closeTab();
                
                this.navigateToRecordPage(this.recordId);
                console.log('record nav - :'+this.recordId);
                  
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
        console.log('entered nav -'+this.recordId);
        
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