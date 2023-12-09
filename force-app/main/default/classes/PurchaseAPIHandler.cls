public with sharing class PurchaseAPIHandler {

   //  Define product code
   public static String getProductCode(String serviceOption, String custodian, String assetManager) {
        List<Product_Code__mdt> productCodeMdt = [SELECT Id, Label, Custodian__c, Service_Option__c, X3_38_Asset_Manager__c
                                                  FROM Product_Code__mdt
                                                  WHERE Service_Option__c = :serviceOption AND Custodian__c = :custodian AND X3_38_Asset_Manager__c = :assetManager LIMIT 1];
        return !productCodeMdt.isEmpty() ? productCodeMdt[0].Label : null;
    }

    //  Merge Sources List
    public static List<AddSources__mdt> getSources(String rothContributions, String safeHarbor, String discretionaryMatch, String discretionaryMatchFormula){
        List<AddSources__mdt> requiredSources = [SELECT Id, Label, SourceId__c,
                                                        SourceType__c,
                                                        Safe_Harbor__c,
                                                        ContributorType__c,
                                                        Roth_Contributions__c,
                                                        Discretionary_Match__c,
                                                        Discretionary_Match_Formula__c,
                                                        Formula__c,
                                                        isRequired__c
                                                FROM AddSources__mdt
                                                WHERE isRequired__c = true];

        List<AddSources__mdt> additionalSources = [SELECT Id, Label, SourceId__c,
                                                            SourceType__c,
                                                            Safe_Harbor__c,
                                                            ContributorType__c,
                                                            Roth_Contributions__c,
                                                            Discretionary_Match__c,
                                                            Discretionary_Match_Formula__c,
                                                            Formula__c,
                                                            isRequired__c
                                                    FROM AddSources__mdt
                                                    WHERE isRequired__c = false AND
                                                          Safe_Harbor__c = :safeHarbor AND
                                                          Roth_Contributions__c = :rothContributions AND
                                                          Discretionary_Match__c = :discretionaryMatch AND
                                                          Discretionary_Match_Formula__c = :discretionaryMatchFormula];


        List<AddSources__mdt> mergedSources = new List<AddSources__mdt>();
        if (!requiredSources.isEmpty()) {
            mergedSources.addAll(requiredSources);
        }

        if (!additionalSources.isEmpty()) {
            for (AddSources__mdt additionalSource : additionalSources) {
                if (!mergedSources.contains(additionalSource)) {
                    mergedSources.add(additionalSource);
                }
            }
        }
        return mergedSources;
    }

    // Portfolio code
    public static String getPortfolioCode(String fundList, String custodian){
        // define Custodian and fund list VALUES in MDT
        List<Portfolio_Code__mdt> portfolioCodeMdt = [SELECT Id, Label, Custodian__c, Fund_List__c
                                FROM Portfolio_Code__mdt
                                WHERE Fund_List__c = :fundList AND Custodian__c = :custodian
                                LIMIT 1];
        return !portfolioCodeMdt.isEmpty() ? portfolioCodeMdt[0].Label : null;
    }

    public static Integer getVesting(String vesting){
        List<Vesting_Id__mdt> vestingMdtList = [SELECT Id, Label, Profit_Sharing_Match_Vesting_Schedule__c, Id__c
                                        FROM Vesting_Id__mdt
                                        WHERE Profit_Sharing_Match_Vesting_Schedule__c = :vesting
                                        LIMIT 1];
        return !vestingMdtList.isEmpty() ? Integer.valueOf(vestingMdtList[0].Id__c) : null;
    }

    //  Define Enrollment Rate
    public static Map<String, String> getEnrollmentRate(String enrollmentRate){
        Map<String, String> enrollmentRateMap = new Map<String, String>();
        String autoDeferralType = enrollmentRate.contains('Escalate') ? 'ESCALATING' : (enrollmentRate.contains('Flat') ? 'FLAT' : null);
        Integer minimumAutoDeferralPercentage = Integer.valueOf(enrollmentRate.split(' ')[0].replace('%', ''));
        if(autoDeferralType == 'ESCALATING'){
            enrollmentRateMap.put('autoDeferralType', autoDeferralType);
            enrollmentRateMap.put('minimumAutoDeferralPercentage', String.valueOf(minimumAutoDeferralPercentage));
            enrollmentRateMap.put('maximumAutoDeferralPercentage', '10');
            enrollmentRateMap.put('yearlyAutoDeferralPercentageIncrease', '1');
        } else if (autoDeferralType == 'FLAT'){
            enrollmentRateMap.put('autoDeferralType', autoDeferralType);
            enrollmentRateMap.put('minimumAutoDeferralPercentage', String.valueOf(minimumAutoDeferralPercentage));
            enrollmentRateMap.put('maximumAutoDeferralPercentage', String.valueOf(minimumAutoDeferralPercentage));
            enrollmentRateMap.put('yearlyAutoDeferralPercentageIncrease', '0');
        } else {
            enrollmentRateMap.put('autoDeferralType', null);
            enrollmentRateMap.put('minimumAutoDeferralPercentage', null);
            enrollmentRateMap.put('maximumAutoDeferralPercentage', null);
            enrollmentRateMap.put('yearlyAutoDeferralPercentageIncrease', null);
        }
        return enrollmentRateMap;
    }

// 006Dw00000OEeKYIA1
    // public static Map<String, Associated_Contact__c> getAssosiatedContacts(String oppId){
    //     Map<String, Associated_Contact__c> associatedContactsMap = new Map<String, Associated_Contact__c>();
    //     List<Associated_Contact__c> associatedContacts = [SELECT Id, Name, Contact__c, Opportunity__c, Contact_Role__c,
    //                                                             Contact__r.NPN_Number__c,
    //                                                             Contact__r.Advisor_CRD__c
    //                                                         FROM Associated_Contact__c
    //                                                         WHERE Opportunity__c = :oppId AND Contact_Role__c = null];
    //     if(!associatedContacts.isEmpty()){
    //         for(Associated_Contact__c associatedContact : associatedContacts){
    //             associatedContactsMap.put(associatedContact.Contact_Role__c, associatedContact);
    //         }
    //     }


    }
}
