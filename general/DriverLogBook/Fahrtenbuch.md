# Example Logbook 
Each section has a associated price (how much did the fuel cost?)
The costs are then distributed among the passengers acording to the logbook.
It is possible to set a flat fee for each ride, regardless of the distance traveled.
The flat fee rate is relative to the total cost and can be set in DIstances.awk.
Distances.awk does also contain all the Distances for each destination.
## Fields
$1:	date as dd.mm
$2: destination
$3: How many rides (H: way there; R: way back)
$4: Passengers as a comma-seperated list WITHOUT SPACES
If some passengers are marked with a * only the marked passengers pay the flat fee.
If no passenger is marked the flat fee is equally distributed among all passengers.


# Year 2018
## May
### 66,77€
01.05 ExplodingCastle HR Kazuma,Megumin
02.05 ExplodingCastle HR Kazuma,Megumin
03.05 ExplodingCastle HR Kazuma,Megumin
04.05 ExplodingCastle HR Kazuma,Megumin
05.05 ExplodingCastle HR Kazuma,Megumin
06.05 ExplodingCastle HR Kazuma,Megumin
07.05 ExplodingCastle HR Kazuma,Megumin
10.05 ExplodingCastle HR Aqua,Megumin
11.05 ExplodingCastle HR Aqua,Megumin
12.05 ExplodingCastle HR Aqua,Megumin
13.05 ExplodingCastle HR Aqua,Megumin
14.05 ExplodingCastle HR Aqua,Megumin
20.05 Alcanretia H Aqua,Darkness,Megumin,Kazuma,Wiz
25.05 Alcanretia R Aqua*,Darkness,Megumin,Kazuma,Wiz

## June
### 1,11€
03.05 WizsShop HR Kazuma,Megumin,Aqua

