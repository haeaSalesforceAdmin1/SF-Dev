/*
 * _______________________________________________________________________________________________________
 * Description: Invocable class to clone package. This will be called from Screen flow
 * _______________________________________________________________________________________________________
 * @author          Bhavana
 * @version         1.0
 * @created         24/10/2024
 * @input			String recordId and String clonedRecordId
 * @output			NA
 * ________________________________________________________________________________________________________
 */
public class DNAMSPackageCloneUpdateTransmittalFields {
    @InvocableMethod(label='Package Clone Update Transmittal Fields Invocable Apex' description='Invocable apex to Update Transmittal Fields clone package' iconName='slds:standard:output')
    public static void clonePackages(List<InvocableInput> requests){
        //Step 1. Get Original Package Record from the clonned pkg
        Package__c originalPkgRecord = getPackage(requests[0].recordId);//Get original package
        System.debug('DNAMSPackageCloneUpdateTransmittalFields==originalPkgRecord='+originalPkgRecord);
        
        //Step 2. Update the cloned package fields for transmittal
		Package__c clonnedPkgRecord = updateTranmittalFields(originalPkgRecord, requests[0].clonedRecordId);
        System.debug('DNAMSPackageCloneUpdateTransmittalFields==clonnedPkgRecord='+clonnedPkgRecord);
        if(clonnedPkgRecord != null){
            update clonnedPkgRecord;
        }
    }
    
    private static Package__c getPackage(String recordId){
        return [
            SELECT
            	Id,
            	Current_Hyundai_Dealer_Code__c,	
            	Prepared_By__c,	
            	Genesis_Facility_Configuration__c,	
            	Addenda_Included__c,	
            	Strategy_DND_Approval_Date__c,	
            	Memo_of_Understanding_on_File__c,	
            	FI_Agreement_on_File__c,	
            	Transmittal_Additional_Comments__c,	
            	Temp_Code__c,	
            	Proposed_Legal_Entity_Name__c,	
            	Proposed_Hyundai_DBA_Name__c,	
            	Term_of_Proposed_Agreement__c,	
            	Planned_Operational_Closing_Date__c,	
            	Date_Prepared__c,	
            	Package_Description__c,	
            	Current_Dealer_Principal_Ownership__c,	
            	Current_General_Manager_Ownership__c,	
            	Background_Check_on_File__c,	
            	Current_Background_Check_Year__c,	
            	Minority_Flag__c,	
            	Proposed_Dealer_Principal__c,	
            	Proposed_Dealer_Principal_Ownership__c,	
            	Proposed_General_Manager__c,	
            	Proposed_General_Manager_Ownership__c,	
            	GM_Status__c,	
            	Start_Date_of_GM_PEP__c,	
            	Min_General_Manager__c,	
            	Min_General_Mgr_Code__c,	
            	Proposed_Net_Working_Capital_Actual__c,	
            	Prop_Net_Working_Capital_Percent_Guide__c,	
            	Proposed_Net_Working_Capital_Guide__c,	
            	Proposed_Net_Working_Capital_As_Of__c,	
            	Proposed_Flooring_Required__c,	
            	Proposed_Flooring_Actual__c,	
            	Proposed_Flooring_Guide__c,	
            	Expected_Registrations__c,	
            	Dealer_Business_Plan__c,	
            	Competitive_Makes_Represented_in_Market__c,	
            	Market_Study_Recommendation__c,	
            	Showroom_Address_2__c,	
            	Proposed_Showroom_Address_Name__c,	
            	Proposed_Showroom_Address_1__c,	
            	Proposed_Showroom_Address_2__c,	
            	Proposed_Showroom_Address_City__c,	
            	Proposed_Showroom_Address_State__c,	
            	Proposed_Showroom_Address_Zip__c,	
            	Parts_Service_Address_2__c,	
            	Proposed_Parts_Service_Address_Name__c,	
            	Proposed_Parts_Service_Address_1__c,	
            	Proposed_Parts_Service_Address_2__c,	
            	Proposed_Parts_Service_Address_City__c,	
            	Proposed_Parts_Service_Address_State__c,	
            	Proposed_Parts_Service_Address_Zip__c,	
            	GDSI_Status__c,	
            	Exclusivity_Status__c,	
            	Current_Genesis_Facility__c,	
            	Proposed_Genesis_Facility__c,	
            	GRD_Status__c,	
            	Facility_Survey_Date__c,	
            	LTC_Branding_Agmt_Signed_Date__c,	
            	LTC_Commencement_Date__c,	
            	LTC_Completion_Date__c,	
            	Gen_Keystone_Perf_Bonus_Prog_Eligible__c,	
            	Completion_Date__c,	
            	Brand_Ambassador_Program_Eligible__c,	
            	RX_Rewards_Program_Eligible__c,	
            	Dealership_Facility_Owned_or_Leased__c,	
            	Dual_Status__c,	
            	DealerComments__c,	
            	Genesis_EV_Sales_Certified__c,	
            	Genesis_EV_Service_Certified__c,
                IONIQ_Status__c,	
            	Blue_Sky_Amount__c,	
            	FF_E_Amount__c,	
            	Property_Amount__c,	
            	Current_Ownership_Details__c,	
            	Proposed_Ownership_Details__c,	
            	Rationale__c,	
            	Dealer_Principal_Has_Majority_Ownership__c,	
            	Dealer_Principal_Has_Majority_Control__c,	
            	If_Yes_Via_What_Document__c,	
            	Ownership_Description__c,	
            	Management__c,	
            	Capitalization__c,	
            	Market_Location__c,	
            	Facility_Proposal__c,	
                Facility_Summary__c,	
            	Plan_of_Succession__c,	
            	Customer_Satisfaction__c,	
            	Other__c,	
            	Regional_Recommendation__c
            FROM Package__c
			Where Id =: recordId
        ];
    }
    
    private static Package__c updateTranmittalFields(Package__c originalPkgRecord, String clonedRecordId){
        Package__c clonnedPkgRecord = getPackage(clonedRecordId);
		clonnedPkgRecord.Current_Hyundai_Dealer_Code__c = originalPkgRecord.Current_Hyundai_Dealer_Code__c;
        clonnedPkgRecord.Prepared_By__c = originalPkgRecord.Prepared_By__c;
        clonnedPkgRecord.Genesis_Facility_Configuration__c = originalPkgRecord.Genesis_Facility_Configuration__c;
        clonnedPkgRecord.Addenda_Included__c = originalPkgRecord.Addenda_Included__c;
        clonnedPkgRecord.Strategy_DND_Approval_Date__c = originalPkgRecord.Strategy_DND_Approval_Date__c;
        clonnedPkgRecord.Memo_of_Understanding_on_File__c = originalPkgRecord.Memo_of_Understanding_on_File__c;
        clonnedPkgRecord.FI_Agreement_on_File__c = originalPkgRecord.FI_Agreement_on_File__c;
        clonnedPkgRecord.Transmittal_Additional_Comments__c = originalPkgRecord.Transmittal_Additional_Comments__c;
        clonnedPkgRecord.Temp_Code__c = originalPkgRecord.Temp_Code__c;
        clonnedPkgRecord.Proposed_Legal_Entity_Name__c = originalPkgRecord.Proposed_Legal_Entity_Name__c;
        clonnedPkgRecord.Proposed_Hyundai_DBA_Name__c = originalPkgRecord.Proposed_Hyundai_DBA_Name__c;
        clonnedPkgRecord.Term_of_Proposed_Agreement__c = originalPkgRecord.Term_of_Proposed_Agreement__c;
        clonnedPkgRecord.Planned_Operational_Closing_Date__c = originalPkgRecord.Planned_Operational_Closing_Date__c;
        clonnedPkgRecord.Date_Prepared__c = originalPkgRecord.Date_Prepared__c;
        clonnedPkgRecord.Package_Description__c = originalPkgRecord.Package_Description__c;
        clonnedPkgRecord.Current_Dealer_Principal_Ownership__c = originalPkgRecord.Current_Dealer_Principal_Ownership__c;
        clonnedPkgRecord.Current_General_Manager_Ownership__c = originalPkgRecord.Current_General_Manager_Ownership__c;
        clonnedPkgRecord.Background_Check_on_File__c = originalPkgRecord.Background_Check_on_File__c;
        clonnedPkgRecord.Current_Background_Check_Year__c = originalPkgRecord.Current_Background_Check_Year__c;
        clonnedPkgRecord.Minority_Flag__c = originalPkgRecord.Minority_Flag__c;
        clonnedPkgRecord.Proposed_Dealer_Principal__c = originalPkgRecord.Proposed_Dealer_Principal__c;
        clonnedPkgRecord.Proposed_Dealer_Principal_Ownership__c = originalPkgRecord.Proposed_Dealer_Principal_Ownership__c;
        clonnedPkgRecord.Proposed_General_Manager__c = originalPkgRecord.Proposed_General_Manager__c;
        clonnedPkgRecord.Proposed_General_Manager_Ownership__c = originalPkgRecord.Proposed_General_Manager_Ownership__c;
        clonnedPkgRecord.GM_Status__c = originalPkgRecord.GM_Status__c;
        clonnedPkgRecord.Start_Date_of_GM_PEP__c = originalPkgRecord.Start_Date_of_GM_PEP__c;
        clonnedPkgRecord.Min_General_Manager__c = originalPkgRecord.Min_General_Manager__c;
        clonnedPkgRecord.Min_General_Mgr_Code__c = originalPkgRecord.Min_General_Mgr_Code__c;
        clonnedPkgRecord.Proposed_Net_Working_Capital_Actual__c = originalPkgRecord.Proposed_Net_Working_Capital_Actual__c;
        clonnedPkgRecord.Prop_Net_Working_Capital_Percent_Guide__c = originalPkgRecord.Prop_Net_Working_Capital_Percent_Guide__c;
        clonnedPkgRecord.Proposed_Net_Working_Capital_Guide__c = originalPkgRecord.Proposed_Net_Working_Capital_Guide__c;
        clonnedPkgRecord.Proposed_Net_Working_Capital_As_Of__c = originalPkgRecord.Proposed_Net_Working_Capital_As_Of__c;
        clonnedPkgRecord.Proposed_Flooring_Required__c = originalPkgRecord.Proposed_Flooring_Required__c;
        clonnedPkgRecord.Proposed_Flooring_Actual__c = originalPkgRecord.Proposed_Flooring_Actual__c;
        clonnedPkgRecord.Proposed_Flooring_Guide__c = originalPkgRecord.Proposed_Flooring_Guide__c;
        clonnedPkgRecord.Expected_Registrations__c = originalPkgRecord.Expected_Registrations__c;
        clonnedPkgRecord.Dealer_Business_Plan__c = originalPkgRecord.Dealer_Business_Plan__c;
        clonnedPkgRecord.Competitive_Makes_Represented_in_Market__c = originalPkgRecord.Competitive_Makes_Represented_in_Market__c;
        clonnedPkgRecord.Market_Study_Recommendation__c = originalPkgRecord.Market_Study_Recommendation__c;
        clonnedPkgRecord.Showroom_Address_2__c = originalPkgRecord.Showroom_Address_2__c;
        clonnedPkgRecord.Proposed_Showroom_Address_Name__c = originalPkgRecord.Proposed_Showroom_Address_Name__c;
        clonnedPkgRecord.Proposed_Showroom_Address_1__c = originalPkgRecord.Proposed_Showroom_Address_1__c;
        clonnedPkgRecord.Proposed_Showroom_Address_2__c = originalPkgRecord.Proposed_Showroom_Address_2__c;
        clonnedPkgRecord.Proposed_Showroom_Address_City__c = originalPkgRecord.Proposed_Showroom_Address_City__c;
        clonnedPkgRecord.Proposed_Showroom_Address_State__c = originalPkgRecord.Proposed_Showroom_Address_State__c;
        clonnedPkgRecord.Proposed_Showroom_Address_Zip__c = originalPkgRecord.Proposed_Showroom_Address_Zip__c;
        clonnedPkgRecord.Parts_Service_Address_2__c = originalPkgRecord.Parts_Service_Address_2__c;
        clonnedPkgRecord.Proposed_Parts_Service_Address_Name__c = originalPkgRecord.Proposed_Parts_Service_Address_Name__c;
        clonnedPkgRecord.Proposed_Parts_Service_Address_1__c = originalPkgRecord.Proposed_Parts_Service_Address_1__c;
        clonnedPkgRecord.Proposed_Parts_Service_Address_2__c = originalPkgRecord.Proposed_Parts_Service_Address_2__c;
        clonnedPkgRecord.Proposed_Parts_Service_Address_City__c = originalPkgRecord.Proposed_Parts_Service_Address_City__c;
        clonnedPkgRecord.Proposed_Parts_Service_Address_State__c = originalPkgRecord.Proposed_Parts_Service_Address_State__c;
        clonnedPkgRecord.Proposed_Parts_Service_Address_Zip__c = originalPkgRecord.Proposed_Parts_Service_Address_Zip__c;
        clonnedPkgRecord.GDSI_Status__c = originalPkgRecord.GDSI_Status__c;
        clonnedPkgRecord.Exclusivity_Status__c = originalPkgRecord.Exclusivity_Status__c;
        clonnedPkgRecord.Current_Genesis_Facility__c = originalPkgRecord.Current_Genesis_Facility__c;
        clonnedPkgRecord.Proposed_Genesis_Facility__c = originalPkgRecord.Proposed_Genesis_Facility__c;
        clonnedPkgRecord.GRD_Status__c = originalPkgRecord.GRD_Status__c;
        clonnedPkgRecord.Facility_Survey_Date__c = originalPkgRecord.Facility_Survey_Date__c;
        clonnedPkgRecord.LTC_Branding_Agmt_Signed_Date__c = originalPkgRecord.LTC_Branding_Agmt_Signed_Date__c;
        clonnedPkgRecord.LTC_Commencement_Date__c = originalPkgRecord.LTC_Commencement_Date__c;
        clonnedPkgRecord.LTC_Completion_Date__c = originalPkgRecord.LTC_Completion_Date__c;
        clonnedPkgRecord.Gen_Keystone_Perf_Bonus_Prog_Eligible__c = originalPkgRecord.Gen_Keystone_Perf_Bonus_Prog_Eligible__c;
        clonnedPkgRecord.Completion_Date__c = originalPkgRecord.Completion_Date__c;
        clonnedPkgRecord.Brand_Ambassador_Program_Eligible__c = originalPkgRecord.Brand_Ambassador_Program_Eligible__c;
        clonnedPkgRecord.RX_Rewards_Program_Eligible__c = originalPkgRecord.RX_Rewards_Program_Eligible__c;
        clonnedPkgRecord.Dealership_Facility_Owned_or_Leased__c = originalPkgRecord.Dealership_Facility_Owned_or_Leased__c;
        clonnedPkgRecord.Dual_Status__c = originalPkgRecord.Dual_Status__c;
        clonnedPkgRecord.DealerComments__c = originalPkgRecord.DealerComments__c;
        clonnedPkgRecord.Genesis_EV_Sales_Certified__c = originalPkgRecord.Genesis_EV_Sales_Certified__c;
        clonnedPkgRecord.Genesis_EV_Service_Certified__c = originalPkgRecord.Genesis_EV_Service_Certified__c;
        clonnedPkgRecord.IONIQ_Status__c = originalPkgRecord.IONIQ_Status__c;
        clonnedPkgRecord.Blue_Sky_Amount__c = originalPkgRecord.Blue_Sky_Amount__c;
        clonnedPkgRecord.FF_E_Amount__c = originalPkgRecord.FF_E_Amount__c;
        clonnedPkgRecord.Property_Amount__c = originalPkgRecord.Property_Amount__c;
        clonnedPkgRecord.Current_Ownership_Details__c = originalPkgRecord.Current_Ownership_Details__c;
        clonnedPkgRecord.Proposed_Ownership_Details__c = originalPkgRecord.Proposed_Ownership_Details__c;
        clonnedPkgRecord.Rationale__c = originalPkgRecord.Rationale__c;
        clonnedPkgRecord.Dealer_Principal_Has_Majority_Ownership__c = originalPkgRecord.Dealer_Principal_Has_Majority_Ownership__c;
        clonnedPkgRecord.Dealer_Principal_Has_Majority_Control__c = originalPkgRecord.Dealer_Principal_Has_Majority_Control__c;
        clonnedPkgRecord.If_Yes_Via_What_Document__c = originalPkgRecord.If_Yes_Via_What_Document__c;
        clonnedPkgRecord.Ownership_Description__c = originalPkgRecord.Ownership_Description__c;
        clonnedPkgRecord.Management__c = originalPkgRecord.Management__c;
        clonnedPkgRecord.Capitalization__c = originalPkgRecord.Capitalization__c;
        clonnedPkgRecord.Market_Location__c = originalPkgRecord.Market_Location__c;
        clonnedPkgRecord.Facility_Proposal__c = originalPkgRecord.Facility_Proposal__c;
        clonnedPkgRecord.Facility_Summary__c = originalPkgRecord.Facility_Summary__c;
        clonnedPkgRecord.Plan_of_Succession__c = originalPkgRecord.Plan_of_Succession__c;
        clonnedPkgRecord.Customer_Satisfaction__c = originalPkgRecord.Customer_Satisfaction__c;
        clonnedPkgRecord.Other__c = originalPkgRecord.Other__c;
        clonnedPkgRecord.Regional_Recommendation__c = originalPkgRecord.Regional_Recommendation__c;
	
            	
        return clonnedPkgRecord;
    }
        
    public class InvocableInput {
    
        @InvocableVariable(label='Original Package Record Id')
        public String recordId;
        
        @InvocableVariable(label='Cloned Package Record Id')
        public String clonedRecordId;
    	
    }

}