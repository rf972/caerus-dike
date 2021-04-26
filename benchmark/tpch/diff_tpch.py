#! /usr/bin/python3
import argparse
from argparse import RawTextHelpFormatter
import time
import subprocess
import sys
import glob
import os

class DiffTpch:
    def __init__(self):
      self._args = None
      self._successCount = 0
      self._failureCount = 0
      self._skipCount = 0
      self._testList = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                        10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
    def parseArgs(self):
        parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                         description="Helper for diff of tpch results.\n")
        parser.add_argument("--debug", "-D", action="store_true",
                            help="enable debug output")
        parser.add_argument("--meld", action="store_true",
                            help="launch meld inline when files differ")
        parser.add_argument("--terse", action="store_true",
                            help="only report differences")
        parser.add_argument("--results", "-r",
                            default="../../spark/build/tpch-results/latest/",
                            help="Results directory\n"
                            "ex. -r ../../spark/build/")
        parser.add_argument("--format", "-f",
                            default="csv",
                            help="format of file, csv or parquet\n")
        parser.add_argument("--baseline", "-b", 
                            default="../../spark/build/tpch-baseline",
                            help="baseline results directory to compare against\n"
                            "ex. -b ../../spark/build/tpch-baseline")
        parser.add_argument("--compare", "-c",
                            help="directory to compare to baseline\n"
                            "ex. --compare spark/tpch-test-output-tblFile")
        parser.add_argument("--tests", "-t",
                            help="tests to compare\n"
                            "ex. -t 1,2,3,5-9,16-19,21")
        self._args = parser.parse_args()
        if (self._args.results and not os.path.exists(self._args.results)):
            sys.exit("results does not exist: {}".format(self._args.results))
        if self._args.compare and (not os.path.exists(self._args.compare)):
            sys.exit("compare does not exist: {}".format(self._args.compare))
        if (self._args.baseline and not os.path.exists(self._args.baseline)):
            sys.exit("baseline does not exist: {}".format(self._args.baseline))
        if (not (self._args.results and self._args.baseline) and
            (not (self._args.baseline and self._args.compare))):
            sys.exit("must supply either --results or both --baseline and --compare")
        if self._args.tests:
            self.parseTestList()

    def parseTestList(self):
        testItems = self._args.tests.split(",")
        self._testList = []

        for i in testItems:
            if "-" in i:
                r = i.split("-")
                if len(r) == 2:
                    for t in range(int(r[0]), int(r[1]) + 1):
                        self._testList.append(t)
            else:
                self._testList.append(int(i))

    def getFileList(self, path):
        return glob.glob(path + os.path.sep + "part-*." + self._args.format)

    def getFirstFile(self, path):
        fileList = self.getFileList(path)
        if len(fileList) == 0:
            return None
        return fileList[0]

    def getTestPath(self, test, rootPath):
        if test < 10:
            testName = "Q0" + str(test)
        else:
            testName = "Q" + str(test)
        path = rootPath + os.path.sep + testName 
        return path

    def runDiff(self, baseRootPath, compareRoot, testList):
        for test in testList:
            basePath = self.getTestPath(test, baseRootPath)
            comparePath = self.getTestPath(test, compareRoot)
            baseFileList = self.getFileList(basePath)
            compareDirName = os.path.split(os.path.split(comparePath)[0])[1]
            diffFileList = []
            compareFile = self.getFirstFile(comparePath)
            index = 0
            for baseFile in baseFileList:
                if (baseFile == None or compareFile == None):
                    if not self._args.terse:
                        print("{} Skipping {}".format(compareDirName, test))
                    continue
                if (self._args.debug):
                    rc = subprocess.call("/usr/bin/diff -q {} {}".format(baseFile, compareFile), shell=True)
                else:
                    rc = subprocess.call(
                        "/usr/bin/diff -q {} {} > /dev/null 2>&1".format(baseFile, compareFile), shell=True)

                if not self._args.terse:
                    print("{} {} {}".format(compareDirName, 
                                            test,
                                            "same" if (rc == 0) else "[{}] DIFFER".format(index)))
                index += 1
                if rc != 0:
                    diffFileList.append(baseFile)
            #print(baseFileList)
            #print(diffFileList)
            # We allow the baseline directory to have multiple possible matches.
            # the one file we are comparing against (compFilePath), must match one of these.
            # Thus, if they all disagree, then none matched.
            if len(diffFileList) == len(baseFileList):
                # No matches, keep track of it.
                self._failureCount += 1
                for diffFile in diffFileList:
                    if self._args.terse:
                        print("{} Test: {} DIFFER".format(compareDirName, test))
                    else:
                        print("Difference in paths: {} {}".format(diffFile, compareFile))
                    if rc != 0 and self._args.meld:
                        subprocess.call("meld {} {}".format(baseFile, compareFile), shell=True)
                        print("meld {} {}".format(baseFile, compareFile))
                        #print("Result of diff {} {} was {}".format(d1File, compareFile, rc))
            elif compareFile != None:
                # They matched, keep track of it.
                self._successCount += 1
            else:
                # If there was no file, then we skipped it.
                self._skipCount += 1

    def run(self):
        self.parseArgs()

        if self._args.compare:
            self.runDiff(self._args.baseline,
                         self._args.compare, self._testList)
        else:
            dirList = glob.glob(self._args.results + os.path.sep + "*")
            #print(dirList)
            for resultRootDir in dirList:
                self.runDiff(self._args.baseline,
                             resultRootDir, self._testList)
        print("Successes: {}".format(self._successCount))
        print("Skipped:   {}".format(self._skipCount))
        print("Failures:  {}".format(self._failureCount))

if __name__ == "__main__":
    r = DiffTpch()

    r.run()
