#! /usr/bin/python3
import argparse
from argparse import RawTextHelpFormatter
import time
import subprocess
import sys
import os

class RunTpch:
    def __init__(self):
      self._args = None
      self._testList = []
      self._workersList = []
      self._testResults = []
      self._debug = False
      self._continueOnError = False
      self._startTime = time.time()
      self._test_failures = 0

    def parseTestList(self):
        testItems = self._args.tests.split(",")

        for i in testItems:
            if "-" in i:
                r = i.split("-")
                if len(r) == 2:
                    for t in range(int(r[0]), int(r[1]) + 1):
                        self._testList.append(t)
            else:
                self._testList.append(int(i))

    def parseWorkersList(self):
        testItems = self._args.workers.split(",")

        for i in testItems:
            if "-" in i:
                r = i.split("-")
                if len(r) == 2:
                    for t in range(int(r[0]), int(r[1]) + 1):
                        self._workersList.append(t)
            else:
                self._workersList.append(int(i))

    def parseArgs(self):
        parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                         description="Helper app for running tpch tests.\n")
        parser.add_argument("--debug", "-D", action="store_true",
                            help="enable debug output")
        parser.add_argument("--dry_run", action="store_true",
                            help="Do not run tests, just print tests to run.")
        parser.add_argument("--tests", "-t",
                            help="tests to run\n"
                            "ex. -t 1,2,3,5-9,16-19,21")
        parser.add_argument("--workers", "-q", default="1",
                            help="worker threads\n"
                            "ex. -w 1,2,3,5-9,16-19,21")
        parser.add_argument("--results", "-r", default="results.csv",
                            help="results file\n"
                            "ex. -r results.csv")
        parser.add_argument("--args", "-a",
                            help="args to test\n"
                            'ex. -a "--test tblPartS3 -t 21 --s3Filter --s3Project"')
        self._args = parser.parse_args()
        self.parseTestList()
        self.parseWorkersList()

    def print(self, trace, debug=False):
        if not debug or self._debug:
            print("{}: {}".format(sys.argv[0], trace))

    def terminate(self, err):
        if not self._continueOnError:
            exit(err)

    def issue_cmd(self, cmd, show_cmd=False, fail_on_err=True,
                  err_msg=None, enable_stdout=True, no_capture=False):
        rc, output = self.run_command(
            cmd, show_cmd, enable_stdout=enable_stdout, no_capture=no_capture)
        if fail_on_err and rc != 0:
            self.print("cmd failed with status: {} cmd: {}".format(rc, cmd))
            if (err_msg):
                self.print(err_msg)
            self.terminate(1)
        return rc, output

    def runCommand(self, command, show_cmd=False, enable_stdout=True, no_capture=False):
        output_lines = []
        if show_cmd or self._debug:
            print("{}: {} ".format(sys.argv[0], command))
        if self._args.dry_run:
            #print("")
            return 0, output_lines
        if no_capture:
            rc = subprocess.call(command, shell=True)
            return rc, output_lines
        process = subprocess.Popen(
            command.split(), stdout=subprocess.PIPE)  # shlex.split(command)
        while True:
            output = process.stdout.readline()
            if (not output or output == '') and process.poll() is not None:
                break
            if output and enable_stdout:
                self.print(str(output, 'utf-8').strip())
            output_lines.append(str(output, 'utf-8'))
        rc = process.poll()
        return rc, output_lines

    def restartAll(self):
        output = subprocess.check_output("cd ../../spark && ./docker/restart_spark_and_nfs.sh > /dev/null 2>&1", shell=True)

    def runCmd(self, cmd):
        (rc, output) = self.runCommand(cmd, show_cmd=True, enable_stdout=False)
        if rc != 0:
            self._test_failures += 1
            failure = "test failed with status {} cmd {}".format(rc, cmd)
            self._testResults.append(failure)
            print(failure)
        lineNum = 0
        for line in output:
            if lineNum > 0:
                lineNum += 1
            if rc == 0 and (("TPCH Failed" in line) or ("FAILED" in line)):
                self._test_failures += 1
                failure = "test failed cmd: {}".format(cmd)
                print(failure)
                self._testResults.append(failure)
            if "Test Results" in line:
                lineNum += 1
            if lineNum == 4:
                print(line.rstrip())
                self._testResults.append(line)
                break

    def showResults(self):
        if os.path.exists(self._args.results):
            mode = "a"
        else:
            mode = "w"
        with open(self._args.results, mode) as fd:
            fd.write("Test: {}\n".format(self._args.args))
            for r in self._testResults:
                print(r.rstrip())
                fd.write(r.rstrip() + "\n")

    def displayElapsed(self):
        end = time.time()
        hours, rem = divmod(end - self._startTime, 3600)
        minutes, seconds = divmod(rem, 60)
        print("elapsed time: {:2}:{:02}:{:02}".format(int(hours), int(minutes), int(seconds)))

    def runTests(self):
        for w in self._workersList:
            for t in self._testList:
                cmd = "./run_tpch.sh -w {} -t {} {}".format(w, t, self._args.args)
                self.runCmd(cmd)
        print("")
        self.showResults()
        self.displayElapsed()
        if (self._test_failures > 0):
            print("test failures: {}".format(self._test_failures))

    def run(self):
        self.parseArgs()
        
        self.runTests()

if __name__ == "__main__":
    r = RunTpch()
    r.run()

