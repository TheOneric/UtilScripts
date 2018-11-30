#!/bin/bash
awk -v tsec="$1" -f ./Distances.awk -f ./generalFunctions.awk -f ./Fahrtenrechner.awk Fahrtenbuch.md

