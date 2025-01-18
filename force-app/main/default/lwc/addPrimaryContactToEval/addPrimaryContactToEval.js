import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import retrieveEvaluationDetails from '@salesforce/apex/SurveyQuestionController.retrieveEvaluationDetails';
import saveEvaluationDetails from '@salesforce/apex/SurveyQuestionController.saveEvaluationDetails';
import retrievEvaluationAccountContacts from '@salesforce/apex/SurveyQuestionController.retrievEvaluationAccountContacts';

/**
 * Add Primary Contact to Evaluation
 * @Author Vinit [IBM]
 * 4th August 2021
 */
export default class addPrimaryContactToEval extends LightningElement {
    
    primaryContact = '--None--';
    accountId;
    evalContacts = [];
    evalAccContList;
    recordId;
    isLoading = false;

    /**
     * Get URL Parameters
     * @Author Vinit [IBM]
     * 4th August 2021
     */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    
    /**
     * Connected Call Back
     * @Author Vinit [IBM]
     * 4th August 2021
     */  
    connectedCallback() {
        this.isLoading = true;
        retrieveEvaluationDetails({recordId: this.recordId,
            launchedFromEval: true}).then(evaluationRec => {
                if (evaluationRec != undefined && evaluationRec != null && evaluationRec.Account__c != null){
                    this.accountId = evaluationRec.Account__c;
                    retrievEvaluationAccountContacts({accountId: this.accountId}).then(evalAccCont => {
                        
                        if (evalAccCont != undefined && evalAccCont != null){
                            var blankContact = {};
                            blankContact.label = '--None--';
                            blankContact.value = '--None--';
                            this.evalContacts.push(blankContact);
                            evalAccCont.forEach(evalContact => {
                                var contactObject = {};
                                contactObject.label = evalContact.Name;
                                contactObject.value = evalContact.ContactId;
                                this.evalContacts.push(contactObject);
                            });
                            this.evalAccContList = this.evalContacts;
                            this.isLoading = false;
                        } else {
                            this.isLoading = false;
                        }
                    }).catch(error =>{
                        const evt = new ShowToastEvent({
                            title: '',
                            message: 'Something Went Wrong While Fetching Evaluation Details!',
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        this.isLoading = false;
                    });
                } else {
                    const evt = new ShowToastEvent({
                        title: '',
                        message: 'Something Went Wrong While Fetching Evaluation Details!',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.isLoading = false;
                }
        }).catch(error => {
            console.log('error '+JSON.stringify(error));
            const evt = new ShowToastEvent({
                title: '',
                message: 'Something Went Wrong!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        });

        
    }

    /**
     * Primary Contact dropdown handle Change
     * @Author Vinit [IBM]
     * 4th August 2021
     */
    handleChange(event){
        this.primaryContact = event.detail.value;
    }

    
    /**
     * Handle Save Evaluation Details on Assign button click
     * @Author Vinit [IBM]
     * 4th August 2021
     */
    handleSaveEvaluationDetailsClick(){
        if (this.primaryContact != '--None--') {
            this.isLoading = true;
            var evalObject = {};   
            evalObject.Id = this.recordId; 
            evalObject.PrimaryContact__c = this.primaryContact;

            saveEvaluationDetails({evaluationJSONString: JSON.stringify(evalObject)}).then(result => {
               
                const evt = new ShowToastEvent({
                    title: '',
                    message: 'Primary Contact Assigned Successfully!',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
                //Refresh the view
                getRecordNotifyChange([{recordId: this.recordId}]);
               
                 this.isLoading = false;
                
            }).catch(error =>{
                console.log('error '+JSON.stringify(error));
                const evt = new ShowToastEvent({
                    title: '',
                    message: 'Something went wrong while assigning primary contact!',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
                this.isLoading = false;
            });
        } else {
                const evt = new ShowToastEvent({
                    title: '',
                    message: 'Please Select Primary Contact to Proceed further',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
    }
}