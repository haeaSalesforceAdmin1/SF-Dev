import { LightningElement, api, track } from 'lwc';
import { communityList, labelList } from 'c/hcuvUtility';
export default class Hcuv_InventoryTable extends LightningElement {

    @api fieldMap = {};
    @api inventories = [];
    @api searchTerm;

    @track fields = [];
    @track invList = [];
    @track data = [];
    @track pageNo = 1;
    @track tableColSpanWhenNoInvFound = 0;// [CCSOM-3] [SF] Dealer User View - Minor Visual Fixes , kih , 231221

    pageSize = labelList.Inventory_Table_Page_Size;
    pageSlab = 1;
    formFactor = communityList.DEVICE_FORM_FACTOR;
    noRecordsFoundMessage = labelList.HCUV_Inventory_No_Records_Found_Message;

    startSelection;
    endSelection;
    checkedPages = [];

    get isMobileView() {
        return this.formFactor == 'Small';
    }

    get showCurrentPage() {
        return this.invList.length > 0;
    }

    get currentPage() {
        let message = labelList.HCUV_Inventory_Entries_Message;
        let pageStart = ((this.pageSize * (this.pageNo - 1)) + 1);
        let pageEnd = (this.invList.length < this.pageSize || this.invList.length < (this.pageSize * this.pageNo)
            ? this.invList.length : (this.pageSize * this.pageNo));
        let pageTotal = this.invList.length;

        message = message.replace('PAGE_START', pageStart);
        message = message.replace('PAGE_END', pageEnd);
        message = message.replace('PAGE_TOTAL', pageTotal);

        return message;
    }

    get pages() {
        let totalPages = Math.ceil(this.invList.length / this.pageSize);
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
        return this.invList.length == 0;
    }

    get lastPage() {
        return Math.ceil(this.invList.length / this.pageSize);
    }

    get disablePrev() {
        return this.pageSlab == 1;
    }

    get disableNext() {
        return this.pageSlab == Math.ceil(this.invList.length / (this.pageSize * 4));
    }

    connectedCallback() {
        this.fields = [];
        for (const key in this.fieldMap) {
            this.fields.push({
                'label': key,
                'apiName': this.fieldMap[key],
                'isSorted': false,
                'isASC': false
            });
        }
        this.tableColSpanWhenNoInvFound = Object.keys(this.fieldMap).length + 1 ;// [CCSOM-3] [SF] Dealer User View - Minor Visual Fixes , kih , 231221
        this.invList = [];

        this.inventories.forEach((item) => {
            let inv = { Id: item.Id };

            for (const key in this.fieldMap) {
                let apiName = this.fieldMap[key];
                inv[apiName] = (item[apiName] ? item[apiName] : '');
            }

            if (this.formFactor == 'Small')
                inv.showDetails = false;

            if (item.Inventory_Status__c == 'C0' || item.Inventory_Status__c == 'Inactive Inventory')
                inv.rowClass = 'row-bg-color';
            this.invList.push(inv);
        });

        this.setFieldValues();
        this.data = this.invList.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
    }

    setFieldValues() {
        this.invList.forEach((item) => {
            let fields = [];

            for (const key in this.fieldMap) {
                let apiName = this.fieldMap[key];
                let value = (item[apiName] ? item[apiName] : '');

                fields.push({
                    'showLink': (apiName == 'Name' ? true : false),
                    'label': key,
                    'value': value
                });
            }
            item.fields = fields;
        });
    }

    handleInventoryClick(event) {
        window.open(communityList.COMMUNITY_BASE_PATH + '/' + communityList.INVENTORY_OBJECT_URL + '/' + event.currentTarget.dataset.id, '_self');
    }

    handleCheckboxChange(event) {

        if (event.currentTarget.dataset.id === 'All') {

            this.startSelection = this.pageNo * this.pageSize - this.pageSize;
            this.endSelection = this.pageNo * this.pageSize;
            if (this.invList != undefined && this.invList.length < this.endSelection) {
                this.endSelection = this.invList.length;
            }
            for (let i = this.startSelection; i < this.endSelection; i++) {
                this.invList[i].selected = (event.currentTarget.checked ? true : false);
            }
            if (this.template.querySelector('[data-id="All"]').checked) {
                this.checkedPages.push(parseInt(this.pageNo));
                
            }
            else {
                if (this.checkedPages != undefined ) {
                    const indexVal = this.checkedPages.indexOf(parseInt(this.pageNo));
                    if (indexVal > -1) {
                        this.checkedPages.splice(indexVal, 1);
                    }
                }
            }
        } else {
            this.invList.forEach((item) => {
                if (item.Id == event.currentTarget.dataset.id)
                    item.selected = (event.currentTarget.checked ? true : false);
            });
        }

        this.data = this.invList.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);

        // notify parent
        let selItems = [];

        this.invList.forEach((item) => {
            if (item.selected)
                selItems.push(item.Id);
        });
        this.dispatchEvent(new CustomEvent('selectedrows', { detail: selItems }));
    }

    handlePageClick(event) {
        let page = event.currentTarget.dataset.id;
        if (this.pageNo != page) {
            if (this.checkedPages != undefined && this.checkedPages.length > 0 && this.checkedPages.includes(parseInt(page))) {
                this.template.querySelector('[data-id="All"]').checked = true;
            }
            else {
                this.template.querySelector('[data-id="All"]').checked = false;
            }
        }
        this.pageNo = page;
        this.data = this.invList.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
    }

    handlePrevNext(event) {
        this.pageSlab = event.target.name == 'prev' ? this.pageSlab - 1 : this.pageSlab + 1;
        this.pageNo = ((this.pageSlab - 1) * 4) + 1;
        this.data = this.invList.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
        if (this.checkedPages != undefined && this.checkedPages.length > 0 && this.checkedPages.includes(parseInt(this.pageNo))) {
            this.template.querySelector('[data-id="All"]').checked = true;
        }
        else {
            this.template.querySelector('[data-id="All"]').checked = false;
        }

    }

    handleSort(event) {
        let apiName = event.currentTarget.dataset.id;

        let isASC;
        this.fields.forEach((field) => {
            if (field.apiName == apiName) {
                field.isSorted = true;
                field.isASC = !field.isASC;
                isASC = field.isASC;
            } else {
                field.isSorted = false;
                field.isASC = false;
            }
        });

        this.pageNo = 1;

        if (isASC)
            this.invList.sort((a, b) => (a[apiName] > b[apiName]) ? 1 : ((b[apiName] > a[apiName]) ? -1 : 0));
        else
            this.invList.sort((a, b) => (a[apiName] > b[apiName]) ? -1 : ((b[apiName] > a[apiName]) ? 1 : 0));

        this.setFieldValues();
        this.data = this.invList.slice((this.pageNo - 1) * this.pageSize, this.pageNo * this.pageSize);
    }

    handleVINClick(event) {
        // iterate invList
        this.invList.forEach((item) => {
            if (item.Id == event.currentTarget.name) {
                item.showDetails = !item.showDetails;
            } else {
                //item.showDetails = false;
            }
        });
    }
}