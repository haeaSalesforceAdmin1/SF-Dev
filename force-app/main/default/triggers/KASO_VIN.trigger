/**
 * Created by dw.lee on 2023-10-17.
 */

trigger KASO_VIN on KASO_VIN__c (before  insert, after insert) {
    new KASO_VIN_tr().run();
}