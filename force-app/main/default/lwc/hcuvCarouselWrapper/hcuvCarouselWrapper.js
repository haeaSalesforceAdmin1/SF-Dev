import { LightningElement, track, api } from 'lwc';
import fetchCarouselConfigInfo from '@salesforce/apex/HCUV_CarosuelConfigController.fetchCarouselConfigInfo';
import { communityList, defaultProgramType } from 'c/hcuvUtility';
import networkId from '@salesforce/community/Id';

const alphaNumericSort = (keyset = []) => {
    const sorter = (a, b) => {
        const isNumber = (v) => (+v).toString() === v;
        const aPart = a.match(/\d+|\D+/g);
        const bPart = b.match(/\d+|\D+/g);
        let i = 0; let len = Math.min(aPart.length, bPart.length);
        while (i < len && aPart[i] === bPart[i]) { i++; };
        if (i === len) {
            return aPart.length - bPart.length;
        };
        if (isNumber(aPart[i]) && isNumber(bPart[i])) {
            return aPart[i] - bPart[i];
        };
        return aPart[i].localeCompare(bPart[i]);
    };
    keyset.sort(sorter);
};

export default class HmaCarouselWrapper extends LightningElement {

    @track defaultPrg = communityList.HCUV_Default_Program;
    @track slides = [];
    @api isImagesAvailable = false;
    @api isOneImageOrZero = false;
    @api stopDotView = false;
    imageBasePath;
    @api isCarouselActive;
    networkId = networkId;
    programName = '';


    connectedCallback() {

        if (sessionStorage.getItem('ProgramType') != null) {
            this.programName = sessionStorage.getItem('ProgramType');
        }
        else {
            this.programName = defaultProgramType();
        }
        this.carouselConfigResult();
    }

    async carouselConfigResult() {
        try {
            let result = [];
            let orientMode = window.matchMedia("(orientation: landscape)");
            result = await fetchCarouselConfigInfo({ programName: this.programName, networkId: this.networkId });
            console.log('......'+JSON.stringify(result));
            if (result) {
                var conts = result;
                let i = 0, slide_index = 0;
                let keyset = Object.keys(conts);
                alphaNumericSort(keyset);

                for (var j = 0; j < keyset.length; j++) {
                    let key = keyset[j];
                    i++;
                    if (conts[key].active == true) {
                        slide_index++;
                        this.isImagesAvailable = true;
                        this.isOneImageOrZero = false;
                        var IsOpen_InSeparateTab = '_blank';
                        var hasHyperLink = false;

                        if (conts[key].isOpenInSeperateTab == false)
                            IsOpen_InSeparateTab = '_self';

                        if (conts[key].contentId) {
                            hasHyperLink = true;
                        } else {
                            hasHyperLink = false;
                        }
                        let CommunitySite = communityList.COMMUNITY_BASE_PATH.substring(0, communityList.COMMUNITY_BASE_PATH.indexOf("/s"));
                        this.slides.push({ image: CommunitySite + '/sfc/servlet.shepherd/document/download/' + conts[key].contentId, href: conts[key].carouselImage, slideIndex: slide_index, cardClasses: "slds-show carouselItemContainer", dotClasses: 'dot', isInSeparateTab: IsOpen_InSeparateTab, hyperLink: hasHyperLink });

                    }
                }

                if (orientMode.matches) {
                    if (!(communityList.DEVICE_FORM_FACTOR == 'Small')) {
                        if (slide_index <= 1) {
                            this.isOneImageOrZero = true;
                            this.stopDotView = true;
                        } else {
                            this.stopDotView = false;
                        }
                    } else {
                        this.isOneImageOrZero = true;
                        if (slide_index <= 1) {
                            this.stopDotView = true;
                        } else {
                            this.stopDotView = false;
                        }
                    }
                } else {
                    this.isOneImageOrZero = true;
                    if (slide_index <= 1) {
                        this.stopDotView = true;
                    } else {
                        this.stopDotView = false;
                    }
                }
                this.slides = JSON.parse(JSON.stringify(this.slides));

            }
        }
        catch (err) { }
    }

    get enableCarousel() {

        if (communityList.DEVICE_FORM_FACTOR == 'Small' && this.isCarouselActive == true)
            return true;
        else if (communityList.DEVICE_FORM_FACTOR != 'Small' && (this.isCarouselActive == false || this.isCarouselActive == undefined || this.isCarouselActive == ''))
            return true;
        else
            return false;
    }
}