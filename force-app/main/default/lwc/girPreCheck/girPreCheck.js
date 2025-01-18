import { LightningElement, api, wire, track } from 'lwc';
import getAffectedOffiesPickListValue from '@salesforce/apex/girPreCheckController.getAffectedOffiesPickListValue';
import getSelectClonRegion from '@salesforce/apex/girReivewController.getSelectClonRegion';

export default class GirPreCheck extends LightningElement{
    @api recordId;
	@api userLan;
    @api affectedOffice;
    affectedOfficeValue=[];
    inputValue = 'Select';
    @track inputOptions=[];

    girRequiredValue = '';
    @track inputOptionsGirRequired=[]

    @wire(getAffectedOffiesPickListValue, {recordId: '$recordId'})
    getAffectedOfficesPicklist({ error, data }){
        let options = [];
        if(data){
            console.log('pickList' + data);
            this.affectedOfficePicklist = data;
            this.error = undefined;
            data.forEach(r => {
                options.push({
                    label: r,
                    value: r,
                });
            });
            this.inputOptions = options;
            // 2023.09.07 Screen Flow 화면에서 previous 버튼을 클릭 시  사용자가 이전에 선택한 AffectedOffiesValue Setting
            this.getLocalStorage();

        } else if(error){
            console.log(error);
            this.error = error;
            this.affectedOfficePicklist = undefined;
        }
    };

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
                this.affectedOfficeValue.push(target);
                selectedOptionNum++;
            }
            this.inputValue = selectedOptionNum+ ' options selected';
            getSelectClonRegion({selectedValueString : this.affectedOfficeValue})
            .then(res => {
                this.affectedOffice = res;
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
        this.connectedCallback();
    }

    handleNoneOption(){
        this.value = [];
        //this.inputValue = 'None';
        let option = this.inputOptions.find(option => option.value === 'None');
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
                this.affectedOfficeValue = ['None'];
            }else if(!this.inputOptions[i].isSelected && this.affectedOfficeValue.includes(this.inputOptions[i].value)){
                for(let j = 0; j < this.affectedOfficeValue.length; j++){
                    if(this.affectedOfficeValue[j]===this.inputOptions[i].value){
                        this.affectedOfficeValue.splice(j,1);
                    }
                }
            }else if(this.inputOptions[i].isSelected && !this.affectedOfficeValue.includes(this.inputOptions[i].value)){
                this.affectedOfficeValue.push(this.inputOptions[i].value);
            }
        }
        getSelectClonRegion({selectedValueString : this.affectedOfficeValue})
        .then(res => {
            this.affectedOffice = res;
        })
    }

    @api
    validate() {
        if(this.affectedOfficeValue.length != 0) {
            // 2023.09.07 Screen Flow 화면에서 Next 버튼을 클릭 시 사용자가 선택한 AffectedOffiesValue LocalStorage 에 저장
            localStorage.setItem('myKey', this.affectedOfficeValue);
            return { isValid: true };
        }else{
			if(this.userLan=='ko'){
				return {
					isValid: false,
					errorMessage: '올바른 사항을 입력해 주십시오. 입력은 선택 사항이 아닙니다.'
	
				};
			}else{
				return {
					isValid: false,
					errorMessage: 'Please select the values.'
	
				};
			}
        }
    }
}