/**
* @description : To display the copp files 
* @author MinheeKim : minheekim@haeaus.com | 10-29-2024
* @ticket no: DPM-5893
 */

import {api, LightningElement, track, wire} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import getCOPPInfos from '@salesforce/apex/COPPFileComponentController.getCOPPInfos';
import {loadStyle} from 'lightning/platformResourceLoader'



export default class CoppFileComponent extends NavigationMixin(LightningElement) {

    activeSections = ['COPPFiles'];
    activeSectionsMessage = '';
    columns = [

        {
            label: 'Dealer Code', fieldName: 'coppInfoUrl', type: 'url', wrapText: true, sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'DealerCode'
                },
                target: '_self'
            }
        },       
        {
            label: 'Attached Files', fieldName: 'strAttachmentCountDisplay', type: 'text', clipText: true,
            cellAttributes: {
                iconName: { fieldName: 'attachmentIcon' },
                iconPosition: 'left',
                iconAlternativeText: 'attachment',
                class: 'icon-padding'
            }
        }
        // ,
        // {label: 'Last Modified Date', fieldName: 'LastmodifiedDate', type: 'text', wrapText: true, sortable: true}
    ];

    @api recordId;

    @track coppInfos = [];


    connectedCallback() {
        this._initDataset();
        
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }



    _initDataset() {
        //Fetch the coppInfo information
        getCOPPInfos({accountId: this.recordId})
            .then(result => {
                console.log('result:: ' + (result));
                let baseUrl = 'https://' + location.host + '/';
                let data = JSON.parse(result);
                data.forEach(coppInfo => {
                    coppInfo.coppInfoUrl = baseUrl + coppInfo.Id;
                    if (coppInfo.strAttachmentCountDisplay) {
                        coppInfo.attachmentIcon = 'utility:attach';
                    }

                    // coppInfo.LastmodifiedDate = this.formatTimestamp(coppInfo.LastmodifiedDate);
                    

                });

                this.coppInfos = data;
            }).catch(error => {
            console.error(error);

        });
    }


    // formatTimestamp(dateString) {
    //     const date = new Date(dateString);
    //     const month = (date.getMonth() + 1).toString().padStart(2, '0');
    //     const day = date.getDate().toString().padStart(2, '0');
    //     const year = date.getFullYear();
    
    //     let hours = date.getHours();
    //     const minutes = date.getMinutes().toString().padStart(2, '0');
    //     const ampm = hours >= 12 ? 'PM' : 'AM';
    //     hours = hours % 12 || 12; 
    
    //     return `${month}/${day}/${year}, ${hours}:${minutes} ${ampm}`;
    // }

    
}