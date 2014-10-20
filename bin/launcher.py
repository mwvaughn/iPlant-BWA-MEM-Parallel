#!/usr/bin/env python

import os
import sys
import pylauncher
import argparse


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "-infile", dest="infile", type=str, default=sys.stdin)
    parser.add_argument("-c", "-cores", dest="cores", type=int, default=1, required=False)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()

    pylauncher.ClassicLauncher(args.infile, cores=args.cores)
    sys.exit()
