public class RecommendCaseEngineer {
    @InvocableMethod(label='Recommend Engineers for Case' description='Recommend Enginners based on skills for the case')
    public static List<List<User>> getRecommendedEngineers(List<Id> caseIds){
        Case c = [SELECT Id, RecordType.Name, Subject, Description, RecommendedCaseTagsLong__c, CategoryofComponentAffected__c FROM Case WHERE Id =: caseIds[0]];
        List<User> users = [SELECT Id, Name, SCSafetySkills__c, SafetyTeamDesignations__c, AssignedCases__c FROM User WHERE 
        SafetyTeamDesignations__c <> NULL AND SafetyTeamDesignations__c LIKE: '%'+c.RecordType.Name+'%' ORDER By AssignedCases__c asc];

        List<EngineerMatchWrapper> recommendedEngineers = new List<EngineerMatchWrapper>();

        if(!users.isEmpty()){
            for(User usr: users){
                Boolean isCorrectTeam = false;
                List<String> userTeams = usr.SafetyTeamDesignations__c.split(',');
                for(String str: userTeams){
                    if(str.trim().startsWithIgnoreCase(c.RecordType.Name)) isCorrectTeam = true;
                }

                if(isCorrectTeam){
                    EngineerMatchWrapper rcmEngineer = new EngineerMatchWrapper(usr);
                    if(usr.SCSafetySkills__c <> NULL){
                        List<String> userSkillsStage1 = usr.SCSafetySkills__c.split(';');
                        List<String> userSkillsStage2 = new List<String>();
                        List<String> userSkillsStage3 = new List<String>();
                        Set<String> userSkillsFinalSet = new Set<String>();
                        for(String str: userSkillsStage1){
                            userSkillsStage2.addAll(str.split(':'));
                        }
                        for(String str: userSkillsStage2){
                            userSkillsStage3.addAll(str.split('/'));
                        }
                        for(String str: userSkillsStage3){
                            if(!userSkillsFinalSet.contains(str)){
                                userSkillsFinalSet.add(str);
                            }
                        }
                        for(String str: userSkillsFinalSet){
                            if(c.Subject <> NULL && c.Subject.containsIgnoreCase(str.trim())) rcmEngineer.mScore += 1;
                            if(c.Description <> NULL && c.Description.containsIgnoreCase(str.trim())) rcmEngineer.mScore += 1;
                            if(c.CategoryofComponentAffected__c <> NULL && c.CategoryofComponentAffected__c.containsIgnoreCase(str.trim())) rcmEngineer.mScore += 1;
                            if(c.RecommendedCaseTagsLong__c <> NULL && c.RecommendedCaseTagsLong__c.containsIgnoreCase(str.trim())) rcmEngineer.mScore += 1;
                        }
                    }

                    recommendedEngineers.add(rcmEngineer);
                }
            }
        }

        List<User> recommendedUsers = new List<User>();
        recommendedEngineers.sort();
        if(!recommendedEngineers.isEmpty()){
            system.debug('Recommended Engineer: ');
            system.debug(JSON.serializePretty(recommendedEngineers));
            for(EngineerMatchWrapper engWrp: recommendedEngineers){
                recommendedUsers.add(engWrp.usr);
            }
        }

        List<List<User>> returnedUsers = new List<List<User>>();
        returnedUsers.add(recommendedUsers);

        return returnedUsers;
    }

    public class EngineerMatchWrapper implements Comparable{
        public Integer compareTo(Object objToCompare){            
            return Integer.valueOf(((EngineerMatchWrapper)objToCompare).mScore - mScore);
        }
        
        @auraenabled
        public User usr {get;set;}
        @auraenabled
        public Decimal mScore {get;set;}       
        
        public EngineerMatchWrapper(User myUser) {
            usr = myUser;
            mScore = 0;
        }
    }
}