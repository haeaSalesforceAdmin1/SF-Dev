import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {communityList,staticResourceList, labelList} from 'c/hcuvUtility';
import getReferenceMaterials from '@salesforce/apex/HCUV_ReferenceMaterialsController.getReferenceMaterials';
import networkId from '@salesforce/community/Id';


export default class ReferenceMaterials extends LightningElement {
    
    @track formsAndGuides = communityList.HCUV_Forms_And_Guides;
    @track videos = communityList.HCUV_Videos;
    @track links = communityList.HCUV_Links;
    @track pdfIcon = communityList.HCUV_Icon_PDF;
    @track videoIcon = communityList.HCUV_Icon_Video;
    networkId = networkId;
    showSpinner = false;
    hmaIcons = {
        'pdf': staticResourceList.HMAIcons + this.pdfIcon,
        'video': staticResourceList.HMAIcons + this.videoIcon
    };
    @track formBrochuresList = [];
    @track linksList = [];
    @track videosList = [];
    docMap = {};
    videoExtensions = ['webm', 'mp4', 'mov', 'm4v'];

    get showFormBrochuresSection() {
        return this.searchTerm == 'formAndBrochures' || this.searchTerm == 'all';
    }

    get showLinksSection() {
        return this.searchTerm == 'links' || this.searchTerm == 'all';
    }

    get showVideosSection() {
        return this.searchTerm == 'videos' || this.searchTerm == 'all';
    }

    // get URL parameters
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference.state) {
            this.urlStateParameters = currentPageReference.state;

            if (this.urlStateParameters.tab) {
                this.searchTerm = this.urlStateParameters.tab;
            }
        }
    }
    @wire(getReferenceMaterials, { networkId: "$networkId" })
    referenceMats(result) {
        this.formBrochuresList = [];
        this.linksList = [];
        this.videosList = [];
        if (result.data) {
            var refMaterials = [];
            refMaterials = JSON.parse(JSON.stringify(result.data));
            if (refMaterials.ReferenceMaterials && refMaterials.ReferenceMaterials.length > 0) {
                refMaterials.ReferenceMaterials.forEach((item) => {
                    item.Id = '';
                    if (item.ContentDocumentLinks && item.ContentDocumentLinks.length > 0) {
                        item.Id = item.ContentDocumentLinks[0].ContentDocumentId;
                        item.isVideo = false;

                        if(this.videoExtensions.includes(item.ContentDocumentLinks[0].ContentDocument.FileExtension)) {
                            item.isVideo = true;
                        }
                    }
                    if (item.Material_Type__c == 'Document')
                        this.formBrochuresList.push(item);
                    if (item.Material_Type__c == 'Link')
                        this.linksList.push(item);
                    else if (item.Material_Type__c == 'Video')
                        this.videosList.push(item);
                });
            }
            //Add clickable condition
            this.formBrochuresList = this.formBrochuresList.map(obj => ({ ...obj, 
            isClickable: obj.ContentDocumentLinks && obj.ContentDocumentLinks.length>0 }))

            this.videosList = this.videosList.map(obj => ({ ...obj, 
            isClickable: obj.ContentDocumentLinks && obj.ContentDocumentLinks.length>0 }))

            this.linksList.forEach((item, index) => {
                item.linkIndex = 'Link' + (index + 1);
            });

            if (refMaterials.DocMap)
                this.docMap = refMaterials.DocMap;

        }
    }


    handleLinkClick(event) {
       
        let videoURL=communityList.COMMUNITY_BASE_PATH.substring(0,communityList.COMMUNITY_BASE_PATH.length-2)+labelList.VIDEO_URL;
        this.formBrochuresList.forEach((conDoc) => {
            if(conDoc.Id == event.currentTarget.dataset.id) {
                if(conDoc.isVideo)
                    window.open(videoURL + event.currentTarget.dataset.id);
                else 
                    window.open(this.docMap[event.currentTarget.dataset.id]);
            }
        });

        this.videosList.forEach((conDoc) => {
            if(conDoc.Id == event.currentTarget.dataset.id) {
                if(conDoc.isVideo)
                    window.open(videoURL + event.currentTarget.dataset.id);
                else 
                    window.open(this.docMap[event.currentTarget.dataset.id]);
            }
        });
    }

    handleURLClick(event) {
        let link = event.currentTarget.dataset.id;
        if(/^(http(s):\/\/.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g.test(link))
            window.open(link);
    }
    
}