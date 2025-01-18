import { LightningElement, api, wire, track } from 'lwc';
import RecordTypeId_FIELD from "@salesforce/schema/Case.RecordTypeId";
import getPickListValuesIntoList from '@salesforce/apex/girReivewController.getPickListValuesIntoList';
import getSelectClonRegion from '@salesforce/apex/girReivewController.getSelectClonRegion';
import getSelectOtherSafetyOffice from '@salesforce/apex/girReivewController.getSelectOtherSafetyOffice';

const field = [RecordTypeId_FIELD];

export default class GirReivew extends LightningElement {

	girCloneRegionOptions = [];
	selectedValue=[];
	@api recordId;
    @api girComplete;
	@api girCloneRegions;
	inputValue = 'Select';
    @track inputOptions=[];
    @wire(getSelectOtherSafetyOffice, {recordId: '$recordId'})
    otherSafetyOffice;

	@wire(getPickListValuesIntoList, {flowRecordId: '$recordId'})
	getRegionPicklist({ error, data }) {
		let options = [];
        if(data){
            console.log('pickList' + data);
            this.error = undefined;
            data.forEach(r => {
                options.push({
                    label: r,
                    value: r,
                });
            });
            this.inputOptions = options;
            if(localStorage.getItem('myKey')==null){
                this.getOtherSafetyValue();
            }
            this.getLocalStorage();
           
            
		} else if(error){
		 	console.log(error);
		 	this.error = error;
		 	//this.pickListvalues = undefined;
		}
       
	};

    getOtherSafetyValue(){
        this.otherSafetyOffice.data.forEach(r => {
            let target = r;
            let option3 = this.inputOptions.find(option1 => option1.value === target);
            option3.isSelected = true;
            this.selectedValue.push(target);
        });

        this.inputValue = this.selectedValue.length+' options selected';
        getSelectClonRegion({selectedValueString : this.selectedValue})
        .then(res => {
			this.girCloneRegions = res;
			this.girComplete = true;
        })
        localStorage.clear();
    }

    getLocalStorage(){
        let data = localStorage.getItem('myKey');
        console.log('lwc getLocalStorage');
        if(data != null && data != ''){
            let listData = data.split(',');
            let selectedOptionNum=0;
            for(let i in listData){
                let target = listData[i];
                let option1 = this.inputOptions.find(option1 => option1.value === target);
                option1.isSelected = true;
                this.selectedValue.push(target);
                selectedOptionNum++;
            }
            this.inputValue = selectedOptionNum+ ' options selected';
            getSelectClonRegion({selectedValueString : this.selectedValue})
            .then(res => {
			this.girCloneRegions = res;
			this.girComplete = true;
			console.log('girCloneRegions : ', this.girCloneRegions);
        })
            localStorage.clear();
        }
    }




    handleSelection(event) {
        let value = event.currentTarget.dataset.value;
        let option = this.inputOptions.find(option => option.value === value);
        option.isSelected = !option.isSelected;

        if (value == 'None' )  {
            let option = this.inputOptions.find(option => option.value === value);
            option.isSelected = !option.isSelected;
            this.handleNoneOption();
        }
        else {
            function isNone(element){
                if(element.value == 'None' && element.isSelected == true)  {
                    return true;
                }
            }
            let option2 = this.inputOptions.some(isNone) ;
            console.log('chage isSelected : '+option2);
            if(option2){
                let option1 = this.inputOptions.find(option1 => option1.value === value);
                option1.isSelected = false;
            }
        }
        let selectedOptionNum=0;
        for(let i = 0; i < this.inputOptions.length; i++){
            if(this.inputOptions[i].isSelected){
                selectedOptionNum++;   
            }
        } 
        this.inputValue = selectedOptionNum+ ' options selected';
        console.log('Updated Options: ');
        console.log(JSON.stringify(this.inputOptions));

        this.connectedCallback();



        
    }

    handleNoneOption(){
        this.value = [];
        //this.inputValue = 'None';
        let option = this.inputOptions.find(option => option.value === 'None');
        console.log(JSON.stringify(option));
        option.isSelected = !option.isSelected;
        for(let i = 0; i < this.inputOptions.length; i++){
            if(this.inputOptions[i].value != 'None'){
                this.inputOptions[i].isSelected = false;
                this.value.push(this.inputOptions[i]);
            }
        } 
    }

    hasRendered;
    renderedCallback() { 
    if (!this.hasRendered) {
        //  we coll the logic once, when page rendered first time
        this.handleDisabled();

    }
    this.hasRendered = true;
    
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

	connectedCallback(){
		for(let i = 0; i < this.inputOptions.length; i++){
            if(this.inputOptions[i].value=='None' && this.inputOptions[i].isSelected){
                this.selectedValue = ['None'];
            }else if(!this.inputOptions[i].isSelected && this.selectedValue.includes(this.inputOptions[i].value)){
                for(let j = 0; j < this.selectedValue.length; j++){
                    if(this.selectedValue[j]===this.inputOptions[i].value){
                        this.selectedValue.splice(j,1);
                    }
                }
            }else if(this.inputOptions[i].isSelected && !this.selectedValue.includes(this.inputOptions[i].value)){
                this.selectedValue.push(this.inputOptions[i].value);
            }
            console.log(this.selectedValue);
        }
        getSelectClonRegion({selectedValueString : this.selectedValue})
        .then(res => {
			this.girCloneRegions = res;
			this.girComplete = true;
			console.log('girCloneRegions : ', this.girCloneRegions);
        })
        
    }    


	@api
	validate() {
		if(this.selectedValue.length != 0) { 	
            localStorage.setItem('myKey', this.selectedValue);	
			return { isValid: true }; 
		} 
		else { 
			return { 
				isValid: false, 
				errorMessage: 'Please select the values.' 
			}; 
		}
	}



}