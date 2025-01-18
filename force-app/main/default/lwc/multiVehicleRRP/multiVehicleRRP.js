import { LightningElement, track, api} from 'lwc';
import getVehicleRRP from '@salesforce/apex/multiVehicleRRPController.getVehicleRRP';

export default class MultiVehicleRRP extends LightningElement() {
    @api recordId;

    @track vehicleOptions=[];
    @track vehicleYear;

    connectedCallback(){
        console.log('start2:::');
        getVehicleRRP({caseId: this.recordId})
        .then(result => {
            result.forEach(vehicle => {
                this.vehicleOptions.push(vehicle);
            });
        }).catch(error => {
            console.log('Error fetching affected vehicles');
            console.log(JSON.stringify(error));
            this.errorList.push(JSON.stringify(error));
        })
    }
}