import { LightningElement,api,wire } from 'lwc';
import getRelatedContacts from '@salesforce/apex/ContactController.getRelatedContacts';


const COLS = [
    {
        label: 'Contact Name',
        fieldName: 'ContactName'
    },
    {
        label: 'Account Name',
        fieldName: 'AccountName',
        //type: 'url',
        //typeAttributes: {label: {fieldName: "AccountName"},target: '_blank'}
    },
    {
        label: 'Role',
        fieldName: 'Role'
    },
    {
        label: 'JobCode',
        fieldName: 'JobCode'
    },
    {
        label: 'Direct',
        fieldName: 'Direct',
        type: 'boolean'
    },
    {
        label: 'Active',
        fieldName: 'IsActive',
        type: 'boolean'
    },
   /* {
        label: 'Account Name',
        fieldName: 'recordlink',
        type:'url',
        typeAttributes: {label: {fieldName: "AccountName"}, tooltip: "Name", target: "_blank", linkify: true}
    },*/
    {
        label: 'Email',
        fieldName: 'Email',
        type: 'email',
    }
];

export default class AccountContactRelatedList extends LightningElement {
    @api recordId;  
    //relatedContacts;
    //error;
    columns = COLS;

    
    @wire(getRelatedContacts,{accId : '$recordId'})
    AccountContactRelation;
}