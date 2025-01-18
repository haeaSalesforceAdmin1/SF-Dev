/**
 * CUV Adoption
 * This batch class deletes CRMALog__c records that are older than a specified number of months.
 * Created by Areum on 2024-02-11 For HVM-460
 */

public with sharing class BatchToDeleteCRMALog implements Database.Batchable<sObject> {

    private Integer monthsToKeep;

    public BatchToDeleteCRMALog(Integer monthsToKeep) {
        this.monthsToKeep = monthsToKeep;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date purgeDate = Date.today().addMonths(-monthsToKeep);

        System.debug('BatchToDeleteCRMALog started. Records older than ' + monthsToKeep + ' months will be deleted.');
        String query = 'SELECT Id ' +
                         'FROM CRMALog__c ' +
                        'WHERE AppType__c = \'CUV\' ' +
                          'AND CreatedDate < :purgeDate';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> records) {
        System.debug('Deleting ' + records.size() + ' records.');
        delete records;
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('BatchToDeleteCRMALog finished.');
    }

}