#!/usr/bin/awk -f

BEGIN {	#time="(([01][0-9])|(2[0-3]))(:[0-5][0-9])";
		timespan=/(([01][0-9])|(2[0-3]))(:[0-5][0-9])-(([01][0-9])|(2[0-3]))(:[0-5][0-9])/;
		h=0; m=0;}

# Comments
NF==0 {next;}
/^[[:space:]]*[#]/ {next}

/^[0-9]{2}\.[0-9]{2}\.[0-9]{5}[[:space:]]+.*/ {
	for (i=2; i<=NF; i++) {
		if (match($i, "\\(.*\\)")) {  #inline comment
		} else if (match($i, timespan)) { #actual timespan
			split($i, T, "-");
			split(T[1], t1, ":");
			split(T[2], t2, ":");
			h += t2[1]-t1[1];
			m += t2[2]-t1[1];
		} else {
			printf "[WARNING]: Unknown element '%s' in line %d field %d !\n",$i,NR,i
		}
	}
	next;
}

# Unmatched valid lines
match($1, /^[0-9]{2}\.[0-9]{2}\.[0-9]{5}[[:space:]]*$/) {next}

1 {printf "\n[WARNING]: Line of unknown format:\n\t'%s'\n",$0}

END {printf "Gesamtzeit: %.4fh\n",(h+(m/60))}
