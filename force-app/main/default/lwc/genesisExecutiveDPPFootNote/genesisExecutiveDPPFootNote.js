/**
 * Created by User on 2024-04-03.
 */

import { LightningElement, api } from 'lwc';

export default class HyundaiExecutiveDPPFootNote extends LightningElement {

    @api results;
    @api content;

    get stringContent() {
        return 'content: ' + this.results[0].name;
    }

    edit(v) {
        const contact = this.content;
        const results = this.results;
        const arr = contact.split(';');

        var year_month = '';
        var quarter = '';

        for (var i = 0; i < results.length; i++) {
            if (results[i].name == 'ym') year_month = results[i].value;
            if (results[i].name == 'qty') quarter = results[i].value;
        }

        if (results.length > 1 && v == 2) {
            return '**QTD as of ' + quarter + ', YTD as of ' + year_month + ' (30-day Grace Period)';
        }

        if (arr.length > 1) {
            if (v == 1) return arr[0];
            if (v == 2) return arr[1];
        }

        if (v == 1) return contact;
    }

    get content_1() { return this.edit(1) }
    get content_2() { return this.edit(2) }

}