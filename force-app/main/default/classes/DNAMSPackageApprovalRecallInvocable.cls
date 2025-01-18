/*
 * _______________________________________________________________________________________________________
 * Description: Invocable class to recall package approval. This will be called from Screen flow
 * _______________________________________________________________________________________________________
 * @author          Bhanu Sakinala
 * @version         1.0
 * @created         08/10/2023
 * @input
 * @output
 * ________________________________________________________________________________________________________
 */
public class DNAMSPackageApprovalRecallInvocable {
    @InvocableMethod(label='Package Approval Invocable Apex' description='Invocable apex to recall package approvals' iconName='slds:standard:output')
    public static List<InvocableOutput> recallApprovals(List<InvocableInput> requests){
        //Declarations 
        List<Package_Approval__c> pendingPackageApprovalList = new List<Package_Approval__c>();
        Map<Id, String> pendingApprovalMap = new Map<Id, String>();
        List<String> groupList = new List<String>();
        String errorMessage = '';

        List<InvocableOutput> responses = new List<InvocableOutput>(); 
        
        InvocableInput flowInput = requests.get(0);
        flowInput.legal = (flowInput.legal == null)? false : flowInput.legal;
        flowInput.bmi = (flowInput.bmi == null)? false : flowInput.bmi;
        flowInput.planning = (flowInput.planning == null)? false : flowInput.planning;
        //DNA-1026, DNA-1029-Start
        flowInput.performance = (flowInput.performance == null)? false : flowInput.performance;
        flowInput.dealerGroups = (flowInput.dealerGroups == null)? false : flowInput.dealerGroups;
        //DNA-1026, DNA-1029-End
        Package_Approval__c currentPackageApproval = flowInput.packageApproval;
        currentPackageApproval.Recalled__c = true;
      
        
        //Package__c currentPackage = new Package__c(Id = currentPackageApproval.Package__c);  //creating instance of the package
        Package__c currentPackage = [Select Id, OwnerId,Status__c,  Region_Market_Manager_Approval_Status__c,LegalApprovalStatus__c, Legal_BMI_Planning_Created__c, Legal_Approval_Required__c, 
                                     BMI_Approval_Status__c,  BMI_Approval_Required__c, Planning_Approval_Status__c,  Planning_Approval_Required__c, DND_2_Approval_Status__c, 
                                     DND_3_Approval_Status__c, Executive_Approval_Status__c, Performance_Approval_Status__c,  Performance_Approval_Required__c,
                                     Dealer_Groups_Approval_Status__c,  Dealer_Groups_Approval_Required__c
                                     From Package__c
                                     Where Id = :currentPackageApproval.Package__c];//DNA-1026, DNA-1029-Added field for Performance and Dealer Groups
        //Package__c currentPackageOld = currentPackage;
        Datetime dt = currentPackageApproval.CreatedDate;
        String queryStr = 'SELECT Id,Name, Approval_Type__c, Decision__c from Package_Approval__c WHERE Package__c = \''+currentPackageApproval.Package__c +'\''+ ' and Decision__c = \'Pending\' and CreatedDate >= :dt';

        if(flowInput.legal){
            groupList.add('Legal');
        }
        if(flowInput.bmi){
            groupList.add('BMI');
        }
        if(flowInput.planning){
            groupList.add('Planning');
        }//DNA-1026, DNA-1029-Start
        if(flowInput.performance){
            groupList.add('Performance');
        }
        if(flowInput.dealerGroups){
            groupList.add('Dealer Groups');
        }
        //DNA-1026, DNA-1029-End
        if(!groupList.isEmpty()){
            queryStr += ' AND Approval_Type__c in :groupList';
        }

        // Looping through pending package approvals after the current approval type and update the Decision field on package approval record
        // and update relevant status and approval boolean fields on Package
        for (Package_Approval__c pendingPackageApproval : Database.query(queryStr)){
                pendingPackageApproval.Decision__c = 'Recalled';
                pendingPackageApproval.Decision_Maker__c = UserInfo.getUserId();
                pendingPackageApproval.DecisionDateAndTime__c = System.now();
                pendingPackageApprovalList.add(pendingPackageApproval);
            if(pendingPackageApproval.Approval_Type__c == 'RGM'){
                currentPackage.Region_Market_Manager_Approval_Status__c = 'Recalled';
            } else if (pendingPackageApproval.Approval_Type__c == 'Legal' ) {
                currentPackage.LegalApprovalStatus__c = 'Recalled';//made not required to Recalled
                currentPackage.Legal_BMI_Planning_Created__c = false;
            } else if (pendingPackageApproval.Approval_Type__c == 'BMI') {
                currentPackage.BMI_Approval_Status__c = 'Recalled';
                currentPackage.Legal_BMI_Planning_Created__c = false;
            } else if (pendingPackageApproval.Approval_Type__c == 'Planning') {
                currentPackage.Planning_Approval_Status__c = 'Recalled';
                currentPackage.Legal_BMI_Planning_Created__c = false;
            } else if (pendingPackageApproval.Approval_Type__c == 'Performance') {//DNA-1026, DNA-1029-Start
                currentPackage.Performance_Approval_Status__c = 'Recalled';
                currentPackage.Legal_BMI_Planning_Created__c = false;
            } else if (pendingPackageApproval.Approval_Type__c == 'Dealer Groups') {
                currentPackage.Dealer_Groups_Approval_Status__c = 'Recalled';
                currentPackage.Legal_BMI_Planning_Created__c = false; //DNA-1026, DNA-1029-End
            } else if (pendingPackageApproval.Approval_Type__c == 'DND 2') {
                currentPackage.DND_2_Approval_Status__c = 'Recalled';
            } else if (pendingPackageApproval.Approval_Type__c == 'DND 3') {
                currentPackage.DND_3_Approval_Status__c = 'Recalled';
            } else if (pendingPackageApproval.Approval_Type__c == 'Executive') {
                currentPackage.Executive_Approval_Status__c = 'Recalled';
            } else {
                
            }
            pendingApprovalMap.put(pendingPackageApproval.Id, pendingPackageApproval.Name+' - '+pendingPackageApproval.Approval_Type__c);
            System.debug('pendingApprovalMap-->'+JSON.serializePretty(pendingApprovalMap));
        }

        //Dont show Legal/BMI/Planning button, in case any of there is in Pending/Approved on Package records
        List<String> pendingApprovedList = new List<String>{'Pending','Approved'};
        if(pendingApprovedList.contains(currentPackage.LegalApprovalStatus__c) || 
            pendingApprovedList.contains(currentPackage.BMI_Approval_Status__c) ||
            pendingApprovedList.contains(currentPackage.Planning_Approval_Status__c) || 
            pendingApprovedList.contains(currentPackage.Performance_Approval_Status__c) ||
            pendingApprovedList.contains(currentPackage.Dealer_Groups_Approval_Status__c) ){ //DNA-1026, DNA-1029-Added field for Performance and Dealer Groups
                currentPackage.Legal_BMI_Planning_Created__c = true;
        }

        //Make Legal/BMI/Planning_Created to false, when all are recalled
        if(currentPackage.LegalApprovalStatus__c == 'Recalled' && //removed not required and made it into recalled
           currentPackage.BMI_Approval_Status__c == 'Recalled' && 
           currentPackage.Planning_Approval_Status__c == 'Recalled' && 
           currentPackage.Performance_Approval_Status__c == 'Recalled' && 
           currentPackage.Dealer_Groups_Approval_Status__c == 'Recalled' ){//DNA-1026, DNA-1029-Added field for Performance and Dealer Groups
            currentPackageApproval.Recalled__c = false;
        }

        //Show Recall button, when any of the DND1 child approval records status is in Pending
        if(currentPackageApproval.Approval_Type__c == 'DND 1' &&  
            (currentPackage.LegalApprovalStatus__c == 'Pending' || currentPackage.BMI_Approval_Status__c == 'Pending' || currentPackage.Planning_Approval_Status__c == 'Pending' 
            || currentPackage.Performance_Approval_Status__c == 'Pending' || currentPackage.Dealer_Groups_Approval_Status__c == 'Pending')){ //DNA-1026, DNA-1029-Added field for Performance and Dealer Groups
                currentPackageApproval.Recalled__c = false;
                System.debug('currentPackageApproval.Recalled__c-->'+currentPackageApproval.Recalled__c);
        }
             
        //Update DML for updating pending package apporval records
        //this response is caught in the frontend to show success message after recalling based on how many child records are recalled
        Database.SaveResult[] srResult = Database.update(pendingPackageApprovalList, false);
        Integer counter = 0; 
        InvocableOutput resp = new InvocableOutput();
        for(Database.SaveResult sr : srResult){ 
            if(sr.isSuccess()){
                if(counter == 0){
                    resp.approvalOneRecalled = pendingApprovalMap.get(sr.getId());
                } else if(counter == 1){
                    resp.approvalTwoRecalled = pendingApprovalMap.get(sr.getId());
                } else if(counter == 2){
                    resp.approvalThreeRecalled = pendingApprovalMap.get(sr.getId());
                }else if(counter == 3){
                    resp.approvalFourRecalled = pendingApprovalMap.get(sr.getId());
                } else {
                    resp.approvalFiveRecalled = pendingApprovalMap.get(sr.getId());
                }
                counter++;
            } else {
                for(Database.Error err : sr.getErrors()){
                    System.debug(err.getStatusCode() + ' : ' + err.getMessage());
                }
            }
        }
        responses.add(resp);
        
        // Approval record with 'DND 1' type and 'Pending' Status doesn't need any new package approval record upon recall.
        // A new package approval records with current package approval type need to be created in all other cases
        if(!(currentPackageApproval.Approval_Type__c == 'DND 1' && currentPackageApproval.Decision__c == 'Pending')){
            Package_Approval__c newPackageApproval =  new Package_Approval__c(Decision__c = 'Pending', Approval_Type__c = currentPackageApproval.Approval_Type__c,
                                                                              OwnerId = currentPackageApproval.OwnerId, Package__c = currentPackageApproval.Package__c, Legal_BMI_Planning_Created__c = currentPackageApproval.Legal_BMI_Planning_Created__c);
            insert newPackageApproval; 
            //system.debug('newPackageApproval-->'+JSON.serialize(newPackageApproval));
        }
        
        currentPackage.OwnerId = currentPackageApproval.OwnerId;     // change the owner of package to the package approval upon recall
        
        //Change the package status to the status relevant to package approval that has been recalled
        switch on currentPackageApproval.Approval_Type__c {
            when 'RMR' {
                currentPackage.Status__c = 'RMR Approval';
            }       
            when 'DND 1' {
                currentPackage.Status__c = 'DND1 Approval';
            }
            when 'DND 2' {
                currentPackage.Status__c = 'DND2 Approval';
            }
            when 'DND 3' {
                currentPackage.Status__c = 'DND3 Approval';
            }
            when else {
                
            }
        }
        
        System.debug('currentPackageApproval before update==>'+JSON.serializePretty(currentPackageApproval));
        update currentPackageApproval;  //DML update on current package approval record
        update currentPackage;  // DML update on package record
        return responses;
    }
    
    public class InvocableInput {
        @InvocableVariable(label='Current Package Approval')
        public Package_Approval__c packageApproval;
        
        @InvocableVariable(label='Legal recalled')
        public Boolean legal;
        
        @InvocableVariable(label='BMI recalled')
        public Boolean bmi;
        
        @InvocableVariable(label='Planning recalled')
        public Boolean planning;
        //DNA-1026, DNA-1029-Added field for Performance and Dealer Groups-Start
        @InvocableVariable(label='Performance recalled')
        public Boolean performance;
        
        @InvocableVariable(label='Dealer Groups recalled')
        public Boolean dealerGroups;
        //DNA-1026, DNA-1029-Added field for Performance and Dealer Groups-End
    }

    public class InvocableOutput {
        @InvocableVariable
        public String approvalOneRecalled;

        @InvocableVariable
        public String approvalTwoRecalled;

        @InvocableVariable
        public String approvalThreeRecalled;
        //DNA-1026, DNA-1029-Added field for Performance and Dealer Groups-Start
        @InvocableVariable
        public String approvalFourRecalled;

        @InvocableVariable
        public String approvalFiveRecalled;
		//DNA-1026, DNA-1029-Added field for Performance and Dealer Groups-Start
    }
    
}