#! /usr/bin/python3
import argparse
from argparse import RawTextHelpFormatter
import time
import subprocess
import sys
import os
import datetime

class ParseLogs:
    def __init__(self):

      self._args = None

    def parseArgs(self):
        parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                         description="Parse Spark Logs.\n")
        parser.add_argument("--debug", "-D", action="store_true",
                            help="enable debug output")
        parser.add_argument("--dry_run", action="store_true",
                            help="For Debug.")
        parser.add_argument("--file", "-f",
                            help="file to parse")
        parser.add_argument("--start", "-s",
                            help="start string")
        parser.add_argument("--end", "-e",
                            help="end string")
        self._args = parser.parse_args()

    def parse(self, file):
        with open(file) as fd:
            index = 0
            start_str = ""
            end_str = ""
            for line in fd.readlines():
                if start_str == "" and self._args.start in line:
                    start_str = line
                    #print("Start found {}) {}".format(index, line), end="")
                if end_str == "" and self._args.end in line:
                    end_str = line
                    #print("End found {}) {}".format(index, line), end="")
                index += 1
            if (start_str == "" or end_str == ""):
                print("Start or end not found")
                exit(1)
            start_fields = start_str.split(" ")
            start_time = start_fields[0] + " " + start_fields[1]
            start_sec = datetime.datetime.strptime(start_time, "%d/%m/%y %H:%M:%S.%f").timestamp()

            end_fields = end_str.split(" ")
            end_time = end_fields[0] + " " + end_fields[1]
            end_sec = datetime.datetime.strptime(end_time, "%d/%m/%y %H:%M:%S.%f").timestamp()

            print("{}: {} {} delta is {}".format(self._args.file,
                                                 start_time, end_time, end_sec - start_sec))
    def getTime(self, line):
        fields = line.split(" ")
        task = fields[6] if len(fields) > 6 else 0
        time = fields[0] + " " + fields[1]
        #print(time + " " + line)
        sec = datetime.datetime.strptime(time, "%d/%m/%y %H:%M:%S.%f").timestamp()
        return (time, sec, task)
    def parse1(self, file):
        tags = {"Pushdown Rule Parse",
                "Pushdown Rule NDP Relation",
                "Pushdown DS getPartitions",
                "Pushdown DS getBlockList",
                #"Pushdown DS createPartition",
                "Pushdown DS parquetmr open",
                "Pushdown DS parquetmr footer read",
                "Pushdown Rule Part2",
                "Pushdown Rule Part3",
                "Pushdown Rule Part4",
                "Pushdown Rule HdfsOpScan",
                "Pushdown test"}
        with open(file) as fd:
            index = 0
            start_str = ""
            end_str = ""
            start_times = {}
            elapsed_times = {}
            overall_start = 0
            overall_end = 0
            rule_start = 0
            total_tasks = 0
            for line in fd.readlines():
                line = line.rstrip('\n')
                for t in tags:
                    if t in line:
                        if "start" in line:
                          (time_str, rule_start, task) = self.getTime(line)
                          start_times[t] = rule_start
                          #print("Start: [{}] {}".format(t, line))
                        if "end" in line:
                          (time_str, rule_end, task) = self.getTime(line)
                          elapsed_times[t] = rule_end - start_times[t]
                          #print("End: [{}] elapsed sec {} {}".format(t, rule_end - start_times[t], line))

                if "Pushdown Rule File" in line:
                    print("Rule: " + line)
                    start_str = ""
                if "Starting task" in line and self._args.start in line:
                    # print("Start found task {}) {}".format(task, line), end="")
                    (time_str, start_sec, task) = self.getTime(line)
                    if start_str == "":
                        start_str = line
                        overall_start = start_sec
                        if "Pushdown test" in start_times:
                            #print("test start to task start {} {}".format(time_str, start_sec - start_times["Pushdown test"]), end="\n")
                            elapsed_times["pre-task"] = start_sec - start_times["Pushdown test"]

                    start_times[task] = start_sec
                if "Finished task" in line and self._args.start in line:
                    end_str = line
                    end_fields = end_str.split(" ")
                    task = end_fields[6]
                    end_time = end_fields[0] + " " + end_fields[1]
                    end_sec = datetime.datetime.strptime(end_time, "%d/%m/%y %H:%M:%S.%f").timestamp()
                    overall_end = end_sec
                    total_tasks += 1
                    # print("{}, {} {}".format(task,
                    #                      end_sec - start_times[task], total_tasks), end="\n")
                index += 1
            if (start_str == "" or end_str == ""):
                print("Start or end not found")
                exit(1)
            #print("total tasks: {}".format(total_tasks))
            elapsed_times["task time"] = end_sec - overall_start
            #print("task time {}".format(end_sec - overall_start))
            print("{},{},{},{},{}".format(total_tasks,elapsed_times["pre-task"], elapsed_times["task time"],
            (elapsed_times["Pushdown test"] - elapsed_times["pre-task"] - elapsed_times["task time"]),
                                    elapsed_times["Pushdown test"]))

    def run(self):
        self.parseArgs()

        self.parse1(self._args.file)

if __name__ == "__main__":
    r = ParseLogs()
    r.run()