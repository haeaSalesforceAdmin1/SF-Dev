/**
 * Created by User on 2023-06-28.
 * Edited by Semy Lee on 2023-01-23
 * 
 * Code modification / BPark / 20240727 / DPM-5617
 **/
import { LightningElement, track, api, wire } from 'lwc';

export default class KeystoneEstimator extends LightningElement {
    @api results;
    @api metadata;
    @api guBun;
    @api bonus;
    @api payoutDataSet;
    

    @api payout;
    @api opportunity;
    @api sumPayout;
    @api sumOpp;
    @api sumOppMax;
    @api totalPercent;
    @api totalCurrency;
    @api allTotalSum;
    @api totalListModelItem;
    @api monthlyArrDataSet;
    @api quarterlyOppPayout;

    @api tempData1;

    @api currentDate;

    payout = [];
    opportunity = [];
    tempData1 = [];

    modelByMsrp = new Map([
        ['G70', '47500'],
        ['G80', '64500'],
        ['ELECTRIFIED G80', '86000'],
        ['G90', '95000'],
        ['GV60', '67500'],
        ['GV70', '55500'],
        ['GV70 EV', '71500'],
        ['GV80', '68000']
    ]);
                            
    /**
        @Description : Check data - payoutDataSet
    **/
    get data() {
        let dealer = '';
        let dealer_check = '';
        if (this.guBun == 'Monthly') {
            dealer = this.payoutDataSet.split(',')[13].replace(/[^A-Za-z0-9]/gi, '');
        } else {
            dealer = this.payoutDataSet.split(',')[2].replace(/[^A-Za-z0-9]/gi, '');
        }
        dealer_check = dealer.substring(0, 2);
        return 'dealer_cd:' + dealer + '; check:' + dealer_check + '; data:' + JSON.stringify(this.payoutDataSet);
    }

    /**
        @Description : Check GuBun
    **/
    get checkGuBun() {
        return this.guBun == 'Monthly' ? true : false;
    }

    /**
        @Description : Check Quarterly Title
    **/
    get checkQuarterlyTitle() {
        let title = '';
        
        if (this.guBun == 'Monthly') {
            title = 'Signature';
        } else {
            let checkNC = this.payoutDataSet.split(',')[2].replace(/[^A-Za-z0-9]/gi, '').substring(0, 2);
            if(checkNC == 'NC'){
                title = 'Apex';
            } else {
                title = 'Signature';
            }
        }
        return title;
    }

    /**
        @Description : Check Payout <div>
    **/
    get checkNC() {
        let check = false;

        if(this.guBun == 'Monthly'){
            check = false;
        } else {
            let checkNC = this.payoutDataSet.split(',')[2].replace(/[^A-Za-z0-9]/gi, '').substring(0, 2);
            if(checkNC == 'NC'){
                check = true;
            } else {
                check = false;
            }
        }
        return check;
    }

    /**
        @Description : Check Opportunity Title
    **/
    get checkOpportunityTitle() {
        let title = '';
    
        if (this.guBun == 'Monthly') {
            title = 'ACHIEVED';
        } else {
            let checkBonus = (this.bonus != null & parseFloat(this.bonus) > 0) ? parseFloat(this.bonus).toFixed(2) : 0;
            let checkNC = this.payoutDataSet.split(',')[2].replace(/[^A-Za-z0-9]/gi, '').substring(0, 2);
            if (checkNC == 'NC') {
                if (this.payoutDataSet.includes('ADAPTIVE')) {
                    if (checkBonus <= 0) {
                        title = 'ACHIEVED';
                    } else {
                        title = 'Units to next Category';
                    }
                } else if (this.payoutDataSet.includes('FULLY')) {
                    if (checkBonus <= 0) {
                        title = 'ACHIEVED';
                    } else {
                        title = 'Units to next Category';
                    }
                } else {
                    title = 'ACHIEVED';
                }
            } else {
                title = 'ACHIEVED';
            }
        }
        return title;
    }

    /**
        @Description : Set Top Time Period Value
    **/
    get estimatorDate() {
        var date = new Date();
        var dateValue = '';
        var dateMonth = date.getMonth() + 1;

        if(this.guBun == 'Monthly'){
            if(this.currentDate == 'null'){
                dateValue = date.getFullYear() + '-' + ('0' + dateMonth).slice(-2);
            } else {
                dateValue = this.currentDate;
            }
        } else {
            if(this.currentDate == 'null'){
                dateValue = date.getFullYear() + 'Q' + Math.ceil(dateMonth/3);
            } else {
                dateValue = this.currentDate;
            }
        }
        return dateValue;
    }

    /**
        @Description : Set Model List
    **/
    get listModelItems() {
        console.log('this.results '+JSON.stringify(this.results));
        console.log('this.metadata '+JSON.stringify(this.metadata));
        console.log('this.guBun '+this.guBun);
        console.log('this.bonus '+this.bonus);
        console.log('this.monthlyArrDataSet '+JSON.stringify(this.monthlyArrDataSet));
        console.log('this.quarterlyOppPayout '+JSON.stringify(this.quarterlyOppPayout));
        console.log('this.currentDate '+this.currentDate);

        if (this.results == null) {
            return [];
        }

        if(this.tempData1.length == 0) {
            let totalSum = 0;
            let tempRdr = new Map();
            let tempCan = new Map();
            this.results.forEach((element, index) => {
                if(element.rdr_type == 'RDR') tempRdr.set(element.vehicle_model, element);
                else if(element.rdr_type == 'CAN') tempCan.set(element.vehicle_model, element);
            });

            let i = 0;
            let tempSumSales = 0;
            for (const [key, value] of this.modelByMsrp) {
                let tempModel = key == 'ELECTRIFIED G80' ? 'G80 EV' : key;
                let tempMsrp = value;
                let tempRdrCount = tempRdr.get(key) != null ? tempRdr.get(key).count : 0;
                let tempCanCount = tempCan.get(key) != null ? tempCan.get(key).count : 0;
                let tempSales = tempRdrCount - tempCanCount;
                totalSum += tempSales * tempMsrp;
                let tempMap = {
                    id : i,
                    model : tempModel,
                    sales : tempSales,
                    msrp : tempMsrp
                };
                this.tempData1.push(tempMap);
                i++;
                tempSumSales += tempSales;
            }
            this.totalListModelItem = tempSumSales;
            this.tempData1.sort((a, b) => a.id - b.id);
            this.allTotalSum = totalSum;
        }
        return this.tempData1;
    }

    /**
        @Description : Set Estimated Payout List
    **/
    get listPayoutItems() {
        let checkBonus = (this.bonus != null & parseFloat(this.bonus) > 0) ? parseFloat(this.bonus).toFixed(2) : 0;

        if(this.guBun == 'Monthly'){
            let checkNC = this.payoutDataSet.split(',')[13].replace(/[^A-Za-z0-9]/gi, '').substring(0, 2);

            if (checkNC == 'NC') {
                this.payout = [
                    {
                        id: '1',
                        program: 'Retailer Performance Bonus',
                        achieved: this.monthlyArrDataSet.total_achievement >= 100 && this.monthlyArrDataSet.sedan_achievement >= 100 ? 'Y' : 'N',
                        payout1: checkBonus > 0 ? parseFloat(checkBonus).toFixed(2) : '-',
                        payout2: '0'
                    },
                    {
                        id: '2',
                        program: 'Sales Customer Experience Index',
                        achieved: this.monthlyArrDataSet.gbx_bonus > 0 ? 'Y (' + this.monthlyArrDataSet.gbx_retailer_status + ')' : 'N',
                        payout1: this.monthlyArrDataSet.gbx_bonus > 0 ? parseFloat(this.monthlyArrDataSet.gbx_bonus).toFixed(2) : '-',
                        payout2: '0'
                    },
                    {
                        id: '3',
                        program: 'Service Customer Experience Index',
                        achieved: this.monthlyArrDataSet.gsx_bonus > 0 ? 'Y (' + this.monthlyArrDataSet.gsx_retailer_status + ')' : 'N',
                        payout1: this.monthlyArrDataSet.gsx_bonus > 0 ? parseFloat(this.monthlyArrDataSet.gsx_bonus).toFixed(2) : '-',
                        payout2: '0'
                    }
                ];
            } else {
                this.payout = [
                    {
                        id: '1',
                        program: 'Retailer Performance Bonus',
                        achieved: this.monthlyArrDataSet.total_achievement >= 100 && this.monthlyArrDataSet.sedan_achievement >= 100 ? 'Y' : 'N',
                        payout1: checkBonus > 0 ? parseFloat(checkBonus).toFixed(2) : '-',
                        payout2: '0'
                    },
                    {
                        id: '2',
                        program: 'Sales Customer Experience Index',
                        achieved: this.monthlyArrDataSet.gbx_bonus > 0 ? 'Y (' + this.monthlyArrDataSet.gbx_retailer_status + ')' : 'N',
                        payout1: this.monthlyArrDataSet.gbx_bonus > 0 ? parseFloat(this.monthlyArrDataSet.gbx_bonus).toFixed(2) : '-',
                        payout2: '0'
                    },
                    {
                        id: '3',
                        program: 'Service Customer Experience Index',
                        achieved: this.monthlyArrDataSet.gsx_bonus > 0 ? 'Y (' + this.monthlyArrDataSet.gsx_retailer_status + ')' : 'N',
                        payout1: this.monthlyArrDataSet.gsx_bonus > 0 ? parseFloat(this.monthlyArrDataSet.gsx_bonus).toFixed(2) : '-',
                        payout2: '0'
                    },
                    {
                        id: '4',
                        program: 'Exclusivity',
                        achieved: this.monthlyArrDataSet.fa_stat_pf == 1 && this.monthlyArrDataSet.fa_type_pf == 1 ? this.monthlyArrDataSet.fa_type+' | '+this.monthlyArrDataSet.fa_stat : 'N',
                        payout1: this.monthlyArrDataSet.fa_bonus > 0 ? parseFloat(this.monthlyArrDataSet.fa_bonus).toFixed(2) : '-',
                        payout2: '0'
                    }
                ];
            }
        } else {
            let checkNC = this.payoutDataSet.split(',')[2].replace(/[^A-Za-z0-9]/gi, '').substring(0, 2);

            if (checkNC == 'NC') {
                let type = '';
                if(this.payoutDataSet.includes('ADAPTIVE')) {
                    type = 'ae';
                    this.payout = [
                        {
                            id: '1',
                            program: 'Genesis Apex Retailer',
                            achieved: checkBonus > 0 ? 'Y' : 'N',
                            payout3: checkBonus > 0 ? this.getSales(type, this.totalListModelItem) : '-'
                        }
                    ];
                } else if(this.payoutDataSet.includes('FULLY')) {
                    type = 'fe';
                    this.payout = [
                        {
                            id: '1',
                            program: 'Genesis Apex Retailer',
                            achieved: checkBonus > 0 ? 'Y' : 'N',
                            payout3: checkBonus > 0 ? this.getSales(type, this.totalListModelItem) : '-'
                        }
                    ];
                } else {
                    this.payout = [
                        {
                            id: '1',
                            program: 'Genesis Apex Retailer',
                            achieved: 'N',
                            payout3: '-'
                        }
                    ];
                }
            } else {
                this.payout = [
                    {
                        id: '1',
                        program: 'Genesis Signature Retailer',
                        achieved: checkBonus > 0 ? 'Y' : 'N',
                        payout1: checkBonus > 0 ? checkBonus : '-',
                        payout2: '0'
                    }
                ];
            }
        }
        this.callChild();
        return this.payout;
    }

    /**
        @Description : Set Estimated Opportunity List
    **/
    get listOppItems() {
        if(this.guBun == 'Monthly'){
            // RPB
            let tempRPB = this.monthlyArrDataSet.total_achievement >= 100 && this.monthlyArrDataSet.sedan_achievement >= 100 ? '-' : 'Y';
            let tempRPBType = this.monthlyArrDataSet.fa_type == 'null' ? '1.00' : '1.50';
            
            // GBX
            let achievedGBX = this.monthlyArrDataSet.gbx >= 977 ? '-' : 'Y (' + this.getPayoutGBX(1000)[2] + ')';
            let payoutGBX = this.monthlyArrDataSet.gbx_bonus > 0
                ? (this.getPayoutGBX(1000)[1] - this.getPayoutGBX(this.monthlyArrDataSet.gbx)[0]).toFixed(2)
                : (this.getPayoutGBX(1000)[1]).toFixed(2);

            // GSX
            let achievedGSX = this.monthlyArrDataSet.gsx >= 966 ? '-' : 'Y (' + this.getPayoutGSX(1000)[2] + ')';
            let payoutGSX = this.monthlyArrDataSet.gsx_bonus > 0
                ? (this.getPayoutGSX(1000)[1] - this.getPayoutGSX(this.monthlyArrDataSet.gsx)[0]).toFixed(2)
                : (this.getPayoutGSX(1000)[1]).toFixed(2);

            this.opportunity = [
                {
                    id: '1',
                    program: 'Retailer Performance Bonus',
                    achieved: tempRPB,
                    payout1: tempRPB == 'Y' ? tempRPBType : '-',
                    payout2: '0'
                },
                {
                    id: '2',
                    program: 'Sales Customer Experience Index',
                    achieved: achievedGBX,
                    payout1: this.monthlyArrDataSet.gbx >= 977 ? '-' : payoutGBX,
                    payout2: this.monthlyArrDataSet.gbx >= 977 ? '-' : '0'
                },
                {
                    id: '3',
                    program: 'Service Customer Experience Index',
                    achieved: achievedGSX,
                    payout1: this.monthlyArrDataSet.gsx >= 966 ? '-' : payoutGSX,
                    payout2: this.monthlyArrDataSet.gsx >= 966 ? '-' : '0'
                }
            ];
        } else {
            let checkBonus = (this.bonus != null & parseFloat(this.bonus) > 0) ? parseFloat(this.bonus).toFixed(2) : 0;
            let checkNC = this.payoutDataSet.split(',')[2].replace(/[^A-Za-z0-9]/gi, '').substring(0, 2);

            if(checkNC == 'NC') {
                let type = '';
                if(this.payoutDataSet.includes('ADAPTIVE')) {
                    type = 'ae';
                    this.opportunity = [
                        {
                            id: '1',
                            program: 'Genesis Apex Retailer',
                            achieved: checkBonus <= 0 ? 'Y' : this.getQtr(this.totalListModelItem),
                            payout4: this.getSales(type, this.totalListModelItem)
                        }
                    ];
                } else if(this.payoutDataSet.includes('FULLY')) {
                    type = 'fe';
                    this.opportunity = [
                        {
                            id: '1',
                            program: 'Genesis Apex Retailer',
                            achieved: checkBonus <= 0 ? 'Y' : this.getQtr(this.totalListModelItem),
                            payout4: this.getSales(type, this.totalListModelItem)
                        }
                    ];
                } else {
                    this.opportunity = [
                        {
                            id: '1',
                            program: 'Genesis Apex Retailer',
                            achieved: this.quarterlyOppPayout > 0 ? 'Y' : '-',
                            payout2: '0'
                        }
                    ];
                }
            } else {
                this.opportunity = [
                    {
                        id: '1',
                        program: 'Genesis Signature Retailer',
                        achieved: this.quarterlyOppPayout > 0 ? 'Y' : '-',
                        payout1: this.quarterlyOppPayout > 0 ? parseFloat(this.quarterlyOppPayout - checkBonus).toFixed(2) : '-',
                        payout2: '0'
                    }
                ];
            }
        }
        this.callChild();
        return this.opportunity;
    }

    /**
        @Description : Called when model Sales/MSRP changed
    **/
    handleChange(event) {
        // Get the row index and field name from the dataset
        const rowIndex = event.target.dataset.rowIndex;
        const fieldName = event.target.dataset.fieldName;
        const updatedValue = event.target.value;

        // Find the corresponding object in the updated data
        const updatedObject = this.tempData1.find(obj => obj.rowIndex === rowIndex);
        if (updatedObject) {
            updatedObject[fieldName] = updatedValue;
        }
        this.tempData1[rowIndex][fieldName] = updatedValue;

        let totalSum = 0;
        let tempSumSales = 0;
        this.tempData1.forEach(function(data, idx){
            if(data.sales > 0) tempSumSales += parseInt(data.sales);
            totalSum += data.sales * data.msrp;
        });
        this.totalListModelItem = tempSumSales;
        this.allTotalSum = totalSum;
        this.callChild();
    }

    /**
        @Description : Calculate Payout/Opportunity/Maximum
    **/
    callChild() {
        if(this.payout != null){
            this.reLoad(this.payout, this.allTotalSum);
            let payPercent = this.getPercent(this.payout);
            let payCurrency = this.getCurrency(this.payout, this.allTotalSum);

            let tempMap = {
                payPercent : payPercent > -1 ? parseFloat(payPercent).toFixed(2) : '-',
                payCurrency : payPercent > -1 ? (parseFloat(payCurrency).toFixed(0)*1).toLocaleString() : '-',
                prefix : (payPercent > -1 ? 'currency' : 'none'),
                suffix : (payPercent > -1 ? 'percent' : 'none')
            };
            this.sumPayout = tempMap;
            this.totalPercent = payPercent;
            this.totalCurrency = (parseFloat(payCurrency).toFixed(0)*1);
        }

        if(this.opportunity != null){
            this.reLoad(this.opportunity, this.allTotalSum);
            let payPercent = this.getPercent(this.opportunity);
            let payCurrency = this.getCurrency(this.opportunity, this.allTotalSum);
            let tempMap = {
                payPercent : payPercent > -1 ? parseFloat(payPercent).toFixed(2) : '-',
                payCurrency : payPercent > -1 ? (parseFloat(payCurrency).toFixed(0)*1).toLocaleString() : '-',
                prefix : (payPercent > -1 ? 'currency' : 'none'),
                suffix : (payPercent > -1 ? 'percent' : 'none')
            };
            this.sumOpp = tempMap;
            this.totalPercent += payPercent;
            this.totalCurrency += (parseFloat(payCurrency).toFixed(0)*1);
        }

        let tempMap = {
            payPercent : this.totalPercent > -1 ? parseFloat(this.totalPercent).toFixed(2) : '-',
            payCurrency : this.totalPercent > -1 ? (parseFloat(this.totalCurrency).toFixed(0)*1).toLocaleString() : '-',
            prefix : (this.totalPercent > -1 ? 'currency' : 'none'),
            suffix : (this.totalPercent > -1 ? 'percent' : 'none')
        };

        this.total = tempMap;

    }

    /**
        @Description : Set Payment/Opportunity/Max Class Properties
    **/
    reLoad(jsonArr, totalSum) {
        let type = '';
        let qty = this.totalListModelItem;
        let prefixNCPayType = 'currency';
        let prefixNCOppType = 'currency';

        let step = '-';
        let nextQty = 0;
        let nextStep = '-';

        let checkBonus = (this.bonus != null & parseFloat(this.bonus) > 0) ? parseFloat(this.bonus).toFixed(2) : 0;

        if (this.guBun !== 'Monthly') {
            if (this.payoutDataSet.includes('ADAPTIVE')) {
                type = 'ae';
                if (checkBonus > 0) {
                    prefixNCPayType = 'currency';
                    step = this.getSales(type, qty);
                    nextQty = Number(this.getQtr(qty)) + Number(qty);
                } else {
                    prefixNCPayType = 'none';
                    step = '-';
                    nextQty = Number(qty);
                }
                nextStep = qty <= 0 ? Number(this.getSales(type, 1)) : Number(this.getSales(type, Number(nextQty)));
            } else if (this.payoutDataSet.includes('FULLY')) {
                type = 'fe';
                if (checkBonus > 0) {
                    prefixNCPayType = 'currency';
                    step = this.getSales(type, qty);
                    nextQty = Number(this.getQtr(qty)) + Number(qty);
                } else {
                    prefixNCPayType = 'none';
                    step = '-';
                    nextQty = Number(qty);
                }
                nextStep = qty <= 0 ? Number(this.getSales(type, 1)) : Number(this.getSales(type, Number(nextQty)));
            } else {
                step = '-';
                prefixNCPayType = 'none';
                prefixNCOppType = 'none';
            }
        }

        jsonArr.forEach(function(data, idx){
            if (data.payout1 > -1) {
                let tempPayout = parseFloat(data.payout1 * totalSum / 100).toFixed(0);
                data.payout2 = (tempPayout*1).toLocaleString();
                data.payoutNCPay = step.toLocaleString();
                data.payoutNCOpp = nextStep.toLocaleString();
                data.prefixNCPay = prefixNCPayType;
                data.prefixNCOpp = prefixNCOppType;
                data.prefix = 'currency';
                data.suffix = 'percent';
            } else {
                data.payout2 = '-';
                data.payoutNCPay = step.toLocaleString();
                data.payoutNCOpp = nextStep.toLocaleString();
                data.prefixNCPay = prefixNCPayType;
                data.prefixNCOpp = prefixNCOppType;
                data.prefix = 'none';
                data.suffix = 'none';
            }
        
            if (data.achieved == 'N'){
                data.color = 'red';
            } else if(data.achieved == '-'){
                data.color = 'black';
            }else {
                data.color = 'blue';
            }
        });
    }

    getPayoutGBX(value) {
        value = Number(value);
        let data = [];
        if (value < 955) {
            data[0] = '-';
            // next step
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[1] = 0.65; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[1] = 0.60; }
            else { data[1] = 0.40; }
            data[2] = 'Step 1';
        } else if (value >= 955 && value <= 965) {
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[0] = 0.65; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[0] = 0.60; }
            else { data[0] = 0.40; }
            // next step
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[1] = 0.85; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[1] = 0.80; }
            else { data[1] = 0.50; }
            data[2] = 'Step 2';
        } else if (value >= 966 && value <= 976) {
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[0] = 0.85; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[0] = 0.80; }
            else { data[0] = 0.50; }
            // next step
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[1] = 1.05; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[1] = 1.00; }
            else { data[1] = 0.60; }
            data[2] = 'Step 3';
        } else if (value >= 977 && value <= 1000) {
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[0] = 1.05; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[0] = 1.00; }
            else { data[0] = 0.60; }
            // next step
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[1] = 1.05; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[1] = 1.00; }
            else { data[1] = 0.60; }
            data[2] = 'Step 3';
        } else {
            data[0] = 'error';
            data[1] = 'error';
        }
        return data;
    }

    getPayoutGSX(value) {
        value = Number(value);
        let data = [];
        if (value < 917) {
            data[0] = '-';
            // next step
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[1] = 0.65; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[1] = 0.60; }
            else { data[1] = 0.40; }
            data[2] = 'Step 1';
        } else if (value >= 917 && value <= 935) {
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[0] = 0.65; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[0] = 0.60; }
            else { data[0] = 0.40; }
            // next step
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[1] = 0.85; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[1] = 0.80; }
            else { data[1] = 0.50; }
            data[2] = 'Step 2';
        } else if (value >= 936 && value <= 965) {
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[0] = 0.85; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[0] = 0.80; }
            else { data[0] = 0.50; }
            // next step
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[1] = 1.05; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[1] = 1.00; }
            else { data[1] = 0.60; }
            data[2] = 'Step 3';
        } else if (value >= 966 && value <= 1000) {
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[0] = 1.05; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[0] = 1.00; }
            else { data[0] = 0.60; }
            // next step
            if (this.monthlyArrDataSet.fa_stat == 'COMPLETED') { data[1] = 1.05; }
            else if (this.monthlyArrDataSet.fa_stat == 'COMMENCED') { data[1] = 1.00; }
            else { data[1] = 0.60; }
            data[2] = 'Step 3';
        } else {
            data[0] = 'error';
            data[1] = 'error';
        }
        return data;
    }

    getQtr(value) {
        value = Number(value);
        let qtr = 0;
        if (value <= 0) { qtr = '-'; }
        else if (value > 0 && value < 60) { qtr = 60 - value; }
        else if (value >= 60 && value < 75) { qtr = 75 - value; }
        else if (value >= 75 && value < 100) { qtr = 100 - value; }
        else if (value >= 100 && value < 130) { qtr = 130 - value; }
        else if (value >= 130 && value < 170) { qtr = 170 - value; }
        else if (value >= 170 && value < 220) { qtr = 220 - value; }
        else if (value >= 220 && value < 280) { qtr = 280 - value; }
        else if (value >= 280 && value < 350) { qtr = 350 - value; }
        else if (value >= 350 && value < 450) { qtr = 450 - value; }
        else if (value >= 450 && value < 600) { qtr = 600 - value; }
        else if (value >= 600 && value < 750) { qtr = 750 - value; }
        else if (value >= 750) { qtr = 0; }
        else { qtr = 'error'; }
        return qtr;
    }

    getSales(type, value) {
        value = Number(value);
        let sales = 0;
        if (type == 'ae') {
            if (value <= 0) { sales = '-'; }
            else if (value > 0 && value < 60) { sales = 60000; }
            else if (value >= 60 && value < 75) { sales = 110000; }
            else if (value >= 75 && value < 100) { sales = 150000; }
            else if (value >= 100 && value < 130) { sales = 200000; }
            else if (value >= 130 && value < 170) { sales = 250000; }
            else if (value >= 170 && value < 220) { sales = 310000; }
            else if (value >= 220 && value < 280) { sales = 370000; }
            else if (value >= 280 && value < 350) { sales = 430000; }
            else if (value >= 350 && value < 450) { sales = 600000; }
            else if (value >= 450 && value < 600) { sales = 680000; }
            else if (value >= 600 && value < 750) { sales = 750000; }
            else if (value >= 750) { sales = 1000000; }
            else { sales = 'error'; }
        } else if (type == 'fe'){
            if (value <= 0) { sales = '-'; }
            else if (value > 0 && value < 60) { sales = 150000; }
            else if (value >= 60 && value < 75) { sales = 200000; }
            else if (value >= 75 && value < 100) { sales = 275000; }
            else if (value >= 100 && value < 130) { sales = 250000; }
            else if (value >= 130 && value < 170) { sales = 425000; }
            else if (value >= 170 && value < 220) { sales = 500000; }
            else if (value >= 220 && value < 280) { sales = 575000; }
            else if (value >= 280 && value < 350) { sales = 650000; }
            else if (value >= 350 && value < 450) { sales = 725000; }
            else if (value >= 450 && value < 600) { sales = 800000; }
            else if (value >= 600 && value < 750) { sales = 900000; }
            else if (value >= 750) { sales = 1500000; }
            else { sales = 'error'; }
        }
        return sales;
    }

    getPercent(jsonArr) {
        let payPercent = 0;
        jsonArr.forEach(function(data, idx){
            if(data.payout1 > 0) {
                payPercent += parseFloat(data.payout1);
            }
        });
        return payPercent;
    }

    getCurrency(jsonArr, totalSum) {
        let payCurrency = 0;
        jsonArr.forEach(function(data, idx){
            if(data.payout1 > 0) {
                payCurrency += data.payout1 * parseFloat(totalSum) / 100;
            }
        });
        return payCurrency;
    }

    connectedCallback(){
        // text-align center style
        const inputAlignCenter = document.createElement('style');
        inputAlignCenter.innerText = '.slds-align_absolute-center input{ text-align: center!important; width: 80px !important;padding:0px !important;background-color:lightyellow !important;border-color:rgb(201, 201, 201) !important; }'
                                    +'.slds-align_absolute-center div{ justify-content: center !important; }'
                                    +'.slds-align_absolute-center label{ padding:0px;margin:0px !important; } .slds-card__header, .slds-card__body{ margin: 0px !important; }';

        if(this.guBun == 'Monthly'){
            inputAlignCenter.innerText += '.card-estimator {height: 550px;}';
        } else {
            inputAlignCenter.innerText += '.card-estimator {height: 470px;}';
        }

        document.body.appendChild(inputAlignCenter);

        if(this.guBun == 'Monthly'){
            console.log('this.payoutDataSet : '+this.payoutDataSet);
            if(this.payoutDataSet != 'null' & this.payoutDataSet != null) {
                console.log('if');
                let tempDataSetArr = this.payoutDataSet.substr(1, this.payoutDataSet.length-2).split(',');
                let tempDataSetMap = {
                    total_achievement : tempDataSetArr[0],
                    sedan_achievement : tempDataSetArr[1],
                    gbx_pf : tempDataSetArr[2],
                    gbx_cnt_pf : tempDataSetArr[3],
                    gbx_bonus : tempDataSetArr[4],
                    gsx_pf : tempDataSetArr[5],
                    gsx_cnt_pf : tempDataSetArr[6],
                    gsx_bonus : tempDataSetArr[7],
                    fa_stat_pf : tempDataSetArr[8],
                    fa_type_pf : tempDataSetArr[9],
                    fa_bonus : tempDataSetArr[10],
                    fa_type : tempDataSetArr[11] != undefined ? tempDataSetArr[11].replace('\"', '').split(' ')[0] : '',
                    fa_stat : tempDataSetArr[12] != undefined ? tempDataSetArr[12].replaceAll('\"', '') : '',
                    dealer_cd : tempDataSetArr[13] != undefined ? tempDataSetArr[13].replace(/[^A-Za-z0-9]/gi, '') : '',
                    gbx : tempDataSetArr[14],
                    gsx : tempDataSetArr[15],
                    gbx_retailer_status : tempDataSetArr[16] != undefined ? tempDataSetArr[16].replaceAll('\"', '') : '',
                    gsx_retailer_status : tempDataSetArr[17] != undefined ? tempDataSetArr[17].replaceAll('\"', '') : ''
                };
                this.monthlyArrDataSet = tempDataSetMap;
            } else {
                console.log('else');
                let tempDataSetMap = {
                    total_achievement : 0,
                    sedan_achievement : 0,
                    gbx_pf : 0,
                    gbx_cnt_pf : 0,
                    gbx_bonus : 0,
                    gsx_pf : 0,
                    gsx_cnt_pf : 0,
                    gsx_bonus : 0,
                    fa_stat_pf : 0,
                    fa_type_pf :0,
                    fa_bonus : 0,
                    fa_type : '',
                    fa_stat : ''
                };
                this.monthlyArrDataSet = tempDataSetMap;
            }
        } else {
            if(this.payoutDataSet.includes('ADAPTIVE')) {
                this.quarterlyOppPayout = 2.50;
            } else if(this.payoutDataSet.includes('FULL')) {
                this.quarterlyOppPayout = 4.50;
            } else {
                this.quarterlyOppPayout = 0.00;
            }
        }
    }
}