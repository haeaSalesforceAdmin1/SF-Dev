import { LightningElement, api } from 'lwc';
import getEinsteinKPIDetailsForEvaluation from '@salesforce/apex/KPISelectorController.getEinsteinKPIDetailsForEvaluation';
import saveEvaluationKPIRecord from '@salesforce/apex/KPISelectorController.saveEvaluationKPIRecord';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
//import TRAILHEAD_LOGO from '@salesforce/resourceUrl/trailhead_logo';

export default class KPISelector extends LightningElement {

    @api recordId;
    @api mandatoryKPIs;
    @api optionalKPIs;
    @api allKPIs;
    @api saveIndexCount = 0;
    @api showSpinner = false;

    connectedCallback() {
        this.showSpinner = true;
        var mandatoryIndex = 0;
        var optionalIndex = 0;
        getEinsteinKPIDetailsForEvaluation({evaluationId: this.recordId})
        .then(results => {
            var tempMandatoryKPIs = [];
            var tempOptionalKPIs = [];
            var tempAllKPIS = [];
            console.log('My Result: ');
            console.log(JSON.stringify(results));
            results.forEach(result => {
                //alert('here');
                console.log('line 29');
                console.log(JSON.stringify(result));
                let kpiWrapper = {};
                console.log('EKPIDetail:' ,result.einsteinKPIDetail);
                kpiWrapper.externalId = null;
                if(result.evaluationKPI.EvalKPIExternalID__c != undefined && result.evaluationKPI.EvalKPIExternalID__c != null) {
                    kpiWrapper.externalId = result.evaluationKPI.EvalKPIExternalID__c;
                }

                kpiWrapper.actionPlanId = null;
                kpiWrapper.actionPlanURL = null;
                console.log(result.evaluationKPI.ActionPlan__c);
                if(result.evaluationKPI.ActionPlan__c != undefined && result.evaluationKPI.ActionPlan__c != null) {
                    kpiWrapper.actionPlanId = result.evaluationKPI.ActionPlan__c;
                    kpiWrapper.actionPlanURL = '/lightning/r/Action_Plan__c/' + result.evaluationKPI.ActionPlan__c + '/view';
                }
                
                kpiWrapper.evaluationKPIDetailId = null;
                if(result.evaluationKPI.EinsteinKPIDetail__c != undefined && result.evaluationKPI.EinsteinKPIDetail__c != null) {
                    kpiWrapper.einsteinKPIDetailId = result.evaluationKPI.EinsteinKPIDetail__c;
                }

                kpiWrapper.kpiname = result.KPIName;
                kpiWrapper.ranking = result.einsteinKPI.Ranking__c;
                kpiWrapper.missingDetail = false;
                if(result.einsteinKPIDetail != null && result.einsteinKPIDetail.Key_Value__c != null && !result.einsteinKPIDetail.Key_Value__c.startsWith('null')) {
                    kpiWrapper.thresholdstatus = result.einsteinKPIDetail.ThresholdStatus__c;
                    kpiWrapper.keyvalue = result.einsteinKPIDetail.Key_Value__c;
                    kpiWrapper.thresholdvalue = result.einsteinKPIDetail.Threshold_Value__c;
                }
                else {
                    kpiWrapper.missingDetail = true;
                }
                    if(result.regionEinsteinKPIDetail != null && result.regionEinsteinKPIDetail.Key_Value__c != null && !result.regionEinsteinKPIDetail.Key_Value__c.startsWith('null')) {    
                        kpiWrapper.DealerValue = result.regionEinsteinKPIDetail.EinsteinKPI__r.Dealer_Value_is_High__c;
                        if(kpiWrapper.DealerValue == false){
                            kpiWrapper.regionkeyvalue = result.regionEinsteinKPIDetail.Key_Value__c;
                            let regionKeyvalue = (result.regionEinsteinKPIDetail.Key_Value__c).toString();
                            let kpiWrapperkeyvalue = (kpiWrapper.keyvalue).toString();
                            if(parseFloat(regionKeyvalue.replace(',', '')) >= parseFloat(kpiWrapperkeyvalue.replace(',', ''))){
                                console.log('Region KPI Green: ',result.regionEinsteinKPIDetail.Key_Value__c);
                                console.log('KeyValue KPI ',kpiWrapperkeyvalue);
                                kpiWrapper.regionKeyValueColor = 'green';
                            }
                            else{
                                console.log('Region KPI Red: ',regionKeyvalue);
                                console.log('KeyValue KPI ',kpiWrapperkeyvalue);
                                kpiWrapper.regionKeyValueColor = 'red';
                            }
                        } else{
                        //if(result.regionEinsteinKPIDetail != null && result.regionEinsteinKPIDetail.Key_Value__c != null && !result.regionEinsteinKPIDetail.Key_Value__c.startsWith('null')) {
                            kpiWrapper.regionkeyvalue = result.regionEinsteinKPIDetail.Key_Value__c;
                            let regionKeyvalue = (result.regionEinsteinKPIDetail.Key_Value__c).toString();
                            let kpiWrapperkeyvalue = (kpiWrapper.keyvalue).toString();
                            if(parseFloat(regionKeyvalue.replace(',', '')) > parseFloat(kpiWrapperkeyvalue.replace(',', ''))){
                                kpiWrapper.regionKeyValueColor = 'red';
                            }
                            else{
                                kpiWrapper.regionKeyValueColor = 'green';
                            }
            
                        //}
                    }
                }
              
                if(result.districtEinsteinKPIDetail != null && result.districtEinsteinKPIDetail.Key_Value__c != null && !result.districtEinsteinKPIDetail.Key_Value__c.startsWith('null')) {
                    kpiWrapper.DealerValue = result.districtEinsteinKPIDetail.EinsteinKPI__r.Dealer_Value_is_High__c;
                    if(kpiWrapper.DealerValue == false){
                        kpiWrapper.districtkeyvalue = result.districtEinsteinKPIDetail.Key_Value__c;
                        let districtKeyValue = (result.districtEinsteinKPIDetail.Key_Value__c).toString();
                        let kpiWrapperkeyvalue = (kpiWrapper.keyvalue).toString();
                        if(parseFloat(districtKeyValue.replace(',', '')) >= parseFloat(kpiWrapperkeyvalue.replace(',', ''))){
                            console.log('District KPI Green: ',districtKeyValue);
                            console.log('KeyValue KPI ',kpiWrapperkeyvalue);
                            kpiWrapper.districtKeyValueColor = 'green';
                        }
                        else{
                            console.log('District KPI Red: ',districtKeyValue);
                            console.log('KeyValue KPI ',kpiWrapperkeyvalue);
                            kpiWrapper.districtKeyValueColor = 'red';
                        }
                    }else{
                        kpiWrapper.districtkeyvalue = result.districtEinsteinKPIDetail.Key_Value__c;
                        let districtKeyValue = (result.districtEinsteinKPIDetail.Key_Value__c).toString();
                        let kpiWrapperkeyvalue = (kpiWrapper.keyvalue).toString();
                        if(parseFloat(districtKeyValue.replace(',', '')) > parseFloat(kpiWrapperkeyvalue.replace(',', ''))){
                            console.log('District KPI Red: ',districtKeyValue);
                            console.log('KeyValue KPI ',kpiWrapperkeyvalue);
                            kpiWrapper.districtKeyValueColor = 'red';
                        }
                        else{
                            console.log('District KPI Red: ',districtKeyValue);
                            console.log('KeyValue KPI ',kpiWrapperkeyvalue);
                            kpiWrapper.districtKeyValueColor = 'green';
                        }
                    }
                }

                kpiWrapper.kpiId = result.einsteinKPI.KPI__c;
                kpiWrapper.iconfilepath = null;
                //console.log(JSON.stringify('result.evaluationKPI'));
                //console.log(JSON.stringify(result.evaluationKPI));
                kpiWrapper.includeinexport = result.evaluationKPI.Include_in_PDF__c;
                kpiWrapper.actionplanreview = result.evaluationKPI.ActionPlanReviewRequired__c;

                if(result.evaluationKPI.Include_in_PDF__c==true && result.evaluationKPI.ActionPlan__c != undefined && result.evaluationKPI.ActionPlan__c != null) {
                    kpiWrapper.checkboxeslocked = true;
                }
                else {
                    if(result.einsteinKPI.ActionPlanRequirement__c == 'Mandatory') {
                        if(kpiWrapper.thresholdstatus == 'Failed') {
                            kpiWrapper.checkboxeslocked = true;
                        }
                    }
                    else {
                        kpiWrapper.checkboxeslocked = false;
                    }
                }

                if(kpiWrapper.thresholdstatus == 'Success') {
                    kpiWrapper.iconfilepath = '/img/msg_icons/confirm32.png';
                }
                else if(kpiWrapper.thresholdstatus == 'Failed') {
                    kpiWrapper.iconfilepath = '/img/msg_icons/error32.png';
                }

                if(result.einsteinKPI.ActionPlanRequirement__c == 'Mandatory') {
                    kpiWrapper.includeInPDFName = 'mandatory-inlcudeinpdf-' + mandatoryIndex;
                    kpiWrapper.createActionPlanName = 'mandatory-actionplanrequired-' + mandatoryIndex;
                    tempMandatoryKPIs.push(kpiWrapper);
                    mandatoryIndex++;
                }
                else {
                    kpiWrapper.includeInPDFName = 'optional-inlcudeinpdf-' + optionalIndex;
                    kpiWrapper.createActionPlanName = 'optional-actionplanrequired-' + optionalIndex;
                    tempOptionalKPIs.push(kpiWrapper);
                    optionalIndex++;
                }
                console.log('kpiWrapper');
                console.log(kpiWrapper);
                tempAllKPIS.push(kpiWrapper);
            });

            this.allKPIs = tempAllKPIS;
            this.mandatoryKPIs = tempMandatoryKPIs;
            this.optionalKPIs = tempOptionalKPIs;
            this.showSpinner = false;

        })
        .catch(error => {
            //this.isLoading = false;
            //this.handlerror(error);
        });
    }

    handleCancel() {
        let closeQuickActionEvent = new CustomEvent("closequickactionevent");
        this.dispatchEvent(closeQuickActionEvent);
    }

    handleSaveKPIs() {
        this.showSpinner = true;
        this.handleSave();
    }
    
    async handleSave() {
        if(this.saveIndexCount == this.allKPIs.length) {
            this.showSpinner = false;
            let closeQuickActionEvent = new CustomEvent("closequickactionevent");
            this.dispatchEvent(closeQuickActionEvent);
            //window.location = '/' + component.get("v.recordId");
            window.location = '/lightning/r/Action_Plan__c/' + this.recordId + '/view';
        }
        else {
            var einsteinKPI = this.allKPIs[this.saveIndexCount];
            //cosnole.log(JSON.stringify(einsteinKPI));
            var evaluationKPI = {};
            //evaluationKPI.KPI__c = einsteinKPI.kpiId;
            evaluationKPI.Include_in_PDF__c = einsteinKPI.includeinexport;
            evaluationKPI.ActionPlanReviewRequired__c = einsteinKPI.actionplanreview;
            evaluationKPI.EvalKPIExternalID__c = einsteinKPI.externalId;
            evaluationKPI.ActionPlan__c = einsteinKPI.actionPlanId;
            evaluationKPI.Evaluation__c = this.recordId;
            evaluationKPI.KPI__c = einsteinKPI.kpiId;
            evaluationKPI.EinsteinKPIDetail__c = einsteinKPI.einsteinKPIDetailId;
            if(einsteinKPI.keyvalue != undefined) {
                evaluationKPI.Initial_Key_Value__c = einsteinKPI.keyvalue;
            }

            if(einsteinKPI.thresholdvalue != undefined) {
                evaluationKPI.Initial_Threshold_Value__c = einsteinKPI.thresholdvalue;
            }

            var evalKPIJSON = JSON.stringify(evaluationKPI)
            console.log(evalKPIJSON);
            const saveresult = await saveEvaluationKPIRecord({ evaulationKPIJSON: evalKPIJSON });
            console.log('save result');
            console.log(saveresult);
            this.saveIndexCount ++;
            this.handleSaveKPIs();
        }
        
    }

    handleIncludeInPDFMandatoryChanged(event) {
        console.log(event.currentTarget.dataset.name);
        var checkboxclicked = event.currentTarget.dataset.name;
        var checkboxclickedarray = event.currentTarget.dataset.name.split('-');
        var indexSelected = checkboxclickedarray[2];
        console.log(event.target.checked);
        this.mandatoryKPIs[indexSelected].includeinexport = event.target.checked;        
    }

    handleIncludeInPDFOptionalChanged(event) {
        console.log(event.currentTarget.dataset.name);
        var checkboxclicked = event.currentTarget.dataset.name;
        var checkboxclickedarray = event.currentTarget.dataset.name.split('-');
        var indexSelected = checkboxclickedarray[2];
        console.log(event.target.checked);
        this.optionalKPIs[indexSelected].includeinexport = event.target.checked;   
    }

    handleActionPlanRequiredMandatoryChanged(event) {
        console.log(event.currentTarget.dataset.name);
        var checkboxclicked = event.currentTarget.dataset.name;
        var checkboxclickedarray = event.currentTarget.dataset.name.split('-');
        var indexSelected = checkboxclickedarray[2];
        console.log(event.target.checked);
        this.mandatoryKPIs[indexSelected].actionplanreview = event.target.checked;
        this.mandatoryKPIs[indexSelected].includeinexport = event.target.checked; 
    }

    handleActionPlanRequiredOptionalChanged(event) {
        console.log(event.currentTarget.dataset.name);
        var checkboxclicked = event.currentTarget.dataset.name;
        var checkboxclickedarray = event.currentTarget.dataset.name.split('-');
        var indexSelected = checkboxclickedarray[2];
        console.log(event.target.checked);
        this.optionalKPIs[indexSelected].actionplanreview = event.target.checked; 
        this.optionalKPIs[indexSelected].includeinexport = event.target.checked;
    }
}