import { LightningElement, api } from 'lwc';

export default class CoppLetterContainer extends LightningElement {
    @api LetterDate; 
    @api regionName;
    @api DealerPrincipalName;
    @api DealershipName;
    @api DealerShip_Address;
    @api City_State_Zip_Code;
    @api Email_Address;
    @api ChoosedTemplate;
    @api regionCode;
    @api Salutation;



    get vfPageUrl() {
        return `/apex/COPPLetter?LetterDate=${this.LetterDate}`+`&regionName=${this.regionName}`
        +`&DealershipName=${this.DealershipName}`+`&DealerShip_Address=${this.DealerShip_Address}`
        +`&City_State_Zip_Code=${this.City_State_Zip_Code}`+`&Email_Address=${this.Email_Address}`
        +`&DealerPrincipalName=${this.DealerPrincipalName}`+`&ChoosedTemplate=${this.ChoosedTemplate}`
        +`&regionCode=${this.regionCode}` 
        +`&Salutation=${this.Salutation}`; //DPM-5861 added salutation 10-16-2024 by MinheeKim
        
    }
}