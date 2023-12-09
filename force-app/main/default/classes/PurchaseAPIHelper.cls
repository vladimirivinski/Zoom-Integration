public with sharing class PurchaseAPIHelper {
    public static String getStateCode(String state) {
    Map<String, String> stateCodeMapping = new Map<String, String>{ 'Alabama' => 'AL', 'Alaska' => 'AK', 'Arizona' => 'AZ', 'Arkansas' => 'AR', 'California' => 'CA', 'Colorado' => 'CO', 'Connecticut' => 'CT', 'Delaware' => 'DE', 'Florida' => 'FL', 'Georgia' => 'GA', 'Hawaii' => 'HI', 'Idaho' => 'ID', 'Illinois' => 'IL', 'Indiana' => 'IN', 'Iowa' => 'IA', 'Kansas' => 'KS', 'Kentucky' => 'KY', 'Louisiana' => 'LA', 'Maine' => 'ME', 'Maryland' => 'MD', 'Massachusetts' => 'MA', 'Michigan' => 'MI', 'Minnesota' => 'MN', 'Mississippi' => 'MS', 'Missouri' => 'MO', 'Montana' => 'MT', 'Nebraska' => 'NE', 'Nevada' => 'NV', 'New Hampshire' => 'NH', 'New Jersey' => 'NJ', 'New Mexico' => 'NM', 'New York' => 'NY', 'North Carolina' => 'NC', 'North Dakota' => 'ND', 'Ohio' => 'OH', 'Oklahoma' => 'OK', 'Oregon' => 'OR', 'Pennsylvania' => 'PA', 'Rhode Island' => 'RI', 'South Carolina' => 'SC', 'South Dakota' => 'SD', 'Tennessee' => 'TN', 'Texas' => 'TX', 'Utah' => 'UT', 'Vermont' => 'VT', 'Virginia' => 'VA', 'Washington' => 'WA', 'West Virginia' => 'WV', 'Wisconsin' => 'WI', 'Wyoming' => 'WY' };
    String result;
    String stateName = state.trim();

    if(stateName != null && stateName != '' && stateName.length() == 2) {
        for (String code : stateCodeMapping.values()) {
            result = code == stateName.toUpperCase() ? code : null;
            if (result != null) {
                break;
            }
        }
        return result;
    } else if (stateName != null && stateName != '' && stateCodeMapping.containsKey(stateName)) {
        result = stateCodeMapping.get(stateName);
        return result;
    } else {
        return result;
    }
    }


    //  Define request Age
    public static Integer getRequiredAge(String eligibilityAge) {
        Integer age = eligibilityAge == 'None' || eligibilityAge == null ? null : Integer.valueOf(eligibilityAge);
        return age;
    }

    public static String convertPlanEntryFrequency(String inputFrequency) {
        if (inputFrequency == 'Immediate') {
            return 'DAILY';
        } else if (inputFrequency == 'Monthly') {
            return 'MONTHLY';
        } else if (inputFrequency == 'Quarterly') {
            return 'QUARTERLY';
        } else if (inputFrequency == 'Semi-Annually') {
            return 'SEMI_ANNUALLY';
        } else {
            return null;
        }
    }

    public static String convertPlanEligibility(String inputFrequency) {
        if (inputFrequency == 'Immediate') {
            return 'IMMEDIATE';
        } else if (inputFrequency == 'One Month') {
            return 'ONE_MONTH';
        } else if (inputFrequency == 'Two Months') {
            return 'TWO_MONTHS';
        } else if (inputFrequency == 'Three Months' || inputFrequency == '90 Day') {
            return 'THREE_MONTHS';
        } else if (inputFrequency == '6 Months') {
            return 'SIX_MONTHS';
        } else if (inputFrequency == '1 Year (1000 Hours)') {
            return 'ONE_YEAR_HOURS';
        } else if (inputFrequency == '1 Year' || inputFrequency == '12 Months Elapsed Time') {
            // Assuming both '1 Year' and '12 Months Elapsed Time' map to the same value
            return 'TWELVE_MONTHS';
        } else {
            return null;
        }
    }

    public static String getFormateDate(Date myDate) {
        if(myDate != null){
            DateTime myDatetime = DateTime.newInstance(myDate.year(), myDate.month(), myDate.day());
            String formattedDateString = myDatetime.format('yyyy-MM-dd');
            return formattedDateString;
        }
        return null;
    }

}