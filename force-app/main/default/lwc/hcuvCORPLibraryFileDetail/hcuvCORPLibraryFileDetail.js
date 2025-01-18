import { LightningElement, api, track, wire } from 'lwc';
import getResultForCUVCORPLib  from '@salesforce/apex/HCUV_FileUtility.getResultForCUVCORPLib';
export default class HcuvCORPLibraryFileDetail extends LightningElement {



    @api isComponentOpen = false;
    @api isEditFormOpen = false;

    @api isVisible_mngr = false; 
    @api isVisible_viewer = false; 

    @api isPrepublished = false;
    @api isMain = false;
    @api isDeleted = false;

    @api isEditButtonVisible = false;

    @api cuvFilePhase; 



    @track
    inputVariables = [] ;

    @api isLoading = false; // 처음부터 false 이면 안됨.
    @api recordId;
    @api objectApiName;

    cvRecordId;


    connectedCallback(){
        console.log("START - connectedCallback ");
        console.log( "recordId" );
        console.log( this.recordId );
        console.log( "objectApiName" );
        console.log( this.objectApiName );
        console.log("// END - connectedCallback ");


    }


    @wire(getResultForCUVCORPLib, { currentContDocumentId: '$recordId'})
    wiredRecord({error, data}) {
        if(error) {
            if (Array.isArray(error.body)) {
                console.log('error = ' + error.body.map(e => e.message).join(', '));
            } else if (typeof error.body.message === 'string') {
                console.log('error = ' + error.body.message);
            }
        } else if (data) {

            console.log("data");
            console.log(data);

            console.log("data.state");
            console.log(data.state);
            console.log(data.isVisible_mngr);
            console.log(data.isVisible_viewer);
            console.log(data.visibilityType);
            console.log(data.userType);




            if( data.visibilityType === "pre" ){
                this.isPrepublished = true;
            }else if( data.visibilityType === "main" ){
                this.isMain = true; 
            }else if( data.visibilityType === "deleted" ){
                this.isDeleted = true; 
            }
            this.isVisible_mngr = data.isVisible_mngr;
            this.isVisible_viewer = data.isVisible_viewer && this.isMain;

            if(this.isVisible_mngr && (['pre','main'].indexOf(data.visibilityType) > -1 ) ){
                this.isEditButtonVisible = true;
            }


            if( 'cvRecordId' in data){
                this.cvRecordId = data.cvRecordId;
                this.inputVariables = [
                    {
                        name: "cvRecordId",
                        type: "String",
                        value: data.cvRecordId,
                    },
                    {
                        name: "visibilityType",
                        type: "String",
                        value: data.visibilityType,
                    }                      
                ]
            }else{
                return;
            }


            this.isComponentOpen = this.isVisible_mngr || this.isVisible_viewer;
        }
    }



    openEditForm() {
        console.log("START - openEditForm ");
        this.isEditFormOpen = true; 


    }


    closeEditForm() {
        console.log("START - closeEditForm ");
        this.isEditFormOpen = false; 


    }


    handleSaveClick(){
        console.log("handleSaveClick");

        setTimeout(() => {this.isEditFormOpen = false;} , 2800);

        
        console.log("handleSaveClick-END");
    }


    handleFlowStatusChange(event) {
        // When Flow finished without exception 
        if(event.detail.status === 'FINISHED') {
            // isLoading = true; 
            this.isLoading = true;             
            setTimeout(() => {this.isLoading = true; } , 100); // 이거도 타임아웃 써서 해줘야??  
            setTimeout(() => { this.isEditFormOpen = false; window.location.reload();} , 100); // lightning output form display right after loading ended

            setTimeout(() => { this.isLoading = false; } , 100);
            // isLoading = false;
            // Redirect to another page in Salesforce., or
            // Redirect to a page outside of Salesforce., or
            // Show a toast, or something else
        }
    }










}