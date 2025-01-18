import { LightningElement, track, api, wire } from 'lwc';
import { staticResourceList, communityList, labelList } from 'c/hcuvUtility';
import getMessagesFilesInfo from '@salesforce/apex/HCUV_MessageController.getMessagesFilesInfo';
export default class HcuvDealerMessageFiles extends LightningElement {
    @api recordId;
    @track contentDocuments = [];
    @track pdfIcon = communityList.HCUV_Icon_PDF;
    @track videoIcon = communityList.HCUV_Icon_Video;
    videoExtensions = ['webm', 'mp4', 'mov', 'm4v'];
    hmaIcons = {
        'pdf': staticResourceList.HMAIcons + this.pdfIcon,
        'video': staticResourceList.HMAIcons + this.videoIcon
    };
    @track selContentDocuments = [];
    docMap = {};

    @wire(getMessagesFilesInfo, { recordId: "$recordId" })
    getMessages(result) {
        if (result.data) {
            var docLinkData = [];
            this.selContentDocuments = JSON.parse(JSON.stringify(result.data));
            this.docMap = this.selContentDocuments.DocMap;
            this.selContentDocuments.ContentDocumentLink.forEach((conDoc) => {
                conDoc.isVideo = false;
                if (this.videoExtensions.includes(conDoc.ContentDocument.FileExtension)) {
                    conDoc.isVideo = true;
                }
                this.contentDocuments.push(conDoc);
            });
        }
    }
	

    handleLinkClick(event) {
        let videoURL = communityList.COMMUNITY_BASE_PATH.substring(0, communityList.COMMUNITY_BASE_PATH.length - 2) + labelList.VIDEO_URL;
        this.selContentDocuments.ContentDocumentLink.forEach((contDocRec) => {
            if (contDocRec.ContentDocumentId == event.currentTarget.dataset.id) {
                if (this.videoExtensions.includes(contDocRec.ContentDocument.FileExtension)) {
                    window.open(videoURL + event.currentTarget.dataset.id);
                }
                else {
                    window.open(this.docMap[event.currentTarget.dataset.id]);
                }
            }
        });
    }

}