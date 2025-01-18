import { LightningElement, track, api } from 'lwc';
import Get_KASO_VINInfo from '@salesforce/apex/Get_KASO_VINInfo_API.Get_KASO_VINInfo';

export default class Kaso_VIN_search extends LightningElement {

    @track outputText;
    @track buttonTrue=false;
    @api checkedVinNumber;
    @api checkedVinId;
    @api vaildationCheck;
    @api inputVinNumber;
    @api inputVinId;
    dataStatus;
   


    @api
    handleSubmit(event){
        event.preventDefault();
        const vinNumber = this.template.querySelector('input').value;
        const vinDataMap  = new Map();
        this.buttonTrue=true;
        Get_KASO_VINInfo({vinNumber : vinNumber}).then((res) => {
            this.buttonTrue=true;
            console.log('success');
            console.log(res);
            vinDataMap.set('Id', res['Id']);
            vinDataMap.set('Name', res['Name']);

            if(vinDataMap.get('Name') == vinNumber){
                this.checkedVinNumber = vinDataMap.get('Name');
                this.checkedVinId = vinDataMap.get('Id');
                this.dataStatus = true;
                this.outputText = 'VIN 정상 조회 되었습니다.';
                this.buttonTrue=false;
                this.vaildationCheck = true;
            }else{
                this.checkedVinNumber = '허용되지 않는 값입니다.';
                this.dataStatus = false;

                this.outputText = 'VIN을 찾을 수 없습니다. ※필수 정상 조회 후 진행 가능. 다음으로 넘어가지 마세요.';
                this.buttonTrue=false;
                this.vaildationCheck = false;
            }
        })
        .catch((error) => {
            this.error = error;
            console.log(error);
            console.log('fail');
            this.vaildationCheck = false;
        })
    }
}