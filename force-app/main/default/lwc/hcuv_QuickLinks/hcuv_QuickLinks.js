import { LightningElement, track, wire } from 'lwc';
import getQuickLinks from '@salesforce/apex/HCUV_QuickLinksController.getQuickLinks';
import { communityList } from 'c/hcuvUtility';
import netId from '@salesforce/community/Id';
/**
 * 
 * Created by [INFOGAIN] on [0000-00-00] for [ZZZ-0000]
 * Edited by [inhokim] on [2024-02-07] for [Ticket CCSOM-14] 
 * desc : quicklink opens with double "https". change handleLinkClick logic 
*/
export default class Hcuv_QuickLinks extends LightningElement {

    showSpinner = false;
    @track quickLinksList = [];
    @track quickLinks = communityList.HCUV_Quick_Links;
    @track carfax = communityList.HCUV_Carfax;
    @track httpText = communityList.HCUV_HTTP;
    networkId = netId;

    @wire(getQuickLinks, { networkId: "$networkId" })
    quickLinks(result) {
        if (result.data) {
            this.quickLinksList = [...result.data];
        }
    }

    handleLinkClick(event) {
        let link = event.currentTarget.dataset.id;
        /*if (link == this.carfax) {

        } else {
            window.open('https://' + event.currentTarget.dataset.id);
        }*/
        if (link != this.carfax) {
            //[CCSOM-14] ADD IF~ELSE, kih, 240208        
            if(event.currentTarget.dataset.id.startsWith("https")){
                window.open(event.currentTarget.dataset.id);
            }else{
                window.open(this.httpText + event.currentTarget.dataset.id);
            }
        }
    }

}