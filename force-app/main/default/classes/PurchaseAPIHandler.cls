public with sharing class PurchaseAPIHandler { 

   //  Define product code
   public static String getProductCode(String serviceOption, String custodian, String assetManager) {
        Product_Code__mdt productCodeMdt = [SELECT Id, Label, Custodian__c, Service_Option__c, X3_38_Asset_Manager__c
                                            FROM Product_Code__mdt
                                            WHERE Service_Option__c = :serviceOption AND Custodian__c = :custodian AND X3_38_Asset_Manager__c = :assetManager LIMIT 1];
        String productCode = productCodeMdt.Label;
        return productCode;
    }

    //  Define request Age
    public static Integer getRequiredAge(String eligibilityAge) {
        Integer age = eligibilityAge == 'None' ? null : Integer.valueOf(eligibilityAge);
        return age;
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
        mergedSources.addAll(requiredSources);
        mergedSources.addAll(additionalSources);
        return mergedSources;
    }

    // TODO: NEED TO DISCUSS ABOUT THIS LOGIC
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
            enrollmentRateMap.put('maximumAutoDeferralPercentage', String.valueOf(minimumAutoDeferralPercentage));  // NOTE: NEED TO DISCUSS ABOUT THIS LOGIC
            enrollmentRateMap.put('yearlyAutoDeferralPercentageIncrease', '0');                                     // NOTE: NEED TO DISCUSS ABOUT THIS LOGIC
        } else {
            enrollmentRateMap.put('autoDeferralType', null);
            enrollmentRateMap.put('minimumAutoDeferralPercentage', null);
            enrollmentRateMap.put('maximumAutoDeferralPercentage', null);
            enrollmentRateMap.put('yearlyAutoDeferralPercentageIncrease', null);
        }

        return enrollmentRateMap;
    }

    // Portfolio code
    public static String getPortfolioCode(String fundList, String custodian){
        // define Custodian and fund list VALUES in MDT
        Portfolio_Code__mdt portfolioCodeMdt = [SELECT Id, Label, Custodian__c, Fund_List__c
                                FROM Portfolio_Code__mdt
                                WHERE Fund_List__c = :fundList AND Custodian__c = :custodian
                                LIMIT 1];
        String portfolioCode = portfolioCodeMdt.Label;
        return portfolioCode;
    }
}



