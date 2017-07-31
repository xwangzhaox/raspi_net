#!/bin/bash
hh=`date '+%H'`
date=`date`
if [ $hh -gt 7 -o $hh -lt 19 ]
then
  echo "[$date]Turn on light"
  ./power_control 'ArduinoUno' '1'
  ./power_control 'ArduinoNano' '1'
else
  echo "[$date]Turn off light"
  ./power_control 'ArduinoUno' '0'
  ./power_control 'ArduinoUno' '0'
fi
