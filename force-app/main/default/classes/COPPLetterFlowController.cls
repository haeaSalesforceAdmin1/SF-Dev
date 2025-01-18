/**
     * [Class Description] COPP Project - Controller for letter template pdf
     * Created by [MinheeKim] on [2024-08-19] for [DPM-5701]
     * Edited by [MinheeKim] on [2024-10-16] for [DPM-5861] added salutation
    */
public with sharing class COPPLetterFlowController {

    public String LetterDate {get; set;}
    public String regionName {get; set;}
    public String regionCode {get; set;}
    public String DealerPrincipalName {get; set;}
    public String DealershipName {get; set;}
    public String DealerShip_Address {get; set;}
    public String City_State_Zip_Code {get; set;} 
    public String Email_Address {get; set;}
    public String ChoosedTemplate {get; set;}
    public String BrandCode {get; set;}
    public String Salutation {get; set;}
    public String today {get; set;}
    
    public COPPLetterFlowController() {
        LetterDate = ApexPages.currentPage().getParameters().get('LetterDate');
        regionName = ApexPages.currentPage().getParameters().get('regionName');
        regionCode = ApexPages.currentPage().getParameters().get('regionCode');
        DealerPrincipalName = ApexPages.currentPage().getParameters().get('DealerPrincipalName');
        DealershipName = ApexPages.currentPage().getParameters().get('DealershipName');
        DealerShip_Address = ApexPages.currentPage().getParameters().get('DealerShip_Address');
        City_State_Zip_Code = ApexPages.currentPage().getParameters().get('City_State_Zip_Code');
        Email_Address = ApexPages.currentPage().getParameters().get('Email_Address');
        ChoosedTemplate = ApexPages.currentPage().getParameters().get('ChoosedTemplate');
        Salutation = ApexPages.currentPage().getParameters().get('Salutation'); //DPM-5861 added salutation 10-16-2024 by MinheeKim
        today = String.format('{0}-{1}-{2}', 
        new List<String>{
            String.valueOf(Date.today().month()).leftPad(2, '0'), 
            String.valueOf(Date.today().day()).leftPad(2, '0'),   
            String.valueOf(Date.today().year())                  
        });

        if(ChoosedTemplate.contains('Hyundai')){
            BrandCode = 'H';
        }else if (ChoosedTemplate.contains('Genesis')){
            BrandCode = 'G';
        }
    }

}