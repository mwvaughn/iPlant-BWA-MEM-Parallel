#!/bin/bash

tar xzf bin.tgz
PATH=$PATH:`pwd`/bin
## File to split
INFILE="${infile}"

## File containing read mates
MATES="${MATES}"

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



## Build up the ARGS string to pass to BWA based on user input
ARGS="mem -t 4"

if [ -n "${minSeedLength}" ]; then ARGS="${ARGS} -k ${qualityForTrimming}"; fi
if [ -n "${bandWidth}" ]; then ARGS="${ARGS} -w ${bandWidth}"; fi
if [ -n "${zDropoff}" ]; then ARGS="${ARGS} -d ${zDropoff}"; fi
if [ -n "${reSeedFactor}" ]; then ARGS="${ARGS} -r ${reSeedFactor}"; fi

if [ -n "${trimDupsThreshold}" ]; then ARGS="${ARGS} -c ${trimDupsThreshold}"; fi
if [ -n "${interleavedPairedEnd}" ]; then ARGS="${ARGS} -P"; fi
if [ -n "${readGroupHeader}" ]; then ARGS="${ARGS} -R ${readGroupHeader}"; fi
if [ -n "${alignmentScoreThreshold}" ]; then ARGS="${ARGS} -T ${alignmentScoreThreshold}"; fi
if [ -n "${outputAllAlignments}" ]; then ARGS="${ARGS} -a"; fi
if [ -n "${appendFastaComments}" ]; then ARGS="${ARGS} -C"; fi
if [ -n "${hardClipping}" ]; then ARGS="${ARGS} -H"; fi
if [ -n "${markSecondaries}" ]; then ARGS="${ARGS} -M"; fi
if [ -n "${verbose}" ]; then ARGS="${ARGS} -v ${verbose}"; fi


## Run BWA on the splits using PyLauncher
## Use four cores per BWA thread. BWA scales relatively
## poorly beyond 4 threads, at which point it is better to simply
## split the input file into more intermediate files.
## First, remove and previous commandfiles.
if [ -e commandfile.txt ]
    then rm commandfile.txt
fi

for i in `ls | grep ".*split_[0-9]*.*"`
do
    echo "bwa ${ARGS} ${BWAINDEX} ${INFILE} ${MATES} >> bwa_output_${i}.sam" >> commandfile.txt
done

python launcher.py -i commandfile -c 4

## Splice the output back together
head -n 120000 temp/split_0.fq >> ${OUTFILE}

for i in temp/*.sam
do
    cat ${i} | grep -v "^@" >> ${OUTFILE}
done

## python splice.py -o ${OUTFILE}


## Clean up all the mess we brought with us so it doesn't
## get pushed back.
rm -rf temp
rm -rf bin