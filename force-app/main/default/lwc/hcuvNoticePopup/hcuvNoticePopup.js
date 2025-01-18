import { LightningElement, api, track, wire } from 'lwc';
import retrieveNoticeDetail from '@salesforce/apex/NoticeController.retrieveNoticeDetail';
import getCurrentAppLightningPage from '@salesforce/apex/NoticeController.getCurrentAppLightningPage';
import { CurrentPageReference } from 'lightning/navigation';
import formFactor from '@salesforce/client/formFactor';
// import siteId from "@salesforce/site/Id";
// import networkId from '@salesforce/community/Id';
// import basepathname from "@salesforce/community/basePath";
// import sitePath from "@salesforce/community/basePath";
export default class HcuvNoticePopup extends LightningElement {

    isModalOpen = false;
    title = ''
    content = ''
    
    // USING BUILT-IN APIS FROM SALESFORCE
    @wire(CurrentPageReference)
    currentPageReference;
    formFactor = formFactor;
    // siteId = siteId;
    // basepathname = basepathname;
    // sitePath = sitePath;
    // //if community, there is networkid
    //networkId = networkId;
    //if lightning app , it is retrieved from apex 
    appName = null;
    targetUser = 'INTERNAL USER';



    connectedCallback(){
        //#1 check current url and get apptype. 
        console.log('starting Conn Callback');
        console.log(this.currentPageReference);
        console.log('comm 여부로 판단 ok?',this.currentPageReference.type);
        console.log(this.currentPageReference.hasOwnProperty('type'));
        console.log('-===================')
        var currentPath = window.location.pathname;
        var currentLocHref = window.location.href;
        var currentLocHostName = window.location.hostname;
        var isInExperience = currentPath.includes('/hyundaidealer/s/') || currentPath.includes('/genesisdealer/s/')
                                || currentPath.includes('/hyundaiCUV/s/') || currentPath.includes('/genesisCPO/s/');
        console.log(currentPath);
        console.log(currentLocHref);
        console.log(currentLocHostName);
        console.log(isInExperience);

        //console.log(this.networkId); // 0DB6g000000CeM2
        // console.log(this.basepathname);
        // console.log(this.sitePath);
        // console.log(this.siteId);

        console.log(this.formFactor);

        try{
            
            
            getCurrentAppLightningPage({}).then(
                res=>{                     
                    console.log("====getCurrentAppLightningPage=====");
                    console.log(res);
                    this.appName =res;
                    
                    if(isInExperience && currentPath.includes('dealer/s/') ){
                        this.appName =  'DPM'; 
                        this.targetUser = 'EXTERNAL USER';
                    }else if(isInExperience && (currentPath.includes('/hyundaiCUV/s/') || currentPath.includes('/genesisCPO/s/'))){
                        this.appName =  'CUV';
                        this.targetUser = 'EXTERNAL USER';
                    }
                    console.log("appName is now.. ")
                    console.log(this.appName);
                    console.log(this.targetUser);
                    retrieveNoticeDetail({appLabel : this.appName, targetUser : this.targetUser}).then(detailRes =>{
                        // console.log("=======APEX RESULT IS ===============");
                        // console.log("======= appLabel IS ===============", this.appName, this.targetUser);
                        //변수 넣을 때 이거 확인 - actionPlanId: this.actionPlanId,
                        if(detailRes){
                            this.isModalOpen = true;
                            console.log(detailRes);console.log(detailRes.title);console.log(detailRes.content);
                            this.title= detailRes.title;
                            this.content = detailRes.content;
                        }else{
                            console.log('nothing returned1');
                        }
                    })

                })
        }catch(e){
            console.log('error');
            console.log(e);
        }
        
    }

    closeModal() {
        this.isModalOpen = false;
    }




}