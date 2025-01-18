import { LightningElement, api } from 'lwc';
import {staticResourceList} from 'c/hcuvUtility';

export default class HcuvPortalIcons extends LightningElement {
    @api width = '15';
	@api height = '15';
	@api icon;
	@api title;

	//this renders the correct URL: SVG_RESOURCE is the static resource
    get svgURL(){
		return `${staticResourceList.SVG_RESOURCE}#${this.icon}`;
	}
	get Title(){
		return this.title;
	}

}