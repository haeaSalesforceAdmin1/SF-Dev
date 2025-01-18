import { LightningElement, api, track, wire } from 'lwc';
import GetMenu from '@salesforce/apex/HCUV_LeftNavigationController.GetMenu';
import {
    communityList,
    staticResourceList,
    defaultProgramType,
    constants,
    fetchLogInsert
} from 'c/hcuvUtility';
import getDealerCode from '@salesforce/apex/HCUV_Utility.getDealerCode';
import { publish, MessageContext } from 'lightning/messageService';
import inventoryNavigationChannel from '@salesforce/messageChannel/InventoryNavigationChannel__c';
import networkId from '@salesforce/community/Id';

export default class hcuvleftnavigation extends LightningElement {

    images = staticResourceList.IMAGES;
    starImage = staticResourceList.IMAGES + '/star.png';
    leftNavIcons = staticResourceList.HMALeftNavIcons;
    formFactor = communityList.DEVICE_FORM_FACTOR;
    networkId = networkId;

    @api showBlueTheme;
    @api showMenuNames;

    @api leftNavItems;
    @track leftArrowImg = staticResourceList.LeftArrow;
    @track expandMenu = staticResourceList.HMAExpandMenu;
    @track leftArrow = staticResourceList.HMALeftArrow;
    @track themeChange = staticResourceList.HMAThemeChange;
    leftArrowCss = '';
    @track navItems = [];
    isMobile;
    leftNavCss;
    dealerCode = '';

    themeChangeCss = this.showBlueTheme ? 'BlueTheme themeChange' : 'WhiteTheme themeChange';

    get showInventory() {
        return this.selNavItem == 'inventory';
    }

    @wire(MessageContext)
    messageContext;

    /* FOR Adoption Anlaytics */
    constants = constants;

    connectedCallback() {
        this.getCurrentDealerCode();
        if (this.leftNavItems != null && this.leftNavItems.length > 0) {
            this.navItems = JSON.parse(sessionStorage.getItem('NavItems'));
        }
        else {
            this.navItems = [];
            this.callInit();
        }
        this.isMobile = (this.formFactor == "Small") ? true : false;
        this.leftNavCss = this.isMobile ? 'slds-m-around_x-small custom-left-nav xs-leftnav-slide' : 'slds-m-around_x-small custom-left-nav';

        // this.callInit();
        this.leftArrowCss = this.showBlueTheme ? 'collapseNavBtn' : 'WhiteTheme collapseNavBtn';
        //this.themeChangeCss = this.showBlueTheme? 'themeChange': 'WhiteTheme themeChange';
    }

    callInit() {
        var programName;
        if (sessionStorage.getItem('ProgramType') != null) {
            programName = sessionStorage.getItem('ProgramType');
        }
        else {
            programName = defaultProgramType();
        }
        GetMenu({ networkId: this.networkId })
            .then(result => {
                result.forEach((item) => {
                    if (item.programType != undefined && item.programType != '' && item.programType != null && item.programType.includes(programName)) {
                        let subMenus = [];
                        if (item.hasSubMenu) {
                            item.subMenus.forEach((subMenu) => {
                                if (subMenu.subMenuProgramType != undefined && subMenu.subMenuProgramType != '' && subMenu.subMenuProgramType != null && subMenu.subMenuProgramType.includes(programName)) {
                                    subMenus.push(
                                        {
                                            'subItemName': subMenu.subMenuName,
                                            'subItemImage': subMenu.subMenuImage,
                                            'isSelectedClassSubMenu': 'slds-p-left_large left-nav-sub-item-wrap',
                                            'isSelectedSubMenu': false
                                        });
                                }
                            });
                        }
                        this.navItems.push(
                            {
                                'name': item.menuName,
                                'image': item.image, //Kishore
                                'isSelected': (item.menuName == 'INVENTORY' ? true : false),
                                'subItems': subMenus,
                                'hasSubMenu': item.hasSubMenu,
                                'isSelectedClassName': (item.menuName == 'INVENTORY' ? 'left-nav-item-ref-wrap menu-active' : 'left-nav-item-ref-wrap'),
                                'subMenucss': this.isMobile ? 'submenu-active' : '',
                                'url': item.url
                            }
                        );
                    }
                });
            })
            .catch(error => {
                console.log('error in init = ' + JSON.stringify(error));
            });
    }

    getCurrentDealerCode() {
        getDealerCode()
            .then(result => {
                this.dealerCode = result;
            })
            .catch(error => { });
    }

    handleNavItemClick(event) {
        let selNavItem = event.currentTarget.dataset.id;
        let url = event.currentTarget.dataset.url;

        sessionStorage.removeItem('activeSubMenu');

        this.navItems.forEach((item) => {
            item.isSelected = (item.name == selNavItem && !item.isSelected ? true : false);
            item.isSelectedClassName = item.isSelected ? 'left-nav-item-ref-wrap menu-active' : 'left-nav-item-ref-wrap';
        });

        sessionStorage.setItem('NavItems', JSON.stringify(this.navItems));

        let pathname = window.location.pathname;

        if (!this.showMenuNames && (selNavItem == 'INVENTORY' || selNavItem == 'SRC')) {
            this.handleLeftNavBar();
        }
        if (selNavItem == 'VEHICLES REPORTED AS SOLD TO HMA' || selNavItem == 'VEHICLES REPORTED AS SOLD TO GMA' || selNavItem == 'CVP PROGRAM "X"') {
            if (pathname == communityList.COMMUNITY_BASE_PATH + '/' + url && this.formFactor != 'Small') {
                fetchLogInsert();
                window.history.pushState({}, '', (communityList.COMMUNITY_BASE_PATH + '/' + url + '?tab=' + selNavItem));
                window.history.replaceState({}, '', (communityList.COMMUNITY_BASE_PATH + '/' + url + '?tab=' + selNavItem));

                const payload = { selectedTab: selNavItem };
                publish(this.messageContext, inventoryNavigationChannel, payload);
            } else {
                window.open(communityList.COMMUNITY_BASE_PATH + '/' + url + '?tab=' + selNavItem, '_self');
            }
        } else if (selNavItem == 'QUICK LINKS') {
            window.open(communityList.COMMUNITY_BASE_PATH + '/' + url, '_self');
        } else if (selNavItem == 'ORDER MERCHANDISING MATERIALS' || selNavItem == 'MERCHANDISING MATERIALS') {
            window.open(communityList.COMMUNITY_BASE_PATH + '/' + url, '_self');
        } else if (selNavItem == 'CONTESTS & INCENTIVES') {
            window.open(communityList.COMMUNITY_BASE_PATH + '/' + url, '_self');
        } else if (selNavItem == 'PERFORMANCE METRICS') {
            window.open(communityList.COMMUNITY_BASE_PATH + '/' + url, '_self');
        } else if (selNavItem == 'USER GUIDE') {
            window.open(communityList.COMMUNITY_BASE_PATH + '/' + url, '_self');
        } else if (selNavItem == 'REPORT VEHICLE SALE') {
            fetchLogInsert();
            window.open(url + '&' + communityList.DealerCode + '=' + this.dealerCode);
        }
        //sessionStorage.removeItem('TopNavItems');
        //sessionStorage.removeItem('TopNavActiveID');

    }

    showHideNavBar() {
        this.showMenuNames = !this.showMenuNames;
    }

    handleNavSubItemClick(event) {
        let selNavItem = event.currentTarget.dataset.id;
        sessionStorage.setItem('activeSubMenu', selNavItem);
        this.navItems.forEach((item) => {
            item.subItems.forEach((subItem) => {
                subItem.isSelectedSubMenu = (subItem.subItemName == selNavItem && !subItem.isSelected ? true : false);
                subItem.isSelectedClassSubMenu = subItem.isSelectedSubMenu ? 'slds-p-left_large left-nav-sub-item-wrap menu-active' : 'slds-p-left_large left-nav-sub-item-wrap';

            });
        });

        sessionStorage.setItem('NavItems', JSON.stringify(this.navItems));

        let pathname = window.location.pathname;
        if (!this.showMenuNames && (selNavItem == 'INVENTORY' || selNavItem == 'SRC')) {
            this.handleLeftNavBar();
        }
        /*if (selNavItem == 'VEHICLES REPORTED AS SOLD TO HMA') {
            if (pathname == communityList.COMMUNITY_BASE_PATH + '/inventory' && this.formFactor != 'Small') {
                window.history.pushState({}, '', (communityList.COMMUNITY_BASE_PATH + '/inventory?tab=' + selNavItem));
                window.history.replaceState({}, '', (communityList.COMMUNITY_BASE_PATH + '/inventory?tab=' + selNavItem));

                const payload = { selectedTab: selNavItem };
                publish(this.messageContext, inventoryNavigationChannel, payload);
            } else {
                window.open(communityList.COMMUNITY_BASE_PATH + '/inventory?tab=' + selNavItem, '_self');
            }
        }*/
        if (pathname == communityList.COMMUNITY_BASE_PATH + '/inventory' && this.formFactor != 'Small') {
            window.history.pushState({}, '', (communityList.COMMUNITY_BASE_PATH + '/inventory?tab=' + selNavItem));
            window.history.replaceState({}, '', (communityList.COMMUNITY_BASE_PATH + '/inventory?tab=' + selNavItem));

            const payload = { selectedTab: event.currentTarget.dataset.id };
            publish(this.messageContext, inventoryNavigationChannel, payload);

            fetchLogInsert();
        } else {
            window.open(communityList.COMMUNITY_BASE_PATH + '/inventory?tab=' + event.currentTarget.dataset.id, '_self');
        }

        //sessionStorage.removeItem('TopNavItems');
        //sessionStorage.removeItem('TopNavActiveID');
    }

    handleLeftNavBar() {
        let showMenu = !this.showMenuNames;
        sessionStorage.setItem('showMenuNames', showMenu);
        const collapseEvent = new CustomEvent("collapse", {
            detail: { showMenu }
        });

        // Fire the custom event
        this.dispatchEvent(collapseEvent);
    }

    handleThemeChange() {
        let showTheme = !this.showBlueTheme;

        sessionStorage.setItem('ShowBlueTheme', showTheme);

        const themeChangeEvent = new CustomEvent("themeChange", {
            detail: { showTheme }
        });
        // Fire the custom event
        this.dispatchEvent(themeChangeEvent);

        this.leftArrowCss = showTheme ? 'collapseNavBtn' : 'WhiteTheme collapseNavBtn';
    }
}