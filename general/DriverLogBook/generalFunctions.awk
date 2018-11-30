# taken from: https://www.gnu.org/software/gawk/manual/html_node/Round-Function.html
# round.awk --- do normal rounding
function round(x,   ival, aval, fraction)
{
   ival = int(x)    # integer part, int() truncates

   # see if fractional part
   if (ival == x)   # no fraction
      return ival   # ensure no decimals

   if (x < 0) {
      aval = -x     # absolute value
      ival = int(aval)
      fraction = aval - ival
      if (fraction >= .5)
         return int(x) - 1   # -2.5 --> -3
      else
         return int(x)       # -2.3 --> -2
   } else {
      fraction = x - ival
      if (fraction >= .5)
         return ival + 1
      else
         return ival
   }
}

# alen --- get length of arrays in POSIX friendly way (gawk also allows length(array))
function alen(a,   i, k) {
    k = 0
    for(i in a) k++
    return k
}

