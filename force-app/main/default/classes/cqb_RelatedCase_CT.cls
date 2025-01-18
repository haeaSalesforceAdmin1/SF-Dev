global class cqb_RelatedCase_CT {
    @AuraEnabled
    public static void linkCases(String parentId, String[] selectedCases) {
        Map<Id, Case> selectedCasesMap = new Map<Id, Case>([SELECT Id, ParentId FROM Case WHERE Id IN:selectedCases]);

        List<RelatedCase__c> existingRelatedCases = [
                SELECT Case__c, Type__c, RelatedCase__c
                FROM RelatedCase__c
                WHERE Case__c = :parentId AND Type__c = 'related to' AND RelatedCase__c IN:selectedCasesMap.keySet()
        ];
        Set<Id> existRelCasesId = new Set<Id>();
        for (RelatedCase__c relCase : existingRelatedCases) {
            if (!existRelCasesId.contains(relCase.RelatedCase__c)) existRelCasesId.add(relCase.RelatedCase__c);
        }

        List<RelatedCase__c> relatedCasesToInsert = new List<RelatedCase__c>();
        if (!selectedCasesMap.isEmpty()) {
            for (Case c : selectedCasesMap.values()) {
                if (!existRelCasesId.contains(c.Id)) {
                    RelatedCase__c relCase = new RelatedCase__c();
                    relCase.Case__c = parentId;
                    relCase.Type__c = 'related to';
                    relCase.RelatedCase__c = c.Id;
                    relatedCasesToInsert.add(relCase);
                }
            }

            if (!relatedCasesToInsert.isEmpty()) {
                upsert relatedCasesToInsert;
            }
        }
    }

    global class cqbWrapRecord implements Comparable {
        //http://www.jitendrazaa.com/blog/salesforce/how-to-sort-wrapper-class-collection-in-apex/
        global Integer compareTo(Object objToCompare) {
            return Integer.valueOf(((cqbWrapRecord) objToCompare).mScore - mScore);
        }

        @AuraEnabled
        public Case c { get; set; }
        @AuraEnabled
        public Decimal mScore { get; set; }
        @AuraEnabled
        public Decimal mPercent { get; set; }

        public cqbWrapRecord(Case myCase) {
            c = myCase;
            mScore = 0;
        }
    }

    @AuraEnabled
    public static cqbWrapRecord[] getRelatedCasesEnhanced(String recordId) {
        // Hazard Dictionary
        Map<String, List<String>> hazardsDictionary = new Map<String, List<String>>();
        /*Problem with Crash Protection (airbags, seatbelts, etc.)*/
        List<String> crashProtection = new List<String>{
                'airbag', 'air bag', 'deploy', 'seatbelt', 'belt', 'buckle', 'curtain', 'srs', 'webbing', 'unlatched', 'false latched'
        };
        hazardsDictionary.put('Problem with Crash Protection (airbags, seatbelts, etc.)', crashProtection);
        // Exposure to fire/smoke/liquids/toxic vapors/leaks’ 
        List<String> exposureToFire = new List<String>{
                'fire', 'smoke', 'melt', 'burn', 'explosion', 'leak', 'hecu', 'fuel', 'overheat', 'caught', 'exhaust', 'engine'
        };
        hazardsDictionary.put('Exposure to fire/smoke/liquids/toxic vapors/leaks', exposureToFire);
        // Difficulty with seeing/being seen, hearing/being heard, or detecting something
        List<String> difficultySeeing = new List<String>{
                'inop', 'light', 'camera', 'blower', 'windshield', 'wiper', 'turn signal', 'hvac', 'backup', 'back-up', 'horn', 'lamp'
        };
        hazardsDictionary.put('Difficulty with seeing/being seen, hearing/being heard, or detecting something', difficultySeeing);
        // Difficulty/inability to control direction/path (steering, stability, etc)
        List<String> difficultySteering = new List<String>{
                'steer', 'power', 'loss', 'assist', 'mdps', 'wheel', 'locked', 'fracture', 'control', 'rack', 'coil', 'spring', 'mount', 'strut'
        };
        hazardsDictionary.put('Difficulty/inability to control direction/path (steering, stability, etc.)', difficultySteering);
        // Difficulty/inability to control speed (UA, brakes, traction, LOMP, can't stop, etc.
        List<String> inabilityToControlSpeed = new List<String>{
                'brake', 'engine', 'stall', 'pedal', 'acceleration', 'intermittent', 'unintended', 'UA', 'pump', 'braking', 'start', 'abs'
        };
        hazardsDictionary.put('Difficulty/inability to control speed (UA, brakes, traction, LOMP, can\'t stop, etc.)', inabilityToControlSpeed);
        // Struck/burned/cut/shocked by something from vehicle, including flyoff and road debris
        List<String> struckBySomething = new List<String>{
                'edge', 'door', 'struck', 'charging', 'sharp', 'cut', 'sliced', 'port', 'charger', 'panoramic', 'sunroof', 'sun roof', 'glass', 'shatters', 'wire', 'fuse', 'block', 'handle'
        };
        hazardsDictionary.put('Struck/burned/cut/shocked by something from vehicle, including flyoff and road debris', struckBySomething);
        // Trapped/caught/or ejected from vehicle; including problem with door/hood/gate/window, etc.
        List<String> doorGateTrapped = new List<String>{
                'door', 'window', 'latch', 'emergency', 'release', 'trunk', 'trap', 'lock', 'gate', 'handle', 'tonneau', 'key'
        };
        hazardsDictionary.put('Trapped/caught/or ejected from vehicle; including problem with door/hood/gate/window, etc.', doorGateTrapped);
        // Undesired vehicle movement from stationary – rollaway
        List<String> rollaway = new List<String>{
                'roll', 'park', 'hill', 'foot', 'brake', 'parking', 'shifter'
        };
        hazardsDictionary.put('Undesired vehicle movement from stationary -rollaway.', rollaway);
        // Vehicle-caused distraction
        List<String> distraction = new List<String>{
                'mirror', 'off', 'broke', 'antenna', 'Warning light/message/alert from vehicle', 'light', 'srs', 'airbag', 'dtc', 'passenger', 'resistance', 'short', 'warning', 'circuit', 'ground', 'occupant', 'detection', 'pods', 'communication'
        };
        hazardsDictionary.put('Vehicle-caused distraction', distraction);
        // Problem with Crash Prevention (include active electronics, some ADAS
        List<String> crashPreventionProblem = new List<String>{
                'lane', 'crash', 'assist', 'aeb', 'abs', 'keep', 'oversteer', 'lka', 'adas', 'activation', 'activate', 'following'
        };
        hazardsDictionary.put('Problem with Crash Prevention (include active electronics, some ADAS)', crashPreventionProblem);
        // Cybersecurity issue/attack
        List<String> cybersecurity = new List<String>{
                'Cyber', 'security', 'hack', 'attack'
        };
        hazardsDictionary.put('Cybersecurity issue/attack)', crashPreventionProblem);
        // Problem with existing recall
        List<String> probWithExistRecall = new List<String>{
                'recall', 'coverage', 'warranty'
        };
        hazardsDictionary.put('Problem with existing recall', probWithExistRecall);
        // Quality issue, no known safety concern
        List<String> qualityIssue = new List<String>{
                'quality'
        };
        hazardsDictionary.put('Quality issue, no known safety concern', qualityIssue);

        Integer totalAvailableScore = 68;


        // Skip recommended related cases which are already linked
        List<RelatedCase__c> existingRelatedCases = [SELECT Case__c, Type__c, RelatedCase__c FROM RelatedCase__c WHERE Case__c = :recordId AND Type__c = 'related to'];
        Set<String> existingRelCasesId = new Set<String>();
        for (RelatedCase__c rlCase : existingRelatedCases) {
            existingRelCasesId.add(rlCase.RelatedCase__c);
        }
        List<cqbWrapRecord> relatedCasesWrappers = new List<cqbWrapRecord>();

        // KASO.2023.05.07 복구시 아래 쿼리에서 KASO_VIN__r.Name, Case_Own_Org__c, KASOVINNAME__c 삭제 필요 (1/4)
        Case parentCase = [
                SELECT Id, SCSCaseNumber__c, Subject, Description, MethodofRepair__c, PossiblyAssociablePrimaryHazard__c,
                        CategoryofComponentAffected__c, Trans__c, Engine__c, Drivetrain__c, ModelCode__c, VehicleModel__c, MY__c,
                        CreatedDate,Status, Severity__c, Make__c, VIN__r.Name,RecordType.DeveloperName, VIN_Text_Field__c, KASO_VIN__r.Name, Case_Own_Org__c, KASO_VIN__r.KASOVINNAME__c
                FROM Case
                WHERE Id = :recordId
        ];

        // KASO.2023.05.07 복구시 아래 쿼리에서 KASO_VIN__r.Name, Case_Own_Org__c, KASOVINNAME__c 삭제 필요 (2/4)
        List<Case> allCases = [


                SELECT
                        Id,
                        SCSCaseNumber__c, Subject, Description, MethodofRepair__c, PossiblyAssociablePrimaryHazard__c,
                        CategoryofComponentAffected__c, Trans__c, Engine__c, Drivetrain__c, ModelCode__c, VehicleModel__c, MY__c,
                        CreatedDate, Severity__c, Make__c,Status, VIN__r.Name,RecordType.DeveloperName, VIN_Text_Field__c, KASO_VIN__r.Name, Case_Own_Org__c, KASO_VIN__r.KASOVINNAME__c
                FROM Case
                WHERE Id NOT IN:existingRelCasesId
                AND (NOT SCSCaseNumber__c LIKE 'NLPLOADN%')
                ORDER BY CreatedDate DESC
        ];

        System.debug('ALL CASES:: ' + allCases.size());
        for (Case childCase : allCases) {
            if (childCase.Id == parentCase.Id) {
                continue;
            }

           
            // KASO.2023.05.07 복구시 아래 if 문 주석 처리 필요 (3/4)
            String baseCaseVin = '';
            String relatedCaseVin = '';
            
            if(childCase.Case_Own_Org__c.containsIgnoreCase('KASO')) {
                baseCaseVin = parentCase.KASO_VIN__r.Name <> null ? parentCase.KASO_VIN__r.KASOVINNAME__c : parentCase.VIN_Text_Field__c;
                relatedCaseVin = childCase.KASO_VIN__r.Name <> null ? childCase.KASO_VIN__r.KASOVINNAME__c : childCase.VIN_Text_Field__c;
            } else {
                baseCaseVin = parentCase.VIN__r.Name <> null ? parentCase.VIN__r.Name : parentCase.VIN_Text_Field__c;
                relatedCaseVin = childCase.VIN__r.Name <> null ? childCase.VIN__r.Name : childCase.VIN_Text_Field__c;
            }


            // KASO.2023.05.07 복구시 아래 주석 제거 필요 (4/4)
            //String baseCaseVin = parentCase.VIN__r.Name <> null ? parentCase.VIN__r.Name : parentCase.VIN_Text_Field__c;
            //String relatedCaseVin = childCase.VIN__r.Name <> null ? childCase.VIN__r.Name : childCase.VIN_Text_Field__c;

            cqbWrapRecord currentWrap = new cqbWrapRecord(childCase);

            System.debug('Child Case Number: ' + childCase.SCSCaseNumber__c);
            // Hazard Category Match 
            if (parentCase.PossiblyAssociablePrimaryHazard__c <> null && hazardsDictionary.containsKey(parentCase.PossiblyAssociablePrimaryHazard__c)) {
                String childText = '';
                if (childCase.Subject <> null) childText = childCase.Subject;
                if (childCase.Description <> null) childText += ' ' + childCase.Description;
                if (childCase.MethodofRepair__c <> null) childText += ' ' + childCase.MethodofRepair__c;
                Integer categoryScore = 0;
                for (String categoryVal : hazardsDictionary.get(parentCase.PossiblyAssociablePrimaryHazard__c)) {
                    if (categoryScore >= 25) break;
                    if (childCase.Subject <> null && childCase.Subject.containsIgnoreCase(categoryVal) && categoryScore <= 25) {
                        categoryScore += 5;
                    }
                    if (childCase.Description <> null && childCase.Description.containsIgnoreCase(categoryVal) && categoryScore <= 25) {
                        categoryScore += 5;
                    }
                    if (childCase.MethodofRepair__c <> null && childCase.MethodofRepair__c.containsIgnoreCase(categoryVal) && categoryScore <= 25) {
                        categoryScore += 5;
                    }

                }
                System.debug('Category Score: ' + categoryScore);

                if (categoryScore > 0) currentWrap.mScore += categoryScore;
            }

            // Direct Match of Hazard:  20 pts
            if (parentCase.PossiblyAssociablePrimaryHazard__c <> null && childCase.PossiblyAssociablePrimaryHazard__c <> null &&
                    parentCase.PossiblyAssociablePrimaryHazard__c == childCase.PossiblyAssociablePrimaryHazard__c) {
                currentWrap.mScore += 20;
                System.debug('PossiblyAssociablePrimaryHazard__c is a match + 20');
            }

            // Direct Match of Component:  5 pts
            if (parentCase.CategoryofComponentAffected__c <> null && childCase.CategoryofComponentAffected__c <> null &&
                    parentCase.CategoryofComponentAffected__c == childCase.CategoryofComponentAffected__c) {
                currentWrap.mScore += 5;
                System.debug('CategoryofComponentAffected__c is a match + 5');
            }

            // Direct Match of Transmission:  1 pts ** Multi-Select - Clarify what needs to be done
            if (parentCase.Trans__c <> null && childCase.Trans__c <> null) {
                Set<String> cTransmissions = new Set<String>(childCase.Trans__c.toLowerCase().split(';'));
                Set<String> pTransmissions = new Set<String>(parentCase.Trans__c.toLowerCase().split(';'));
                for (String pValue : pTransmissions) {
                    if (cTransmissions.contains(pValue)) {
                        currentWrap.mScore += 1;
                        System.debug('Transmission is a match + 1');
                        break;
                    }
                }
            }

            // Direct Match of Engine:  1 pts ** Multi-Select - Clarify what needs to be done
            if (parentCase.Engine__c <> null && childCase.Engine__c <> null) {
                Set<String> cEngines = new Set<String>(childCase.Engine__c.toLowerCase().split(';'));
                Set<String> pEngines = new Set<String>(parentCase.Engine__c.toLowerCase().split(';'));
                for (String pValue : pEngines) {
                    if (cEngines.contains(pValue)) {
                        currentWrap.mScore += 1;
                        System.debug('Engine is a match + 1');
                        break;
                    }
                }
            }

            // Direct Match of Drivetrain:  1 pts ** Multi-Select - Clarify what needs to be done
            if (parentCase.Drivetrain__c <> null && childCase.Drivetrain__c <> null) {
                Set<String> cDrivetrains = new Set<String>(childCase.Drivetrain__c.toLowerCase().split(';'));
                Set<String> pDrivetrains = new Set<String>(parentCase.Drivetrain__c.toLowerCase().split(';'));
                for (String pValue : pDrivetrains) {
                    if (cDrivetrains.contains(pValue)) {
                        currentWrap.mScore += 1;
                        System.debug('Drivetrain is a match + 1');
                        break;
                    }
                }
            }

            // Model Code match (Iterative):  5 pts ** Multi-Select - Clarify what needs to be done
            if (parentCase.ModelCode__c <> null && childCase.ModelCode__c <> null) {
                Set<String> cModelCodes = new Set<String>(childCase.ModelCode__c.toLowerCase().split(';'));
                Set<String> pModelCodes = new Set<String>(parentCase.ModelCode__c.toLowerCase().split(';'));
                for (String pValue : pModelCodes) {
                    if (cModelCodes.contains(pValue)) {
                        currentWrap.mScore += 5;
                        System.debug('Model Code is a match + 5');
                        break;
                    }
                }
            }

            // Model Name (Iterative):  5 pts ** Multi-Select - Clarify what needs to be done
            if (parentCase.VehicleModel__c <> null && childCase.VehicleModel__c <> null) {
                Set<String> cModelNames = new Set<String>(childCase.VehicleModel__c.toLowerCase().split(';'));
                Set<String> pModelNames = new Set<String>(parentCase.VehicleModel__c.toLowerCase().split(';'));
                for (String pValue : pModelNames) {
                    if (cModelNames.contains(pValue)) {
                        currentWrap.mScore += 5;
                        System.debug('Model Name is a match + 5');
                        break;
                    }
                }
            }

            // Model year in range match:  5pts  
            //(Note:  if base model year a range then go with that but if base model year a single then +/-2 years
            if (parentCase.MY__c <> null && childCase.MY__c <> null) {
                List<String> cModelYears = childCase.MY__c.toLowerCase().split(';');
                List<String> pModelYears = parentCase.MY__c.toLowerCase().split(';');
                if (pModelYears.size() == 1) {
                    Integer pModelYearInt = Integer.valueOf(pModelYears[0]);

                    pModelYears.add(String.valueOf(pModelYearInt + 1));
                    pModelYears.add(String.valueOf(pModelYearInt + 2));
                    pModelYears.add(String.valueOf(pModelYearInt - 1));
                    pModelYears.add(String.valueOf(pModelYearInt - 2));
                }

                if (cModelYears.size() == 1) {
                    Integer cModelYearInt = Integer.valueOf(cModelYears[0]);
                    cModelYears.add(String.valueOf(cModelYearInt + 1));
                    cModelYears.add(String.valueOf(cModelYearInt + 2));
                    cModelYears.add(String.valueOf(cModelYearInt - 1));
                    cModelYears.add(String.valueOf(cModelYearInt - 2));
                }

                for (String pValue : pModelYears) {
                    if (cModelYears.contains(pValue)) {
                        currentWrap.mScore += 5;
                        System.debug('Model Year is a match + 5');
                        break;
                    }
                }
            }
            if (String.isNotEmpty(baseCaseVin) && String.isNotEmpty(relatedCaseVin) && baseCaseVin == relatedCaseVin) {
                currentWrap.mScore = 68;
            }

            if (currentWrap.mScore > 0) {
                Decimal wrapScore = currentWrap.mScore / totalAvailableScore;
                currentWrap.mPercent = wrapScore.setScale(2) * 100;
                if (currentWrap.mPercent > 100) currentWrap.mPercent = 100;
                relatedCasesWrappers.add(currentWrap);
            }
        }

        //sort list of wrapper objects by score high-low with custom sort method
        relatedCasesWrappers.sort();
        return relatedCasesWrappers;
    }
}