//  @description : Changed Lab Request Detail page Tab Name
//  @author San, Kang : SanKang@autoeveramerica.com | 2024-09-06
//  @tecket no: SO-462

@isTest
 public class QC_ConsoleTabLabelControllerTEST {

     @isTest static void Test() {
        Id QDARecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Q_DA').getRecordTypeId();
        Case Caseobj = ContentDocumentTestFactory.makeCase();
        Caseobj.SCSCaseNumber__c = 'C-001';
        Caseobj.RecordTypeId = QDARecordTypeId;
        Caseobj.stage__c = 'Q-DA';
        
        insert Caseobj;

        Test.startTest();
        QC_ConsoleTabLabelController.getQCObj(Caseobj.Id);
        Test.stopTest();
 
     }
 }