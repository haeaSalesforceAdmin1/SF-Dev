import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountDetail from '@salesforce/apex/HCUV_UserProfile.getAccountDetail';
import getDPMSiteURL from '@salesforce/apex/HCUV_UserProfile.getDPMSiteURL';
import uId from "@salesforce/user/Id";
import networkId from '@salesforce/community/Id';
import { labelList, communityList, staticResourceList } from 'c/hcuvUtility';

export default class HmaUserProfile extends NavigationMixin(LightningElement) {
    @track dealerName;
    @track userProfileLogo = staticResourceList.Userprofile;
    @track showUserprofile = false;
    @track baseUserUrl = communityList.COMMUNITY_BASE_PATH + "/" + communityList.PROFILE + "/";
    @track baseAccURL = communityList.COMMUNITY_BASE_PATH + "/" + communityList.DETAIL + "/";
    @track logoutURL = labelList.HMALogoutURL;
    @track downArrowCss;
    @track showChangeDealer = false;
    @track myAccount = communityList.MY_ACCOUNT;
    @track myProfile = communityList.MY_PROFILE;
    @track changeDealer = communityList.CHANGE_DEALER;
    @track switchToDPM = communityList.SWITCH_TO_DPM;
    @track genesisDPM = communityList.HCUV_DPM_Genesis;
    @track hyundaiDPM = communityList.HCUV_DPM_Hyundai;
    @track logout = communityList.LOGOUT;
    dealerVis= false;
    accURL;
    isMobile;
    userId = uId;
    selectedDealerVal = '';
    networkId = networkId;
    
    // Getting Dealer Information
    @wire(getAccountDetail, {})
    account(result) {
        //this.dataToRefresh = result;
        if (result.data) {
            this.dealerName = result.data.Name;
            this.selectedDealerVal = result.data.Id;
            sessionStorage.setItem('DealerName', this.dealerName);
            this.accURL = this.baseAccURL + result.data.Id;
        } 
    }

    connectedCallback() {
        this.downArrowCss = this.showUserprofile ? 'down-arrow slds-float_right rotate' : 'down-arrow slds-float_right';
        this.isMobile = (communityList.DEVICE_FORM_FACTOR == "Small") ? true : false;
        this.baseUserUrl = this.baseUserUrl + this.userId;
        
        let path = window.location.pathname;

        if(path.includes("GMA") || path.includes("genesis")){
            this.userProfileLogo = staticResourceList.UserprofileGMA;
        }
        else {
            this.userProfileLogo = staticResourceList.Userprofile;
        }
    }
    
    onClickUserProfile() {
        this.showUserprofile = !this.showUserprofile;
        this.downArrowCss = this.showUserprofile ? 'down-arrow slds-float_right rotate' : 'down-arrow slds-float_right';
    }

    onBlurUserProfile() {
        if (this.showUserprofile) {
            setTimeout(() => {
                this.showUserprofile = !this.showUserprofile;
                this.downArrowCss = this.showUserprofile ? 'down-arrow slds-float_right rotate' : 'down-arrow slds-float_right';
            }, 400);
        }
    }

    get enableSubMenu() {
        return this.showUserprofile;
    }

    handleChangeDealer() {
        this.template.querySelector('c-hcuv-dual-account').handleOnAccountCheck();
    }
    handleChangeDealerVis(event) {
        this.dealerVis = event.detail.visibility;
    }
    handleSwitchToDPM(){
        getDPMSiteURL({networkId : this.networkId })
            .then(result => {
                window.open(result);
            })
            .catch(error => {
                console.log('error in getInventories = ' + JSON.stringify(error));
            });
    }
}