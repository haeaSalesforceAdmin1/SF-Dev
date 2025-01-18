import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInventoryDetail from '@salesforce/apex/HCUV_InventoryQAController.getInventoryDetail';
import activeInventory from '@salesforce/label/c.HCUV_Active_Inventory';
import iamPram from '@salesforce/label/c.HCUV_Pram';
import agedInventory from '@salesforce/label/c.HCUV_AgedInventory';
import removeInventory from '@salesforce/label/c.HCUV_RemoveInventory';
import dealerCode from '@salesforce/label/c.HCUV_DealerCode';

export default class HcuvInventoryQuickAction extends LightningElement {
    @api recordId;
    @api target;
    @api hmaActionUrl;
    @api gmaActionUrl;
    @api errorMsg;
    @api source;
    activeInventory = activeInventory;
    iamPram = iamPram;
    removeInventory = removeInventory;
    agedInventory = agedInventory;
    toastDismissable = 'dismissible';
    toastError = 'error';
    invName = '';
    statusDesc = '';
    dealerRecType = '';
    actionUrl = '';
    dealerCode = dealerCode;
    invDealerCode = '';
    @wire(getInventoryDetail, { recordId: '$recordId' })
    inventoryRecord(result) {
        if (result.data) {
            this.dealerRecType = result.data.Dealer__r.RecordType.DeveloperName;
            this.invName = result.data.Name;
            this.statusDesc = result.data.StatusDescription__c;
            this.invDealerCode = result.data.Dealer_Code__c;
            const closePopupEvt = new CustomEvent("closepopup", { detail: '' });
            this.dispatchEvent(closePopupEvt);
            if (this.dealerRecType == 'HyundaiDealer') {
                this.actionUrl = this.hmaActionUrl;
            }
            else if (this.dealerRecType == 'GenesisRetailer') {
                this.actionUrl = this.gmaActionUrl;
            }
            if (this.source == this.removeInventory) {
                if (this.statusDesc == this.activeInventory || this.statusDesc == this.agedInventory) {
                    var urlVal = this.actionUrl + '&' + this.iamPram + '=' + this.invName + '&' + this.dealerCode + '=' + this.invDealerCode;
                    window.open(urlVal, this.target);
                }
                else {
                    const evt = new ShowToastEvent({
                        title: '',
                        message: this.errorMsg,
                        variant: this.toastError,
                        mode: this.toastDismissable
                    });
                    this.dispatchEvent(evt);
                }
            }
            else if (this.statusDesc == this.activeInventory) {
                var urlVal = this.actionUrl + '&' + this.iamPram + '=' + this.invName + '&' + this.dealerCode + '=' + this.invDealerCode;
                window.open(urlVal, this.target);
            }
            else {
                const evt = new ShowToastEvent({
                    title: '',
                    message: this.errorMsg,
                    variant: this.toastError,
                    mode: this.toastDismissable
                });
                this.dispatchEvent(evt);
            }

        }

    }


}