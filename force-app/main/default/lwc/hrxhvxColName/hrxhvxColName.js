/**
 * Created by User on 2024-04-03.
 */

import { LightningElement, api } from 'lwc';

export default class HrxhvxColName extends LightningElement {

    @api column;
    @api column2;
    @api column3;
    @api column4;
    @api column5;
    @api positionClassName;

    get columnName() {
        return this.column;
    }
    get columnName2() {
        return this.column2;
    }
    get columnName3() {
        return this.column3;
    }
    get columnName4() {
        return this.column4;
    }
    get columnName5() {
        return this.column5;
    }
    get positionGroupClass() {
        if(this.positionClassName == '' || this.positionClassName == null){
            return 'hrxhvx-group';
        }
        return `hrxhvx-group-${this.positionClassName}`;
    }
    get positionContainerClass() {
        if(this.positionClassName == '' || this.positionClassName == null){
            return 'hrxhvx-container';
        }
        return `hrxhvx-container-${this.positionClassName}`;
    }


    get hasOneColumn(){
        if(this.column2 == null){
            return true;
        }else{
            return false;
        }
    }



}