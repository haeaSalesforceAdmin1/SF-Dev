import { LightningElement, api } from 'lwc';
import handleEvaluationApprovals from '@salesforce/apex/EvaluationApprovalController.handleEvaluationApprovals';

export default class ActionPlanApproval extends LightningElement {

    @api evaluationId;
    @api action;
    @api status;
    @api comments;

    connectedCallback() {
        if(this.action != 'Reject') {
            this.approveEvaluation();
        }
    }

    @api
    approveEvaluation() {

        handleEvaluationApprovals({evaluationId: this.evaluationId,
                                   action: this.action,
                                   comments: this.comments,
                                   status: this.status  })
        .then((returnValue) => {  
            if(returnValue == 'Success') {
                this.dispatchEvent(
                    new CustomEvent('approvalcomplete', {
                        bubbles: true})
                );
            }
            else {
                alert(returnValue);
                this.dispatchEvent(
                    new CustomEvent('approvalcomplete', {
                        bubbles: true})
                );
            }
        });
    }

}