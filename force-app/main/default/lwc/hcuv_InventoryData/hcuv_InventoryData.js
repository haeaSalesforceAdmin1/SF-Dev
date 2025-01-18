import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import IMAGES from '@salesforce/resourceUrl/hcuvImages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { constants, labelList,communityList, defaultProgramType } from 'c/hcuvUtility';
import getInventories from '@salesforce/apex/HCUV_InventoryDataCtrl.getInventories';
import getDealerCode from '@salesforce/apex/HCUV_Utility.getDealerCode';
import getCarFaxURL from '@salesforce/apex/HCUV_CarFaxController.getCarFaxURL';
import getInspectionChecklistURL from '@salesforce/apex/HCUV_InspectionChecklistCtrl.getInspectionChecklistURL';
import { APPLICATION_SCOPE, MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import inventoryNavigationChannel from '@salesforce/messageChannel/InventoryNavigationChannel__c';
import networkId from '@salesforce/community/Id';

export default class Hcuv_InventoryData extends LightningElement {

    networkId = networkId;
    
    subscription = null;
    showSpinner = false;
    createRDR = 'createRDR';
    removeInventory = 'removeInventory';
    windowSticker = 'windowSticker';
    @track windowStickerURL = labelList.WindowStickerURL;
    @track createRDRURL = labelList.CreateRDRURL;
    @track removeInventoryURL = labelList.RemoveInventoryURL;
    @track iamPram = labelList.IAMPram;
    @track searchTerm = labelList.ActiveInventoryText;
    @track activeInventory = labelList.ActiveInventoryText;
    @track agedInventory = labelList.AgedInventory;
    @track windowStickerTooltip = labelList.WindowStickerTooltip;
    @track createRDRTooltip = labelList.CreateRDRTooltip;
    @track removeInventoryTooltip = labelList.RemoveInventoryTooltip;
    @track inspectionChecklistTooltip = labelList.InspectionchecklistTooltip;
    @track gmaWindowStickerURL= labelList.gmaWindowStickerURL;
    @track gmaCreateRDRURL= labelList.gmaCreateRDRURL;
    @track gmaRemoveInventoryURL= labelList.gmaRemoveInventoryURL;
    communityBasePath=communityList.COMMUNITY_BASE_PATH;

    createRDRVis = false;
    selectedVINs = '';

    @track invList = [];
    @track fieldMap = {};
    subMenus = {};

    theme;
    showTable = false;
    searchTerm = constants.SEARCH_TERM_ACTIVE_INVENTORY;
    selectedrows = [];
    showDownloadOptions = false;
    selDownloadOption = '';
    formFactor = FORM_FACTOR;
    downloadImage = IMAGES + constants.DOWNLOAD_IMAGE_120;

    downloadOptions = constants.DOWNLOAD_OPTIONS;

    constants = constants;
    dealerCode = '';

    
    get headerTitle() {
        return this.searchTerm;
    }

    get headerDescription() {
        return this.subMenus[this.searchTerm];
    }

    get isMobileView() {
        return this.formFactor == 'Small';
    }

    get disableCarfax() {
        return this.selectedrows.length != 1;
    }
    get disableInspectionChecklist() {
        return this.selectedrows.length != 1;
    }
    get showCarfax() {
        return this.searchTerm == constants.SEARCH_TERM_ACTIVE_INVENTORY || this.searchTerm == constants.SEARCH_TERM_CARFAX_DERCERTIFIED_VEHICLES;
    }
    
    get showWindowSticker() {
        return this.searchTerm == constants.SEARCH_TERM_ACTIVE_INVENTORY;
    }
    get showCarfaxToolTip() {
        return this.selectedrows.length > 1;
    }
    get showCreateRDRToolTip() {
        return this.selectedrows.length > 10;
    }
    get showWindowStickerToolTip() {
        return this.selectedrows.length > 10;
    }
    get showRemoveInventoryToolTip() {
        return this.selectedrows.length > 10;
    }
    get showInspectionChecklistToolTip() {
        return this.selectedrows.length > 1;
    }
    get showCreateRDR() {
        return this.searchTerm == constants.SEARCH_TERM_ACTIVE_INVENTORY;
    }
    get showRemoveInventory(){
        return this.searchTerm == this.activeInventory || this.searchTerm == this.agedInventory;
    }
    get showInspectionChecklist() {
        return this.searchTerm == this.activeInventory || this.searchTerm == this.agedInventory;
    }
    get disableWindowSticker() {
        return this.selectedrows.length == 0 || this.selectedrows.length > 10;
    }
    get disableCreateRDR() {
        return this.selectedrows.length == 0 || this.selectedrows.length > 10;
    }

    get disableRemoveInventory() {
        return this.selectedrows.length == 0 || this.selectedrows.length > 10;
    }

    get disableDownload() {
        return this.invList.length == 0;
    }

    get disablePrint() {
        return this.invList.length == 0;
    }

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                inventoryNavigationChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        this.searchTerm = message.selectedTab;
        this.showTable = false;
        this.callGetInventories();
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.getCurrentDealerCode();
        if (sessionStorage.getItem('activeSubMenu')) {
            let inventorySubMenu = sessionStorage.getItem('activeSubMenu')
            this.searchTerm = inventorySubMenu;

            this.showTable = false;
            this.callGetInventories();
        }
    }

    getCurrentDealerCode() {
        this.showSpinner = true;
        getDealerCode()
            .then(result => {
                this.dealerCode = result;
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    // get URL parameters
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference.state) {
            //console.log('PageReference parameters = ' + JSON.stringify(currentPageReference.state));

            this.urlStateParameters = currentPageReference.state;

            if (this.urlStateParameters.tab) {
                this.searchTerm = this.urlStateParameters.tab;
            }
            this.callGetInventories();
        }
    }

    callGetInventories() {
        this.showSpinner = true;
        let programType;

        if (sessionStorage.getItem('ProgramType')) {
            programType = sessionStorage.getItem('ProgramType');
        } else {
            programType = defaultProgramType();
        }

        // call getInventories
        getInventories({ searchTerm: this.searchTerm, programType: programType, networkId : this.networkId })
            .then(result => {
                //console.log('result = ', result);

                this.subMenus = result.SubMenus;

                if (result.FieldMap) {
                    this.fieldMap = result.FieldMap;
                    this.invList = (result.Inventories ? [...result.Inventories] : []);
                    this.showTable = true;
                } else {
                    this.showToast('', 'Error while processing the request. List view not found.', 'error', 'dismissable');
                }

                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('error in getInventories = ' + JSON.stringify(error));
            });
    }

    handleChange(event) {
        let name = event.target.name;
        let value = event.target.value;

        if (name == 'downloadOption') {
            this.exportData(value);
            event.target.value = '';
            this.showDownloadOptions = false;
        }
    }

    handleSelectedRows(event) {
        this.selectedrows = event.detail;
    }

    handleDownloadClick() {
        this.showDownloadOptions = true;
    }

    handlCarfaxClick() {
        this.showSpinner = true;

        let invId;
        this.invList.forEach(item => {
            if (this.selectedrows.includes(item.Id)) {
                invId = item.Id;
            }
        });

        // call getCarFaxURL
        getCarFaxURL({ invId: invId })
            .then(result => {
                if (result)
                    window.open(result);
                else {
                    this.showToast('', 'Error while processing the request.', 'error', 'dismissable');
                }

                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('error in getCarFaxURL = ' + error.body.message);
                this.showToast('', error.body.message, 'error', 'dismissable');
            });
    }
    handleInspectionChecklistClick(){
        this.showSpinner = true;
        let invId;
        this.invList.forEach(item => {
            if (this.selectedrows.includes(item.Id)) {
                invId = item.Id;
            }
        });

        // call InspectionChecklist
        getInspectionChecklistURL({ invId: invId,communityUrl:this.communityBasePath })
            .then(result => {
                if (result)
                    window.open(result);
                else {
                    this.showToast('', 'Error while processing the request.', 'error', 'dismissable');
                }

                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('', error.body.message, 'error', 'dismissable');
            });
    }
    handleWindowStickerClick() {
        this.showSpinner = true;
        let invVIN;
        for (let i = 0; i < this.invList.length; i++) {
            if (this.selectedrows.includes(this.invList[i].Id)) {
                if (invVIN)
                    invVIN = invVIN + ',' + this.invList[i].Name;
                else
                    invVIN = this.invList[i].Name;
                if (i == 9) {
                    break;
                }
            }
        }
        var urlVal='';
        if(communityList.COMMUNITY_BASE_PATH.includes('HMA') || communityList.COMMUNITY_BASE_PATH.includes('hyundai')){
            urlVal = this.windowStickerURL +'&' + communityList.DealerCode + '=' + this.dealerCode+ '&' + this.iamPram + '=' + invVIN ;
        }
        else if(communityList.COMMUNITY_BASE_PATH.includes('GMA') || communityList.COMMUNITY_BASE_PATH.includes('genesis')){
            urlVal = this.gmaWindowStickerURL +'&' + communityList.DealerCode + '=' + this.dealerCode+ '&' + this.iamPram + '=' + invVIN;
        }
        //var urlVal = this.windowStickerURL + '&' + this.iamPram + '=' + invVIN;
        window.open(urlVal, this.windowSticker);
        this.showSpinner = false;
    }

    handleCreateRDRClick() {
        this.showSpinner = true;
        let invVIN;
        for (let i = 0; i < this.invList.length; i++) {
            if (this.selectedrows.includes(this.invList[i].Id)) {
                if (invVIN)
                    invVIN = invVIN + ',' + this.invList[i].Name;
                else
                    invVIN = this.invList[i].Name;
                if (i == 9) {
                    break;
                }
            }
        }
        var urlVal='';
        if(communityList.COMMUNITY_BASE_PATH.includes('HMA') || communityList.COMMUNITY_BASE_PATH.includes('hyundai')){
            urlVal = this.createRDRURL +'&' + communityList.DealerCode + '=' + this.dealerCode+ '&' + this.iamPram + '=' + invVIN ;
        }
        else if(communityList.COMMUNITY_BASE_PATH.includes('GMA') || communityList.COMMUNITY_BASE_PATH.includes('genesis')){
            urlVal = this.gmaCreateRDRURL + '&' + communityList.DealerCode + '=' + this.dealerCode + '&' + this.iamPram + '=' + invVIN;
        }
        //var urlVal = this.createRDRURL + '&' + this.iamPram + '=' + invVIN;
        window.open(urlVal, this.createRDR);
        this.showSpinner = false;
    }

    handleRemoveInventoryClick() {
        this.showSpinner = true;
        let invVIN;
        for (let i = 0; i < this.invList.length; i++) {
            if (this.selectedrows.includes(this.invList[i].Id)) {
                if (invVIN)
                    invVIN = invVIN + ',' + this.invList[i].Name;
                else
                    invVIN = this.invList[i].Name;
                if (i == 9) {
                    break;
                }
            }
        }
        var urlVal='';
        if(communityList.COMMUNITY_BASE_PATH.includes('HMA') || communityList.COMMUNITY_BASE_PATH.includes('hyundai')){
            urlVal = this.removeInventoryURL +'&' + communityList.DealerCode + '=' + this.dealerCode+ '&' + this.iamPram + '=' + invVIN ;
        }
        else if(communityList.COMMUNITY_BASE_PATH.includes('GMA') || communityList.COMMUNITY_BASE_PATH.includes('genesis')){
            urlVal = this.gmaRemoveInventoryURL +'&'+ communityList.DealerCode + '=' + this.dealerCode+ '&' + this.iamPram + '=' + invVIN;
        }
        //var urlVal = this.removeInventoryURL + '&' + this.iamPram + '=' + invVIN;
        window.open(urlVal, this.removeInventory);
        this.showSpinner = false;
    }


    handleBlur() {
        this.showDownloadOptions = false;
    }

    exportData(option) {
        let doc = '';

        if (option == 'Excel') {
            // Prepare a html table
            doc = '<table>';
            // Add styles for the table
            doc += '<style>';
            doc += 'table, th, td {';
            doc += '    border: 1px solid black;';
            doc += '    border-collapse: collapse;';
            doc += '}';
            doc += '</style>';
            // Add all the Table Headers
            doc += '<tr>';

            for (const key in this.fieldMap) {
                doc += '<th>' + key + '</th>';
            }

            doc += '</tr>';
        } else {
            // Add all the Table Headers
            for (const key in this.fieldMap) {
                doc += key + ',';
            }
            doc += '\n';
        }

        // Add the data rows
        this.invList.forEach(item => {
            if (this.selectedrows.length == 0 || this.selectedrows.includes(item.Id)) {
                let values = [];

                for (const key in this.fieldMap) {
                    let apiName = this.fieldMap[key];
                    let value = (item[apiName] ? item[apiName] : '');

                    values.push(value);
                }

                if (option == 'Excel') {
                    doc += '<tr>';

                    values.forEach(value => {
                        doc += '<td>' + value + '</td>';
                    });

                    doc += '</tr>';
                } else {
                    values.forEach(value => {
                        doc += value + ',';
                    });

                    doc += '\n';
                }
            }
        });

        if (option == 'Excel') {
            doc += '</table>';
        }

        var element = (option == 'Excel' ? 'data:application/vnd.ms-excel,' : 'data:text/csv;charset=utf-8,') + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = this.searchTerm + '.' + (option == 'Excel' ? 'xls' : 'csv');
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
}