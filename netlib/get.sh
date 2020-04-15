#!/bin/bash

instances=(
    "afiro"
    "adlittle"
    "sc50a"
    "sc50b"
    "sc105"
    "sc205"
)

for i in "${instances[@]}"
do
    wget https://www.netlib.org/lp/data/$i
    ./emps $i > $i.mps
    rm $i
done

