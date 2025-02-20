import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeOwner from '@salesforce/apex/ListviewChangeOwnerController.changeOwner';
import isSystemAdmin from '@salesforce/apex/ListviewChangeOwnerController.isSystemAdmin';

export default class ownerChangeListviewButton extends LightningElement {
    @api recordIds;  // ListView에서 받아온 레코드 IDs
    newOwnerId; // 새로운 소유자 ID
    isAdmin = false; // 시스템 관리자 여부


    connectedCallback() {
        const params = new URLSearchParams(window.location.search);
        this.recordIds = params.get('ids') ? params.get('ids').split(',') : [];
        console.log('recordIds: ' + this.recordIds);

        this.checkIfAdmin();
    }

    checkIfAdmin() {
        isSystemAdmin()
            .then(result => {
                this.isAdmin = result;
                console.log('isAdmin: ' + this.isAdmin);
            })
            .catch(error => {
                this.showError('Error checking user permissions.');
            });
    }

    showError(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            })
        );
    }

    // 소유자 변경 버튼 클릭 처리
    handleChangeOwner() {
        if (!this.newOwnerId) {
            this.showError('Please provide a new owner ID.');
            return;
        }

        changeOwner({ recordIds: this.recordIds, newOwnerId: this.newOwnerId, objectApiName: 'Account' })  // 예시로 Account 사용
            .then(() => {
                this.showSuccess('Owner changed successfully.');
            })
            .catch((error) => {
                this.showError('Error changing owner: ' + error.body.message);
            });
    }

    // 성공 메시지 표시
    showSuccess(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: message,
                variant: 'success',
            })
        );
    }

    // 오류 메시지 표시
    showError(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error',
            })
        );
    }
}