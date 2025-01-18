import { LightningElement, api, track, wire } from 'lwc';
import communityBasePath from '@salesforce/community/basePath';
import { NavigationMixin } from "lightning/navigation";
import getIconDetails from '@salesforce/apex/HCUV_Utility.getIconDetails';
import HMAExpandMenu from '@salesforce/resourceUrl/hcuvExpandMenu';
import HMAHamburgLeftNav from '@salesforce/resourceUrl/hcuvHamburgLeftNav';
import {communityList, defaultProgramType, constants} from 'c/hcuvUtility';
//import CUVTopNavigationMenu from '@salesforce/resourceUrl/hcuvTopNavigationMenu';
//import { loadScript } from 'lightning/platformResourceLoader';
import formFactor from '@salesforce/client/formFactor';
import networkId from '@salesforce/community/Id';
import basepathname from "@salesforce/community/basePath";
import sitePath from "@salesforce/community/basePath";
import { CurrentPageReference } from 'lightning/navigation';

export default class HmaTopnavigation extends NavigationMixin(LightningElement) {

    @api menuItems;
    @track refMaterialsTab = communityList.HCUV_Reference_Materials_Tab;
    @track vinSearch = communityList.HCUV_VIN_Search;
    @track glbSearch = communityList.HCUV_Global_Search;
    @track isSelectedClassName = '';
    iconDetails = [];
    menuProgramType = [];
    menuURL = [];
    @track expandMenu = HMAExpandMenu;
    @track showVINSearch = false;
    activeId = 1;
    isSubMenuActive = false;
    subMenuIndex = ["4", "5", "6", "7"];
    mobileTopNav;
    topNavCss;
    subMenuCss;
    @track topMenuItems = [];
    isReferenceActive = false;
    networkId = networkId;

    @wire(CurrentPageReference)
    currentPageReference;

    /* FOR Adoption Anlaytics */
    constants = constants;

    metric;
    topMenuArray = ['quicklinks','referencematerials']; // 이걸 하드코딩이아니라 메타데이터같은데서 가져올수없는가..?

    connectedCallback() {
        this.mobileTopNav = HMAHamburgLeftNav;
        this.topNavCss = this.isMobile ? 'xs-topnav-slide' : 'dsk-top-nav';
        this.subMenuCss = this.isMobile ? 'top-nav-submenu-wrap submenu-active' : 'top-nav-submenu-wrap';
    }

    @wire(getIconDetails, { networkId : '$networkId' })
    iconData(result) {
        if (result.data) {
                        
            this.iconDetails = JSON.parse(result.data[0]);
            this.menuProgramType = JSON.parse(result.data[1]);
            this.menuURL = JSON.parse(result.data[2]);
            //if (sessionStorage.getItem('ProgramType') == null && this.activeId == 1 && window.location.pathname == communityList.COMMUNITY_BASE_PATH+'/') {
            if (this.activeId == 1 && window.location.pathname == communityList.COMMUNITY_BASE_PATH+'/') {
                sessionStorage.setItem('ProgramType', result.data[3]);
            }
        }
    }

    get isMobile() {
        return formFactor == "Small";
    }

    // handling TopNav Click
    handleNavClick(event) {
        let menuLbl = event.currentTarget.dataset.id;
        this.activeId = event.currentTarget.dataset.menuItemId;
               
        this.menuItems = this.menuItems.map(record => ({
            ...record,
            enableSubMenu: record.id == this.activeId && !record.enableSubMenu && !this.isSubMenuActive ? true : false,
            isSelectedClassName: record.id == this.activeId ? 'active' : ''
        }));
        if (this.activeId == 1 || this.activeId == 2) {
            sessionStorage.setItem('ProgramType', this.menuProgramType[menuLbl]);
        }
        else if(this.activeId == 3 && sessionStorage.getItem('ProgramType') != defaultProgramType()){
            sessionStorage.setItem('ProgramType', defaultProgramType());
            window.open(window.location.href, '_self');
        }
        else{
            sessionStorage.setItem('ProgramType', defaultProgramType());
            //sessionStorage.setItem('ProgramType', '');
        }
        
        sessionStorage.setItem('TopNavActiveID', this.activeId);
        sessionStorage.setItem('TopNavItems', JSON.stringify(this.menuItems));
        if (this.subMenuIndex.includes(this.activeId))
            this.isSubMenuActive = true;
        else
            this.isSubMenuActive = false;
        if (this.activeId == 8) this.isReferenceActive = true;
        if (this.activeId == 1 || this.activeId == 2) {
            let refMat = {
                '1': '', '2': this.menuURL[menuLbl]
            };
            this.navigateToCommunityPage(communityBasePath + '/' + refMat[this.activeId]);
        } else if (this.activeId >= 4 && this.activeId <= 7) {
            let refMat = {
                '4': this.menuURL[menuLbl], '5': this.menuURL[menuLbl], '6': this.menuURL[menuLbl], '7': this.menuURL[menuLbl]
            };
            this.navigateToCommunityPage(communityBasePath + this.refMaterialsTab + refMat[this.activeId]);
        }
        else if (this.isMobile && (this.activeId != 9) && (this.activeId != 8)) {
            let navMenu = window.navObj.topNav.filter(e => e.id == this.activeId);
            this.navigateToCommunityPage(communityBasePath + navMenu[0].navigation);
        }
        else if ((this.activeId != 9) && (this.activeId != 8)) {
            this.navigateToPage(event);
        }
        else if (this.activeId == 9) {
            window.open(communityBasePath + '/' + this.menuURL[menuLbl], '_self');
        }

        sessionStorage.removeItem('NavItems');


    }


    handleSubMenuBlur(event) {
        setTimeout(() => {
            this.menuItems = this.menuItems.map(record => ({
                ...record,
                enableSubMenu: false
            }));
            this.isSubMenuActive = false;
            sessionStorage.setItem('TopNavItems', JSON.stringify(this.menuItems));
        }, 400);

    }

    navigateToPage(event) {
        this.dispatchEvent(new CustomEvent('navigateto', {
            detail: {
                menuItemId: this.activeId
            }
        }))
    }

    navigateToCommunityPage(navUrl) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: navUrl
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, '_self');
        });
    }

    get finalMenu() {
        let menu = [];
        if ((sessionStorage.getItem('TopNavItems') != null)) {
            this.menuItems = JSON.parse(sessionStorage.getItem('TopNavItems'));
            this.activeId = sessionStorage.getItem('TopNavActiveID');
        }

        // change index
        this.menuItems = JSON.parse(JSON.stringify((this.menuItems)));

        this.menuItems.forEach(item => {
            if(item.label == 'REFERENCE MATERIALS') {
                item.id = 8;
                
                if(item.subMenu) {
                    item.subMenu.forEach(subMenuItem => {
                        if(subMenuItem.label == 'FORMS AND GUIDES')
                            subMenuItem.id = 4;
                        else if(subMenuItem.label == 'LINKS')
                            subMenuItem.id = 5;
                        else if(subMenuItem.label == 'VIDEOS')
                            subMenuItem.id = 6;
                        else if(subMenuItem.label == 'ALL')
                            subMenuItem.id = 7;
                    });
                }
                
            }
            else if(item.label == 'QUICK LINKS') {
                item.id = 9;
            }
        });
        
        this.menuItems.forEach(record => {
            let item = { ...record };            
            if(item.label == 'REFERENCE MATERIALS') {
                item.id = 8;
                
                if(item.subMenu) {
                    let subMenu = [];
                
                    item.subMenu.forEach(subMenuItem => {
                        let subMenuItem1 = { ...subMenuItem };

                        if(subMenuItem.label == 'FORMS AND GUIDES')
                            subMenuItem1.id = 4;
                        else if(subMenuItem.label == 'LINKS')
                            subMenuItem1.id = 5;
                        else if(subMenuItem.label == 'VIDEOS')
                            subMenuItem1.id = 6;
                        else if(subMenuItem.label == 'ALL')
                            subMenuItem1.id = 7;

                        subMenu.push(subMenuItem1);
                    });
                    item.subMenu = subMenu;
                }
                
            }
            else if(item.label == 'QUICK LINKS') {
                item.id = 9;
            }  

            if (item.label != 'Home') {
                item.hasSubMenu = item.subMenu ? true : false;
                if (this.iconDetails) {
                    item.iconUrl = this.iconDetails[item.label];
                    if (item.subMenu) {
                        let submenuObj = [];
                        item.subMenu.forEach(subRecord => {
                            let subitem = { ...subRecord };
                            subitem.iconUrl = this.iconDetails[subitem.label];
                            subitem.active = (item.id == this.activeId ? true : false);
                            subitem.isSelectedClassName = item.active ? 'active' : '';
                            submenuObj.push(subitem);
                        });
                        item.subMenu = submenuObj;
                    }
                }

                item.active = (item.id == this.activeId ? true : false);
                item.isSelectedClassName = item.active ? 'active' : '';
                item.showSubMenu = (item.active && item.hasSubMenu) ? true : false;
                item.showVINSearch = (item.label == this.vinSearch && item.active) ? true : false;
                menu.push(item);
            }

        });

        this.topMenuItems = menu;
        return menu;
    }

    handleEnter(event) {
        if (event.keyCode === 13) {
            let searchValue = event.target.value;
            window.open(this.glbSearch + searchValue, '_self');
        }
    }

    handleNavigation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__navigationToMsgcentre',
                apiName: 'CustomTabName'
            },
            state: {
                c__counter: '5'
            }
        });
    }

}