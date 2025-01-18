/**
     * [Class Description] COPP Project - Component to contain GM Scorecard pdf
     * Created by [MinheeKim] on [2024-11-05] for [DPM-5916]
    */


import { LightningElement , api} from 'lwc';

export default class CoppScorecardContainer extends LightningElement {
    @api recordId; 
    @api CommentsValue;

    get vfPageUrl() {   
        console.log('recordId: ' + this.recordId + ' CommentsValue: ' + this.CommentsValue);
        //this.CommentsValue = this.CommentsValue || "";
        this.CommentsValue = (this.CommentsValue || "")
        .replace(/\n/g, '<br/>')
        // .replace(/(<p>\s*<\/p>)+/g, ''); 
        // if(this.CommentsValue == "") {
        //     return `/apex/GMScorecard?recordId=${this.recordId}&CommentsValue=${this.CommentsValue}`;
        // } else {
            return `/apex/GMScorecard?recordId=${this.recordId}&CommentsValue=${encodeURIComponent(this.CommentsValue)}`;
        // }
        
    }
}