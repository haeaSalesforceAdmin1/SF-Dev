import { LightningElement, api } from 'lwc';
import SVG_RESOURCE from '@salesforce/resourceUrl/hcuvPortalIcons';

export default class CuvPortalIcons extends LightningElement {
    @api width = '15';
	@api height = '15';
	@api icon;
	@api title;

	//this renders the correct URL: SVG_RESOURCE is the static resource
    get svgURL(){
		return `${SVG_RESOURCE}#${this.icon}`;
	}
	get Title(){
		return this.title;
	}

}