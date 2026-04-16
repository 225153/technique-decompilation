#!/bin/bash

echo "1+2" | ./calc
echo "3.5+4.2" | ./calc
echo "1+2*3" | ./calc
echo "(1+2)*3" | ./calc
echo "-5" | ./calc
echo "5/0" | ./calc
echo "1+" | ./calc