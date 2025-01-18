import {api, LightningElement} from 'lwc';

export default class CaseVinMismatchMessageElement extends LightningElement {
    @api label;
    @api value;
}