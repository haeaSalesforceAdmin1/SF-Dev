import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import COMMUNITY_BASE_PATH from '@salesforce/community/basePath';
import DEVICE_FORM_FACTOR from '@salesforce/client/formFactor';//To check device type
import IMAGES from '@salesforce/resourceUrl/hcuvImages';
import LeftArrow from '@salesforce/resourceUrl/hcuvLeftArrow';
import HMALeftNavIcons from '@salesforce/resourceUrl/hcuvLeftNavIcons';//Kishore
import HMAExpandMenu from '@salesforce/resourceUrl/hcuvExpandMenu';
import HMALeftArrow from '@salesforce/resourceUrl/hcuvLeftArrow';
import HMAThemeChange from '@salesforce/resourceUrl/hcuvThemeChange';
import HMAClearIcon from '@salesforce/resourceUrl/hcuvUtilityClearIcon';
import HMAIcons from '@salesforce/resourceUrl/hcuvIcons';
import Inventory_Table_Page_Size from '@salesforce/label/c.Inventory_Table_Page_Size';
import MessagePageSize from '@salesforce/label/c.MessagePageSize';
import SVG_RESOURCE from '@salesforce/resourceUrl/hcuvPortalIcons';
import HMA_QuickTip from '@salesforce/label/c.HCUV_QuickTip';
import HMAHamburgLeftNav from '@salesforce/resourceUrl/hcuvHamburgLeftNav';
import CUVTopNavigationMenu from '@salesforce/resourceUrl/hcuvTopNavigationMenu';
import Userprofile from '@salesforce/resourceUrl/hcuvUserProfile';
import UserprofileGMA from '@salesforce/resourceUrl/hcuvUserProfileGMACPO';
import HMALogoutURL from '@salesforce/label/c.HCUV_LogoutURL';
import MY_ACCOUNT from '@salesforce/label/c.HCUV_My_Account';
import MY_PROFILE from '@salesforce/label/c.HCUV_My_Profile';
import CHANGE_DEALER from '@salesforce/label/c.HCUV_Change_Dealer';
import LOGOUT from '@salesforce/label/c.HCUV_Logout';
import PROFILE from '@salesforce/label/c.HCUV_Profile';
import DETAIL from '@salesforce/label/c.HCUV_Detail';
import HCUV_Select_Account from '@salesforce/label/c.HCUV_Select_Account';
import HCUV_AccountId from '@salesforce/label/c.HCUV_AccountId';
import HCUV_Dealer_Name from '@salesforce/label/c.HCUV_Dealer_Name';
import HCUV_Dealer_Code from '@salesforce/label/c.HCUV_Dealer_Code';
import HCUV_Select from '@salesforce/label/c.HCUV_Select';
import HCUV_Cancel from '@salesforce/label/c.HCUV_Cancel';
import HCUV_Ok from '@salesforce/label/c.HCUV_OK';
import HCUV_Quick_Links from '@salesforce/label/c.HCUV_Quick_Links';
import HCUV_Carfax from '@salesforce/label/c.HCUV_Carfax';
import HCUV_HTTP from '@salesforce/label/c.HCUV_HTTP';
import HCUV_Forms_And_Guides from '@salesforce/label/c.HCUV_Forms_And_Guides';
import HCUV_Videos from '@salesforce/label/c.HCUV_Videos';
import HCUV_Links from '@salesforce/label/c.HCUV_Links';
import HCUV_Icon_PDF from '@salesforce/label/c.HCUV_Icon_PDF';
import HCUV_Icon_Video from '@salesforce/label/c.HCUV_Icon_Video';
import HCUV_Merchandising_Materials from '@salesforce/label/c.HCUV_Merchandising_Materials';
import HCUV_Reference_Materials_Tab from '@salesforce/label/c.HCUV_Reference_Materials_Tab';
import HCUV_VIN_Search from '@salesforce/label/c.HCUV_VIN_Search';
import HCUV_Global_Search from '@salesforce/label/c.HCUV_Global_Search';
import HCUV_Message_Center from '@salesforce/label/c.HCUV_Message_Center';
import HCUV_No_Record from '@salesforce/label/c.HCUV_No_records_found';
import HCUV_Inventory_Entries_Message from '@salesforce/label/c.HCUV_Inventory_Entries_Message';
import HCUV_Inventory_No_Records_Found_Message from '@salesforce/label/c.HCUV_Inventory_No_Records_Found_Message';
import CreateRDRURL from '@salesforce/label/c.HCUV_Create_RDR';
import RemoveInventoryURL from '@salesforce/label/c.HCUV_Remove_Inventory';
import WindowStickerURL from '@salesforce/label/c.HCUV_Window_Sticker';
import ActiveInventory from '@salesforce/label/c.HCUV_Active_Inventory';
import ActiveInventoryText from '@salesforce/label/c.HCUV_ActiveInventory';
import IAMPram from '@salesforce/label/c.HCUV_Pram';
import QuickTips from '@salesforce/label/c.HCUV_Quick_Tips';
import HCUV_Default_Program from '@salesforce/label/c.HCUV_Default_Program';
import HCUV_Contests_Incentives from '@salesforce/label/c.HCUV_Contests_Incentives';
import HCUV_Program_Name from '@salesforce/label/c.HCUV_Program_Name';
import HCUV_Start_Date from '@salesforce/label/c.HCUV_Start_Date';
import HCUV_End_Date from '@salesforce/label/c.HCUV_End_Date';
import HCUV_New from '@salesforce/label/c.HCUV_New';
import HCUV_No_Record_Display from '@salesforce/label/c.HCUV_No_Record_Display';
import AgedInventory from '@salesforce/label/c.HCUV_AgedInventory';
import WindowStickerTooltip from '@salesforce/label/c.HCUV_Window_Sticker_Tooltip';
import CreateRDRTooltip from '@salesforce/label/c.HCUV_Create_RDR_Tooltip';
import RemoveInventoryTooltip from '@salesforce/label/c.HCUV_Remove_Inventory_Tooltip';
import InspectionchecklistTooltip from '@salesforce/label/c.HCUV_Inspection_checklist';
import gmaWindowStickerURL from '@salesforce/label/c.HCUV_GMA_Window_Sticker_URL';
import gmaCreateRDRURL from '@salesforce/label/c.HCUV_GMA_Create_RDR_URL';
import gmaRemoveInventoryURL from '@salesforce/label/c.HCUV_GMA_Remove_Inventory_URL';
import SWITCH_TO_DPM from '@salesforce/label/c.HCUV_Switch_To_DPM';
import DealerCode from '@salesforce/label/c.HCUV_DealerCode';
import HCUV_SALESFORCE_TRAINING_VIDEO from '@salesforce/label/c.HCUV_Salesforce_Training_Video';
import fetchLogRecord from '@salesforce/apex/CRMALogger.fetchLogRecord';

export const CARFAX_NAVIGATE_URL = 'https://www.carfax.com/VehicleHistory/p/Report.cfx?partner=HYU_0&vin=';
export const INVALID_TEMPLATE_ERROR = 'Please select valid template'
export const VIDEO_URL ='/sfc/servlet.shepherd/document/download/'
export const labelList = {
    CARFAX_NAVIGATE_URL,
    Inventory_Table_Page_Size,
    MessagePageSize,
    HMA_QuickTip,
    HMALogoutURL,
    INVALID_TEMPLATE_ERROR,
    VIDEO_URL,
    HCUV_Inventory_Entries_Message,
    HCUV_Inventory_No_Records_Found_Message,
    CreateRDRURL,
    RemoveInventoryURL,
    WindowStickerURL,
    ActiveInventory,
    IAMPram,
    ActiveInventoryText,
    AgedInventory,
    WindowStickerTooltip,
    CreateRDRTooltip,
    RemoveInventoryTooltip,
    InspectionchecklistTooltip,
    gmaWindowStickerURL,
    gmaCreateRDRURL,
    gmaRemoveInventoryURL,

}

export const INVENTORY_OBJECT_URL = 'hcuv-inventory';
export const REFERENCE_OBJECT_URL = 'reference-materia';
export const CONTESTS_INCENTIVES_OBJECT_URL = 'hcuv-contests-incentives';
export const communityList = {
    COMMUNITY_BASE_PATH,
    DEVICE_FORM_FACTOR,
    INVENTORY_OBJECT_URL,
    REFERENCE_OBJECT_URL,
    CONTESTS_INCENTIVES_OBJECT_URL,
    MY_ACCOUNT,
    MY_PROFILE,
    CHANGE_DEALER,
    LOGOUT,
    PROFILE,
    DETAIL,
    HCUV_Select_Account,
    HCUV_AccountId,
    HCUV_Dealer_Name,
    HCUV_Dealer_Code,
    HCUV_Select,
    HCUV_Cancel,
    HCUV_Ok,
    HCUV_Quick_Links,
    HCUV_Carfax,
    HCUV_HTTP,
    HCUV_Forms_And_Guides,
    HCUV_Videos,
    HCUV_Links,
    HCUV_Icon_PDF,
    HCUV_Icon_Video,
    HCUV_Merchandising_Materials,
    HCUV_Reference_Materials_Tab,
    HCUV_VIN_Search,
    HCUV_Global_Search,
    HCUV_Message_Center,
    HCUV_No_Record,
    QuickTips,
    HCUV_Default_Program,
    HCUV_Contests_Incentives,
    HCUV_Program_Name,
    HCUV_Start_Date,
    HCUV_End_Date,
    HCUV_New,
    HCUV_No_Record_Display,
    SWITCH_TO_DPM,
    DealerCode,
    HCUV_SALESFORCE_TRAINING_VIDEO
}

export const staticResourceList = {
    IMAGES,
    LeftArrow,
    HMALeftNavIcons,
    HMAExpandMenu,
    HMALeftArrow,
    HMAThemeChange,
    HMAClearIcon,
    HMAIcons,
    SVG_RESOURCE,
    HMAHamburgLeftNav,
    CUVTopNavigationMenu,
    Userprofile,
    UserprofileGMA
}

export const TOAST_TITLE_SUCCESS = 'Success'
export const TOAST_MODE_DISMISSIBLE = 'dismissible'
export const TOAST_VARIANT_SUCCESS = 'success'
export const TOAST_VARIANT_ERROR = 'error'
export const TOAST_TITLE_FAILURE = 'Failure'

export const toastlabelList = { TOAST_TITLE_SUCCESS, TOAST_TITLE_FAILURE, TOAST_VARIANT_ERROR, TOAST_VARIANT_SUCCESS, TOAST_MODE_DISMISSIBLE }

export const showToast = function (toastTitle, toastMessage, toastVariant, toastMode, toastMessageData) {
    this.dispatchEvent(new ShowToastEvent({
        title: toastTitle,
        message: toastMessage,
        variant: toastVariant,
        mode: toastMode,
        messageData: toastMessageData
    }))
}

export const constants = {
    SEARCH_TERM_ACTIVE_INVENTORY: 'Active Inventory',
    SEARCH_TERM_CARFAX_DERCERTIFIED_VEHICLES: 'CARFAX Decertified Vehicles',
    DOWNLOAD_OPTIONS: [
        { label: 'Export to Excel', value: 'Excel' },
        { label: 'Export to CSV', value: 'CSV' }
    ],
    DOWNLOAD_IMAGE_120: '/download_120.svg',
    COMMUNITY_SITE_NAME: {CUV : 'Hyundai Certified Used Vehicles',
        HSU : 'Hyundai Select Used',
        CPO : 'Genesis Certified Vehicles'}
};

const defaultProgramType = () => {
    var programType = ''
    if (COMMUNITY_BASE_PATH.includes('HMA') || COMMUNITY_BASE_PATH.includes('hyundai')) {
        programType = 'CUV';
    }
    else if (COMMUNITY_BASE_PATH.includes('GMA') || COMMUNITY_BASE_PATH.includes('genesis')) {
        programType = 'CPO';
    }
    return programType;
};
export { defaultProgramType };



/**
 * CUV Adoption Analytics Start -------------------------------------------------------------
 * Modify Existing Activity Logger & Add Callout elements inside CUV/CPO component
 * Created by Areum on 2024-01-23 for HVM-459
 */


/**
 * Retrieves the currently selected top menu information from session storage.
 * @returns {Object|string} - An object containing information about the selected top menu item, or an empty string if no item is selected.
 */
const getCurrentSelectedTopMenuInfo = () => {
    const topNavItems = JSON.parse(sessionStorage.getItem('TopNavItems'));
    let activeTopNavItem = topNavItems?.find(item => item.isSelectedClassName === "active");

    return activeTopNavItem || "";
};


/**
 * Retrieves the currently selected sub-menu information
 * @returns {{selectedMainMenuItem: null, subMenuName: string, selectedSubMenuItem: null}}
 */
const getCurrentSelectedSubMenu = () => {
    const navItems = JSON.parse(sessionStorage.getItem('NavItems'));
    const activeSubMenuName = sessionStorage.getItem('activeSubMenu');
    let selectedMainMenuItem = null;
    let selectedSubMenuItem = null;

    // 2depth
    if (navItems != null) {
        selectedMainMenuItem = navItems.find(item => item.isSelected);

        // 3depth
        if (selectedMainMenuItem && selectedMainMenuItem.subItems) {
            selectedSubMenuItem = selectedMainMenuItem.subItems.find(subItem => subItem.subItemName === activeSubMenuName);
        }
    }

    return {
        selectedMainMenuItem,
        selectedSubMenuItem,
        subMenuName: activeSubMenuName,
    };
};

/**
 * Creates the interaction detail based on provided parameters.
 * If no programType is provided, it checks the URL pathname to determine the programType.
 * Handles special cases for 'Reference Materials' and 'Quick Links'.
 *
 * @param {string} topMenuLabel - The label of the top menu.
 * @param {string} mainMenuName - The name of the main menu.
 * @param {string} programType - The type of the program.
 * @returns {string} The created interaction detail.
 */
function createInteractionDetail(topMenuLabel, mainMenuName, programType) {

    //home: On initial URL access, there may not be a value in session storage
    if (!programType) {
        const pathname = window.location.pathname;

        if (pathname.includes('CUV')) {
            programType = 'CUV';
        } else if (pathname.includes('CPO')) {
            programType = 'CPO';
        }
    }

    // edited by AR on 2024-02-16: Shortened 1st-level menu names as requested.
    let defaultTopMenuLabel = '';
    if(programType === 'CUV') {
        //defaultTopMenuLabel = 'Hyundai Certified Used Vehicles';
        defaultTopMenuLabel = 'HCUV';
    } else if (programType === 'HSU') {
        //defaultTopMenuLabel = 'Hyundai Select Used';
        defaultTopMenuLabel = 'HSU';
    } else if (programType === 'CPO') {
        //defaultTopMenuLabel = 'Genesis Certified Vehicles';
        defaultTopMenuLabel = 'GCPO';
    }

    //topMenuLabel, mainMenuName X
    if (!topMenuLabel && !mainMenuName) {
        return `${defaultTopMenuLabel} - Home`;
    }

    //topMenuLabelX
    if (!topMenuLabel && mainMenuName) {
        return `${defaultTopMenuLabel} - ${mainMenuName}`;
    }

    //Added by Areum on 2024-02-22 : Reference Materials, Quick Link Exception Handling
    if (mainMenuName === '') {
        if (topMenuLabel === "Reference Materials" || topMenuLabel === "Quick Links") {
            if(programType === 'CUV') {
                return `Hyundai - ${topMenuLabel}`
            } else if (programType === 'CPO') {
                return `Genesis - ${topMenuLabel}`
            }
        }
    }

    return `${defaultTopMenuLabel} - ${mainMenuName || 'Home'}`
}

/**
 * Generates an interaction metric for user interactions based on the provided parameters.
 * Handles special cases for 'Reference Materials' and 'Quick Links'.
 *
 * @param {string} topMenuLabel - The label for the top menu.
 * @param {string} mainMenuName - The name of the main menu.
 * @param {string} subMenuName - The name of the sub-menu.
 * @param {string} programType - The type of the program.
 *
 * @returns {string} The generated interaction metric.
 */
function createInteractionMetric(topMenuLabel, mainMenuName, subMenuName, programType) {
    if (!programType) {
        const pathname = window.location.pathname;

        if (pathname.includes('CUV')) {
            programType = 'CUV';
        } else if (pathname.includes('CPO')) {
            programType = 'CPO';
        }
    }

    if (mainMenuName === '') {
        if (topMenuLabel === "Reference Materials") {
            const params = new URLSearchParams(window.location.search);
            let tabName = params.get('tab');

            //Added by AR on 2024-02-22: Reference Materials, Quick Link Exception Handling
            //Added by AR on 2024-03-21: Added exception handling for cases where 'tabName' is missing.
            if (tabName) {
                if (tabName.startsWith("form")) {
                    tabName = "Forms & Guides";
                }
                else {
                    tabName = convertCapitalizedCase(tabName);
                }
            }
            else {
                return;
            }

            if (programType === 'CUV') {
                return `HMA Reference Materials : ${tabName}`;
            } else if (programType === 'CPO') {
                return `GMA Reference Materials : ${tabName}`;
            }
        }

        if (topMenuLabel === "Quick Links") {
            if (programType === 'CUV') {
                return 'Hyundai : Quick Links Tab';
            } else if (programType === 'CPO') {
                return 'Genesis : Quick Links Tab';
            }
        }
    }

    if (!mainMenuName) {
        if (programType === 'CUV') {
            return 'HCUV Home Tab';
        } else if (programType === 'HSU') {
            return  'HSU Home Tab';
        } else if (programType === 'CPO') {
            return 'GCPO Home Tab';
        }
    }

    return subMenuName ? `${mainMenuName} : ${subMenuName} Tab` : `${mainMenuName} Tab`;
}

/**
 * Converts a string to capitalized case, excluding specific exception words.
 *
 * @param {string} str - The string to be converted.
 * @returns {string} The converted string in capitalized case.
 */
const convertCapitalizedCase = (str) => {
    const exceptionWords = ['HMA','GMA','CVP'];
    return str
        .toLowerCase()
        .split(' ')
        .map(word => {
            if (exceptionWords.includes(word.toUpperCase())) {
                return word.toUpperCase();
            }
            return word.charAt(0).toUpperCase() + word.slice(1);
        })
        .join(' ');
}

/**
 * Fetches log insert for the current selected top and sub menus.
 *
 * @returns {void}
 */
export const fetchLogInsert = () => {
    const currentSelectedTopMenuInfo = getCurrentSelectedTopMenuInfo();
    const currentSelectedSubMenuInfo = getCurrentSelectedSubMenu();

    const topMenuLabel = currentSelectedTopMenuInfo?.label ? convertCapitalizedCase(currentSelectedTopMenuInfo.label) : "";
    const mainMenuName = currentSelectedSubMenuInfo.selectedMainMenuItem?.name ? convertCapitalizedCase(currentSelectedSubMenuInfo.selectedMainMenuItem.name) : "";
    const subMenuName = currentSelectedSubMenuInfo.selectedSubMenuItem?.subItemName || "";

    console.log('topMenuLabel : ', topMenuLabel);
    console.log('mainMenuName : ', topMenuLabel);
    console.log('subMenuName : ', topMenuLabel);

    // Added by AR on 2024-03-21:
    // Changed to save 'programType' as null instead of 'undefined' in session storage for better error handling.
    // This was done after noticing 'undefined' was stored as a string.
    let programType = sessionStorage.getItem('ProgramType') === 'undefined' ? null : sessionStorage.getItem('ProgramType');

    const interactionDetail = createInteractionDetail(topMenuLabel, mainMenuName,programType);
    const interactionMetric = createInteractionMetric(topMenuLabel, mainMenuName, subMenuName, programType);

    fetchLogRecord({
        interactionType: 'Community',
        interaction: 'CUV',
        interactionDetail: interactionDetail,
        interactionMetric: interactionMetric,
        url: '',
        appType: 'CUV'
    })
        .then(result => {
            console.log('Success! Result Message: ', result);
        })
        .catch(error => {
            console.log('ERROR');
            console.error(error);
        });

};

fetchLogInsert();


/**
 * CUV Adoption Analytics End -------------------------------------------------------------
 **/