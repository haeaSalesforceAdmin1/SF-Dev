import { LightningElement, track, wire } from 'lwc';
import getOrderMerchandising from '@salesforce/apex/HCUV_OrderMerchandising_ctrl.getOrderMerchandising';
import { communityList, staticResourceList, labelList } from 'c/hcuvUtility';
import networkId from '@salesforce/community/Id';

export default class HcuvOrderMerchandisingMaterial extends LightningElement {
    
    @track pdfIcon = communityList.HCUV_Icon_PDF;
    @track videoIcon = communityList.HCUV_Icon_Video;
    @track merchandisingMaterials = communityList.HCUV_Merchandising_Materials;
    networkId = networkId;
    showSpinner = false;
    hmaIcons = {
        'pdf': staticResourceList.HMAIcons + this.pdfIcon,
        'video': staticResourceList.HMAIcons + this.videoIcon
    };
    @track referenceMaterialList = [];
    docMap = {};
    videoExtensions = ['webm', 'mp4', 'mov', 'm4v'];

    @wire(getOrderMerchandising, { networkId: "$networkId" })
    orderMerchandising(result) {
        if (result.data) {
            var orderMerchandisingData = [];
            orderMerchandisingData = JSON.parse(JSON.stringify(result.data));
            this.referenceMaterialList = [];
            if (orderMerchandisingData.ReferenceMaterials && orderMerchandisingData.ReferenceMaterials.length > 0) {
                orderMerchandisingData.ReferenceMaterials.forEach((item) => {
                    item.Id = '';
                    if (item.ContentDocumentLinks && item.ContentDocumentLinks.length > 0) {
                        item.Id = item.ContentDocumentLinks[0].ContentDocumentId;
                        item.isVideo = false;

                        if (this.videoExtensions.includes(item.ContentDocumentLinks[0].ContentDocument.FileExtension)) {
                            item.isVideo = true;
                        }
                    }
                    this.referenceMaterialList.push(item)
                });
            }
            this.referenceMaterialList = this.referenceMaterialList.map(obj => ({
                ...obj,
                isClickable: obj.ContentDocumentLinks && obj.ContentDocumentLinks.length > 0 ? true : false
            })
            );

            if (orderMerchandisingData.DocMap)
                this.docMap = orderMerchandisingData.DocMap;
        }
    }

    handleLinkClick(event) {
        let videoURL = communityList.COMMUNITY_BASE_PATH.substring(0, communityList.COMMUNITY_BASE_PATH.length - 2) + labelList.VIDEO_URL;
        this.referenceMaterialList.forEach((conDoc) => {
            if (conDoc.Id == event.currentTarget.dataset.id) {
                if (conDoc.isVideo)
                    window.open(videoURL + event.currentTarget.dataset.id);
                else
                    window.open(this.docMap[event.currentTarget.dataset.id]);
            }
        });
    }

}