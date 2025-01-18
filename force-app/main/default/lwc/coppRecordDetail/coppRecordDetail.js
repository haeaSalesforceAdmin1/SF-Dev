/**
* @description : To get input data for COPP KPI Detail information on the Account record page
* @author MinheeKim : minheekim@haeaus.com | 2024-08-12
* @ticket no: DPM-5700
 */

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getFromCOPPInfo from '@salesforce/apex/COPPKPIDetailController.getFromCOPPInfo';
import getKPIDetailsBySection from '@salesforce/apex/COPPKPIDetailController.getKPIDetailsBySection';
import saveKPIDetails from '@salesforce/apex/COPPKPIDetailController.saveKPIDetails';
import updateCOPPInfo from '@salesforce/apex/COPPKPIDetailController.updateCOPPInfo';
import getWAVEs from '@salesforce/apex/COPPKPIDetailController.getWAVEs';
import getAllWAVEs from '@salesforce/apex/COPPKPIDetailController.getAllWAVEs';
import getPermission from '@salesforce/apex/COPPKPIDetailController.getPermission';


export default class CoppRecordDetail extends LightningElement {
    activeSections = ['COPP', 'COPPKPI'];
    activeSectionsMessage = '';
    @track isViewMode = true;
    @track isEditMode = false;
    @api recordId;
    @track sections = [];
    @track initialScoreDate;
    @track targetScoreDate;
    @track DealerSalesScore;
    @track ExpectedSalesScore;
    @track errors = {};
    @track isErrors = {};
    @track coppInfoData = {}; 
    @track picklistOptions = [];
    
    
    @track InitialOptionsH = [
        { label: '--none--', value: '' },
        { label: 'GDSI 2.0 Not Compliant', value: 'GDSI 2.0 Not Compliant' },
    ];
    @track TargetOptionsH = [
        { label: '--none--', value: '' },
        { label: 'GDSI 2.0 Compliant', value: 'GDSI 2.0 Compliant' },
    ];

    @track InitialOptionsG = [
        { label: '--none--', value: '' },
        { label: 'GRD Not Compliant', value: 'GRD Not Compliant' },
    ];
    @track TargetOptionsG = [
        { label: '--none--', value: '' },
        { label: 'GRD Compliant', value: 'GRD Compliant' },
    ];

    @track errorStartDate = '';//Validate for Start Date
    @track errorGraduationDate = '';//Validate for Graduation Date
    @track errorCurrentMonth = '';//Validate for Current start month
    @track errorBuySellDate = '';//Validate for Buy/SellCOPP
    @track errorDealerScore = '';//Validate for dealer initial score
    @track errorExpectedScore = '';//Validate for expected initial score
    @track errorEndDate= '';
    @track errorGraduation='';
    @track errorBuySell='';
    @track errorBuySellStartDate='';
    @track errorWave = '';
    
    isNotCOPP = true;
    isCOPP = false;
    isSaveDisabled = true;
    missingRequired = false;

    validationInitial = true;
    validationTarget = true;
    validationDiff = true;
    validateCurrent = true;
    validateScore = true;
    validateDealerScore = true;
    validateExpectedScore = true;

    validaionWave = true;
    validaionEndDate = true;
    validationStartDate = true;
    validationGradDate = true;
    validaionEndDateCOPP = true;
    validaionBuySellCOPP = true;
    validaionBuySellCOPPEndDate = true;
    validationBuySellStartDate = true;

    isWAVENull;
    isGenesis; 
    isCOPPManager = false;
    formattedLastModifiedDate;
    BrandCode;

    wiredKpiDetailsResult;
    wiredCOPPDetailsResult;

    @track waveData = {}; // This will store the data from the Apex method
    selectedWaveName; // This should be bound to your UI element (e.g., a dropdown or input)

     /**
    * [Method Description] Check if the user is copp manager or system admin
    * Created by [MinheeKim] on [2024-09-09] for [DPM-5775]
    */
     @wire(getPermission)
     wiredPermission({ error, data }) {
        if (data) {
            this.isCOPPManager = data;  // Handle the result if successful
            console.log('isCOPPManager: '+ this.isCOPPManager);
        } else if (error) {
            console.error('Error retrieving permission:', error);  // Handle any error
        }
    }

    /**
    * [Method Description] Get fields related to COPP from Account obj
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    @wire(getFromCOPPInfo, { recordId: '$recordId' })
    wiredCOPPInfo(result) {
        this.wiredCOPPDetailsResult = result;
        console.log('result.data: '+result.data);
        if (result.data) {
            this.coppInfoData = result.data.coppInfo;
            this.formattedLastModifiedDate= this.coppInfoData.Last_Saved_Time__c? this.formatTimestamp(this.coppInfoData.Last_Saved_Time__c) : null ;
            console.log('this.coppInfoData.Account__c '+this.coppInfoData.Account__c );
            if(result.data.BrandCode =='G'){
                this.BrandCode = 'G'
                this.isGenesis = true;
            }else{
                this.BrandCode = 'H'
                this.isGenesis = false;
            }

            if(this.BrandCode!=null){
                this.fetchWAVEs();
            }

            if(this.coppInfoData.WAVE__c==null || this.coppInfoData.WAVE__c==''){
                this.isWAVENull = true;
            }else{
                this.isWAVENull = false;
            }

            if (this.coppInfoData.COPP__c || this.coppInfoData.Buy_Sell_COPP__c) {
                this.isNotCOPP = false;
                this.isCOPP = true;
            }
        } else if (result.error) {
            console.error('Error fetching account data:', result.error);
        }
    }

    fetchWAVEs() {
        getAllWAVEs({ BrandCode: this.BrandCode })  
            .then(result => {
                if (result) {
                    this.picklistOptions = Object.keys(result).map(wave => {
                        return { label: wave, value: wave };
                    });
                    
                    this.picklistOptions.unshift({ label: '--none--', value: '' });
    
                    console.log('wave: ' + JSON.stringify(this.picklistOptions));
                    this.error = undefined;
                }
            })
            .catch(error => {
                console.error('Error fetching WAVEs:', error);
                this.error = error;
                this.picklistOptions = [];
            });
    }
    

    formatTimestamp(dateString) {
        const date = new Date(dateString); 
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
            const day = date.getDate().toString().padStart(2, '0');
            const year = date.getFullYear();
            const hours = date.getHours().toString().padStart(2, '0');
            const minutes = date.getMinutes().toString().padStart(2, '0');

            return `${month}/${day}/${year} ${hours}:${minutes}`;
    }

    get hasData() {
        return this.coppInfoData !== undefined;
    }


    /**
    * [Method Description] Get fields related to the account from COPPKPIDetail obj
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    @wire(getKPIDetailsBySection, { recordId: '$recordId' })
    wiredKpiDetails(result) {
        this.wiredKpiDetailsResult = result;
        if (result.data) {
            let index = 0;
            this.sections = Object.keys(result.data).map(section => {

                return {
                    name: section,
                    details: result.data[section].map(kpiDetail => {
                        let targetScore = kpiDetail.kpiDetail.Target_Score__c;
                        let noTarget = false;
                        let isSalesEfficiency = false;

                        if ((kpiDetail.kpi.Name === 'Sales Efficiency % (R12)' || kpiDetail.kpi.Name === 'Reg Efficiency %') && !targetScore) {
                            targetScore = 100;
                        }else if (kpiDetail.kpi.Name === 'Dealer Sales' || kpiDetail.kpi.Name === 'Expected') {
                            noTarget = true;
                        }

                        if(kpiDetail.kpi.Name === 'Sales Efficiency % (R12)'){
                            isSalesEfficiency = true
                        }else if(kpiDetail.kpi.Name === 'Dealer Sales' ){
                            this.DealerSalesScore=kpiDetail.kpiDetail.Initial_Score__c;
                        }else if(kpiDetail.kpi.Name === 'Expected'){
                            this.ExpectedSalesScore=kpiDetail.kpiDetail.Initial_Score__c;
                        }

                        return {
                            kpi: { ...kpiDetail.kpi, isBranding: kpiDetail.kpi.Name === 'Branding'},
                            kpiDetail: { ...kpiDetail.kpiDetail, index: index++, Target_Score__c: targetScore, errorInitial:'', 
                                errorTarget:'', errorRequired:'', errorTargetScore:'',errorInitialScore:'', hideTarget: noTarget, salesEfficiency:isSalesEfficiency},
                            
                        };
                    })
                };
            });
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.sections = [];
        }
    }


    /**
    * [Method Description] Reset fields when user click cancel
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    reset(result) {
        //this.wiredKpiDetailsResult = result;
        if (result.data) {
            let index = 0;
            this.sections = Object.keys(result.data).map(section => {
                return {
                    name: section,
                    details: result.data[section].map(kpiDetail => {
                        let targetScore = kpiDetail.kpiDetail.Target_Score__c;
                        let noTarget = false;
                        let isSalesEfficiency = false;

                        if ((kpiDetail.kpi.Name === 'Sales Efficiency % (R12)' || kpiDetail.kpi.Name === 'Reg Efficiency %') && !targetScore) {
                            targetScore = 100;
                        }else if (kpiDetail.kpi.Name === 'Dealer Sales' || kpiDetail.kpi.Name === 'Expected') {
                            noTarget = true;
                        }

                        if(kpiDetail.kpi.Name === 'Sales Efficiency % (R12)'){
                            isSalesEfficiency = true
                        }else if(kpiDetail.kpi.Name === 'Dealer Sales' ){
                            this.DealerSalesScore=kpiDetail.kpiDetail.Initial_Score__c;
                        }else if(kpiDetail.kpi.Name === 'Expected'){
                            this.ExpectedSalesScore=kpiDetail.kpiDetail.Initial_Score__c;
                        }

                        return {
                            kpi: { ...kpiDetail.kpi, isBranding: kpiDetail.kpi.Name === 'Branding'},
                            kpiDetail: { ...kpiDetail.kpiDetail, index: index++, Target_Score__c: targetScore, errorInitial:'', 
                                errorTarget:'', errorRequired:'', errorTargetScore:'',errorInitialScore:'', hideTarget: noTarget, salesEfficiency:isSalesEfficiency},
                            
                        };
                    })
                };
            });
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.sections = [];
        }
    }

    /**
    * [Method Description] Reset fields when user click cancel
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    resetCOPPInfo(result) {
        //this.wiredKpiDetailsResult = result;
        if (result.data) {
            this.coppInfoData = result.data.coppInfo;
            this.errorStartDate = '';
            this.errorGraduationDate = '';
            this.errorCurrentMonth = '';
            this.errorBuySellDate = '';
            this.errorDealerScore = '';
            this.errorExpectedScore = '';
            this.errorEndDate= '';
            this.errorGraduation='';
            this.errorBuySell='';
            this.errorBuySellStartDate='';
            this.errorWave = '';
            
            console.log('this.coppInfoData.Account__c '+this.coppInfoData.Account__c );
            if(result.data.BrandCode =='G'){
                this.
                this.isGenesis = true;
            }else{
                this.isGenesis = false;
            }
            if(this.coppInfoData.WAVE__c==null || this.coppInfoData.WAVE__c==''){
                                   this.isWAVENull = true;
            }else{
                this.isWAVENull = false;
            }
                        
            
        } else if (result.error) {
            console.error('Error fetching account data:', result.error);
        }
    }

    get formattedInitialScoreDate() {
        return this.formatDate(this.initialScoreDate);
    }

    get formattedTargetScoreDate() {
        return this.formatDate(this.targetScoreDate);
    }

    /**
    * [Method Description] Format the date as MM-yyyy
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    formatDate(dateString) {
        if (!dateString) {
            return '';
        }
        const date = new Date(dateString);
        const month = ('0' + (date.getMonth() + 1)).slice(-2); // Add 1 because getMonth() returns 0-indexed month
        const year = date.getFullYear();
        return `${month}-${year}`;
    }

    /**
    * [Method Description] validate and save the fields when user change the values in copp kpi fields
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    handleFieldChange(event) {
        const field = event.target.name;
        const index = parseInt(event.target.dataset.index, 10);
        const value = event.target.value;

        event.target.dispatchEvent(new Event('input')); //added to get cached data.

        // Reset errors for the specific field
        if (!this.errors[index]) {
            this.errors[index] = {};
        }
        this.errors[index][field] = '';

        this.sections.forEach(section => {
            section.details.forEach(wrapper => {
                if (wrapper.kpiDetail.index === index) {
                    if (field === 'Initial_Score_Date__c' || field === 'Target_Score_Date__c') {
                        console.log('Date!');
                        if (value!=null && value!='' && !this.isValidDateFormat(value)) {
                            console.log('isValidDateFormat: '+this.isValidDateFormat(value));
                            
                            if(field === 'Initial_Score_Date__c' ){
                                wrapper.kpiDetail.errorInitial = 'Invalid month format. Expected MM-YYYY';
                                this.validationInitial = false;
                            }
                            if(field === 'Target_Score_Date__c'){
                                wrapper.kpiDetail.errorTarget = 'Invalid month format. Expected MM-YYYY';
                                this.validationTarget = false;
                            }
                            
                        } else if(wrapper.kpiDetail.Initial_Score_Date__c!=null && wrapper.kpiDetail.Target_Score_Date__c!=null){
                            wrapper.kpiDetail[field] = value;
                            //this.validation = true;
    
                            if(field === 'Initial_Score_Date__c' && this.isValidDateFormat(value) ){
                                wrapper.kpiDetail.errorInitial = '';
                                this.validationInitial = true;
                            }
                            if(field === 'Target_Score_Date__c' && this.isValidDateFormat(value)){
                                wrapper.kpiDetail.errorTarget = '';
                                this.validationTarget = true;
                            }

                            // Convert date strings to Date objects for comparison
                            const initialDate = new Date(wrapper.kpiDetail.Initial_Score_Date__c.replace(/(\d{2})-(\d{4})/, '$2-$1-01'));
                            const targetDate = new Date(wrapper.kpiDetail.Target_Score_Date__c.replace(/(\d{2})-(\d{4})/, '$2-$1-01'));
    
                            if ((field === 'Initial_Score_Date__c' || field === 'Target_Score_Date__c')) {
                                if (initialDate > targetDate && this.validationTarget && this.validationInitial) {
                                    wrapper.kpiDetail.errorInitial = 'Initial month must be before or equal to Target month';
                                    wrapper.kpiDetail.errorTarget = 'Target month must be after or equal to Initial month';
                                    // this.validationInitial = false;
                                    // this.validationTarget = false;
                                    this.validationDiff = false;
                                    console.log('1');
                                }else if(this.validationTarget && this.validationInitial){
                                    wrapper.kpiDetail.errorInitial = '';
                                    wrapper.kpiDetail.errorTarget = '';
                                    this.validationInitial = true;
                                    this.validationTarget = true;
                                    this.validationDiff = true;
                                    console.log('4');
                                }
                            }
                        }else if(value==null || value==''){
                            if (field === 'Initial_Score_Date__c'){
                                wrapper.kpiDetail.errorInitial = '';
                                console.log('5');
                            }//else
                            if(field === 'Target_Score_Date__c'){
                                wrapper.kpiDetail.errorTarget = '';
                                console.log('6');
                            }
                            
                        }else {
                            wrapper.kpiDetail.errorInitial = '';
                            wrapper.kpiDetail.errorTarget = '';
                            this.validationInitial = true;
                            this.validationTarget = true;
                            console.log('7');
                        }
                        wrapper.kpiDetail[field] = value;
                        
                    }else if (field === 'Initial_Score__c' || field === 'Target_Score__c') {
                        console.log('Score!');
                        if(value!=null && value!=''){
                            if (!this.isValidScoreFormat(value)) {
                                console.log('isValidScoreFormat: '+this.isValidScoreFormat(value));
                                
                                if(field === 'Initial_Score__c'){
                                    wrapper.kpiDetail.errorInitialScore = 'Invalid format. Expected number value';
                                    this.validateScore = false;
                                }
                                if(field === 'Target_Score__c'){
                                    wrapper.kpiDetail.errorTargetScore = 'Invalid format. Expected number value';
                                    this.validateScore = false;
                                }
                                
                            } else {
                                wrapper.kpiDetail.errorInitialScore = '';
                                wrapper.kpiDetail.errorTargetScore = '';
                                this.validateScore = true;
                            }
                        }else{
                            wrapper.kpiDetail.errorInitialScore = '';
                            wrapper.kpiDetail.errorTargetScore = '';
                            this.validateScore = true;
                        }
                        wrapper.kpiDetail[field] = value;
                        
                    } else if (field === 'Visiblity__c') {
                        wrapper.kpiDetail[field] = event.target.type === 'checkbox' ? event.target.checked : value;
                        
                        if (index === 0 && wrapper.kpiDetail[field] === true) {
                            this.sections.forEach(sec => {
                                sec.details.forEach(wrap => {
                                    if (wrap.kpiDetail.index === 1 || wrap.kpiDetail.index === 2) {
                                        wrap.kpiDetail.Visiblity__c = true;
                                    }
                                });
                            });
                        }
                        
                        console.log(`Updated ${field} for index ${index} to ${wrapper.kpiDetail[field]}`);
                    } else {
                        wrapper.kpiDetail[field] = event.target.type === 'checkbox' ? event.target.checked : value;
                        console.log(`Updated ${field} for index ${index} to ${wrapper.kpiDetail[field]}`);
                    }

                } 
                if(field=='DealerSalesScore'){ 
                    if (wrapper.kpiDetail.index == 1) {
                        console.log('Updating Initial_Score__c for index 1 with DealerSalesScore:', value);
                        wrapper.kpiDetail.Initial_Score__c = value;
                        this.DealerSalesScore = value;
                    }
                    console.log('Score!');
                    if(value!=null && value!=''){
                        wrapper.kpiDetail.errorRequired = '';
                        if (!this.isValidScoreFormat(value)) {
                            console.log('isValidScoreFormat: '+this.isValidScoreFormat(value));
                            this.errorDealerScore= 'Invalid format. Expected number value';
                            this.validateDealerScore = false;
                        } else {
                            this.errorDealerScore = '';
                            this.validateDealerScore = true;
                        }
                    }else{
                        this.errorDealerScore = '';
                        this.validateDealerScore = true;
                    }
                }else if(field=='ExpectedSalesScore'){
                    if (wrapper.kpiDetail.index == 2) {
                        console.log('Updating Initial_Score__c for index 1 with ExpectedSalesScore:', value);
                        wrapper.kpiDetail.Initial_Score__c = value;
                        this.ExpectedSalesScore = value;
                    }
                    console.log('Score!');
                    if(value!=null && value!=''){
                        wrapper.kpiDetail.errorRequired = '';
                        if (!this.isValidScoreFormat(value)) {
                            console.log('isValidScoreFormat: '+this.isValidScoreFormat(value));
                            this.errorExpectedScore= 'Invalid format. Expected number value';
                            this.validateExpectedScore = false;
                        } else {
                            this.errorExpectedScore = '';
                            this.validateExpectedScore = true;
                        }
                    }else{
                        this.errorExpectedScore = '';
                        this.validateExpectedScore = true;
                    }
                }
            });
        });
    }

    /**
    * [Method Description] validate the date user input (format: MM-YYYY) 
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    isValidDateFormat(value) {
        const regex = /^(0[1-9]|1[0-2])-(20[0-9]{2}|21[0-9]{2})$/;
        return regex.test(value);
    }

    /**
    * [Method Description] validate the score user input (format: numeric) 
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    isValidScoreFormat(value) {
        const regex = /^[0-9]+(\.[0-9]+)?$/;
        console.log('is Number: '+regex.test(value));
        return regex.test(value);
    }


    /**
    * [Method Description] validate and save the fields when user change the values at copp fields in account
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    handleAccountFieldChange(event) {
        const field = event.target.name;
        console.log(`Before ${field} : ${this.coppInfoData[field]}`);
        this.coppInfoData = { ...this.coppInfoData, [field]: event.target.type === 'checkbox' ? event.target.checked : event.target.value };

        if (field === 'WAVE__c') {
            if(this.coppInfoData.WAVE__c!=null && this.coppInfoData.WAVE__c!=''){
                const selectedWaveName = this.coppInfoData[field];
                const brandcode = this.BrandCode;
                // Fetch WAVE data based on the selected wave name
                if(selectedWaveName!='' && selectedWaveName!=null && selectedWaveName!='--none--'){
                    getWAVEs({ waveName: selectedWaveName, BrandCode: brandcode })
                    .then(result => {
                        // Update waveData with the result
                        this.waveData = result;
                        console.log('waveData:', this.waveData);
        
                        // Safely access months after ensuring waveData is updated
                        const months = this.waveData[selectedWaveName];
                        console.log('months: ' + months);
        
                        if (months && months.length > 0) {
                            this.coppInfoData.Initial_Start_Month__c = months[0];
                            this.coppInfoData.Current_Start_Month__c = months.length > 1 ? months[1] : null;
                            console.log('this.coppInfoData.Initial_Start_Month__c: ' + this.coppInfoData.Initial_Start_Month__c);
                            console.log('this.coppInfoData.Current_Start_Month__c: ' + this.coppInfoData.Current_Start_Month__c);
                        }
                        this.isWAVENull = false;
                    })
                    .catch(error => {
                        // Handle error (e.g., show toast message)
                        console.error('Error fetching WAVE data:', error);
                    });
                }
                    
            }else{
                this.isWAVENull = true;
                this.coppInfoData.Initial_Start_Month__c = null;
                this.coppInfoData.Current_Start_Month__c = null;
            }
        }

        /**Validations for COPP**/
        if(field === 'COPP__c' || field === 'Buy_Sell_COPP__c'){

            //Disable start date when it's not copp dealer
            if (this.coppInfoData.COPP__c || this.coppInfoData.Buy_Sell_COPP__c) {
                this.isNotCOPP = false;
                this.isCOPP = true;
            }else if(!this.coppInfoData.COPP__c && !this.coppInfoData.Buy_Sell_COPP__c){
                this.isNotCOPP = true;
                this.isCOPP = false;
                this.coppInfoData.COPP_Start_Date__c = null; //[DPM-5926] Test. Change this code to comments and roll back - 11.08.2024 MinheeKim 
            }

            //Validate for Buy/SellCOPP
            if(this.coppInfoData.Buy_Sell_COPP__c ==true && this.coppInfoData.COPP__c==true){
                this.errorBuySell = 'Buy/Sell COPP Flag cannot be checked when COPP Flag is checked.';
                this.validaionBuySellCOPP = false;
            }else{
                this.errorBuySell = '';
                this.validaionBuySellCOPP = true;
            }
        }

        if(field === 'COPP__c' || field === 'Buy_Sell_COPP__c' || field === 'WAVE__c'){
            //Validate for Wave
            if(this.coppInfoData.COPP__c && (this.coppInfoData.WAVE__c=='' ||  this.coppInfoData.WAVE__c==null)){
                this.errorWave = 'WAVE must be selected when COPP flag is checked.';
                this.validaionWave = false;
            }else if(this.coppInfoData.Buy_Sell_COPP__c && (this.coppInfoData.WAVE__c=='' ||  this.coppInfoData.WAVE__c==null)){
                this.errorWave = 'WAVE must be selected when Buy/Sell COPP flag is checked.';
                this.validaionWave = false;
            }else{
                this.errorWave = '';
                this.validaionWave = true;
            }
        }

        if( field === 'COPP__c' || field === 'COPP_Start_Date__c'){
            //Validate for Start Date
            if(this.coppInfoData.COPP_Start_Date__c ==null && this.coppInfoData.COPP__c==true){
                this.errorStartDate = 'COPP Start Date is a mandate field when COPP Flag is checked.';
                this.validationStartDate = false;
            }else{
                this.validationStartDate = true;
                this.errorStartDate = '';
            }

        }
        if(field === 'COPP__c' || field === 'COPP_End_Date__c' ){
            //Validate for Buy/SellCOPP
            if(this.coppInfoData.COPP_End_Date__c !=null && this.coppInfoData.COPP__c==true){
                this.errorEndDate = 'COPP can\'t be checked if COPP End Date is entered.';
                this.validaionEndDateCOPP = false;
            }else{
                this.errorEndDate = '';
                this.validaionEndDateCOPP = true;
            }
        }

        /**Validations for Buy/Sell COPP**/
        if( field === 'Buy_Sell_COPP__c' || field === 'COPP_Start_Date__c'){
            //Validate for Start Date and Buy/Sell
            if(this.coppInfoData.COPP_Start_Date__c ==null && this.coppInfoData.Buy_Sell_COPP__c==true){
                this.errorBuySellStartDate = 'COPP Start Date is a mandate field when Buy/Sell COPP Flag is checked.';
                this.validationBuySellStartDate = false;
            }else{
                this.validationBuySellStartDate = true;
                this.errorBuySellStartDate = '';
            }

        }

        if(field === 'Buy_Sell_COPP__c' || field === 'COPP_End_Date__c'){
            //Validate for Buy/SellCOPP
            if(this.coppInfoData.COPP_End_Date__c !=null && this.coppInfoData.Buy_Sell_COPP__c==true){
                this.errorBuySellDate = 'Buy/Sell COPP can\'t be checked if COPP End Date is entered.';
                this.validaionBuySellCOPPEndDate = false;
            }else{
                this.errorBuySellDate = '';
                this.validaionBuySellCOPPEndDate = true;
            }
        }




        if(field === 'COPP_Graduation__c' ||field === 'COPP_Graduation_Date__c' ){
            //Validate for Graduation Date
            if(this.coppInfoData.COPP_Graduation_Date__c ==null && this.coppInfoData.COPP_Graduation__c==true){
                this.errorGraduationDate = 'COPP Graduation Date is a mandate field when COPP Graduation Flag is checked';
                this.validationGradDate = false;
            }else if(this.coppInfoData.COPP_Graduation__c==false){
                this.coppInfoData.COPP_Graduation_Date__c = null;
                this.errorGraduationDate ='';
                this.validationGradDate = true;
            }else{
                this.errorGraduationDate ='';
                this.validationGradDate = true;
            }
        }
        if (field === 'Current_Start_Month__c') {
            console.log('Date!');
            if(this.coppInfoData.Current_Start_Month__c!=null && this.coppInfoData.Current_Start_Month__c!=''){
                let isValidate = this.isValidDateFormat(this.coppInfoData.Current_Start_Month__c);
                if (!isValidate) {
                    console.log('isValidDateFormat: '+this.isValidDateFormat(this.coppInfoData.Current_Start_Month__c));
                    this.errorCurrentMonth = 'Invalid month format. Expected MM-YYYY';
                    this.validateCurrent = false;
                    
                } else {
                    this.errorCurrentMonth = '';
                    this.validateCurrent = true;
                }
            }else if((this.coppInfoData.Current_Start_Month__c==null || this.coppInfoData.Current_Start_Month__c=='')&& this.coppInfoData.WAVE__c != null){
                this.errorCurrentMonth = 'Current Performance Period Start Month can not be blank when wave is selected.';
                this.validateCurrent = false;
            }else {
                this.errorCurrentMonth = '';
                this.validateCurrent = true;
            }
            
        } 
        
        

        


    
        console.log(`Updated ${field} to ${this.coppInfoData[field]}`);
    }

    /**
    * [Method Description] validate whether the required fields are missing or not
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    validateRequired(){
        this.missingRequired = false;
        //Required field shoud be filled
        this.sections.forEach(section => {
            section.details.forEach(wrapper => {
                if(wrapper.kpiDetail.Visiblity__c === false || 
                    ( wrapper.kpiDetail.index !=0 && wrapper.kpiDetail.Visiblity__c === true 
                    && (wrapper.kpiDetail.Initial_Score_Date__c!=null && wrapper.kpiDetail.Initial_Score_Date__c!='') 
                    && (wrapper.kpiDetail.Target_Score_Date__c!=null && wrapper.kpiDetail.Target_Score_Date__c !='')
                    && ((wrapper.kpiDetail.Initial_Score__c!=null && wrapper.kpiDetail.Initial_Score__c!='') 
                    || (wrapper.kpiDetail.Initial_Score_Text__c!=null && wrapper.kpiDetail.Initial_Score_Text__c!='') )
                    && ((wrapper.kpiDetail.Target_Score__c!=null && wrapper.kpiDetail.Target_Score__c!='')
                    ||(wrapper.kpiDetail.Target_Score_Text__c!=null && wrapper.kpiDetail.Target_Score_Text__c!=''))
                )){
                    if(!this.missingRequired) this.missingRequired = false;
                    wrapper.kpiDetail.errorRequired = '';
                    console.log(wrapper.kpiDetail.Name+': '+this.missingRequired);
                    
                }else if(wrapper.kpiDetail.Visiblity__c === false || 
                    ( wrapper.kpiDetail.index ==0  && wrapper.kpiDetail.Visiblity__c === true 
                    && (wrapper.kpiDetail.Initial_Score_Date__c!=null && wrapper.kpiDetail.Initial_Score_Date__c!='') 
                    && (wrapper.kpiDetail.Target_Score_Date__c!=null && wrapper.kpiDetail.Target_Score_Date__c !='')
                    && ((wrapper.kpiDetail.Initial_Score__c!=null && wrapper.kpiDetail.Initial_Score__c!='') 
                    || (wrapper.kpiDetail.Initial_Score_Text__c!=null && wrapper.kpiDetail.Initial_Score_Text__c!='') )
                    && ((wrapper.kpiDetail.Target_Score__c!=null && wrapper.kpiDetail.Target_Score__c!='')
                    ||(wrapper.kpiDetail.Target_Score_Text__c!=null && wrapper.kpiDetail.Target_Score_Text__c!=''))
                    && (this.DealerSalesScore!=null && this.DealerSalesScore!='')
                    && (this.ExpectedSalesScore!=null && this.ExpectedSalesScore!='')
                )){
                    if(!this.missingRequired) this.missingRequired = false;
                    wrapper.kpiDetail.errorRequired = '';
                    console.log(wrapper.kpiDetail.Name+': '+this.missingRequired);
                    console.log('DealerSalesScore: '+this.DealerSalesScore);
                    console.log('ExpectedSalesScore: '+this.ExpectedSalesScore);
                    
                }else if(wrapper.kpiDetail.index !=0 && wrapper.kpiDetail.index !=1 && wrapper.kpiDetail.index !=2 && wrapper.kpiDetail.Visiblity__c === true && 
                    ( (wrapper.kpiDetail.Initial_Score_Date__c==null || wrapper.kpiDetail.Initial_Score_Date__c=='') 
                    || (wrapper.kpiDetail.Target_Score_Date__c==null || wrapper.kpiDetail.Target_Score_Date__c=='')
                    || ((wrapper.kpiDetail.Initial_Score__c==null || wrapper.kpiDetail.Initial_Score__c=='') 
                    && (wrapper.kpiDetail.Initial_Score_Text__c==null || wrapper.kpiDetail.Initial_Score_Text__c==''))
                    || ((wrapper.kpiDetail.Target_Score__c==null || wrapper.kpiDetail.Target_Score__c=='')
                    && (wrapper.kpiDetail.Target_Score_Text__c==null || wrapper.kpiDetail.Target_Score_Text__c==''))
                )){
                    this.missingRequired = true;
                    wrapper.kpiDetail.errorRequired ='Fill in the required field.';
                    console.log(wrapper.kpiDetail.Name+': '+this.missingRequired);
                }else if(wrapper.kpiDetail.index ==0 && wrapper.kpiDetail.Visiblity__c === true && 
                    ( (wrapper.kpiDetail.Initial_Score_Date__c==null || wrapper.kpiDetail.Initial_Score_Date__c=='') 
                    || (wrapper.kpiDetail.Target_Score_Date__c==null || wrapper.kpiDetail.Target_Score_Date__c=='')
                    || ((wrapper.kpiDetail.Initial_Score__c==null || wrapper.kpiDetail.Initial_Score__c=='') 
                    && (wrapper.kpiDetail.Initial_Score_Text__c==null || wrapper.kpiDetail.Initial_Score_Text__c==''))
                    || ((wrapper.kpiDetail.Target_Score__c==null || wrapper.kpiDetail.Target_Score__c=='')
                    && (wrapper.kpiDetail.Target_Score_Text__c==null || wrapper.kpiDetail.Target_Score_Text__c==''))
                    || (this.DealerSalesScore==null  || this.DealerSalesScore=='' ) 
                    || (this.ExpectedSalesScore==null || this.ExpectedSalesScore=='')
                )){
                    this.missingRequired = true;
                    wrapper.kpiDetail.errorRequired ='Fill in the required field.';
                    console.log(wrapper.kpiDetail.Name+': '+this.missingRequired);
                    console.log('DealerSalesScore: '+this.DealerSalesScore);
                    console.log('ExpectedSalesScore: '+this.ExpectedSalesScore);
                }

                
            });
        });
    }

    /**
    * [Method Description] save the values that user input 
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    * Edited by [MinheeKim] on [2024-11-08] for [DPM-5926] added to towst error message when there's no COPP of Buy/Sell COPP flag checked, but COPP Start Date is not nul.
    */
    handleSave() {
        const details = [];
        this.sections.forEach(section => {
            section.details.forEach(wrapper => {
                details.push(wrapper.kpiDetail);
            });
        });

        //Validate for Start Date
        if(this.coppInfoData.COPP_Start_Date__c ==null && this.coppInfoData.COPP__c==true){
            this.errorStartDate = 'COPP Start Date is mandate field for COPP Flag checked.';
            this.validationStartDate = false;
        }else{
            this.validationStartDate = true;
            this.errorStartDate = '';
        }

        //Validate for Graduation Date
        if(this.coppInfoData.COPP_Graduation_Date__c ==null && this.coppInfoData.COPP_Graduation__c==true){
            this.errorGraduationDate = 'COPP Graduation Date is mandate field for COPP Graduation Flag checked.';
            this.validationGradDate = false;
        }else{
            this.errorGraduationDate ='';
            this.validationGradDate = true;
        }
        //Validate for Buy/SellCOPP
        if(this.coppInfoData.Buy_Sell_COPP__c ==true && this.coppInfoData.COPP__c==true){
            this.errorBuySellDate = 'Buy/Cell COPP Flag cannot be checked when COPP Flag is checked.';
            this.validaionBuySellCOPP = false;
        }else{
            this.errorBuySellDate = '';
            this.validaionBuySellCOPP = true;
        }
        //Validate for Buy/SellCOPP
        if(this.coppInfoData.COPP_End_Date__c !=null && this.coppInfoData.Buy_Sell_COPP__c==true){
                this.errorBuySellDate = 'Buy/Sell COPP can\'t be checked if COPP End Date is entered.';
                this.validaionBuySellCOPPEndDate = false;
        }else{
                this.errorBuySellDate = '';
                this.validaionBuySellCOPPEndDate = true;
        }
        

        //Validate for Start Date and Buy/Sell
        if(this.coppInfoData.COPP_Start_Date__c ==null && this.coppInfoData.Buy_Sell_COPP__c==true){
            this.errorBuySellStartDate = 'COPP Start Date is a mandate field when Buy/Sell COPP Flag is checked.';
            this.validationBuySellStartDate = false;
        }else{
            this.validationBuySellStartDate = true;
            this.errorBuySellStartDate = '';
        }
        

        //Validate for Buy/SellCOPP
        if(this.coppInfoData.COPP_End_Date__c !=null && this.coppInfoData.COPP__c==true){
                this.errorEndDate = 'COPP can\'t be checked if COPP End Date is entered.';
                this.validaionEndDateCOPP = false;
            }else{
                this.errorEndDate = '';
                this.validaionEndDateCOPP = true;
        }

        //Validate for Wave
        if(this.coppInfoData.COPP__c && (this.coppInfoData.WAVE__c=='' ||  this.coppInfoData.WAVE__c==null)){
            this.errorWave = 'WAVE must be selected when COPP flag is checked.';
            this.validaionWave = false;
        }else if(this.coppInfoData.Buy_Sell_COPP__c && (this.coppInfoData.WAVE__c=='' ||  this.coppInfoData.WAVE__c==null)){
            this.errorWave = 'WAVE must be selected when Buy/Sell COPP flag is checked.';
            this.validaionWave = false;
        }else{
            this.errorWave = '';
            this.validaionWave = true;
        }
        
        this.validateRequired();
        console.log('missingRequired : '+this.missingRequired);

        this.isSaveDisabled = this.validationInitial && this.validationTarget && this.validationDiff && this.validateScore && this.validationStartDate && this.validationGradDate && this.validaionBuySellCOPP 
                                && !this.missingRequired && this.validateCurrent && this.validateDealerScore && this.validaionEndDate 
                                && this.validaionBuySellCOPPEndDate && this.validaionEndDateCOPP && this.validationBuySellStartDate && this.validaionWave;

        if(this.isSaveDisabled){

            updateCOPPInfo({ coppInfo: this.coppInfoData })
                .then(() => {
                    this.isViewMode = true;
                    this.isEditMode = false;
                    if(this.coppInfoData.COPP_End_Date__c !=null){
                        this.coppInfoData.COPP__c = false;
                    }

                    saveKPIDetails({ kpiDetails: details })
                    .then(() => {
                        this.isViewMode = true;
                        this.isEditMode = false;
                        return refreshApex(this.wiredKpiDetailsResult);
                    })
                    .catch(error => {
                        console.error('Error saving KPI Details:', error);
                    });

                    
                    return refreshApex(this.wiredCOPPDetailsResult);

                
                })
                .catch(error => {
                    console.error('Error saving Account Details:', error);
                    //DPM-5926 added to towst error message by MinheeKim - 11.08.2024
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message, 
                        variant: 'error',
                    });
                    this.dispatchEvent(event);//DPM-5926 end
                });

            
      
            }
    }
   
    
    /**
    * [Method Description] change to edit mode when user click edit
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    handleEdit() {
        this.isViewMode = false;
        this.isEditMode = true;
    }

    /**
    * [Method Description] change to view mode when user click cancel
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    handleCancel() {
        this.isViewMode = true;
        this.isEditMode = false;
        this.reset(this.wiredKpiDetailsResult);
        this.resetCOPPInfo(this.wiredCOPPDetailsResult);

    }

    /**
    * [Method Description] open and close the toggle
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

   

    /**
    * [Method Description] check the brand code
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    get sectionContainer() {
        return this.isGenesis ? 'container genesis' : 'container';
    }

    /**
    * [Method Description] check the graduation field
    * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
    */
    get isCOPPGraduationDisabled() {
        return !this.coppInfoData?.COPP_Graduation__c;
    }


}