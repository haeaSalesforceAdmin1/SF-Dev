/**
 * Created by dw.lee on 2023-10-16.
 */

trigger HMCReferenceDataMapping on HMCReferenceDataMapping__c (after insert, after update) {
    new HMCReferenceDataMapping_tr().run();
}