__author__ = 'Eric T Dawson'

import os
import argparse

## TODO: add timestamping and output to folder (also specify output folder)
## TODO: short and long versions of input flags

fastq_extensions = ["fq", "fastq"]
fasta_extensions = ["fa", "fas", "fasta"]


def parse_args():
    parser = argparse.ArgumentParser(description="A program to split a single FASTA/FASTQ into many smaller"
                                                 "files.")
    parser.add_argument("-i", dest="infile", type=str, default=None,
                        help="The input file to split.")
    parser.add_argument("-splits", dest="splits", type=int, default=None,
                        help="The number of intermediate files to split the infile into.")
    parser.add_argument("-records", dest="records", type=int, default=None, required=False,
                        help="The maximum number of records to put in an intermediate file.")
    parser.add_argument("-o", dest="output", type=str, required=False,
                        help="The absolute or relative path in which to place the output")
    args = parser.parse_args()
    return args


def count_records(filename, isFastq):
    count = 0
    iden = "@" if isFastq else ">"
    with open(filename, "r") as infile:
        for line in infile:
            if line.startswith(iden):
                count += 1
    return count


def process_fasta_by_splits(filename, isFastq, num_splits):
    """Splits a given file into <num_splits> files. May be slow on
    systems with limited I/O performance"""
    split_number = -1
    basename = os.path.basename(filename)
    extension = basename.split(".")[-1]
    iden = "@" if isFastq else ">"
    record_count = 0
    with open(filename, "r") as infile:
        for line in infile:
            is_new = line.startswith(iden)
            if is_new:
                split_number += 1
                if split_number >= num_splits:
                    split_number = 0
                record_count += 1
            cname = "".join(basename.split(".")[:-1]) + "_split_" + str(split_number) + "." + extension
            with open(cname, "a") as outfile:
                outfile.write(line)
    return record_count


def process_fasta(filename, isFastq, num_records=1000):
    """Splits a given file into a set of files each
    containing <num_records> records"""
    split_number = 0
    basename = os.path.basename(filename)
    extension = basename.split(".")[-1]
    records = []
    tmp_dir = ""
    # shutil.rmtree(tmp_dir)
    # os.mkdir(tmp_dir)
    iden = "@" if isFastq else ">"
    original_records_count = 0
    with open(filename, "r") as infile:
        count = 0
        for line in infile:
            is_new = line.startswith(iden)
            if is_new:
                count += 1
            if count >= num_records:
                cname = "".join(basename.split(".")[:-1]) + "_split_" + str(split_number) + "." + extension
                with open(cname, "w") as outfile:
                    for record in records:
                        outfile.write(record)
                records = []
                original_records_count += count
                count = 0
                split_number += 1
            records.append(line)
    return original_records_count


def main():
    args = parse_args()
    filename = args.infile
    basename = os.path.basename(filename)

    isFastq = basename.split(".")[-1] in fastq_extensions
    if not isFastq and not basename.split(".")[-1] in fasta_extensions:
        raise ValueError("The file provided has neither a fasta nor fastq extension.")

    if args.splits is not None:
        process_fasta_by_splits(filename, isFastq, args.splits)

    elif args.records is not None:
        process_fasta(filename, isFastq, args.records)

    else:
        raise ValueError("Please specify either -splits or -records, but not both.")


if __name__ == "__main__":
    main()
