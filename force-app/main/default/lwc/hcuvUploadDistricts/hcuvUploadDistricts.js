import { LightningElement, api, track } from 'lwc';

import updateDistricts from '@salesforce/apex/HCUV_UploadDistrictsCtrl.updateDistricts';

export default class HcuvUploadDistricts extends LightningElement {

    @api recordId;
    @api objectApiName;
    showSpinner = false;
    showFileUpload = true;
    @track acceptedFormats = ['.csv'];
    data = [];
    recordsProcessed = 0;
    error = '';
    
    get message() {
        return 'Processed ' + this.recordsProcessed + ' out of ' + (this.data.length) + ' records.';
    }

    createRecords() {
        console.log('inside createRecords');
        this.showSpinner = true;
        console.log('this.data = ' + JSON.stringify(this.data));
        console.log('this.data.length = ' + this.data.length);

        let eligibleData = [];

        this.data.forEach(item => {
            if (item['Market Code'] && item['Market Code'] != '') {
                eligibleData.push(item);
            }
        });

        console.log('eligibleData = ' + JSON.stringify(eligibleData));
        console.log('eligibleData.length = ' + eligibleData.length);

        // call updateDistricts
        updateDistricts({ recordId: this.recordId, objectApi: this.objectApiName, data: eligibleData })
            .then(result => {
                //console.log('result = ' + JSON.stringify(result));
                console.log('result = ' + result);
                this.recordsProcessed = result;

                this.showFileUpload = false;

                setTimeout(() => {
                    eval("$A.get('e.force:refreshView').fire();");
                }, 500); 
            
                /*if (result)
                    window.open(result);
                else {
                    const event = new ShowToastEvent({
                        title: '',
                        message: 'Error while processing the request.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }*/

                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('error in updateDistricts = ' + JSON.stringify(error));

                this.error = 'File failed to upload. Please check the format and try again.';
            });
    }

    handleUploadFinished(event) {
        const files = event.detail.files;
        //console.log('files = ' + JSON.stringify(files));
        //console.log('files.length = ' + files.length);
        //console.log('files.type = ' + files[0].type);
        this.error = '';
        
        if (files.length > 0 && files[0].type.includes('text/csv')) {
            const file = files[0];

            // start reading the uploaded csv file
            this.read(file);
        } else {
            console.log('File failed to upload. Please check the format and try again.');
            this.error = 'File failed to upload. Please check the format and try again.';
        }
    }

    async read(file) {
        //console.log('file = ' + JSON.stringify(file));

        try {
            const result = await this.load(file);
            //console.log('result = ' + JSON.stringify(result));

            // execute the logic for parsing the uploaded csv file
            this.parse(result);

            if(!this.error)
                this.createRecords();

        } catch (e) {
            this.error = e;
            console.log('this.error = ' + JSON.stringify(this.error));
        }
    }

    async load(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            reader.onload = () => {
                resolve(reader.result);
            };
            reader.onerror = () => {
                reject(reader.error);
            };
            reader.readAsText(file);
        });
    }

    parse(csv) {
        // parse the csv file and treat each line as one item of an array
        const lines = csv.split(/\r\n|\n/);

        // parse the first line containing the csv column headers
        const headers = lines[0].split(',');
        //console.log('headers = ' + headers);

        this.error = '';
        
        if(!headers || !headers.includes('Market Code'))
            this.error = 'File failed to upload. Please check the format and try again.';

        // iterate through csv headers and transform them to column format supported by the datatable
        this.columns = headers.map((header) => {
            return { label: header, fieldName: header };
        });

        const data = [];

        // iterate through csv file rows and transform them to format supported by the datatable
        lines.forEach((line, i) => {
            if (i === 0) return;

            const obj = {};
            const currentline = line.split(',');

            for (let j = 0; j < headers.length; j++) {
                obj[headers[j]] = currentline[j];
            }

            data.push(obj);
        });

        // assign the converted csv data for the lightning datatable
        this.data = data;
    }
}