#!/usr/bin/python

import argparse
from argparse import RawTextHelpFormatter
import time
import subprocess
import sys
import os

class Convert:
    def __init__(self):
      self._args = None

    def parseArgs(self):
        parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                         description="Convert file separators\n")
        parser.add_argument("--debug", "-D",
                            help="enable debug output")
        parser.add_argument("--infile", "-i", required=True,
                            help="input file")
        parser.add_argument("--outfile", "-o", required=True,
                            help="output file")
        self._args = parser.parse_args()

    def run(self):
      self.parseArgs()
      with open(self._args.infile) as infile, open(self._args.outfile, 'w') as outfile:
          for line in infile:
            outfile.write(" ".join(line.split()).replace(' ', ','))
            outfile.write("\n") # trailing comma shouldn't matter


if __name__ == "__main__":
    c = Convert()

    c.run()
