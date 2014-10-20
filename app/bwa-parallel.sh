#!/bin/bash

## File to split
INFILE="${infile}"

## Basename of the outfile.
OUTFILE="${OUTPUT}"


## Number of slices
SLICES="${slices}"

## Max number of records per slice
RECORDS="${records}"

## BWA Algorithm to use for analysis
ALG="${ALG}"

## Reference genome for alignment
BWAINDEX="${BWAINDEX}"

## The number of threads to use for each BWA process
THREADS=4

## Split the input file into smaller files
python split.py -i ${INFILE} -r ${RECORDS}


## Run BWA on the splits using PyLauncher
## Use four cores per BWA thread. BWA scales relatively
## poorly beyond 4 threads, at which point it is better to simply
## split the input file into more intermediate files.
if [ -e commandfile.txt ]
    then rm commandfile.txt
fi

for i in `ls | grep ".*split_[0-9]*.*"`
do
    echo "bwa ${ALG} -t ${THREADS} ${BWAINDEX} ${i} >> bwa_output_${i}.sam" >> commandfile.txt
done

python launcher.py -i commandfile -c 4

## Splice the output back together
python splice.py -o ${OUTFILE}

rm *split_*
rm -rf bin