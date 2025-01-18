import { LightningElement, api } from 'lwc';
import handleActionPlanApprovals from '@salesforce/apex/ActionPlanApprovalController.handleActionPlanApprovals';

export default class ActionPlanApproval extends LightningElement {

    @api actionPlanId;
    @api action;
    @api status;
    @api comments;

    connectedCallback() {
        if(this.action != 'Reject') {
            this.approveActionPlan();
        }
    }

    @api
    approveActionPlan() {

        handleActionPlanApprovals({actionPlanId: this.actionPlanId,
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