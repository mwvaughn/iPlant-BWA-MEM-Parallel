#!/bin/bash
#SBATCH -p development
#SBATCH -t 00:30:00
#SBATCH -n 16
#SBATCH -A iPlant-Collabs 
#SBATCH -J test-BWA
#SBATCH -o test-BWA-index.o%j

cd ..

##./build.sh
tar xzf bin.tgz

## Input (a fastq file)

## Algorithm (we'll start with mem, but others may be appropriate)

## Index file (we'll be using E. coli)


rm -rf ./bin
