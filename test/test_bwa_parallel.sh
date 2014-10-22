#!/bin/bash
#SBATCH -p development
#SBATCH -t 02:00:00
#SBATCH -n 16
#SBATCH -A iPlant-Collabs 
#SBATCH -J test-BWA
#SBATCH -o test-BWA-index.o%j

module load pylauncher

cd ..

##./build.sh
tar xzf bin.tgz

## Input (a fastq file)
INFILE=$WORK/sandbox/ecoli_mda_lane1.fastq
INDEX=${WORK}/sandbox/U00096.2.fas
#Split it all up: 100K records per file
echo "Time to split file into files of 100K records a piece"
time python split.py -i ${INFILE} -r 100000

## Algorithm (we'll start with mem, but others may be appropriate)
if [ -e commandfile.txt ]
    then rm commandfile.txt
fi

for i in `ls | grep ".*split_[0-9]*.*"`
do
    echo "bwa ${ARGS} ${BWAINDEX} ${INFILE} ${MATES} >> bwa_output_${i}.sam" >> commandfile.txt
done

python launcher.py -i commandfile -c 4


head -n 120000 temp/split_0.fq >> ${OUTFILE}

for i in temp/*.sam
do
    cat ${i} | grep -v "^@" >> ${OUTFILE}
done


rm -rf ./bin
rm -rf temp