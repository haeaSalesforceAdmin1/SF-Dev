import { LightningElement, track, wire } from 'lwc';
import getcontestIncentive from '@salesforce/apex/HCUV_ContestsIncentivesDataCtrl.getcontestIncentive';
import { communityList, staticResourceList, labelList, defaultProgramType } from 'c/hcuvUtility';
import networkId from '@salesforce/community/Id';

export default class HCUVcontestsIncentivesData extends LightningElement {
    showSpinner = false;
    @track contestsIncentivesList = [];
    @track data = [];
    @track pageNo = 1;
    pageSize = labelList.Inventory_Table_Page_Size;
    pageSlab = 1;
    showAll = false;
    docMap = {};
    selContestsIncentive;
    selContentDocuments = [];
    videoExtensions = ['webm', 'mp4', 'mov', 'm4v'];
    @track defaultPrg = communityList.HCUV_Default_Program;
    @track pdfIcon = communityList.HCUV_Icon_PDF;
    @track videoIcon = communityList.HCUV_Icon_Video;
    @track contestsIncentives = communityList.HCUV_Contests_Incentives;
    @track prgNameText = communityList.HCUV_Program_Name;
    @track startDate = communityList.HCUV_Start_Date;
    @track endDate = communityList.HCUV_End_Date;
    @track newText = communityList.HCUV_New;
    @track recordDisplayText = communityList.HCUV_No_Record_Display;
    networkId = networkId;
    programName = '';

    hmaIcons = {
        'pdf': staticResourceList.HMAIcons + this.pdfIcon,
        'video': staticResourceList.HMAIcons + this.videoIcon
    };

    get showCurrentPage() {
        return this.contestsIncentivesList.length > 0 && !this.showAll;
    }

    get currentPage() {
        return 'Showing '
            + ((this.pageSize * (this.pageNo - 1)) + 1)
            + ' to '
            + (this.contestsIncentivesList.length < this.pageSize || this.contestsIncentivesList.length < (this.pageSize * this.pageNo) ? this.contestsIncentivesList.length
                : (this.pageSize * this.pageNo))
            + ' of ' + this.contestsIncentivesList.length + ' entries';
    }

    get pages() {
        let totalPages = Math.ceil(this.contestsIncentivesList.length / this.pageSize);
        let pages = [];

        for (let j = 1; j <= totalPages; j++) {
            if (j > (this.pageSlab - 1) * 4 && j <= this.pageSlab * 4)
                pages.push({
                    'no': j.toString(),
                    'class': (j == this.pageNo ? 'slds-m-left_small active-page' : 'slds-m-left_small')
                });
        }
        return pages;
    }

    get isNoInventoryFound() {
        return this.contestsIncentivesList.length < 1;
    }

    get lastPage() {
        return Math.ceil(this.contestsIncentivesList.length / this.pageSize);
    }

    get disablePrev() {
        return this.pageSlab == 1;
    }

    get disableNext() {
        return this.pageSlab == Math.ceil(this.contestsIncentivesList.length / (this.pageSize * 4));
    }

    connectedCallback() {
        if (sessionStorage.getItem('ProgramType') != null) {
            this.programName = sessionStorage.getItem('ProgramType');
        }
        else{
            this.programName = defaultProgramType();
        }
    }
    @wire(getcontestIncentive, { programName: "$programName", networkId: "$networkId" })
    contestIncentiveData(result) {
        if (result.data) {
            this.contestsIncentivesList = [];
            var incentiveRes = [];
            incentiveRes = JSON.parse(JSON.stringify(result.data));
            let todayDate = new Date();
            todayDate.setDate(todayDate.getDate() - 1);
            if (incentiveRes.ContestsIncentives && incentiveRes.ContestsIncentives.length > 0) {
                incentiveRes.ContestsIncentives.forEach((item) => {
                    let date = new Date(item.CreatedDate);
                    item.isNew = (date < todayDate ? false : true);
                    //item.priorityClass = (item.Priority__c == 'Normal' ? 'slds-truncate text-normal' : (item.Priority__c == 'Low' ? 'slds-truncate text-low' : 'slds-truncate text-high'));
                    item.priorityClass = 'slds-truncate text-high';
                    this.contestsIncentivesList.push(item);
                });
                this.contestsIncentivesList.sort((a, b) => b.LastModifiedDate.localeCompare(a.LastModifiedDate));
            }

            if (incentiveRes.DocMap)
                this.docMap = incentiveRes.DocMap;

            this.data = this.contestsIncentivesList.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
            this.showSpinner = false;
        }

    }

    handlePageClick(event) {
        let page = event.currentTarget.dataset.id;
        this.pageNo = page;

        this.data = this.contestsIncentivesList.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
    }

    handlePrevNext(event) {
        this.pageSlab = event.target.name == 'prev' ? this.pageSlab - 1 : this.pageSlab + 1;
        this.pageNo = ((this.pageSlab - 1) * 4) + 1;
        this.data = this.contestsIncentivesList.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
    }

    handleViewAllClick() {
        this.showAll = true;
        this.data = this.contestsIncentivesList;
    }

    handleNameClick(event) {

        this.contestsIncentivesList.forEach((item) => {
            if (item.Id == event.currentTarget.dataset.id) {
                this.selContestsIncentive = item;

                this.selContentDocuments = [];

                if (item.ContentDocumentLinks && item.ContentDocumentLinks.length > 0) {
                    item.ContentDocumentLinks.forEach((conDoc) => {
                        conDoc.isVideo = false;

                        if (this.videoExtensions.includes(conDoc.ContentDocument.FileExtension)) {
                            conDoc.isVideo = true;
                        }

                        this.selContentDocuments.push(conDoc);
                    });
                }
            }
        });
    }

    handleLinkClick(event) {

        let videoURL = communityList.COMMUNITY_BASE_PATH.substring(0, communityList.COMMUNITY_BASE_PATH.length - 2) + labelList.VIDEO_URL;
        this.selContentDocuments.forEach((conDoc) => {
            if (conDoc.ContentDocumentId == event.currentTarget.dataset.id) {
                if (this.videoExtensions.includes(conDoc.ContentDocument.FileExtension))
                    window.open(videoURL + event.currentTarget.dataset.id);
                else
                    window.open(this.docMap[event.currentTarget.dataset.id]);
            }
        });
    }

    handleBackClick() {
        this.selContestsIncentive = null;
    }

}