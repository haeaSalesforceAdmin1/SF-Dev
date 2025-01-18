/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 02-02-2021
 * @last modified by  : Amit Singh
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   02-02-2021   Amit Singh   Initial Version
**/
import {LightningElement, api, track} from 'lwc';
export default class MultiSelectPicklistLwc extends LightningElement {

    /* 
        component receives the following params:
        label - String with label name;
        disabled - Boolean value, enable or disable Input;
        options - Array of objects [{label:'option label', value: 'option value'},{...},...];
    
        to clear the value call clear() function from parent:
        let multiSelectPicklist = this.template.querySelector('c-multi-select-pick-list');
        if (multiSelectPicklist) {
           multiSelectPicklist.clear();
        }
   
        to get the value receive "valuechange" event in parent;
        returned value is the array of strings - values of selected options;
        example of usage:
        <c-multi-select-pick-list options={marketAccessOptions}
                                   onvaluechange={handleValueChange}
                                   label="Market Access">
        </c-multi-select-pick-list>

        handleValueChange(event){
            console.log(JSON.stringify(event.detail));
        }
    */


    @api label = "Default label";
    @api fieldName;
    @api showlabel = false;
    _disabled = false;
    _isRequired = false;
    @api
    get disabled(){
        return this._disabled;
    }
    set disabled(value){
        this._disabled = value;
        this.handleDisabled();
    }
    @api
    get isRequired(){
        return this._isRequired;
    }
    set isRequired(value){
        this._isRequired = value;
    }
    @track inputOptions;
    value = [];
    @api
    get options() {
        return this.inputOptions.filter(option => option.value !== 'All');
    }
    set options(value) {
        this.value = [];
        
        let valueObj = JSON.parse(JSON.stringify(value));
        this.inputOptions = valueObj;
       
        for(let i = 0; i < this.inputOptions.length; i++){
            if(this.inputOptions[i].isSelected) {
                this.value.push(this.inputOptions[i]);
            }
        }

        if (this.value.length > 1) {
            let allOption = this.inputOptions.find(allOpt => allOpt.value === 'All');
            if(allOption && allOption.isSelected){
                this.inputValue = 'All';
            } else {
                this.inputValue = this.value.length + ' options selected';
            }  
        }
        else if (this.value.length === 1) {
            this.inputValue = this.value[0].label;
        } else {
            this.inputValue = 'Select'
        }
    }
    @api vehicleid;
    @api
    clear(){
        this.handleAllOption();
    }
    @track inputValue = 'Select';
    hasRendered;
    renderedCallback() { 
        if (!this.hasRendered) {
            //  we coll the logic once, when page rendered first time
            this.handleDisabled();
        }
        this.hasRendered = true;
    }

    connectedCallback(){
        
    }

    handleDisabled(){
        let input = this.template.querySelector("input");
        if (input){
            input.disabled = this.disabled;
        }
    }
    comboboxIsRendered;
    handleClick() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.toggle("slds-is-open");
        if (!this.comboboxIsRendered){
            // let allOption = this.template.querySelector('[data-id="All"]');
            // allOption.firstChild.classList.add("slds-is-selected");
            this.comboboxIsRendered = true;
        }
    }
    handleSelection(event) {
        let value = event.currentTarget.dataset.value;
        if (value === 'All') {
            this.handleAllOption();
        }
        else {
            this.handleOption(event, value);
        }
        let input = this.template.querySelector("input");
        input.focus();
        console.log('Updated Options: ');
        console.log(JSON.stringify(this.inputOptions));
        this.sendValues();
    }
    sendValues(){
        let data = {vehicleid: this.vehicleid, label: this.label, options: this.inputOptions, fieldName: this.fieldName};
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: data
        }));
    }
    handleAllOption(){
        console.log('In Handle All Option');
        this.value = [];
        this.inputValue = 'All';
        // let listBoxOptions = this.template.querySelectorAll('.slds-is-selected');
        // for (let option of listBoxOptions) {
        //     option.classList.remove("slds-is-selected");
        // }
        let option = this.inputOptions.find(option => option.value === 'All');
        console.log('All Option Obj: ');
        console.log(JSON.stringify(option));
        option.isSelected = !option.isSelected;

        if(option && option.isSelected){
            this.value = [];
            console.log('All option is selected');
            for(let i = 0; i < this.inputOptions.length; i++){
                this.inputOptions[i].isSelected = true;
                this.value.push(this.inputOptions[i]);
            }
        } else {
            console.log('All option is not selected');
            for(let i = 0; i < this.inputOptions.length; i++){
                this.inputOptions[i].isSelected = false;
            }
            this.value = [];
        }
    }
    handleOption(event, value){
        try {
            console.log('Beginning of Options Selected Method');
            console.log(JSON.stringify(value));
            let option = this.inputOptions.find(option => option.value === value);
            let allOption = this.inputOptions.find(allOpt => allOpt.value === 'All');
            if(option.isSelected){
                this.value = this.value.filter(option => option.value !== value);
                if(allOption.isSelected){
                    allOption.isSelected = false;
                }
            } else {
                this.value.push(option);
            }
            console.log('Option: ');
            option.isSelected = !option.isSelected;
            console.log(JSON.stringify(option));

            if (allOption.isSelected) {
                this.inputValue = 'All';
            } else if (this.value.length > 1) {
                this.inputValue = this.value.length + ' options selected';
            }
            else if (this.value.length === 1) {
                this.inputValue = this.value[0].label;
            }
            else {
                this.inputValue = 'Select';
            }

            console.log('Selected Options: ');
            console.log(JSON.stringify(this.value));
        } catch (error) {
            console.log('Error: ' + error);
        }
        
    }
    dropDownInFocus = false;
    handleBlur() {
        if (!this.dropDownInFocus) {
            this.closeDropbox();
        }
    }
    handleMouseleave() {
        this.dropDownInFocus = false;
    }
    handleMouseEnter() {
        this.dropDownInFocus = true;
    }
    closeDropbox() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.remove("slds-is-open");
    }
}