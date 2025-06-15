/*---------------------------------------------------------------
  Step 1: Import CSV file into a permanent SAS dataset
----------------------------------------------------------------*/
proc import datafile="/home/u64256136/EPG1V2/data/TSAClaims2002_2017.csv"
    out=pg1.tsa_claims
    dbms=csv
    replace;
    guessingrows=max;
run;

/*---------------------------------------------------------------
  Step 2: Clean the data and engineer features
----------------------------------------------------------------*/
data tsa_claims_clean;
    set pg1.tsa_claims;

    /* Format date fields for readability */
    format Incident_Date Date_Received date9.;

    /* Standardize categorical text values to Proper Case */
    Claim_Site     = propcase(coalescec(Claim_Site, "Unknown"));
    Claim_Type     = propcase(coalescec(Claim_Type, "Unknown"));
    Disposition    = propcase(coalescec(Disposition, "Unknown"));

    /* Flag for logical errors: incidents occurring after the claim is received */
    Date_Issue     = (Incident_Date > Date_Received);

    /* Extract year for trend analysis */
    Year = year(Incident_Date);
run;

/*---------------------------------------------------------------
  Step 3: Verify cleaning with sample observations
----------------------------------------------------------------*/
proc print data=tsa_claims_clean(obs=10);
    var Incident_Date Year Claim_Type;
run;

/*---------------------------------------------------------------
  Step 4: Analyze frequency of claims by year
----------------------------------------------------------------*/
proc freq data=tsa_claims_clean order=internal;
    tables Year;
run;

/*---------------------------------------------------------------
  Step 5: Analyze most common claim types
----------------------------------------------------------------*/
proc freq data=tsa_claims_clean order=freq;
    tables Claim_Type / nocum;
run;

/*---------------------------------------------------------------
  Step 6: Analyze yearly payout statistics (Close Amount)
----------------------------------------------------------------*/
proc means data=tsa_claims_clean mean median max min;
    class Year;
    var Close_Amount;
run;

/*---------------------------------------------------------------
  Step 7: Identify top states for TSA claims
----------------------------------------------------------------*/
proc freq data=tsa_claims_clean order=freq;
    tables StateName / nocum;
run;
