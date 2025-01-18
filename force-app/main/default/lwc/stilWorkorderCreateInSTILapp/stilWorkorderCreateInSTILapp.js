import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from "lightning/navigation"; //NavigationMixin.Navigate
import getCases from "@salesforce/apex/STIL_Utility.getCasesByKeywordInCreationFlow";
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';


// export default class Test_searchcase extends LightningElement {
export default class StilWorkorderCreateInSTILapp  extends LightningElement{

    @api lwcOutputRegionValue;
    @api lwcOutputPhaseValue;
    @api lwcOutputRequestOrgValue;
    @api lwcOutputSCSCaseNumValue;
    @api lwcOutputSubjectValue;

    searchKey;
    resHtmlStr;
    recommendations = [];
    retrievedResult = [];
    recommendationsObj = {};
    selectedObj = {};

    recommendationsExist = false;
    isHidden = 'isHidden'; 


    /**
     * 
     * Edited by Areum on 2024-10-24 for OU24-124
     * Dispatches a FlowAttributeChangeEvent to update 'lwcOutputSCSCaseNumValue' with an empty string.
     */
    catchModalSearchKeyChange(event) {
      console.log('catchModalSearchKeyChange>>>>');
        console.log('event.target.value');
        console.log(event.target.value);
        this.searchKey = event.target.value;
        console.log(`searchKey ${this.searchKey}`)
        if (this.searchKey.length > 1){
          this.handleApexGetAddress(this.searchKey);
        }else{// if len become 0 ( no character in searchTxt input )
          this.recommendations = [];
          this.recommendationsExist = false;

          // Edited by Areum on 2024-10-24 for OU24-124
          this.dispatchEvent(new FlowAttributeChangeEvent('lwcOutputSCSCaseNumValue', ''));
        }
    }

    selectSearchClick() {
        console.log("=========APEX CALLOUT =======");
        this.handleApexGetAddress(this.searchKey);
      }



      debouncingTimer; // 디바운싱을 위한  debouncingTimer선언
      handleApexGetAddress(searchKey) {
        if (this.debouncingTimer) {
          clearTimeout(this.debouncingTimer);
        }
        this.debouncingTimer = setTimeout(() => {
            
            getCases({ keyword: searchKey })
            .then((res) => {
              // console.log("res");
              // console.log(res);
              this.retrievedResult = res;
              this.recommendations = res;
              this.recommendationsObj = res.reduce((acc, item) => {
                acc[item.Id] = item;
                return acc;
            }, {});
            // console.log(`ReccomendationObj >>>>  ${this.recommendationsObj}`);
            // console.log(this.recommendationsObj);
              
              if(res.length > 0 ){

                this.isHidden = 'isNotHidden';

                this.recommendationsExist = true;
                  this.resHtmlStr = ''; //init 
                  //resHtmlStr += 
                  res.forEach((i) => {(
                    this.resHtmlStr  += `<li key=${i.Id}
                      class="slds-listbox__item li_stil"
                      onclick="handleSelect()"
                      data-id=${i.Id}
                      onmouseover="this.style.backgroundColor='#006db9';this.style.cursor = 'pointer';" onmouseout="this.style.backgroundColor='';this.style.cursor = 'default';"                     
                      >
                      ${i.SCSCaseNumber__c} ${i.Stage__c}
                      </li> ` 
                    )}
                  ) 

                  // this.setupClickHandlers();


              }
            })
            .catch((error) => {
              console.error("error : ", error);
              console.error("error handleApexGetAddress ");
            });
        }, 800); /// debounce using TIMEOUT 
      }
    handleMouseEnter(event) {
      event.currentTarget.classList.add('li_hover');
      event.currentTarget.classList.remove('li_normal');
  }
  
  handleMouseLeave(event) {
      event.currentTarget.classList.add('li_normal');
      event.currentTarget.classList.remove('li_hover');
  }


  handleSelect(event){
        const selectedCaseId = event.currentTarget.dataset.id;
        let stringFull = event.currentTarget.textContent;
        // console.log(stringFull.split('/')[0].replace(/\s/g, '') ); //str.replace(/\s/g, '');
        let caseNumber = event.currentTarget.textContent.split('/')[0].replace(/\s/g, '') ;
        this.searchKey = caseNumber; // Update the input to show the selected name
        let objSelected = this.recommendations.find(item => item.Id === selectedCaseId);
        // console.log("objSelected");
        // console.log(objSelected);
        this.recommendations = [];
        this.recommendationsExist = false;

        let objArr =  this.recommendationsObj; 
        let selectedRegionVal =  objSelected['SCSCaseRegion__c'];
        // OU24-146 change the phase value shown as ->  SDA 
        let selectedPhaseVal  =  objSelected && typeof objSelected['Stage__c'] === 'string' && objSelected['Stage__c'].includes('SDA') ?  'SDA' :     objSelected['Stage__c']  ;
        let selectedCaseNumVal  =  objSelected['SCSCaseNumber__c'];
        let selectedSubjectVal  =  objSelected['Subject'];
        let selectObj = {
            lwcOutputRegionValue : selectedRegionVal ,
            lwcOutputPhaseValue :  selectedPhaseVal,
            lwcOutputRequestOrgValue : "NASO",
            lwcOutputSCSCaseNumValue :  selectedCaseNumVal,
            lwcOutputSubjectValue :  selectedSubjectVal,
        }
        sessionStorage.setItem( "selectedCase" ,JSON.stringify(selectObj));




        ["lwcOutputRegionValue", "lwcOutputPhaseValue","lwcOutputRequestOrgValue","lwcOutputSCSCaseNumValue","lwcOutputSubjectValue"].forEach((loc) => {
          this.dispatchEvent(new FlowAttributeChangeEvent(loc, selectObj[loc] )); //console.log(`value ==>> ${selectObj[loc]}`);

      });


        // hard coded - OU24-122
        let reqOrgObj = {
            'North America': 'NASO',
            'Europe' : 'EASO',
            'Other':'KASO'
        }

    }

  setupClickHandlers(){
    console.log('START +==== setupClickHandlers()'); 
      const liTags = this.template.querySelectorAll('li');
      liTags.forEach((i)=>{
        // console.log('setupClickHandlers ===========    i================');
        // console.log(i);
        i.addEventListener('mouseenter', () => {
          i.style.backgroundColor = '#006db9'; // Change background color on hover
          i.style.cursor = 'pointer'; // Change cursor to pointer on hover
        });
        i.addEventListener('mouseleave', () => {
          i.style.backgroundColor = ''; // Revert background color
          i.style.cursor = 'default'; // Revert cursor
        });
      })
  }

  connectedCallback() {
    // console.log('START +==== connectedCallback()'); 
    // console.log('GET SELECTED');
    // console.log(sessionStorage.getItem("selectedCase")); //sessionStorage.setItem( "selectedCase" ,JSON.stringify(selectObj));
    // console.log(sessionStorage.getItem('lwcOutputRegionValue'));
    // console.log(sessionStorage.getItem('lwcOutputPhaseValue'));
    // console.log(sessionStorage.getItem('lwcOutputRequestOrgValue'));
    // console.log(sessionStorage.getItem('lwcOutputSCSCaseNumValue'));
    // console.log(sessionStorage.getItem('lwcOutputSubjectValue'));
    // this.searchKey = sessionStorage.getItem('lwcOutputSCSCaseNumValue');
    // sessionStorage.clear();
    // console.log('END +==== connectedCallback()'); 
  }
  disconnectedCallback(){
    // console.log('START +==== disconnectedCallback()'); 

    // console.log('END +==== disconnectedCallback()'); 
  }
  
  renderedCallback() {
    // console.log('START +==== RenderedCallback()'); 
    this.setupClickHandlers();
  }



}