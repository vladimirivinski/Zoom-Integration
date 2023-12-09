public with sharing class PurchaseAPIController {
    public static void getProposal(Id proposalId){
        Proposal__c proposal = [SELECT Id, X3_38__c,
                                        Opportunity__c,
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
                                        Discretionary_Match_Formula__c,
                                        Restatement_Date__c,
                                        TPA_EIN__c
                                FROM Proposal__c
                                WHERE Id = :proposalId
                                WITH SECURITY_ENFORCED
                                LIMIT 1 ];

        String result = processProposals(proposal);
        System.debug('result: ' + result);

    }

    public static String processProposals(Proposal__c prop){

        String productCode = PurchaseAPIHandler.getProductCode(prop.Service_Option__c, prop.Custodian__c, prop.x3_38__c);
        Integer year = PurchaseAPIHelper.getRequiredAge(prop.Eligibility_Age__c);
        String stateCode = PurchaseAPIHelper.getStateCode(prop.Company_State__c);
        Map<String, String> enrollmentRateMap = PurchaseAPIHandler.getEnrollmentRate(prop.Auto_Enrollment_Deferral_Escalation_Rate__c);
        String portfolioCode = PurchaseAPIHandler.getPortfolioCode(prop.Fund_List__c, prop.Custodian__c);
        List<AddSources__mdt> sourcesList = PurchaseAPIHandler.getSources(prop.Roth_Contributions__c, prop.Safe_Harbor__c, prop.Discretionary_Match__c, prop.Discretionary_Match_Formula__c);

        // List<Contact> contacts = PurchaseAPIHandler.getAdvisor(prop.Id);

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
            addSource.vestingId             = PurchaseAPIHandler.getVesting(prop.Profit_Sharing_Match_Vesting_Schedule__c);
            addSource.age                   = age;
            addSource.entry                 = prop.Plan_Entry_Frequency__c;
            addSource.serviceEligibility    = prop.Plan_Eligibility__c;
            addSource.planSourceFrequency   = 'PAYROLL';
            addSource.effectiveDate         = null;                                         // Date in format 2023-07-12 NEED TO WORK ON THIS!!!!!!!!
            addSource.formula               = null;                                         // DO we need this formula????
            addSource.included              = false;                                        // NOTE16:   NEED TO WORK ON THIS!!!!!!!!
            addSource.grandfatherDate       = PurchaseAPIHelper.getFormateDate(prop.Grandfather_Date__c); // Date in format 2023-07-12
            addSourcesList.add(addSource);
        }

        // ===================ATTRIBUTES===================
        List<Attributes> attributesList = new List<Attributes>();
        Attributes attribute = new Attributes();
        attribute.key = null;
        attribute.value = null;

        // ===================ADVISOR===================
        Advisor advisor = new Advisor();
        advisor.advisorFeeCollectionSource  = null; // NOTE18:   [ NONE, BROKER_12B_1, INVOICE, DIRECT, ASSETS ]
        advisor.fixedAmount                 = null;
        advisor.bpsAmount                   = null;
        advisor.requireReview               = null;
        advisor.advisorNpn                  = null;
        advisor.advisorCrd                  = null;

        // ===================TPA===================
        TPA tpa = new TPA();
        tpa.feeCollectionSource = null;
        tpa.fixedAmount         = null;
        tpa.bpsAmount           = null;
        tpa.disbursedByUbiquity = null;
        tpa.tpaEin              = prop.TPA_EIN__c;




        // ===================PAYLOAD===================

        purchPayload.productCode                    = productCode;
        purchPayload.entry                          = PurchaseAPIHelper.convertPlanEntryFrequency(prop.Plan_Entry_Frequency__c);
        purchPayload.serviceEligibility             = PurchaseAPIHelper.convertPlanEligibility(prop.Plan_Eligibility__c);
        purchPayload.allowsLoans                    = prop.Loans__c == 'Yes' ? true : (prop.Loans__c == 'No' ? false : null);
        purchPayload.allowsHardshipWithdrawals      = prop.Hardships__c == 'Yes' ? true : (prop.Hardships__c == 'No' ? false : null);
        purchPayload.autoEnrollmentType             = prop.Auto_Enrollment__c == 'None' ? null : prop.Auto_Enrollment__c;
        purchPayload.numberOfEmployees              = Integer.valueOf(prop.Number_of_Employees__c);     // REQUIRED FIELD
        purchPayload.companyName                    = prop.Client_Company_Name__c;                      // REQUIRED FIELD
        purchPayload.planName                       = prop.Plan_Name__c;                                // NOTE5: ?????
        purchPayload.irsPlanNumber                  = prop.Plan_Number__c;
        purchPayload.companyPhone                   = prop.Contact_Phone_Number__c;                     // REQUIRED FIELD
        purchPayload.sponsorFirstName               = prop.Company_Contact_First_Name__c;               // REQUIRED FIELD
        purchPayload.sponsorLastName                = prop.Company_Contact_Last_Name__c;                // REQUIRED FIELD
        purchPayload.sponsorEmail                   = prop.Company_Email__c;                            // REQUIRED FIELD
        purchPayload.stateCode                      = PurchaseAPIHelper.getStateCode(stateCode);        // REQUIRED FIELD   ONLY 2 characters
        purchPayload.planId                         = null;                                             // always NULL??
        purchPayload.planEffectiveDate              = PurchaseAPIHelper.getFormateDate(prop.Plan_Effective_Date__c); // format yyyy-MM-dd
        purchPayload.autoDeferralType               = enrollmentRateMap.get('autoDeferralType');        // Escalating, Flat
        purchPayload.eligibilityCalculationMethod   = 'ELAPSED_TIME';
        purchPayload.portfolioCode                  = portfolioCode;                                    // NOTE10: NEED TO ANALYZE
        purchPayload.pepCode                        = null;                                             // NOTE11:   ALWAYS NULL??????
        purchPayload.minimumAutoDeferralPercentage  = Integer.valueOf(enrollmentRateMap.get('minimumAutoDeferralPercentage'));
        purchPayload.maximumAutoDeferralPercentage  = Integer.valueOf(enrollmentRateMap.get('maximumAutoDeferralPercentage'));
        purchPayload.yearlyAutoDeferralPercentageIncrease = Integer.valueOf(enrollmentRateMap.get('yearlyAutoDeferralPercentageIncrease'));
        purchPayload.addSources                     = addSourcesList;
        purchPayload.attributes                     = attributesList;                                   // ALWAYS NULL????
        purchPayload.employerPaidParticipantFees    = prop.Participant_Fee_Payment__c == 'Employer' ? true : (prop.Participant_Fee_Payment__c == 'Employee' ? false : null);


        String resultJSONPayload = JSON.serialize(purchPayload);
        return resultJSONPayload;
    }

    public class PurchasePayload {
        public String productCode { get; set; }
        public Age requiredAge { get; set; }
        public String entry { get; set; }                   // [ DAILY, MONTHLY, QUARTERLY, SEMI_ANNUALLY, ANNUALLY, OTHER ]
        public String serviceEligibility { get; set; }      // [ IMMEDIATE, ONE_MONTH, TWO_MONTHS, THREE_MONTHS, SIX_MONTHS, TWELVE_MONTHS, ONE_YEAR_HOURS ]
        public List<Sources> sources { get; set; }          // Don't use this Object
        public Boolean allowsLoans { get; set; }
        public Boolean allowsHardshipWithdrawals { get; set; }
        public String autoEnrollmentType { get; set; }      // [ ACA, EACA, QACA ]
        public Integer numberOfEmployees { get; set; }      // *REQUIRED FIELD
        public String companyName { get; set; }             // *REQUIRED FIELD
        public String planName { get; set; }
        public String irsPlanNumber { get; set; }
        public String companyPhone { get; set; }            // *REQUIRED FIELD
        public String sponsorFirstName { get;set; }         // *REQUIRED FIELD
        public String sponsorLastName { get;set; }          // *REQUIRED FIELD
        public String sponsorEmail { get;set; }             // *REQUIRED FIELD
        public String stateCode { get;set; }                // *REQUIRED FIELD   2 characters
        public Integer planId { get; set; }
        public String planEffectiveDate { get; set; }       // Date in format yyyy-MM-dd
        public String autoDeferralType { get; set; }        // NOTE7: [ ESCALATING, FLAT ]
        public String eligibilityCalculationMethod { get; set; } // NOTE9:[ ELAPSED_TIME, HOURS ]
        public String portfolioCode { get; set; }           // NOTE10: NEED TO ANALYZE
        public String pepCode { get; set; }                 // NOTE11:   ????
        public Integer minimumAutoDeferralPercentage { get; set; }
        public Integer maximumAutoDeferralPercentage { get; set; }
        public Integer yearlyAutoDeferralPercentageIncrease { get; set; }
        public List<AddSources> addSources { get; set; }

        public List<Attributes> attributes { get; set; }    // ALWAYS NULL????
        public Advisor advisor { get; set; }

        public Boolean employerPaidParticipantFees { get; set; }

        public TPA tpa { get; set; }
    }

    public class Age {
        public Integer month { get; set; }
        public Integer year { get; set; }
    }

    public class Sources {
        public Integer id { get; set; }
        public String name { get; set; }
        public String sourceType { get; set; }             // [ DEFERRAL, LOAN, MATCH, PROFIT, RELATED_ROLLOVER, ROLLOVER, SAFE, QMAC, QNEC ]
        public String contributorType { get; set; }        // [ EMPLOYEE, EMPLOYER, LOAN ]
        public Integer vestingId { get; set; }
        public Age age { get; set; }
        public String entry { get; set; }                  // [ DAILY, MONTHLY, QUARTERLY, SEMI_ANNUALLY, ANNUALLY, OTHER ]
        public String serviceEligibility { get; set; }     // [ IMMEDIATE, ONE_MONTH, TWO_MONTHS, THREE_MONTHS, SIX_MONTHS, TWELVE_MONTHS, ONE_YEAR_HOURS ]
        public String planSourceFrequency { get; set; }    // [ PAYROLL, ANNUAL ]
        public String effectiveDate { get; set; }          // Date in format yyyy-MM-dd
        public String formula { get; set; }
        public Boolean included { get; set; }
        public String grandfatherDate { get; set; }        // Date in format yyyy-MM-dd
    }

    public class AddSources {
        public Integer id { get; set; }
        public String name { get; set; }
        public String sourceType { get; set; }             // [ DEFERRAL, LOAN, MATCH, PROFIT, RELATED_ROLLOVER, ROLLOVER, SAFE, QMAC, QNEC ]
        public String contributorType { get; set; }        // [ EMPLOYEE, EMPLOYER, LOAN ]
        public Integer vestingId { get; set; }
        public Age age { get; set; }
        public String entry { get; set; }                  // [ DAILY, MONTHLY, QUARTERLY, SEMI_ANNUALLY, ANNUALLY, OTHER ]
        public String serviceEligibility { get; set; }     // [ IMMEDIATE, ONE_MONTH, TWO_MONTHS, THREE_MONTHS, SIX_MONTHS, TWELVE_MONTHS, ONE_YEAR_HOURS ]
        public String planSourceFrequency { get; set; }    // [ PAYROLL, ANNUAL ]
        public String effectiveDate { get; set; }          // Date in format yyyy-MM-dd
        public String formula { get; set; }
        public Boolean included { get; set; }
        public String grandfatherDate { get; set; }        // Date in format yyyy-MM-dd
    }

    public class Attributes {
        public String key { get; set; }
        public String value { get; set; }
    }

    public class Advisor {
        public String advisorFeeCollectionSource  { get; set; } // NOTE18:   [ NONE, BROKER_12B_1, INVOICE, DIRECT, ASSETS ]
        public Integer fixedAmount { get; set; }
        public Integer bpsAmount { get; set; }
        public Boolean requireReview { get; set; }
        public String advisorNpn { get; set; }
        public String advisorCrd { get; set; }
    }

    public class TPA {
        public String feeCollectionSource { get;set; }
        public Integer fixedAmount { get;set; }
        public Integer bpsAmount { get;set; }
        public Boolean disbursedByUbiquity { get;set; }
        public String tpaEin { get;set; }
        public ProcessingFees processingFees { get;set; }
        public List<Users> users { get;set; }
    }

    public class ProcessingFees {
        public String feeType { get;set; }
        public Integer amount { get;set; }
    }

    public class Users {
        public String email { get;set; }
        public String roles { get;set; }
    }

}

