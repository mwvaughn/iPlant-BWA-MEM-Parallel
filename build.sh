
## Decompress and untar the source code
if [ -e bwa-0.7.10 ]
    then rm -r bwa-0.7.10
fi
##bzip2 -d bwa-0.7.10.tar.bz2
tar xvf bwa-0.7.10.tar
cd bwa-0.7.10

module load intel
make CC=icc CFLAGS="-O3 -g -xHost"

#if [ -e ../bin ]
#    then rm -r ../bin
#fi
#mkdir ../bin
cp bwa ../bin
cd ..
mv bwa-0.7.10 ./bin


