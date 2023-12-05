public with sharing class PurchaseAPIController {
    public static void getProposal(Id proposalId){
        Proposal__c proposal = [SELECT Id, X3_38__c,
                                        Service_Option__c,
                                        Auto_Enrollment__c,
                                        Auto_Enrollment_Deferral_Escalation_Rate__c,
                                        Client_Company_Name__c,
                                        Plan_Name__c,
                                        Company_Contact_First_Name__c,
                                        Company_Contact_Last_Name__c,
                                        Company_Email__c,
                                        Company_State__c,
                                        Contact_Phone_Number__c,
                                        Custodian__c,
                                        Discretionary_Match__c,
                                        Discretionary_Match_Formula_Notes__c,
                                        Eligibility_Age__c,
                                        Fund_List__c,
                                        Grandfather_Date__c,
                                        Hardships__c,
                                        Loans__c,
                                        Number_of_Employees__c,
                                        Participant_Fee_Payment__c,
                                        Plan_Effective_Date__c,
                                        Plan_Eligibility__c,
                                        Plan_Entry_Frequency__c,
                                        Plan_Type__c,
                                        Profit_Sharing__c,
                                        Profit_Sharing_Match_Vesting_Schedule__c,
                                        QACA_Safe_Harbor_Vesting_Schedule__c,
                                        Roth_Contributions__c,
                                        Safe_Harbor__c,
                                        Safe_Harbor_Match_Determination_Period__c,
                                        Original_Effective_Date__c,
                                        Plan_Number__c,
                                        Restatement_Date__c
                                FROM Proposal__c
                                WHERE Id = :proposalId
                                WITH SECURITY_ENFORCED
                                LIMIT 1 ];

        processProposals(proposal);
    }

    public static String processProposals(Proposal__c prop){

        String productCode = PurchaseAPIHandler.getProductCode(prop.Service_Option__c, prop.Custodian__c, prop.x3_38__c);
        Integer year = PurchaseAPIHandler.getRequiredAge(prop.Eligibility_Age__c);
        String stateCode = PurchaseAPIHelper.getStateCode(prop.Company_State__c);
        Map<String, String> enrollmentRateMap = PurchaseAPIHandler.getEnrollmentRate(prop.Auto_Enrollment_Deferral_Escalation_Rate__c);
        String portfolioCode = PurchaseAPIHandler.getPortfolioCode(prop.Fund_List__c, prop.Custodian__c);
        List<AddSources__mdt> sourcesList = PurchaseAPIHandler.getSources(prop.Roth_Contributions__c, prop.Safe_Harbor__c, prop.Discretionary_Match__c, prop.Discretionary_Match_Formula__c);

        PurchasePayload purchPayload = new PurchasePayload();

        // ===================AGE===========================
        Age age = new Age();
        age.year = year;
        age.month = year == null ? null : 0;
        purchPayload.requiredAge = age;

        // ===================ADD SOURCES===================
        List<AddSources> addSourcesList = new List<AddSources>();
        for(AddSources__mdt source : sourcesList){
            AddSources addSource = new AddSources();
            addSource.id                    = Integer.valueOf(source.SourceId__c);
            addSource.name                  = source.Label;
            addSource.sourceType            = source.SourceType__c;
            addSource.contributorType       = source.ContributorType__c;
            addSource.vestingId             = Integer.valueOf(prop.Profit_Sharing_Match_Vesting_Schedule__c); // NOTE14:   NEED TO WORK ON THIS!!!!!!!! APENDIX D
            addSource.age                   = age;
            addSource.entry                 = prop.Plan_Entry_Frequency__c;                 // NOTE1: Immediate, Monthly, Quarterly, Semi-Annually !!! CHECK VALUES
            addSource.serviceEligibility    = prop.Plan_Eligibility__c;                     // NOTE2: Immediate, One Month, Two Months, Three Months, 6 Months, 1 Year (1000 Hours), 90 Day, 1 Year, 12 Months Elapsed Time,
            addSource.planSourceFrequency   = 'PAYROLL';                                    // NOTE15:   NEED TO WORK ON THIS!!!!!!!!
            addSource.effectiveDate         = null;                                         // Date in format 2023-07-12 NEED TO WORK ON THIS!!!!!!!!
            addSource.formula               = null;                                         // NOTE13:   DO we need this formula????
            addSource.included              = false;                                        // NOTE16:   NEED TO WORK ON THIS!!!!!!!!
            addSource.grandfatherDate       = String.valueOfGmt(prop.Grandfather_Date__c);  // CHECK FORMAT !!!!!! Date in format 2023-07-12
            addSourcesList.add(addSource);
        }

        // ===================PAYLOAD===================

        purchPayload.productCode                    = productCode;
        purchPayload.entry                          = prop.Plan_Entry_Frequency__c;                     // NOTE1: Immediate, Monthly, Quarterly, Semi-Annually !!!
        purchPayload.serviceEligibility             = prop.Plan_Eligibility__c;                         // NOTE2: Immediate, One Month, Two Months, Three Months, 6 Months, 1 Year (1000 Hours), 90 Day, 1 Year, 12 Months Elapsed Time,
        purchPayload.allowsLoans                    = prop.Loans__c == 'Yes' ? true : (prop.Loans__c == 'No' ? false : null);
        purchPayload.allowsHardshipWithdrawals      = prop.Hardships__c == 'Yes' ? true : (prop.Hardships__c == 'No' ? false : null);
        purchPayload.autoEnrollmentType             = prop.Auto_Enrollment__c == 'None' ? null : prop.Auto_Enrollment__c;   // NOTE4: None, EACA, QACA | Using ONLY QACA for now
        purchPayload.numberOfEmployees              = Integer.valueOf(prop.Number_of_Employees__c);                      // REQUIRED FIELD
        purchPayload.companyName                    = prop.Client_Company_Name__c;                      // REQUIRED FIELD
        purchPayload.planName                       = prop.Plan_Name__c;                                // NOTE5: ?????
        purchPayload.irsPlanNumber                  = prop.Plan_Number__c;
        purchPayload.companyPhone                   = prop.Contact_Phone_Number__c;                     // REQUIRED FIELD
        purchPayload.sponsorFirstName               = prop.Company_Contact_First_Name__c;               // REQUIRED FIELD
        purchPayload.sponsorLastName                = prop.Company_Contact_Last_Name__c;                // REQUIRED FIELD
        purchPayload.sponsorEmail                   = prop.Company_Email__c;                            // REQUIRED FIELD
        purchPayload.stateCode                      = stateCode;                                        // NOTE8: ONLY 2 characters !!!! REQUIRED FIELD
        purchPayload.planId                         = null;                                             // NOTE6: is this field always NULL??
        purchPayload.planEffectiveDate              = String.valueOfGmt(prop.Plan_Effective_Date__c);   // CHECK FORMAT !!!!!! Date in format 2023-07-12
        purchPayload.autoDeferralType               = enrollmentRateMap.get('autoDeferralType');        // NOTE7: Escalating, Flat
        purchPayload.eligibilityCalculationMethod   = 'ELAPSED_TIME';                                   // NOTE9:  Always Elapsed Time
        purchPayload.portfolioCode                  = portfolioCode;                                    // NOTE10: NEED TO ANALYZE
        purchPayload.pepCode                        = null;                                             // NOTE11:   ALWAYS NULL??????
        purchPayload.minimumAutoDeferralPercentage  = Integer.valueOf(enrollmentRateMap.get('minimumAutoDeferralPercentage'));                     // NOTE12:   MOCK DATA????
        purchPayload.maximumAutoDeferralPercentage  = Integer.valueOf(enrollmentRateMap.get('maximumAutoDeferralPercentage'));                     // NOTE12:   MOCK DATA????
        purchPayload.yearlyAutoDeferralPercentageIncrease = Integer.valueOf(enrollmentRateMap.get('yearlyAutoDeferralPercentageIncrease'));        // NOTE12:   MOCK DATA????
        purchPayload.addSources                     = addSourcesList;


        String resultJSONPayload = JSON.serialize(purchPayload);
        return resultJSONPayload;
    }

    public class PurchasePayload {
        public String productCode { get; set; }
        public Age requiredAge { get; set; }
        public String entry { get; set; }                   // NOTE1: [ DAILY, MONTHLY, QUARTERLY, SEMI_ANNUALLY, ANNUALLY, OTHER ]
        public String serviceEligibility { get; set; }      // NOTE2: [ IMMEDIATE, ONE_MONTH, TWO_MONTHS, THREE_MONTHS, SIX_MONTHS, TWELVE_MONTHS, ONE_YEAR_HOURS ]
        public List<Sources> sources { get; set; }          // NOTE3: Don't use this Object
        public Boolean allowsLoans { get; set; }
        public Boolean allowsHardshipWithdrawals { get; set; }
        public String autoEnrollmentType { get; set; }      // NOTE4: [ ACA, EACA, QACA ]
        public Integer numberOfEmployees { get; set; }      // REQUIRED FIELD
        public String companyName { get; set; }             // REQUIRED FIELD
        public String planName { get; set; }
        public String irsPlanNumber { get; set; }
        public String companyPhone { get; set; }            // REQUIRED FIELD
        public String sponsorFirstName { get;set; }         // REQUIRED FIELD
        public String sponsorLastName { get;set; }          // REQUIRED FIELD
        public String sponsorEmail { get;set; }             // REQUIRED FIELD
        public String stateCode { get;set; }                // NOTE8: ONLY 2 characters !!!! REQUIRED FIELD
        public Integer planId { get; set; }
        public String planEffectiveDate { get; set; }       // Date in format yyyy-MM-dd
        public String autoDeferralType { get; set; }        // NOTE7: [ ESCALATING, FLAT ]
        public String eligibilityCalculationMethod { get; set; } // NOTE9:[ ELAPSED_TIME, HOURS ]
        public String portfolioCode { get; set; }           // NOTE10: NEED TO ANALYZE
        public String pepCode { get; set; }                 // NOTE11:   ????
        public Integer minimumAutoDeferralPercentage { get; set; }              // NOTE12:   ????
        public Integer maximumAutoDeferralPercentage { get; set; }              // NOTE12:   ????
        public Integer yearlyAutoDeferralPercentageIncrease { get; set; }       // NOTE12:   ????
        public List<AddSources> addSources { get; set; }
    }

    public class Age {
        public Integer month { get; set; }
        public Integer year { get; set; }
    }

    public class Sources {
        public Integer id { get; set; }
        public String name { get; set; }
        public String sourceType { get; set; }             // DEFERRAL, LOAN, MATCH, PROFIT, RELATED_ROLLOVER, ROLLOVER, SAFE, QMAC, QNEC
        public String contributorType { get; set; }        // EMPLOYEE, EMPLOYER, LOAN
        public Integer vestingId { get; set; }
        public Age age { get; set; }
        public String entry { get; set; }                  // DAILY, MONTHLY, QUARTERLY, SEMI_ANNUALLY, ANNUALLY, OTHER
        public String serviceEligibility { get; set; }     // IMMEDIATE, ONE_MONTH, TWO_MONTHS, THREE_MONTHS, SIX_MONTHS, TWELVE_MONTHS, ONE_YEAR_HOURS
        public String planSourceFrequency { get; set; }    // PAYROLL, ANNUAL
        public String effectiveDate { get; set; }          // Date in format yyyy-MM-dd
        public String formula { get; set; }
        public Boolean included { get; set; }
        public String grandfatherDate { get; set; }        // Date in format yyyy-MM-dd
    }

    public class AddSources {
        public Integer id { get; set; }
        public String name { get; set; }
        public String sourceType { get; set; }             // DEFERRAL, LOAN, MATCH, PROFIT, RELATED_ROLLOVER, ROLLOVER, SAFE, QMAC, QNEC
        public String contributorType { get; set; }        // EMPLOYEE, EMPLOYER, LOAN
        public Integer vestingId { get; set; }
        public Age age { get; set; }
        public String entry { get; set; }                  // DAILY, MONTHLY, QUARTERLY, SEMI_ANNUALLY, ANNUALLY, OTHER
        public String serviceEligibility { get; set; }     // IMMEDIATE, ONE_MONTH, TWO_MONTHS, THREE_MONTHS, SIX_MONTHS, TWELVE_MONTHS, ONE_YEAR_HOURS
        public String planSourceFrequency { get; set; }    // PAYROLL, ANNUAL
        public String effectiveDate { get; set; }          // Date in format yyyy-MM-dd
        public String formula { get; set; }
        public Boolean included { get; set; }
        public String grandfatherDate { get; set; }        // Date in format yyyy-MM-dd
    }

}