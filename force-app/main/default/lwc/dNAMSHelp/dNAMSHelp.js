import { LightningElement, api } from 'lwc';
import getIntHMAPermissionLinks from '@salesforce/apex/DNAMSHelpController.getIntHMAPermissionLinks';
import getIntHMAGuidesPermissionLinks from '@salesforce/apex/DNAMSHelpController.getIntHMAGuidesPermissionLinks';//DNA-993
import getIntGMAGuidesPermissionLinks from '@salesforce/apex/DNAMSHelpController.getIntGMAGuidesPermissionLinks';//DNA-993
import getIntHMAGuideLinks from '@salesforce/apex/DNAMSHelpController.getIntHMAGuideLinks';
import getIntGMAPermissionLinks from '@salesforce/apex/DNAMSHelpController.getIntGMAPermissionLinks';
import getIntGMAGuideLinks from '@salesforce/apex/DNAMSHelpController.getIntGMAGuideLinks';
import getDealerHMAPermissionLinks from '@salesforce/apex/DNAMSHelpController.getDealerHMAPermissionLinks';
import getDealerHMAGuideLinks from '@salesforce/apex/DNAMSHelpController.getDealerHMAGuideLinks';
import getDealerGMAPermissionLinks from '@salesforce/apex/DNAMSHelpController.getDealerGMAPermissionLinks';
import getDealerGMAGuideLinks from '@salesforce/apex/DNAMSHelpController.getDealerGMAGuideLinks';
export default class DNAMSHelp extends LightningElement {

    @api dnamsTraininglinkHeader;
	@api dnamsTraining;
	@api communityType;
	showHMA = false;
	showGMA = false;
	showAllTabs;
	isInternalUser = false;

	intHMAPermissionlinks;
	intHMAGuidesPermissionLinks;//DNA-993
	intGMAGuidesPermissionLinks;//DNA-993
	intHMAGuidelinks;
	intGMAPermissionlinks;
	intGMAGuidelinks;
	dealerHMAPermimssionlinks;
	dealerHMAGuidelinks;
	dealerGMAPermissionlinks;
	dealerGMAGuidelinks;


    connectedCallback() {
		if(this.communityType == 'HMA' || this.communityType == 'GMA'){
			this.isInternalUser = false;
			if(this.communityType == 'HMA'){
				this.showHMA = true;
			}
			if(this.communityType == 'GMA'){
				this.showGMA = true;
			}
			this.showAllTabs = true;
		}else{
			this.isInternalUser = true;
			this.showGMA = true;
			this.showHMA = true;
		}

		getIntHMAPermissionLinks().then(
			result =>
			{
				this.intHMAPermissionlinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		//DNA-993-Start
		getIntHMAGuidesPermissionLinks().then(
			result =>
			{
				this.intHMAGuidesPermissionLinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		getIntGMAGuidesPermissionLinks().then(
			result =>
			{
				this.intGMAGuidesPermissionLinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		//DNA-993-End
		getIntHMAGuideLinks().then(
			result =>
			{
				this.intHMAGuidelinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		getIntGMAPermissionLinks().then(
			result =>
			{
				this.intGMAPermissionlinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		getIntGMAGuideLinks().then(
			result =>
			{
				this.intGMAGuidelinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		getDealerHMAPermissionLinks().then(
			result =>
			{
				this.dealerHMAPermimssionlinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		getDealerHMAGuideLinks().then(
			result =>
			{
				this.dealerHMAGuidelinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		getDealerGMAPermissionLinks().then(
			result =>
			{
				this.dealerGMAPermissionlinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})
		getDealerGMAGuideLinks().then(
			result =>
			{
				this.dealerGMAGuidelinks = result;
			}
		).catch ( error => {console.error('Error ==> '+ error);})

		
    }
}