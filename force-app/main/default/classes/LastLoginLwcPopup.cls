/**
    * Pop up for Increased License Number
    * @return Decimal     
    * @author Milind [12 Apr 2022] [IBM] Ticket DPM-3979
    */
public with sharing class LastLoginLwcPopup {

	@AuraEnabled
    public static Decimal getLastLoginDetail(){
        Id userId = UserInfo.getUserId();
        Decimal count;
        
        if (userId != NULL) {
            User usr = [SELECT Id, Last_Login_Count__c FROM User WHERE Id =:userId];
            if (usr.Last_Login_Count__c == NULL || usr.Last_Login_Count__c == 0) {
                usr.Last_Login_Count__c = 1;
            } else {
                usr.Last_Login_Count__c = usr.Last_Login_Count__c + 1;
            }
            
            count = usr.Last_Login_Count__c;
            update usr;
        }
        return count;
    }
}