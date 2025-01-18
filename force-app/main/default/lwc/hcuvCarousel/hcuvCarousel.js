import { LightningElement, api } from 'lwc';
import {communityList, defaultProgramType} from 'c/hcuvUtility';
const CARD_VISIBLE_CLASSES = `slds-show-${defaultProgramType()}`
const CARD_HIDDEN_CLASSES = 'slds-hide'
const DOT_VISIBLE_CLASSES = 'dot active'
const DOT_HIDDEN_CLASSES = 'dot'
const DEFAULT_SLIDER_TIMER = 10000

export default class HmaCarousel extends LightningElement {

    slides = []
    slideIndex = 1
    timer = [];
    @api slideTimer = DEFAULT_SLIDER_TIMER;
    @api getImagesAvailability;
    @api isSingleImage;
    @api isStopDotView;
    @api get slidesData() {
        return this.slides
    }

    carouselmethod() { }
    set slidesData(data) {
        this.slides = data.map((item, index) => {
            return index === 0 ? {
                ...item,
                slideIndex: index + 1,
                cardClasses: CARD_VISIBLE_CLASSES,
                dotClasses: DOT_VISIBLE_CLASSES
            } : {
                    ...item,
                    slideIndex: index + 1,
                    cardClasses: CARD_HIDDEN_CLASSES,
                    dotClasses: DOT_HIDDEN_CLASSES
                }
        })
    }

    connectedCallback() {
        try {
            this.timer = window.setInterval(() => {
                this.slideSelectionHandler(this.slideIndex + 1)
            }, Number(this.slideTimer))
        }
        catch (err) {
            console.log("Something went wrong!!", err.name + '  ' + err.message, "error");
        }
    }

    disconnectedCallback() {
        window.clearInterval(this.timer)
    }

    currentSlide(event) {
        let slideIndex = Number(event.target.dataset.id)
        this.slideSelectionHandler(slideIndex)
    }

    backslide() {
        let slideIndex = this.slideIndex - 1
        this.slideSelectionHandler(slideIndex)
    }
    forwardslide() {
        let slideIndex = this.slideIndex + 1
        this.slideSelectionHandler(slideIndex)
    }

    slideSelectionHandler(id) {
        try {
            if (communityList.DEVICE_FORM_FACTOR == 'Small') {
                const container = this.template.querySelector('.slds-is-relative.container');
                let touchstartX = 0;
                let touchendX = 0;
                container.addEventListener('touchstart', (e) => {
                    e.stopPropagation();
                    e.stopImmediatePropagation();
                    touchstartX = e.changedTouches[0].screenX;
                });
                container.addEventListener('touchend', e => {
                    e.stopPropagation();
                    e.stopImmediatePropagation();
                    touchendX = e.changedTouches[0].screenX;
                    if (touchendX < touchstartX) {
                        this.forwardslide();
                    }
                    if (touchendX > touchstartX) {
                        this.backslide();
                    }
                });
            }

            if (id > this.slides.length) {
                this.slideIndex = 1
            } else if (id < 1) {
                this.slideIndex = this.slides.length
            } else {
                this.slideIndex = id
            }
            this.slides = this.slides.map(item => {
                return this.slideIndex === item.slideIndex ? {
                    ...item,
                    cardClasses: CARD_VISIBLE_CLASSES,
                    dotClasses: DOT_VISIBLE_CLASSES
                } : {
                        ...item,
                        cardClasses: CARD_HIDDEN_CLASSES,
                        dotClasses: DOT_HIDDEN_CLASSES
                    }
            })
        }
        catch (err) {
            console.log("Something went wrong!!", err.name + '  ' + err.message, "error");
        }
    }

    get imageURL(){
        //console.log('watch:' + JSON.stringify(this.slides));
        return `background-image: url(${this.slides[this.slideIndex-1].image})`;

    }

    get reponsiveImageLink(){
        //console.log('watch:' + JSON.stringify(this.slides));
        return `imageLink-${defaultProgramType()}`;
    }
    get reponsiveSldsShow(){
        //console.log('watch:' + JSON.stringify(this.slides));
        return `imageLink-${defaultProgramType()}`;
    }
}