import { LightningElement, track, wire } from 'lwc';
import getQuickTip from '@salesforce/apex/HCUV_MessageController.getQuickTip';
import HMA_QuickTip from '@salesforce/label/c.HCUV_QuickTip';
import { communityList, defaultProgramType } from 'c/hcuvUtility';
import networkId from '@salesforce/community/Id';

export default class HmaQuickTip extends LightningElement {
    @track quickTipMsg;
    @track hasQuickTipMsg = true;
    @track constQuickTip = HMA_QuickTip;
    @track quickTips = communityList.QuickTips;
    @track defaultPrg = communityList.HCUV_Default_Program;
    networkId = networkId;
    quickTipTextVis=false;
    programName = '';

    connectedCallback() {
        if (sessionStorage.getItem('ProgramType') != null) {
            this.programName = sessionStorage.getItem('ProgramType');
        }
        else {
            this.programName = defaultProgramType();
        }
        if(communityList.COMMUNITY_BASE_PATH.includes('HMA') || communityList.COMMUNITY_BASE_PATH.includes('hyundai')){
            this.quickTipTextVis=true;
        }
        else if(communityList.COMMUNITY_BASE_PATH.includes('GMA') || communityList.COMMUNITY_BASE_PATH.includes('genesis')){
            this.quickTipTextVis=false;
        }
    }
    @wire(getQuickTip, { programName: "$programName", networkId: "$networkId" })
    quickTips(result) {
        if (result.data) {
            var quickTips = [];
            quickTips = result.data;
            if (quickTips?.MessageObj?.Message__c && quickTips?.MessageObj?.Message__c != "") {
                if(quickTips.AccountId || quickTips.MessageObj.Message__c.length < 250){
                    this.quickTipMsg = quickTips.MessageObj.Message__c;
                }
                else {
                    this.quickTipMsg = quickTips.MessageObj.Message__c.substring(0, 250) + '...';
                }
            }
            else {
                this.hasQuickTipMsg = false;
            }
        }
    }
}