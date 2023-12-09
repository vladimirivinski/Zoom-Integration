List<Proposal__c> proposalList = [SELECT Id,
                                        Name,
                                        X3_38__c,
                                        Client_Company_Name__c,
                                        Company_Contact_First_Name__c,
                                        Company_Contact_Last_Name__c,
                                        Company_Email__c,
                                        Company_State__c,
                                        Number_of_Employees__c,
                                        Contact_Phone_Number__c,
                                        Eligibility_Age__c,
                                        Grandfather_Date__c,
                                        Hardships__c,
                                        Loans__c,
                                        Participant_Fee_Payment__c,
                                        Plan_Eligibility__c,
                                        Plan_ID__c,
                                        Plan_Name__c,
                                        Plan_Entry_Frequency__c,
                                        Plan_Type__c,
                                        Profit_Sharing__c,
                                        Roth_Contributions__c,
                                        Safe_Harbor__c,
                                        Original_Effective_Date__c,
                                        Plan_Number__c,
                                        Restatement_Date__c,
                                        Previously_Sponsored_401_k_Plan__c,
                                        Current_Recent_SIMPLE_Plan__c,
                                        Auto_Enrollment__c,
                                        Product_Type__c,
                                        Service_Option__c,
                                        Auto_Enrollment_Deferral_Escalation_Rate__c,
                                        Profit_Sharing_Match_Vesting_Schedule__c,
                                        Safe_Harbor_Match_Determination_Period__c,
                                        QACA_Safe_Harbor_Vesting_Schedule__c,
                                        Brokerage_Accounts_PCRA__c,
                                        Custodian__c,
                                        Fund_List__c,
                                        Discretionary_Match__c,
                                        TPA_EIN__c,
                                        TPA_Firm_Name__c,
                                        Advisor_NPN__c,
                                        Advisor_CRD__c,
                                        Financial_Professional_Role__c
                                FROM Proposal__c];

Proposal__c prop = new Proposal__c();

    prop.Client_Company_Name__c = 'Test Company Name';
    prop.Company_Contact_First_Name__c = 'Test First Name';
    prop.Company_Contact_Last_Name__c = 'Test Last Name';
    prop.Company_Email__c = 'testcompany@gmail.com';
    prop.Company_State__c = 'CA';
    prop.Number_of_Employees__c = 100;
    prop.Contact_Phone_Number__c = '1234567890';
    prop.Eligibility_Age__c = '21';
    prop.Grandfather_Date__c = Date.newInstance(2016, 1, 1);
    prop.Hardships__c = 'Yes';
    prop.Loans__c = 'Yes';
    prop.Participant_Fee_Payment__c = 'Employee';
    prop.Plan_Eligibility__c = 'Immediate';
    prop.Plan_ID__c = '123456';
    prop.Plan_Name__c = 'Test Plan Name';
    prop.Plan_Entry_Frequency__c = 'Monthly';
    prop.Plan_Type__c = 'New Plan';
    prop.Profit_Sharing__c = 'Pro Rata';
    prop.Roth_Contributions__c = null;
    
    prop.Original_Effective_Date__c = Date.newInstance(2016, 1, 1);
    prop.Plan_Number__c = '1234';
    prop.Restatement_Date__c = Date.newInstance(2016, 1, 1);
    prop.Previously_Sponsored_401_k_Plan__c = 'Yes';
    prop.Current_Recent_SIMPLE_Plan__c = 'Yes';

    // Product Code ---- sscensiblyyours
    prop.Service_Option__c = 'Saver(k)';
    prop.X3_38__c = 'Kaye Capital';
    prop.Custodian__c = 'Schwab Trust';

    // Appendix C ---- Employer QACA 4% Match
    prop.Safe_Harbor__c = '4% QACA Match';

    // Portfolio Codes ---- scbidxtrust
    prop.Fund_List__c = 'Schwab Index Advantage list';

    prop.Auto_Enrollment__c = 'QACA';
    prop.Product_Type__c = '401(k)';
    prop.Auto_Enrollment_Deferral_Escalation_Rate__c = '3% Flat Deferral Rate';
    prop.Profit_Sharing_Match_Vesting_Schedule__c = 'Immediate';
    prop.Safe_Harbor_Match_Determination_Period__c = 'Annual';
    prop.QACA_Safe_Harbor_Vesting_Schedule__c = 'None';
    prop.Brokerage_Accounts_PCRA__c = 'Yes';
    
    prop.Discretionary_Match__c = null;

    prop.TPA_EIN__c = '12345';
    prop.TPA_Firm_Name__c = 'Test TPA Firm Name';

    prop.Advisor_NPN__c = '12345';
    prop.Advisor_CRD__c = '54321';
    prop.Financial_Professional_Role__c = 'RR';

    prop.RecordTypeId = '0121G000000AjeLQAS';
insert prop;



SELECT Id, Name, X3_38__c, Client_Company_Name__c, Company_Contact_First_Name__c, Company_Contact_Last_Name__c, Company_Email__c, Company_State__c, Number_of_Employees__c, Contact_Phone_Number__c, Eligibility_Age__c, Grandfather_Date__c, Hardships__c, Loans__c, Participant_Fee_Payment__c, Plan_Eligibility__c, Plan_ID__c, Plan_Name__c, Plan_Entry_Frequency__c, Plan_Type__c, Profit_Sharing__c, Roth_Contributions__c, Safe_Harbor__c, Original_Effective_Date__c, Plan_Number__c, Restatement_Date__c, Previously_Sponsored_401_k_Plan__c, Current_Recent_SIMPLE_Plan__c, Auto_Enrollment__c, Product_Type__c, Service_Option__c, Auto_Enrollment_Deferral_Escalation_Rate__c, Profit_Sharing_Match_Vesting_Schedule__c, Safe_Harbor_Match_Determination_Period__c, QACA_Safe_Harbor_Vesting_Schedule__c, Brokerage_Accounts_PCRA__c, Custodian__c, Fund_List__c, Discretionary_Match__c, TPA_EIN__c, TPA_Firm_Name__c, Advisor_NPN__c, Advisor_CRD__c, Financial_Professional_Role__c FROM Proposal__c


PurchaseAPIController.getProposal('a1IDw00000HUfn6MAD');


SELECT Id, TPA_Account__r.Name, TPA_Contact__r.Name, Advisor_Account__r.Name, Advisor_Contact__r.Name FROM Proposal__c



List<Opportunity> = [SELECT Id, As FROM Opportunity WHERE Id = '0061G00000B8Z6HQAV'];

