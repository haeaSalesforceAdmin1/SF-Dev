/**
 * Created by baltamimi on 2022-02-21.
 */

import LightningDatatable from 'lightning/datatable';
import progressRing from './progressRing.html';

export default class CustomTypes extends LightningDatatable {
    static customTypes = {
        progressRing: {
            template: progressRing,
            standardCellLayout: true,
            typeAttributes: ['progress', 'variant']
        }
    }
}