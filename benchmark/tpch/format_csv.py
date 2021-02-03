#! /usr/bin/python3
import argparse
from argparse import RawTextHelpFormatter
import time
import subprocess
import sys
import glob
import os

KEY=\
"""Key:
tblHdfs, tblWebHdfs - Standard Spark Data source using hdfs
tblHdfsDs, tblWebHdfsDs - Our V2 datasource using hdfs
tblDikeHdfs - Our V2 datasource using Dike Hdfs (with processor)
tblDikeHdfsNoProc - Our V2 datasource using Dike HDFS (no processor)
-p 1 - single partition
Filt/Proj - Pushdown of only filter and project
Aggregate - Pushdown of filter, project, and aggregate
W1, W4, W6 - Number of workers.
tblPartS3 - Our V2 datasource using DikeCS and file based partitions.
tblS3 - Our V2 datasource using a single file.

"""
class testRunner:
    def __init__(self):
      self._args = None
      self._lines = {}
      self._linesWritten = 0
      self._testList = []
      self._fileHandle = 0

    def parseArgs(self):
        parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                         description="Helper for diff of tpch results.\n")
        parser.add_argument("--debug", "-D", action="store_true",
                            help="enable debug output")
        parser.add_argument("--terse", action="store_true",
                            help="only report differences")
        parser.add_argument("--results", "-r",
                            default="../../spark/build/tpch-results/latest/",
                            help="Results directory\n"
                            "ex. -r ../../spark/build/")
        parser.add_argument("--input", "-i", required=True,
                            help="input file\n"
                            "ex. -i results.csv")
        parser.add_argument("--tests", "-t",
                            help="tests to compare\n"
                            "ex. -t tblHdfs,tblWebHdfs")
        self._args = parser.parse_args()
        if (self._args.input and not os.path.exists(self._args.input)):
            sys.exit("input does not exist: {}".format(self._args.input))
        if self._args.tests:
            self.parseTestList()
        self._outputFile = self._args.input.replace(".csv", "")
        self._outputFile += "_formatted"
        self._outputFile += ".csv"

    def parseTestList(self):
        self._testList = self._args.tests.split(",")
    def isTestBreak(self, line):
        tests = ["--workers 1 --test tblHdfs \n",
                 "--workers 1 --test tblHdfs -p 1 \n",
                 "--workers 4 --test tblHdfs \n",
                 "--workers 6 --test tblHdfs \n",
                 "--workers 1 --test tblPartS3 \n",
                 "--workers 4 --test tblPartS3 \n",
                 "--workers 6 --test tblPartS3 \n",
                 "--workers 1 --test tblS3 -p 1 \n" ]
        for test in tests:
            if test in line.replace("--check", ""):
                return True
        return False
    def processHeader(self, header):
        newHeader = header.replace("Test: --workers ", "W").replace("--test ", "")
        newHeader = newHeader.replace("--s3Filter --s3Project","Filt/Proj")
        newHeader = newHeader.replace("--s3Select","Aggregate")
        return newHeader
    def insertLine(self, line, index):
        if index not in self._lines:
            self._lines[index] = line
        else:
            self._lines[index] += line
    def parseFile(self):
        index = 0
        result = 0
        test = -1
        with open(self._args.input) as f:
            for line in f.readlines():
                origLine = line
                line = line.rstrip()
                #print("index: {} test: {} line: {}".format(index, test, line))              
                if 'test' in line:
                    if '--check' in line:
                        pass
                    if index != 0 and self.isTestBreak(origLine):
                        self.writeFile()
                        index = 0
                        test = -1
                        self._lines = {}
                        result += 1
                        #print("break-- " + line)
                        if result > 1000000:
                            break
                    index = 0
                    test += 1
                    line = self.processHeader(line)
                    if test == 0:
                        line += ",,,"
                        headerLine = "Test #, Seconds, Bytes,"
                    else:
                        line += ",,"
                        headerLine = "Seconds, Bytes,"
                    self.insertLine(line, index)
                    index += 1
                    self.insertLine(headerLine, index)
                    index += 1
                else:
                    if test != 0:
                        elements = line.split(",")
                        line = "{},{},".format(elements[1],elements[2])
                    else:
                        line += ","
                    self.insertLine(line, index)
                    index += 1

    def insertKey(self):
        if self._fileHandle == 0:
            self._fileHandle = open(self._outputFile, "w+")
        self._fileHandle.write(KEY)

    def writeFile(self):
        if self._fileHandle == 0:
            self._fileHandle = open(self._outputFile, "w+")
        for k in self._lines.keys():                
            self._fileHandle.write("{}\n".format(self._lines[k]))
            self._linesWritten += 1

    def run(self):
        self.parseArgs()
        self.insertKey()
        self.parseFile()

        self.writeFile()

        if self._linesWritten > 0:
            print("{} successfully wrote {} lines".format(self._outputFile, self._linesWritten))
        if self._fileHandle != 0:
            self._fileHandle.close()

if __name__ == "__main__":
    r = testRunner()

    r.run()
