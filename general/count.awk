#!/usr/bin/awk -f

BEGIN { 		#time="(([01][0-9])|(2[0-3]))(:[0-5][0-9])";
                #timespan=/(([01][0-9])|(2[0-3]))(\:[0-5][0-9])\-(([01][0-9])|(2[0-3]))(\:[0-5][0-9])/;
                h=0; m=0;}

# Comments
NF==0 {next;}
/^[[:space:]]*[#]/ {next}

/^[0-9]{2}\.(09|10)\.12018[[:space:]]+.*/ {
        dh = 0;
        dm = 0;
        for (i=2; i<=NF; i++) {
#               if (NR == 9) {  printf "Match '%s': %d (true: %d)\n\n",$i,($i ~ timespan),TRUE;}
                if (match($i, /\(.*\)/)) {  #inline comment
#               } else if (match($i, timespan)) { #actual timespan
                } else if ($i ~ /([01][0-9]|2[0-3]):[0-5][0-9]\-([01][0-9]|2[0-3]):[0-5][0-9]/) { #actual timespan
                        split($i, T, "-");
                        split(T[1], t1, ":");
                        split(T[2], t2, ":");
                        dh += t2[1]-t1[1];
                        dm += t2[2]-t1[2];
                } else {
                        printf "[WARNING]: Unknown element '%s' in line %d field %d !\n",$i,NR,i
                }
        }
        h += dh;
        m += dm;
        printf $1":\t%.4fh (%dh %dm)\n",(dh+(dm/60)),dh,dm
        next;
}

# Unmatched "valid" lines
match($1, /^[0-9]{2}\.[0-9]{2}\.[0-9]{5}[[:space:]]*$/) {next}

1 {printf "\n[WARNING]: Line of unknown format:\n\t'%s'\n",$0}

END {printf "Gesamtzeit: %.4fh (%dh und %dm)\n",(h+(m/60)),h,m}

