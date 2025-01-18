import { LightningElement, track, wire } from 'lwc';
import getMessages from '@salesforce/apex/HCUV_MessageController.getMessages';
import { communityList, defaultProgramType } from 'c/hcuvUtility';
import formFactorPropertyName from '@salesforce/client/formFactor';
import MessagePageSize from '@salesforce/label/c.MessagePageSize';
import networkId from '@salesforce/community/Id';
import { NavigationMixin } from "lightning/navigation";

export default class HmaMessageCenter extends NavigationMixin(LightningElement) {
    @track messages;
    @track latestMsg;
    @track showMsgs = false;
    @track loader = false;
    @track error = null;
    @track pageSize = MessagePageSize;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track recordStart = 0;
    @track isPrev = true;
    @track isNext = true;
    @track HMA_Message = [];
    @track data = [];
    pageNo = 1;
    pageSlab = 1;
    isMobile;
    viewAllCss;
    showViewAll = false;
    @track messageCenter = communityList.HCUV_Message_Center;
    @track noRecordFound = communityList.HCUV_No_Record;
    @track defaultPrg = communityList.HCUV_Default_Program;
    acceptedFormats = ['.pdf', '.png'];
    showDetails = false;
    networkId = networkId;
    programName = '';

    connectedCallback() {
        this.isMobile = (formFactorPropertyName == "Small") ? true : false;
        this.viewAllCss = this.isMobile ? 'slds-size_1-of-2 slds-m-bottom_xx-small' : 'slds-size_1-of-2 slds-m-bottom_xx-small';
        if (sessionStorage.getItem('ProgramType') != null) {
            this.programName = sessionStorage.getItem('ProgramType');
        }
        else {
            this.programName = defaultProgramType();
        }

    }

    @wire(getMessages, { programName: "$programName", networkId: "$networkId" })
    messageCenter(result) {

        if (result.data) {
            var messageList = [];
            messageList = JSON.parse(JSON.stringify(result.data));
            messageList.sort((a, b) => b.LastModifiedDate.localeCompare(a.LastModifiedDate));
            var msgs = [];
            messageList.forEach(message => {
                msgs.push({
                    'Id': message.Id,
                    'Label': message.Message_Subject__c,
                    'Message': message.Message__c,
                    'ShortMessage': (message.Message__c && message.Message__c.length > 240 ? message.Message__c.substring(0, 240) + '...' : message.Message__c),
                    'StartDate': message.Start_Date__c, 'Priority': message.Priority__c,
                    'PriorityCSS': message.Priority__c == 'Normal' ? 'slds-float--right text-normal' : message.Priority__c == 'High' ? 'slds-float--right text-high' : 'slds-float--right text-low'
                });
            });
            this.messages = msgs;
            if (msgs.length > 0) {
                this.latestMsg = { ...this.messages[0] };
            }
            this.showViewAll = this.messages.length > 1 ? true : false;
            this.isDisplayNoRecords();
            this.data = this.messages.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
        }
    }






    //handle next
    handleNext() {
        this.pageNumber = this.pageNumber + 1;
        this.getHMAMessageList();
    }

    //handle prev
    handlePrev() {
        this.pageNumber = this.pageNumber - 1;
        this.getHMAMessageList();
    }

    handleLabelClick(event) {
        let keyId = event.target?.dataset?.id
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: keyId,
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        })
    }

    handleBack() {
        this.showDetails = false;
    }

    getHMAMessageList() {
        this.showMsgs = true;
        this.data.forEach((item) => {
            item.PriorityCSS = (item.Priority == 'Normal' ? 'text-normal' : item.Priority == 'High' ? 'text-high' : 'text-low');
        });
    }

    //display no records
    isDisplayNoRecords() {
        var isDisplay = true;
        if (this.messages) {
            if (this.messages.length == 0) {
                isDisplay = true;
            } else {
                isDisplay = false;
            }
        }
        return isDisplay;
    }

    getSingleMessage() {
        this.showMsgs = false;
        this.latestMsg.PriorityCSS = (this.latestMsg.Priority == 'Normal' ? 'slds-float--right text-normal' : this.latestMsg.Priority == 'High' ? 'slds-float--right text-high' : 'slds-float--right text-low');

    }

    get showCurrentPage() {
        return this.messages.length > 0;
    }

    get pages() {
        let totalPages = Math.ceil(this.messages.length / this.pageSize);
        let pages = [];

        for (let j = 1; j <= totalPages; j++) {
            pages.push({ 'pageNo': j.toString(), 'isSelectedCSS': this.pageNo == j ? 'slds-m-left_small active-page' : 'slds-m-left_small' });
        }
        return pages;
    }

    get lastPage() {
        return Math.ceil(this.messages.length / this.pageSize);
    }

    get disablePrev() {
        return this.pageNo == 1;
    }

    get disableNext() {
        return this.pageNo == Math.ceil(this.messages.length / (this.pageSize));
    }

    handlePageClick(event) {
        let page = event.currentTarget.dataset.id;
        this.pageNo = page;

        this.data = this.messages.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
        this.data.forEach((item) => {
            item.PriorityCSS = (item.Priority == 'Normal' ? 'text-normal' : item.Priority == 'High' ? 'text-high' : 'text-low');
        });
    }

    handlePrevNext(event) {
        this.pageSlab = event.target.name == 'prev' ? this.pageSlab - 1 : this.pageSlab + 1;
        this.pageNo = event.target.name == 'prev' ? this.pageNo - 1 : this.pageNo + 1;
        this.data = this.messages.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
        this.data.forEach((item) => {
            item.PriorityCSS = (item.Priority == 'Normal' ? 'text-normal' : item.Priority == 'High' ? 'text-high' : 'text-low');
        });
    }

    handleBackClick() {
        this.selContestsIncentive = null;
    }

    /*handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
    }*/

}