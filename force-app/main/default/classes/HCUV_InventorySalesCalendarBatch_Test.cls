/**
************************************************************************************************
* @classname         : HCUV_InventorySalesCalendarBatch_Test; being used for Code Coverage
* @description       : Test class for HCUV_InventorySalesCalendarBatch
* @author            : Hemanth
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          04 Dec 2023         Madhu		         			      Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_InventorySalesCalendarBatch_Test {
    	
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        HCUV_TestDataFactory.createInventories(5);
        //Insert Sales calendar
        HCUV_Sales_Calendar__c objSalesCalendar = new HCUV_Sales_Calendar__c();        
            Date todayDate = System.today();
            objSalesCalendar.Calendar_Date__c =  todayDate;        
            objSalesCalendar.Calendar_Seq_Num__c = 1;
            objSalesCalendar.Sales_Year__c = todayDate.Year();
            objSalesCalendar.Sales_Month__c = todayDate.Month();
        insert objSalesCalendar;
    }
    
    @IsTest
    static void TestHCUV_InventorySalesCalendarBatch(){
        User internalUser = [SELECT Id FROM User WHERE id =: UserInfo.getUserId()];        
        System.runAs(internalUser) {
            Test.startTest();
        	    HCUV_InventorySalesCalendarBatch salCalBatch = new HCUV_InventorySalesCalendarBatch();
            	Database.ExecuteBatch(salCalBatch);            
          		List<HCUV_Inventory__c> listInventory = [Select id,Transaction_Date__c from HCUV_Inventory__c where RDR_Sales_Calendar_ID__c !=null];
            	System.assert(listInventory.size()==0,	'RDR_Sales_Calendar_ID__c not udpated');
            Test.stopTest();
        }        
    }   
}