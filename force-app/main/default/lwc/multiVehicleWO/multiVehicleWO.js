import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getAffectedVehicles from '@salesforce/apex/multiVehicleWOController.getAffectedVehicles';
import getVehicleMakes from '@salesforce/apex/multiVehicleWOController.getVehicleMakes';
import getVehicleModels from '@salesforce/apex/multiVehicleWOController.getVehicleModels';
import getVehicleYears from '@salesforce/apex/multiVehicleWOController.getVehicleYears';
import getVehicleModelcodes from '@salesforce/apex/multiVehicleWOController.getVehicleModelcodes';
import saveVehicles from '@salesforce/apex/multiVehicleWOController.saveVehicles';
import deleteVehicles from '@salesforce/apex/multiVehicleWOController.deleteVehicles';
import getVehicleUpdateOptions from '@salesforce/apex/multiVehicleWOController.getVehicleUpdateOptions';
import deleteAllVehicles from '@salesforce/apex/multiVehicleWOController.deleteAllVehicles';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import INFO_BAD_DATA_LABEL from '@salesforce/label/c.INFO_BAD_DATA';

export default class MultiVehicleWO extends NavigationMixin(LightningElement) {
    @track showNewScreen = false;
    // Table Logics
    @api recordId;
    @track vehicleOptions = {
        make: [],
        model: [],
        year: [],
        modelCode: [],
    };
    @track affectedVehicles = [];
    @track hasMultiRows = false;

    @track isEdit = false;
    @track isNew = false;

    @track isConfDialogVisible = false;

    @track showSpinner = false;

    @track isClearAllClicked = false;

    @track summaryList = [];
    @track errorList = [];

    label = {
        INFO_BAD_DATA_LABEL
    };

    vehicleIdToDelete = '';

    connectedCallback(){
        console.log('222!!');
        this.retrieveAffectedVehicles();
        // Load all vehicles makes
        this.retrieveVehicleMakes();
    }

    retrieveAffectedVehicles(){
        this.errorList = [];

         getAffectedVehicles({woId: this.recordId})
         .then(result => {
             console.log('Result: ');
             this.affectedVehicles = JSON.parse(result);
             console.log(this.affectedVehicles);
             this.hasMultiRows = this.affectedVehicles.length > 1;
         }).catch(error => {
             // TODO: Error Handling
             console.log('Error fetching affected vehicles');
             console.log(JSON.stringify(error));
             this.errorList.push(JSON.stringify(error));
         })
    }

    retrieveVehicleMakes(){
        this.showSpinner = true;
        // Get All Vehicle Makes
        let selectedMakes = Array.prototype.map.call(this.vehicleOptions.make.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";"); 
        getVehicleMakes({selectedMakes: selectedMakes})
        .then(result => {
            console.log('Vehicle Make: ');
            console.log(result);
            let allOptions = [{
                value: 'All',
                label: 'All',
                isSelected: false
            }];
            let resultObj = JSON.parse(result);
            if(resultObj.length > 0){
                this.vehicleOptions.make = allOptions.concat(resultObj);
            }

            this.showSpinner = false;
        }).catch(error => {
            console.log('Error fetching Vehicle Make: ');
            console.log(error);
            this.errorList.push(JSON.stringify(error));
            this.showSpinner = false;
        })
    }

    retrieveVehicleYears(){
        this.showSpinner = true;
        let vehicleMakes = Array.prototype.map.call(this.vehicleOptions.make.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";"); 
        let vehicleModels = Array.prototype.map.call(this.vehicleOptions.model.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        let vehicleYears = Array.prototype.map.call(this.vehicleOptions.year.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        console.log('Vehicle Makes: ' + vehicleMakes);
        console.log('Vehicle Years: ' + vehicleYears);
        console.log('Vehicle Models: ' + vehicleModels);
        console.log(JSON.stringify(this.vehicleOptions));
        // Get All Vehicle Years
        getVehicleYears({makes: vehicleMakes, models: vehicleModels, selectedYears: vehicleYears})
        .then(result => {
            console.log('Vehicle Years Result: ');
            console.log(result);

            let allOptions = [{
                value: 'All',
                label: 'All',
                isSelected: false
            }];
            let resultObj = JSON.parse(result);
            if(resultObj.length > 0){
                this.vehicleOptions.year = allOptions.concat(resultObj);
            }

            this.showSpinner = false;
        }).catch(error => {
            console.log('Error fetching Vehicle Years: ');
            console.log(error);
            this.errorList.push(JSON.stringify(error));
            this.showSpinner = false;
        })
    }

    retrieveVehicleModels(){
        this.showSpinner = true;
        let vehicleMakes = Array.prototype.map.call(this.vehicleOptions.make.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";"); 
        let vehicleModels = Array.prototype.map.call(this.vehicleOptions.model.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        console.log('Vehicle Makes: ' + vehicleMakes);
        console.log('Vehicle Models: ' + vehicleModels);
        console.log(JSON.stringify(this.vehicleOptions));
        // Get All Vehicle Models
        getVehicleModels({makes: vehicleMakes, selectedVehicleModels: vehicleModels})
        .then(result => {
            console.log('Vehicle Model: ');
            console.log(result);

            let allOptions = [{
                value: 'All',
                label: 'All',
                isSelected: false
            }];
            let resultObj = JSON.parse(result);
            if(resultObj.length > 0){
                this.vehicleOptions.model = allOptions.concat(resultObj);
            }

            this.showSpinner = false;
        }).catch(error => {
            console.log('Error fetching Vehicle Model: ');
            console.log(error);
            this.errorList.push(JSON.stringify(error));
            this.showSpinner = false;
        })
    }

    retrieveVehicleModelCodes(){
        this.showSpinner = true;
        let vehicleMakes = Array.prototype.map.call(this.vehicleOptions.make.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";"); 
        let vehicleYears = Array.prototype.map.call(this.vehicleOptions.year.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        let vehicleModels = Array.prototype.map.call(this.vehicleOptions.model.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        let vehicleModelcodes = Array.prototype.map.call(this.vehicleOptions.modelCode.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        console.log('Vehicle Options: ');
        console.log(JSON.stringify(this.vehicleOptions));
        // Get All Vehicle Modelcodes
        getVehicleModelcodes({makes: vehicleMakes, years: vehicleYears, models: vehicleModels, selectedModelcodes: vehicleModelcodes})
        .then(result => {
            console.log('Vehicle Modelcodes: ');
            console.log(result);
            let allOptions = [{
                value: 'All',
                label: 'All',
                isSelected: false
            }];
            let resultObj = JSON.parse(result);
            if(resultObj.length > 0){
                this.vehicleOptions.modelCode = allOptions.concat(resultObj);
            }

            this.showSpinner = false;
        }).catch(error => {
            console.log('Error fetching Vehicle Modelcodes: ');
            console.log(error);
            this.errorList.push(JSON.stringify(error));
            this.showSpinner = false;
        })
    }

    retrieveVehicleUpdateOptions(){
        this.showSpinner = true;
        this.errorList = [];

        let vehicleMakes = Array.prototype.map.call(this.vehicleOptions.make.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";"); 
        let vehicleYears = Array.prototype.map.call(this.vehicleOptions.year.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        let vehicleModels = Array.prototype.map.call(this.vehicleOptions.model.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        let vehicleModelcodes = Array.prototype.map.call(this.vehicleOptions.modelCode.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        console.log('Vehicle Options: ');
        console.log(JSON.stringify(this.vehicleOptions));
        // Get All Vehicle Update Options
        getVehicleUpdateOptions({makes: vehicleMakes, years: vehicleYears, models: vehicleModels, modelcodes: vehicleModelcodes})
        .then(result => {
            console.log('Vehicle Update Options: ');
            console.log(result);
            this.vehicleOptions = JSON.parse(result);
            this.vehicleOptions.make.sort((a, b) => a.value.localeCompare(b.value));
            this.vehicleOptions.model.sort((a, b) => a.value.localeCompare(b.value));
            this.vehicleOptions.year.sort((a, b) => b.value.localeCompare(a.value));
            this.vehicleOptions.modelCode.sort((a, b) => a.value.localeCompare(b.value));

            if(this.vehicleOptions.make.length > 0){
                let allOptions = [{
                    value: 'All',
                    label: 'All',
                    isSelected: false
                }];
                this.vehicleOptions.make = allOptions.concat(this.vehicleOptions.make);
            }
            if(this.vehicleOptions.model.length > 0){
                let allOptions = [{
                    value: 'All',
                    label: 'All',
                    isSelected: false
                }];
                this.vehicleOptions.model = allOptions.concat(this.vehicleOptions.model);
            }
            if(this.vehicleOptions.year.length > 0){
                let allOptions = [{
                    value: 'All',
                    label: 'All',
                    isSelected: false
                }];
                this.vehicleOptions.year = allOptions.concat(this.vehicleOptions.year);
            }
            if(this.vehicleOptions.modelCode.length > 0){
                let allOptions = [{
                    value: 'All',
                    label: 'All',
                    isSelected: false
                }];
                this.vehicleOptions.modelCode = allOptions.concat(this.vehicleOptions.modelCode);
            }

            this.showSpinner = false;
        }).catch(error => {
            console.log('Error fetching Vehicle Update Options: ');
            console.log(error);
            this.errorList.push(JSON.stringify(error));
            this.showSpinner = false;
        })
    }

    handleValueChange(event){
        this.errorList = [];

        console.log('Value Changed: ');
        console.log(JSON.stringify(event));
        let vehicleId = event.detail.vehicleid;
        if(vehicleId){
            // check if affected vehicle is changed
            let vehicle = this.affectedVehicles.find(vehicle => vehicle.id === event.detail.vehicleid);
            if(vehicle){
                vehicle[event.detail.label].options = event.detail.options;
            }
            console.log(event.detail.vehicleid);

        } else {
            // Check if vehicle option is changed
            console.log('Vehicle option is changed');
            console.log(JSON.stringify(event.detail));
            this.vehicleOptions[event.detail.fieldName] = event.detail.options;
            if(event.detail.fieldName === 'make'){
                this.retrieveVehicleModels();
                this.retrieveVehicleYears();
                this.retrieveVehicleModelCodes();
            } else if(event.detail.fieldName === 'model'){
                this.retrieveVehicleYears();
                this.retrieveVehicleModelCodes();
            } else if(event.detail.fieldName === 'year'){
                this.retrieveVehicleModelCodes();
            }
        }
    }

    // When new button on Lightning card is clicked
    handleNewBtn(event){
        console.log('New button clicked');
        this.showNewScreen = true;
        this.isNew = true;
        this.isEdit = false;
        this.summaryList = [];
        this.errorList = [];
        this.resetVehicleOptions();
    }

    // When cancel button is clicked in New Vehicle Screen
    handleNewScrCancelBtn(event){
        // Hide New Screen
        this.showNewScreen = false;
        //this.resetVehicleOptions();
    }

    resetVehicleOptions(){
        this.vehicleOptions = {
            make: [],
            model: [],
            year: [],
            modelCode: [],
        };
        this.isEdit = false;
        this.summaryList = [];
        this.errorList = [];
        this.retrieveVehicleMakes();
    }

    // When save button is clicked in New Vehicle Screen
    handleNewScrSaveBtn(event){
        this.showSpinner = true;
        console.log('Save button is clicked');
        let isRequiredFieldValid = true;
        let requiredFieldNull = '';
        this.errorList = [];
        this.summaryList = [];
        let vehicleMakes = Array.prototype.map.call(this.vehicleOptions.make.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";"); 
        let vehicleYears = Array.prototype.map.call(this.vehicleOptions.year.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        let vehicleModels = Array.prototype.map.call(this.vehicleOptions.model.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        let vehicleModelcodes = Array.prototype.map.call(this.vehicleOptions.modelCode.filter(x => x.isSelected == true), function(item) { return item.value; }).join(";");
        if(vehicleMakes === null || vehicleMakes === 'null' || vehicleMakes === ''){
            vehicleMakes = '';
            isRequiredFieldValid = false;
            requiredFieldNull = 'Make';
            console.log('Vehicle Make is empty');
        }
        if(vehicleModels === null || vehicleModels === 'null' || vehicleModels === ''){
            vehicleModels = '';
            isRequiredFieldValid = false;
            if(requiredFieldNull === '') requiredFieldNull = 'Model';
        }
        if(vehicleYears === null || vehicleYears === 'null' || vehicleYears === ''){
            vehicleYears = '';
            isRequiredFieldValid = false;
            if(requiredFieldNull === '') requiredFieldNull = 'Year';;
        }
        if(vehicleModelcodes === null || vehicleModelcodes === 'null' || vehicleModelcodes === ''){
            vehicleModelcodes = '';
            //isRequiredFieldValid = false;
            //if(requiredFieldNull === '') requiredFieldNull = 'Model Code';
        }
        
        if(isRequiredFieldValid){
            saveVehicles({woId: this.recordId, makes: vehicleMakes, years: vehicleYears, models: vehicleModels, modelcodes: vehicleModelcodes})
            .then(result => {
                console.log('Save Result: ');
                console.log(result);
                this.summaryList = JSON.parse(result);
                this.retrieveAffectedVehicles();
                this.errorList = [];
                this.refreshRecord();
                this.showSpinner = false;
            }).catch(error => {
                console.log('Error: ');
                console.log(JSON.stringify(error));
                this.errorList.push(JSON.stringify(error));
                this.showSpinner = false;
            })
        } else {
            this.errorList.push('Please make sure Vehicle ' + requiredFieldNull + ' has value');
            this.showSpinner = false;
        }
    }

    handleVehicleEdit(event){
        console.log('Vehicle Edit is clicked!');
        this.isNew = false;
        this.isEdit = true;
        this.summaryList = [];
        this.errorList = [];
        this.showNewScreen = true;
        let vehicle = this.affectedVehicles.find(vehicle => vehicle.id === event.currentTarget.dataset.id);
        if(vehicle){
            this.vehicleOptions.make = vehicle.make.options;
            this.vehicleOptions.model = vehicle.model.options;
            this.vehicleOptions.year = vehicle.year.options;
            this.vehicleOptions.modelCode = vehicle.modelCode.options;
            
            // Get Vehicle Data
            this.retrieveVehicleUpdateOptions();
        }

        console.log(JSON.stringify(this.vehicleOptions));
    }

    handleVehicleDelete(event){
        this.errorList = [];

        let vehicleIds = event.currentTarget.dataset.id;
        console.log('Vehicle Delete is clicked: ' + vehicleIds);
        this.vehicleIdToDelete = vehicleIds;
        this.isConfDialogVisible = true;
    }

    handleClearAllBtn(){
        this.isClearAllClicked = true;
        this.isConfDialogVisible = true;
    }

    handleResetBtn(){
        this.resetVehicleOptions();
    }

    handleConfirmationClick(event){
        this.errorList = [];

        //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
        if(event.detail !== 1){
            //gets the detail message published by the child component
            console.log('Status: ' + event.detail.status + '. Event detail: ' + JSON.stringify(event.detail.originalMessage) + '.');
            //you can do some custom logic here based on your scenario
            if(event.detail.status === 'confirm') {
                if(this.isClearAllClicked){
                    this.isClearAllClicked = false;
                    this.showSpinner = true;
                    deleteAllVehicles({woId: this.recordId})
                    .then(result => {
                        this.refreshRecord();
                        this.showSpinner = false;
                        this.affectedVehicles = [];
                        this.hasMultiRows = false;
                    }).catch(error => {
                        console.log('Error deleting all vehicles');
                        console.log(JSON.stringify(error));
                    })
                } else {
                    this.showSpinner = true;
                    console.log('Confirm is clicked!');
                    deleteVehicles({vehicleIds: this.vehicleIdToDelete, woId: this.recordId})
                    .then(result => {
                        console.log(result);
                        this.affectedVehicles = this.affectedVehicles.filter(vehicle => vehicle.id !== this.vehicleIdToDelete);
                        this.hasMultiRows = this.affectedVehicles.length > 1;
                        this.refreshRecord();
                        this.showSpinner = false;
                    }).catch(error => {

                        this.errorList.push('Error while deleting the record. Error Details: ' + error.body.message);
                        console.log('Error while deleting the record. Error Details: ' + JSON.stringify(error));
                        console.log(error);
                        this.showSpinner = false;
                    })
                }
            }else if(event.detail.status === 'cancel'){
                //do something else
                console.log('Cancel is clicked!');
                this.isClearAllClicked = false;
            }
        }

        //hides the component
        this.isConfDialogVisible = false;
    }

    refreshRecord(){
        getRecordNotifyChange([{recordId: this.recordId}]);
    }

    viewRecord(event){
        console.log('Redirect to : ' + event.target.value);
        // Navigate to Account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "LRVehicle__c",
                "actionName": "view"
            },
        });
    }
}