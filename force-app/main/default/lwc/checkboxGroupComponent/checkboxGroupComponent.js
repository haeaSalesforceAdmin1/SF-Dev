import { LightningElement, wire, track,api } from 'lwc';

export default class CheckboxGroupComponent extends LightningElement {
    @api values = [];
    @api options = [];
    @api name;
    _isMobile;

    @api
    get isMobile() {
        return this._isMobile;
    }

    set isMobile(value) {
        this._isMobile = value;
    }

    handleClick(event){
        var index;
        var optionIndex;
        var optionToUpdate;

        var newValues = [...this.values];
        var updatedOptions = [...this.options];

        event.preventDefault();

        if(!this.values.includes(event.target.name)) {
            newValues.push(event.target.name);
            for(var i = 0; i < this.options.length; i++) {
                var option = this.options[i];
                if(option.label === event.target.name) {
                    optionIndex = i;
                    optionToUpdate = Object.assign({}, option);
                    if(this.isMobile) {
                        optionToUpdate.classVal = 'slds-button slds-button_brand slds-button_stretch';
                    }
                    else {
                        optionToUpdate.classVal = 'slds-button slds-button_brand';
                    }                    
                    break;
                }
            }

            //classUpdata='slds-m-left_x-small slds-m-bottom_xx-small slds-button addColor ';
            //classUpdata='slds-button addColor '; 
        }
        else {
            index = this.values.indexOf(event.target.name);
            newValues.splice(index, 1);
            for(var i = 0; i < this.options.length; i++) {
                var option = this.options[i];
                if(option.label === event.target.name) {
                    optionIndex = i;
                    optionToUpdate = Object.assign({}, option);
                    if(this.isMobile) {
                        optionToUpdate.classVal = 'slds-button slds-button_neutral slds-button_stretch';
                    }
                    else {
                        optionToUpdate.classVal = 'slds-button slds-button_neutral';
                    }
                    break;
                }
            }
        }
        updatedOptions[optionIndex] = optionToUpdate;
        
        //let foundelement = this.options.find(ele => ele.label === event.target.name);
        //let updatedelement = Object.assign({}, foundelement);

        //console.error(JSON.stringify(updatedelement));
        //updatedelement.classVal = classUpdata;
        
        this.options = updatedOptions;
        this.values = newValues;

        /*console.error(JSON.stringify(this.values));
        console.error(JSON.stringify(this.options));*/

        const selectedEvent = new CustomEvent("checkboxvalueupdate", {
            bubbles: true,
            detail: { values: this.values,
                      name: this.name,
                      options: this.options
            }
        });
        this.dispatchEvent(selectedEvent);
    }
}