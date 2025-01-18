/**
 * Created by baltamimi on 2022-02-10.
 */

import {LightningElement, api, track} from 'lwc';
import {reduceErrors} from "c/ldsUtils";
import {FlowNavigationNextEvent} from 'lightning/flowSupport';
import getTemplatePackageElements
    from '@salesforce/apex/PackageElementsSelectorController.getPackageElementsFromTemplate';
import createNewPackage from '@salesforce/apex/PackageElementsSelectorController.createNewPackage';

const actions = [
  //  {label: 'Delete', name: 'delete'} DNA-1022 Disable element deletion
];

//Package Elements table columns 
const mainTableColumns = [
    {label: 'Name', fieldName: 'Name'},
    {label: 'Section', fieldName: 'Section__c', type: 'text'},
    {label: 'Type', fieldName: 'Type__c', type: 'text'},
    {label: 'Is Required', fieldName: 'Required__c', type: 'boolean', editable: false, fixedWidth: 100},
    {label: 'Visible to Dealer', fieldName: 'VisibletoDealer__c', type: 'boolean', editable: false, fixedWidth: 130},
    {
        type: 'action',
        typeAttributes: {rowActions: actions},
    }
];

const addMoreColumns = [
    {label: 'SN', fieldName: 'Sequence__c', type: 'number', fixedWidth: 60},
    {label: 'Name', fieldName: 'Name'},
    {label: 'Section', fieldName: 'Section__c', type: 'text'},
    {label: 'Type', fieldName: 'Type__c', type: 'text'},
    {label: 'Is Required', fieldName: 'Required__c', type: 'boolean', fixedWidth: 100},
    {label: 'Visible to Dealer', fieldName: 'VisibletoDealer__c', type: 'boolean', fixedWidth: 130},
];

export default class PackageElementsSelector extends LightningElement {

    @api templatePackageId;
    @api dealerId;
    @api sellingDealerId;
    @api originalData;
    @track templateElements = [];
    @track otherTemplateElements = [];
    @api createdPackageId;
    @api errorMessage;
    @api packageName;
    @api packageDescription;
    @api primaryContactId;

    mainColumns = mainTableColumns;
    addMoreColumns = addMoreColumns;
    saveDisabled = false;

    // Add new Template modal
    @track isOpenModal = false;

    openModal() {
        this.isOpenModal = true;
    }

    closeModal() {
        this.isOpenModal = false;
    }

    saveModal() {
        let selector = this.template.querySelector('.addMoreDataTable');

        let rows = selector.getSelectedRows();
        for (let index in rows) {
            let row = rows[index];
            this.templateElements = [...this.templateElements, row];

            this.otherTemplateElements = this.deleteRow(this.otherTemplateElements, row);

        }
        this.isOpenModal = false;
    }

    connectedCallback() {
        //Fetch the template package elements
        getTemplatePackageElements({templatePackageId: this.templatePackageId})
            .then(result => {
                this.originalData = result;
                console.log(JSON.stringify(this.originalData));

                let tempSelectedElements = [];
            //    let tempOtherElements = [];
                for (let row in this.originalData) {
                    console.log(JSON.stringify(row));
                    console.log(JSON.stringify(this.originalData[row].Required__c));

                 //   if (this.originalData[row].Required__c) {
                        tempSelectedElements.push(this.originalData[row]);
                 //   } else {
                 //       tempOtherElements.push(this.originalData[row]);
                 //   }
                }
                this.templateElements = tempSelectedElements;
             //   this.otherTemplateElements = tempOtherElements;

            }).catch(error => {
            console.log(error);
        });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.otherTemplateElements.push(row);
                this.templateElements = this.deleteRow(this.templateElements, row);
                break;
            default:
        }
    }

    handleUpdate(event) {
        this.saveDisabled = true;
        let draftValues = this.template.querySelector('.mainDataTable').draftValues;
        console.log(draftValues);
        console.log('Draft Values: ' + JSON.stringify(draftValues));

        console.log('Template Element Before: ' + JSON.stringify(this.templateElements));

        for (let draftValue in draftValues) {
            console.log(JSON.stringify(draftValue));
            let index = this.findRowIndexById(this.templateElements, draftValues[draftValue].Id);
            if (draftValues[draftValue].VisibletoDealer__c) {
                this.templateElements[index].VisibletoDealer__c = draftValues[draftValue].VisibletoDealer__c;
            }
            if (draftValues[draftValue].Required__c) {
                this.templateElements[index].Required__c = draftValues[draftValue].Required__c;
            }
        }

        console.log('Template Element After: ' + JSON.stringify(this.templateElements));
        console.log('Package Name: ' + this.packageName);
        console.log('Package Description: ' + this.packageDescription);
        console.log('Primary Contact ID: ' + this.primaryContactId);
        //Create new package  
        createNewPackage({
            dealerId: this.dealerId,
            sellingDealerId: this.sellingDealerId,
            templatePackageId: this.templatePackageId,
            packageName: this.packageName,
            packageDescription: this.packageDescription,
            primaryContactId: this.primaryContactId,
            selectedPackageElementsTemplates: this.templateElements
        })
            .then(result => {
                this.createdPackageId = result;
                console.log('SUCCESS!! Package Id = ' + this.createdPackageId);

                let navigationEvent = new FlowNavigationNextEvent();

                try {
                    this.dispatchEvent(navigationEvent);
                } catch (err) {
                    console.log('ERROR!!' + JSON.stringify(error));
                    this.errorMessage = reduceErrors(this.error);
                }
                
            }).catch(error => {
            console.log('ERROR!!' + JSON.stringify(error));
            this.errorMessage = reduceErrors(this.error);
        });
    }

    deleteRow(arr, row) {
        const {Id} = row;
        const index = this.findRowIndexById(arr, Id);
        if (index !== -1) {

            arr = arr
                .slice(0, index)
                .concat(arr.slice(index + 1));
        }

        return arr;
    }

    findRowIndexById(arr, Id) {
        let ret = -1;
        arr.some((row, index) => {
            if (row.Id === Id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }
}