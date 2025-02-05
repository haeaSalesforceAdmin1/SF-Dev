/**
     * [Class Description] COPP Project - COPP Dealer View Dashboard
     * Created by [MinheeKim] on [2024-09-11] for [DPM-5707]
    */
import { LightningElement, api, track, wire } from 'lwc';


export default class CoppDealerView extends LightningElement {

    @track _brandCode;
    @track _coppKPIData;

    _isBrandCodeSet = false;
    _isCoppKPIDataSet = false;
    _isBrandingSet = false;
    _isCOPPSet = false;
    showMessage=false;

     @api
    set brandCode(value) {
        this._brandCode = value;
        console.log('BrandCode Set:', value);
        this._isBrandCodeSet = true;  
        this.checkAndProcessData();   
    }

    get brandCode() {
        return this._brandCode;
    }

    @track brandings = [];
    _brandingQuery;
    
    @api 
    set brandingQuery(value) {
        this._brandingQuery = value;
        this._isBrandingSet = true;
        this.processBrandingData();
        this.checkAndProcessData();
    }

    get brandingQuery() {
        return this._brandingQuery;
    }

    @track kpiDetails = [];
    _coppKPIData;
    
    @api
    set coppKPIData(value) {
        this._coppKPIData = value;
        console.log('coppKPIData Set:', value);
        this._isCoppKPIDataSet = true;  
        this.checkAndProcessData();     
    }

    get coppKPIData() {
        return this._coppKPIData;
    }

    @track coppFlags = [];
    @api 
    set coppChecked(value) {
        this._coppChecked = value;
        this._isCOPPSet = true;
        this.checkAndProcessData();
    }

    get coppChecked() {
        return this._coppChecked;
    }
    @api reportingMonth;
    //@api brandingQuery;

    /**
     * [Method Description] COPP Project - check whether the the parameters from CRMA are all loaded 
     * Created by [MinheeKim] on [2024-09-17] for [DPM-5707]
    */
    checkAndProcessData() {
        if (this._isBrandCodeSet && this._isCoppKPIDataSet && this._isBrandingSet && this._isCOPPSet) {
            this.processCOPP();  
        }
    }

    /**
     * [Method Description] COPP Project - process the branding data from CRMA
     * Created by [MinheeKim] on [2024-09-17] for [DPM-5707]
    */
    processBrandingData() {
        if (this._brandingQuery) {  
            console.log('Data branding:', this._brandingQuery);
            let arrayKPI = JSON.parse(this._brandingQuery);
            if (Array.isArray(arrayKPI) && arrayKPI.length > 0) {
                this.brandings = arrayKPI
                    .map(item => {
                        return {
                            dealer_cd: item[0] ? item[0] : '', 
                            achived: item[1] ? item[1] : ''
                        };
                    });
            } else {
                console.error('branding is either not an array or empty');
            }
        } else {
            console.error('branding is undefined or null');
        }
    }

    /**
     * [Method Description] COPP Project - to set up the copp flag and Buy/Sell copp flag
     * Created by [MinheeKim] on [2024-09-30] for [DPM-5707]
    */
    processCOPP(){
        if (this._coppChecked) {  
            console.log('Data copp checked:', this._coppChecked);
            let arrayKPI = JSON.parse(this._coppChecked);
            if (Array.isArray(arrayKPI) && arrayKPI.length > 0) {
                this.coppFlags = arrayKPI
                    .map(item => {
                        return {
                            dealer_cd: item[0] ? item[0] : '', 
                            copp: item[1] ? item[1] : '',  
                            buysell: item[2] ? item[2] : '',
                            hideCOPP : item[1]=='N' && item[2]=='N' ? true : false
                        };
                    });

                const trueFlags = this.coppFlags.filter(flag => flag.hideCOPP);

                if (trueFlags.length === 1) {
                    this.showMessage = true;
                }

                if(!this.showMessage){
                    this.processData();
                }
            } else {
                console.error('copp is either not an array or empty');
            }
        } else {
            console.error('copp is undefined or null');
        }
    }

    /**
     * [Method Description] COPP Project - get data from crma to lwc
     * Created by [MinheeKim] on [2024-09-11] for [DPM-5707]
    */
    processData() {
        if (this._coppKPIData) {
            
            console.log('Data received:', this._coppKPIData);
            let arrayKPI = JSON.parse(this._coppKPIData);
            if (Array.isArray(arrayKPI) && arrayKPI.length > 0) {
                this.kpiDetails = arrayKPI
                    .filter(item => !(item[2] == 310 || item[2] == 315 || item[2] == '310' || item[2] == '315' || item[1] == 'Dealer Sales' || item[1] == 'Expected'))
                    .map(item => {
                        return {
                            dealer_cd: item[0] ? item[0] : '', 
                            kpi_name: item[1] ? item[1] : '',  
                            kpi_seq: item[2] ? item[2] : '',   
                            cur_score: item[3] ? item[3] : '-', 
                            cur_month: item[4] ? item[4] : '',  
                            init_score: item[5] ? item[5] : '-',  
                            init_month: item[6] ? item[2]==800 ? this.brandingMonth(item[0],item[11]) : item[6] : '',  
                            tgt_score: item[7] ? item[7] : '-',  
                            tgt_month: item[8] ? item[8] : '',  
                            is_percent: item[9] ? item[9] : '',  
                            vs_tgt: item[10] ? item[10] : '-',  
                            reportMonth : item[11] ? this.setReportingMonth(item[11]) : '',
                            brandScore: item[2]==800 ? this.brandingCurrent(item[0],item[11]) : null,

                            vsTgtClass: item[10] && item[2] ? this.getVsTgtClass(item[10], item[2]) : '',
                            show: true,
                            branding: item[2]==800 ? true : false,
                            brandingChecked : item[2]==800 ? this.getBranding(this.brandingCurrent(item[0],item[11])) : ''
                        };

                    });
            } else {
                console.error('coppKPIData is either not an array or empty');
            }
        } else {
            console.error('coppKPIData is undefined or null');
        }
    }

    /**
     * [Method Description] COPP Project - process the current score of branding data 
     * Created by [MinheeKim] on [2024-09-17] for [DPM-5707]
    */
    brandingCurrent(dealerCD, reportMonth) {
        let brandingKPIs = this.brandings;
        let brandCode = this.brandCode;
        
        if (Array.isArray(brandingKPIs)) {
            let achieved = null;
            let result = '';  
    
            brandingKPIs
                .forEach(item => {
                    if(item.dealer_cd == dealerCD) {
                        achieved = item.achived ? item.achived.replace('-', '').substring(0, 6) : null;
                        
                        if (achieved !== null) {
                            if (reportMonth >= achieved) {
                                if (brandCode === 'G') {
                                    result = 'GRD Compliant';
                                } else if (brandCode === 'H') {
                                    result = 'GDSI 2.0 Compliant';
                                }
                            } else {
                                if (brandCode === 'G') {
                                    result = 'GRD Not Compliant';
                                } else if (brandCode === 'H') {
                                    result = 'GDSI 2.0 Not Compliant';
                                }
                            }
                        } else if (achieved === null && brandCode === 'G') {
                            result = 'GRD Not Compliant';
                        } else if (achieved === null && brandCode === 'H') {
                            result = 'GDSI 2.0 Not Compliant';
                        }
                    }
                });
    
            return result;  
        } else {
            console.error('brandingKPIs is either not an array or empty');
            return 'Unknown';  
        }
    }
    

    /**
     * [Method Description] COPP Project - process the achieved month of branding data 
     * Created by [MinheeKim] on [2024-09-17] for [DPM-5707]
    */
    brandingMonth(dealerCD, reportMonth){
        let brandingKPIs = this.brandings;
        const months = [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
            "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"
        ];
        let result = '';  
        

        if(brandingKPIs){
            brandingKPIs
            .map(item => {
                let achieved = item.achived ? item.achived.replace('-', '').substring(0, 6) : null;
                if(item.dealer_cd == dealerCD){
                    if(item.achived && reportMonth >= achieved ){
                        let parts = item.achived.split('-');
                        let year = parts[0]; // "2024"
                        let monthIndex = parseInt(parts[1], 10) - 1; // "09" -> 9 -> 8 
                        
                        let formattedDate = `${months[monthIndex]} ${year}`;
                        result = formattedDate;
                    }
                    
                }
            });
            return result;
        }else{
                console.error('brandingQuery is either not an array or empty');
                return 'Unknown';
        }
    }

    /**
     * [Method Description] COPP Project - process the report month  
     * Created by [MinheeKim] on [2024-09-17] for [DPM-5707]
    */
    setReportingMonth(reportMonth){

        const months = [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ];
        if(reportMonth){
            const year = reportMonth.substring(0, 4);  
            const month = reportMonth.substring(4, 6); 
            const monthName = months[parseInt(month, 10) - 1];

            return `${monthName} ${year}`;
                        
        }              
        return null;

    }

    
    /**
     * [Method Description] COPP Project - check the brand code
     * Created by [MinheeKim] on [2024-09-11] for [DPM-5707]
    */
    get brandClass() {
        return this.brandCode === 'G' ? 'g-brand' : 
               this.brandCode === 'H' ? 'h-brand' : '';
    }

    /**
     * [Method Description] COPP Project - check the target data is positive or not
     * Created by [MinheeKim] on [2024-09-11] for [DPM-5707]
     * Edited by [MinheeKim] on [2025-01-22] for [DPM-6035]]
    */
    getVsTgtClass(vsTgt, seq) {
        if ((seq==325 && vsTgt && vsTgt.includes('-')) || (seq!=325 && vsTgt && vsTgt.includes('+'))) {
            return 'positive';
        } else if ((seq==325 && vsTgt && vsTgt.includes('+')) ||  (seq!=325 && vsTgt && vsTgt.includes('-')) ) {
            return 'negative';
        }else if(vsTgt=='-'){
            return 'black';
        }
        return '';
    }


    /**
     * [Method Description] COPP Project - check the branding data is positive or not
     * Created by [MinheeKim] on [2024-09-17] for [DPM-5707]
    */
    getBranding(currentScore){

        if(currentScore.includes('Not')){
            return 'negativeBranding'
        }
        return 'positiveBranding'

    }


}