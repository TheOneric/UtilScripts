# To use please set 'tsec' to the name of the target section

function error(msg) {
	printf "ERROR: [Line %d]: ",NR;
	print msg;
	ERROR_FLAG++;
	exit;
}

function warn(msg) {
	printf "WARNING: [Line %d]: ",NR;
	print msg;
	WARN_FLAG++;
}

#Return a negative number if an error occured (eg not a valid price format)
function priceToNum(p,   pFormat) {
	pFormat = "[[:digit:]]+(,[[:digit:]]{2})?€";
	
	gsub(/^[[:blank:]]+/, p);
	gsub(/[[:blank:]]+$/, p);
	if(!(p ~ pFormat))
		return -1;
	p = substr(p, 0,length(p)-1);
	gsub(/,/, ".", p)
	return p;
}

BEGIN {	INSEC=0;SEC_FLAG=0; ERROR_FLAG=0;WARN_FLAG=0;
		COST=-1;TOTAL_DIST=0;TOTAL_RIDE_COUNT=0; }

# Make sure we are in the right section
$0 ~ "^##[[:blank:]]+" {INSEC=0;}
$0 ~ "^##[[:blank:]]+"tsec"[[:blank:]]*" {INSEC=1; SEC_FLAG=1;} 
#INSEC {print $0;}
!INSEC {next;}

# Load the combined COST
/^\#\#\#/ { 
	if(COST == -1) {
		COST=priceToNum($2);
		if (COST < 0)
			error("Invalid cost specification '"$2"' !")
		} else {
			print "Illegal redefinition of cost in line "NR" !";
			exit;
		}
	next;
}

# Process each ride
# Distance each passenger has to pay for is stored in BILL_dist
# flat fee counter for each passenger is stored in BILL_ffee
/^[[:digit:]]{2}\.[[:digit:]]{2}/ {
	#Check for errors and invalid/unusual formats
	if (NF < 4) 
		error("Too few fields")
	else if (NF > 4 && !($5 ~ /^\/\//)) 
		warn("More than 4 non-comment fields");	
	if (!($3 ~ /^[HR]+$/))
		warn("Unusual counter: '"$3"'");
	if(DISTS[$2] == "")
		error("Unknown destination: '"$2"'");
	
	#Start actual processing
	multiplier=length($3);
	TOTAL_RIDE_COUNT += multiplier;
	pssng_count = split($4, passengers, ",");
	# Distribute flat fee
	## Check if the fee should be split unequal
	ffee_spec_count = 0;
	## Clear array 'ffee_spec_pssng' in POSIX-compliant way 
	## (With gawk one could also use:  delete ffee_spec_pssng;)
	split("", ffee_spec_pssng);
	for(i in passengers) {
		flag = gsub(/\*/, "", passengers[i]);
		if (flag) {
			ffee_spec_pssng[ffee_spec_count++]=passengers[i]; 
		}
	}
	if (ffee_spec_count == 0) { #Split equal
		for(i in passengers)		
			BILL_ffee[passengers[i]] += multiplier/pssng_count;
	} else { # Only special passengers pay flat fee
		for(i in ffee_spec_pssng)
			BILL_ffee[ffee_spec_pssng[i]] += multiplier/ffee_spec_count;
	}
	# Distribute distance (always equal)
	TOTAL_DIST += multiplier*DISTS[$2];
	for (i in passengers)
		BILL_dist[passengers[i]] += multiplier*(DISTS[$2]/pssng_count);
}



END {
  ## Check for errors
  if(!SEC_FLAG) {
	print "Specified section '"tsec"' not found !";
	ERROR_FLAG++;
  }
  if(COST<0) {
	print "No total cost defined in section '"tsec"' !";
	ERROR_FLAG++;
  }
  ## Print exit message according to state
  if (ERROR_FLAG) {
	print "Exited with "ERROR_FLAG" error(s).";
  } else {
	print "Total cost:\t"(COST)"€";
	print "Total dist:\t"(TOTAL_DIST)"km (approx)";
	print "Total rides:\t"(TOTAL_RIDE_COUNT)" ";
	print "Flat Fee Rate:\t"(FLAT_FEE_PART*100)"%"
	# Print distribution
	print "Person\tDistanz\tFahrtpauschalen"
	for(i in BILL_dist) {
		printf "%8s:\t%8.4fkm\t%8.5f\n",i,BILL_dist[i],BILL_ffee[i];
	}
	# Calculate price in ct , then round and transform back to euros
	flatFee_total  = COST*FLAT_FEE_PART*100;
	distanceFee_total = COST*100 - flatFee_total;
	#print "FF-Part:\t"flatFee_total;
	#print "Ds-Part:\t"distanceFee_total;
	for(i in BILL_dist)
		finalBill[i] = 0;
	for(i in BILL_ffee)
		finalBill[i] += (flatFee_total*BILL_ffee[i])/TOTAL_RIDE_COUNT;
	for(i in BILL_dist)
		finalBill[i] += (distanceFee_total*BILL_dist[i])/TOTAL_DIST;
	for(i in finalBill)
		finalBill[i] = round(finalBill[i]);
	#Print final bill for every passsenger
	print "----------- ENDPREIS -----------";
	for(i in finalBill)
		printf "%8s:\t%5.2f€\n",i,(finalBill[i]/100);

	
	if (WARN_FLAG) print "Finished with "WARN_FLAG" warning(s).";
	else print "\nFinished without warnings nor errors.";
  }
	#for(i in DISTS)
	#	print "\t"i": "DISTS[i];
}

