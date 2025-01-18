import { LightningElement, track, api } from 'lwc';
import getAccounts from '@salesforce/apex/HCUV_Utility.getAccountList';
import setAccount from '@salesforce/apex/HCUV_Utility.setUserAccountId';
import { communityList } from 'c/hcuvUtility';
export default class HcuvDualAccount extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @api isModalOpen = false;
    @api selectedDealer;
    @track isLoading = false;
    @track accountList = [];
    @track selectedAccount;
    @track selectAcc = communityList.HCUV_Select_Account;
    @track accountId = communityList.HCUV_AccountId;
    @track dealerName = communityList.HCUV_Dealer_Name;
    @track dealerCode = communityList.HCUV_Dealer_Code;
    @track select = communityList.HCUV_Select;
    @track cancel = communityList.HCUV_Cancel;
    @track ok = communityList.HCUV_Ok;

    connectedCallback() {
        this.populateDualAccounts();
    }
    handleSelection(event) {
        // Get the selected ID from the radio button value
        const selectedId = event.target.value;
        // Display the message with the selected ID
        this.selectedAccount = selectedId;
    }
    @api
    handleOnAccountCheck() {
        this.isModalOpen = true;
        this.populateDualAccounts();
    }
    populateDualAccounts() {
        try {
            this.isLoading = true;
            getAccounts({}).then(result => {
                if (result != null && result != undefined) {
                    this.accountList.length = 0;
                    result.forEach(message => {
                        this.accountList.push({ 'Dealer_Id': message.Account.Id, 'Dealer_Name': message.Account.Name, 'Dealer_Code': message.Account.DealerCode__c, 'Dealer_checked':message.Account.Id==this.selectedDealer?true:false});
                    });
                    var changeDealerVis = false;
                    if (this.accountList.length > 1) {
                        changeDealerVis = true;
                    }
                    const selectEvent = new CustomEvent('changedealer', {
                        detail: {
                            visibility: changeDealerVis
                        }
                    });
                    this.dispatchEvent(selectEvent);
                }
            });
        } catch (error) { }
        finally {
            this.isLoading = false;
        }

    }
    updateUserSelectedAccount() {
        this.isLoading = true;
        setAccount({ accountId: this.selectedAccount }).then(response => {
            this.isLoading = false;
            window.open(window.location.href, '_self');
        })
    }


    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.updateUserSelectedAccount();
        this.isModalOpen = false;
    }
}