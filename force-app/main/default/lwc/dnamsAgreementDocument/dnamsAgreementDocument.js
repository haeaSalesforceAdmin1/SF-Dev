/**
 * Created by Bhavana on 2023-09-15.
 */
/**
 * Dnams Agreement Document Component
 */
import {api, LightningElement, track, wire} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import getRelatedFilesByRecordId from '@salesforce/apex/DNAMSAgreementDocumentsController.getRelatedFilesByRecordId';
import basepath from '@salesforce/community/basePath';

export default class DnamsAgreementDocument extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showRecords = false;
    @track showError = false;
    @track showOnload = true;
    @track isModalOpen = false; // Track modal visibility
    @track records = [];
    @track allRecords = [];
    @track firstFourRecords = [];
    @track showViewAll = true;
    @track showViewLess = false;
    @track sortDirection = 'desc';
    @track sortBy = 'LastModified';
    @track baseUrl='';
    showSpinner = false;
    @track communityBasePath;

    columns = [
        {
            label: 'Title', fieldName: 'packageRequestUrl', type: 'url', wrapText: true, sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'Title'
                },
                target: '_self'
            }
        },
        {label: 'File Extension', fieldName: 'FileExtension', type: 'text', wrapText: true, sortable: true},
        {label: 'Last Modified', fieldName: 'LastModified', type: 'text', wrapText: true, sortable: true},
        {label: 'Size', fieldName: 'Size', type: 'text', wrapText: true, sortable: true},
        { label: '', type: 'action', typeAttributes: { rowActions: this.getRowActions }}
    ];
    // Define row actions
    getRowActions(row, doneCallback) {
        const actions = [
            { label: 'Download', name: 'download' }
        ];
        doneCallback(actions);
    }
    filesList =[];

    connectedCallback() {
        this.communityBasePath = basepath;
        this._initDataset();
    }
    _initDataset() {
        //Fetch the Package Element page information
        getRelatedFilesByRecordId({
                recordId: this.recordId
            })
            .then(result => {
                let baseUrl = 'https://' + location.host + this.communityBasePath ;
                let data = JSON.parse(result);
                let processedResult = [];
                data.forEach(record => {
                    record.packageRequestUrl = baseUrl + '/contentdocument/' + record.Id;
                    var consize = parseInt(record.Size);
                    var total;
                    if (consize < 1024){
                        total = String(consize) + ' Bytes';
                    }else if (consize >= 1024 && consize < (1024*1024)){
                        var kb = consize;
                        kb = kb / 1024;
                        total = String(Math.round(kb)) + ' KB';
                    }else if (consize >= (1024*1024) && consize < (1024*1024*1024)){
                        var mb = consize;
                        mb = mb/(1024*1024);
                        total = String(Math.round(mb)) + ' MB';
                    }else{
                        var gb = consize;
                        gb = gb/(1024*1024*1024);
                        total = String( Math.round(gb)) + ' GB';
                    } 
                    record.Size = total;
                    processedResult.push(record);
                });
                
                this.allRecords = processedResult;
                let number;
                if(processedResult.length > 4){
                    number = 4;
                }else{
                    number = processedResult.length
                }
                for (let i = 0; i < number; i++) {
                    console.log('i======================>'+i);
                    this.firstFourRecords.push(processedResult[i]);
                    console.log('i======================>'+JSON.stringify(processedResult[i]));
                }
                this.records = this.firstFourRecords;

                if(this.records.length > 0){
                    this.showRecords = true;
                    this.sortData(this.sortBy, this.sortDirection);
                }else{
                    this.showRecords = false;
                }
                this.showError = false;
            }).catch(error => {
                console.error(error);
                this.showRecords = false;
                this.showError = true;
                this.showOnload = true; // Disable the New button
            }
        );
    }
    
    handleRowAction(event) {
        this.showSpinner = true;
        const action = event.detail.action.name;
        const recordId = event.detail.row.Id;
        let baseUrl = 'https://' + location.host + this.communityBasePath + '/';
        baseUrl= baseUrl.replace('/s/', '/');
        if (action === 'download') {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: baseUrl + '/sfc/servlet.shepherd/document/download/' + recordId
                }
            });
            
        } 
    }
    viewAll(){
        this.showSpinner = true;
        this.records = this.allRecords;
        this.showViewAll = false;
        this.showViewLess = true;
        this.showSpinner = false;
    }
    viewLess(){
        this.showSpinner = true;
        this.records = this.firstFourRecords;
        this.showViewAll = true;
        this.showViewLess = false;
        this.showSpinner = false;
    }
    /*
     * Client controller to initiate sorting on-click of the data table column headers
     */
    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    /*
     * Sort data table columns by the column header
     */
    sortData(fieldName, sortDirection) {
        let parseData = JSON.parse(JSON.stringify(this.records));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldName];
        };
        // cheking reverse direction
        let isReverse = sortDirection === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.records = parseData;
    }
    /*
     * Function to capture the current column label on which sorting is performed.
     * this.sortBy stores the column's fieldName attribute. We need column label instead of the fieldName
     */
    get sortByLabel() {
        if(this.sortBy == 'packageRequestUrl')
            return 'Title';
        else if(this.sortBy == 'LastModified')
            return 'Last Modified';
        else if(this.sortBy == 'Size')
            return 'Size';
        else if(this.sortBy == 'FileExtension')
            return 'File Extension';    
        else
            return this.sortBy;
    }
    
}