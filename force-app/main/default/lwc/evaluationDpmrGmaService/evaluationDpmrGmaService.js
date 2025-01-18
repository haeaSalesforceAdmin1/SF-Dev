import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation'; 
import saveEvaluation from '@salesforce/apex/EvaluationDpmrController.saveEvaluation';
import getContactOptions from '@salesforce/apex/EvaluationDpmrController.getContactOptions';
import getSecondaryContactOptions from '@salesforce/apex/EvaluationDpmrController.getSecondaryContactOptions';
import uploadFile from '@salesforce/apex/EvaluationDpmrController.uploadFile';
import getAccountName from '@salesforce/apex/EvaluationDpmrController.getAccountName';
import getRecordType from '@salesforce/apex/EvaluationDpmrController.getRecordType';
import createEvalName from '@salesforce/apex/EvaluationDpmrController.createEvalName';

// custom label
import dpmrFileUploadErrorMsg from '@salesforce/label/c.dpmrFileUploadErrorMsg';

const MAX_FILE_SIZE = 3072000;

export default class EvaluationDpmrGmaService extends NavigationMixin(LightningElement) {
    @track selectedTopics = [];
    @track primaryContactName = '';
    @track evaluationName = '';
    @track primaryContactRole = '';
    @track selectedContactType = '';
    @track contactDate = '';
    @track evalStatus = 'Open';
    @track primaryContactId = '';
    @track comment = '';
    @track fileList = [];
    @track reqFileList = [];
    @track accountName = '';
    @api recordId;
    @track recordTypeName = 'DPMR_After_Sales_Dealer_Performance_Management_Report_Internal_Confidentia';
    @track recordTypeId;
    @track contactOptions = [];
    @track isOtherContactSelected = false;
    @track isNext = false;
    @track isLoading = false; 
    //Added by JongHoon Kim DPM-5904 12.04.2024
    @track secondaryContactName = '';
    @track secondaryContactRole = '';
    @track secondaryContactId = 'N/A';
    @track secondaryContactOptions = [];
    @track isOtherSecondContactSelected = false;

    // Added by JongHoon Kim 01.07.2025
    @track errorMessage = '';


    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg'];


    contactTypeOptions = [
        { label: 'On-site', value: 'On-site' },
        { label: 'Off-site', value: 'Off-site' },
        { label: 'Virtual', value: 'Virtual' },
        { label: 'Phone', value: 'Phone' }
    ];
    

    topicOptions = [
        // { label: 'Accessory Sales', value: 'Accessory Sales'},
        { label: 'Campaign Completion', value: 'Campaign Completion' },
        { label: 'Customer Experience', value: 'Customer Experience' },
        { label: 'CVP/Valet', value: 'CVP/Valet' },
        { label: 'Facility Inspection', value: 'Facility Inspection' },
        { label: 'Financial Performance', value: 'Financial Performance' },
        { label: 'Keystone Program', value: 'Keystone Program' },
        { label: 'Marketing', value: 'Marketing' },
        { label: 'Parts & Accessory Sales', value: 'Parts & Accessory Sales' },
        { label: 'Service Capacity', value: 'Service Capacity' },
        { label: 'Service Retention', value: 'Service Retention' },
        { label: 'Training', value: 'Training' },
        { label: 'WOPR', value: 'WOPR' },
        { label: 'Other (add comments)', value: 'Other (add comments)' }
    ];

    statusOptions = [
        { label: 'Open', value: 'Open' },
        { label: 'Submitted', value: 'Submitted' }
    ];

    connectedCallback() {
        this.isLoading = true;
        setTimeout(() => {
            if (this.recordId) {
                this.isLoading = false;
                console.log("connectedCallback recordId", this.recordId);
                this.loadContacts();
                this.getAccName();
                this.getRTId();
            } else {
                console.log("connectedCallback False");
                this.isLoading = false;
            }
        }, 5)
        
    }

    loadContacts() {
        getContactOptions({ accountId: this.recordId })
            .then(result => {
                this.contactOptions = result;
            })
            .catch(error => {
                console.error('Error loading contacts', error);
                this.showToast('Error', 'Error loading contacts', 'error');
            });

        
    }

    getAccName() {
        getAccountName({ accountId: this.recordId })
            .then(result => {
                this.accountName = result;
            })
            .catch(error => {
                console.error('Error getAccountName', error);
                // this.showToast('Error', 'Error loading contacts', 'error');
            });
    }

    getRTId() {
        getRecordType({ recordTypeName: this.recordTypeName })
            .then(result => {
                this.recordTypeId = result;
            })
            .catch(error => {
                console.error('Error getRecordType', error);
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleTopicChange(event) {
        this.selectedTopics = event.detail.value;

        if(this.contactDate) {
            createEvalName({ recordId: this.recordId, contactDate: this.contactDate, division: 'Service' , topic: this.selectedTopics.join(';')})
            .then(result => {
                console.log('handleTopicChange createEvalName');
                this.evaluationName = result;
                console.log('this.evaluationName', this.evaluationName);
            })
            .catch(error => {
                console.error('Error getAccountName', error);
            });
        }
    }

    handleEvalNameChange(event) {
        this.evaluationName = event.detail.value;
    }

    get isSecondaryContactDisabled() {
        return !this.primaryContactId;
    }

    handleStatusChange(event) {
        this.evalStatus = event.detail.value;
    }

    //Added to add 'N/A' to secondary contact options by Jonghoon Kim DPM-5904 12.04.2024
    handlePrimaryContactChange(event) {
        this.primaryContactId = event.detail.value;

        getSecondaryContactOptions({ accountId: this.recordId, primaryContactId: this.primaryContactId })
        .then(result => {
            const optionsWithNA = [{ label: 'N/A', value: 'N/A' }, ...result];
            this.secondaryContactOptions = optionsWithNA;
        })
        .catch(error => {
            console.error('Error loading contacts', error);
            this.showToast('Error', 'Error loading contacts', 'error');
        });

        if(this.primaryContactId === this.secondaryContactId && !(this.primaryContactId === 'OtherContact')) {
            this.secondaryContactId = 'N/A';
        }

        this.isOtherContactSelected = this.primaryContactId === 'OtherContact';
    }

    //Added by Jonghoon DPM-5904 12.04.2024
    handleSecondContactChange(event) {
        this.secondaryContactId = event.detail.value;
        this.isOtherSecondContactSelected = this.secondaryContactId === 'OtherContact';
    }

    handleContactNameChange(event) {
        this.primaryContactName = event.target.value;
    }

    //Added by Jonghoon DPM-5904 12.04.2024
    handleSecondContactNameChange(event) {
        this.secondaryContactName = event.target.value;
    }

    handleContactRoleChange(event) {
        this.primaryContactRole = event.target.value;
    }

    //Added to handle secondary contact's role by Jonghoon DPM-5904 12.04.2024
    handleSecondContactRoleChange(event) {
        this.secondaryContactRole = event.target.value;
    }

    handleContactTypeChange(event) {
        this.selectedContactType = event.detail.value;
    }

    handleContactDateChange(event) {
        this.contactDate = event.target.value;

        createEvalName({ recordId: this.recordId, contactDate: this.contactDate, division: 'Service' , topic: this.selectedTopics.join(';') })
            .then(result => {
                console.log('handleContactDateChange');
                this.evaluationName = result;
                console.log('this.evaluationName', this.evaluationName);
            })
            .catch(error => {
                console.error('Error getAccountName', error);
                // this.showToast('Error', 'Error loading contacts', 'error');
            });

    }

    handleCommentChange(event) {
        this.comment = event.target.value;
    }

    handleFileTestUpload(event) {
        const files = event.target.files;
        if (files && files.length > 0) {
            Array.from(files).forEach(file => {
                this.imgFile.push({
                    name: file.name
                });
            });
        }
    }

    // DPM-5986 JongHoon Add file Size Validation - 01.07.25 
    handleFileUpload(event) {
        const files = event.target.files;
        if (files && files.length > 0) {
            Array.from(files).forEach(file => {
                if (file.size > MAX_FILE_SIZE) {
                    this.showToast(`The file ${file.name} exceeds the maximum size of 3MB.`);
                    this.errorMessage = dpmrFileUploadErrorMsg;
                    return;
                }
                this.errorMessage = '';
                const reader = new FileReader();
                reader.onloadend = () => {
                    const base64Data = reader.result.split(',')[1];
                    this.fileList.push({
                        name: file.name,
                        contentType: file.type,
                        base64Data: base64Data
                    });
                };
                reader.readAsDataURL(file);
            });
        }
    }

    handleFileReqUpload(event) {
        const reqFiles = event.target.files;
        if (reqFiles && reqFiles.length > 0) {
            Array.from(reqFiles).forEach(reqFiles => {
                const reader = new FileReader();
                reader.onloadend = () => {
                    const base64Data = reader.result.split(',')[1];
                    this.reqFileList.push({
                        name: reqFiles.name,
                        contentType: reqFiles.type,
                        base64Data: base64Data
                    });

                    this.fileList.push({
                        name: reqFiles.name,
                        contentType: reqFiles.type,
                        base64Data: base64Data
                    });
                };
                reader.readAsDataURL(reqFiles);
            });
        }
    }

    handleSave() {
        this.isLoading = true;
        if (this.validateFields()) {
             if (this.isValidDate(this.contactDate)) {

            const params = {
                selectedTopics: this.selectedTopics.join(';'),
                accountId: this.recordId,
                recordTypeId: this.recordTypeId,
                evalStatus: this.evalStatus,
                evaluationName: this.evaluationName,
                division: 'Service',
                primaryContactId: this.primaryContactId,
                primaryContactName: this.primaryContactName,
                primaryContactRole: this.primaryContactRole,
                selectedContactType: this.selectedContactType,
                secondaryContactId: this.secondaryContactId, // DPM-5904 added by Jonghoon Kim 12.04.2024
                secondaryContactName: this.secondaryContactName, // DPM-5904 added by Jonghoon Kim 12.04.2024
                secondaryContactRole: this.secondaryContactRole, // DPM-5904 added by Jonghoon Kim 12.04.2024
                contactDate: this.contactDate,
                comment: this.comment
            };
    
            saveEvaluation({ params })
                .then(result => {
                    const evaluationId = result;
                    console.log('Evaluation saved with ID: ', evaluationId);
    
                    if (this.fileList.length > 0) {
                        this.uploadFilesSequentially(evaluationId, this.fileList)
                            .then(() => {
                                this.showToast('Success', 'Files uploaded successfully', 'success');
                                this.navigateToRecordPage(evaluationId);
                                 setTimeout(() => {
                                        window.location.reload();
                                    }, 300); 
                            })
                            .catch(error => {
                                console.error('Error uploading files', error);
                                this.showToast('Error', 'Error uploading files', 'error');
                            })
                            .finally(() => {
                                this.isLoading = false;
                            });
                    } else {
                        this.showToast('Success', 'Evaluation record saved successfully', 'success');
                        this.navigateToRecordPage(evaluationId);
                         setTimeout(() => {
                                window.location.reload();
                            }, 300); 
                        this.isLoading = false;
                    }
                })
                .catch(error => {
                    console.error('Error saving evaluation record', error);
                    this.showToast('Error', 'Error saving evaluation record', 'error');
                    this.isLoading = false;
                });
            } else {
                this.showToast('Error', 'Selected date is not valid. Please select a valid date.', 'error');
                this.isLoading = false;
            }
        } else {
            this.showToast('Error', 'Please fill in all required fields.', 'error');
            this.isLoading = false;
        }
       
    }
    
    uploadFilesSequentially(recordId, files) {
        let uploadPromise = Promise.resolve(); 
    
        files.forEach(file => {
            uploadPromise = uploadPromise.then(() => {
                return uploadFile({
                    recordId: recordId,
                    fileName: file.name,
                    base64Data: file.base64Data,
                    contentType: file.contentType
                });
            });
        });
    
        return uploadPromise; 
    }

    handlePrevious() {
        const previousEvent = new CustomEvent('changeflag', {
            detail: {
                nextStep_GMAService: false,
                showRecordTypeSelection: true
            }
        });
        this.dispatchEvent(previousEvent);
    }

    handleReturn() {
        this.isNext = false;
    }

    handleCRMA(event) {
        event.preventDefault();
        // Account Link
        // console.log("navigateToRecordPageInNewTab", this.recordId);
        const baseUrl = '/lightning/r/'; 
        const recordUrl = `${baseUrl}Account/${this.recordId}/view`;

        
        window.open(recordUrl, '_blank');
        
    }

    handleFileDelete(event) {
        const fileNameToDelete = event.target.dataset.id;
        console.log("handleFileDelete.fileNameToDelete => ",fileNameToDelete);
        this.fileList = this.fileList.filter(file => file.name !== fileNameToDelete);
    }

    validateFields() {
       
        return this.evaluationName && ( this.selectedTopics.length > 0) &&
               this.primaryContactId && 
               (!this.isOtherContactSelected || (this.primaryContactName && this.primaryContactRole)) &&
               (!this.isOtherSecondContactSelected || (this.secondaryContactName && this.secondaryContactRole)) && // DPM-5904 Add Secondary Field
               this.selectedContactType && this.contactDate;
    }

    isValidDate(date) {
        if (!date) return false;

        const selectedDate = new Date(date);
        const today = new Date();
        const day = today.getDate();
        const month = today.getMonth();
        const year = today.getFullYear();
        const currentDate = new Date(year, month, day);

        const fifteenthDay = new Date(year, month, 15);
        const previousMonthEnd = new Date(year, month, 0); // Last day of the previous month
        const previousMonthStart = new Date(year, month - 1, 0);

        if (currentDate > fifteenthDay) {
            // If today is after the 15th, last month's dates should not be allowed
            if (selectedDate < previousMonthEnd ) {
                return false;
            }
        } else {
            // If today is on or before the 15th
            if (selectedDate < previousMonthStart || selectedDate > currentDate) {
                return false;
            }
        }

        return true;
    }

    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            },
            state: {
                filterName: '__Recent'
            }
        });
    }
}