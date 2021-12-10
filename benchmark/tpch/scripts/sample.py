#!/usr/bin/python3
import argparse
from argparse import RawTextHelpFormatter
import time
import subprocess
import sys
import glob
import os
import shutil
import psutil

class Sample:
    def __init__(self):
      self._args = None
      self._continueOnError = False
      self._debug = False
      self._excludeProcs = ["sample.py"]

    def parseArgs(self):
        parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                         description="Sample stats for process.\n")
        parser.add_argument("--debug", "-D", action="store_true",
                            help="enable debug output")
        parser.add_argument("--noRetry", "-R", action="store_true",
                            help="retry when process not available")
        parser.add_argument("--name", "-n", required=True, default="",
                            help="sample this proces name")
        parser.add_argument("--adapter", "-a", required=False, default="",
                            help="network to sample")
        parser.add_argument("--results", "-r", default="results.csv",
                            help="results file\n"
                            "ex. -r results.csv")
        parser.add_argument("--sample_interval", "-s", type=float, default=1.0,
                            help="sample interval")
        self._args = parser.parse_args()


    def issueCmd(self, cmd, show_cmd=False, fail_on_err=True,
                  err_msg=None, enable_stdout=True, no_capture=False):
        rc, output = self.runCommand(
            cmd, show_cmd, enable_stdout=enable_stdout, no_capture=no_capture)
        if fail_on_err and rc != 0:
            self.print("cmd failed with status: {} cmd: {}".format(rc, cmd))
            if (err_msg):
                self.print(err_msg)
            self.terminate(1)
        return rc, output

    def runCommand(self, command, show_cmd=False, enable_stdout=True, no_capture=False, log_file=""):
        output_lines = []
        log_fd = None
        if os.path.exists(log_file):
            mode = "a"
        else:
            mode = "w"
        if (log_file != ""):
            print("opening {}".format(log_file))
            log_fd = open(log_file, mode)
        if show_cmd or self._args.debug:
            print("{}: {} ".format(sys.argv[0], command))
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
            if output and log_fd:
                log_fd.write(str(output, 'utf-8').strip() + "\n")
            output_lines.append(str(output, 'utf-8'))
        if log_fd:
            log_fd.close()
        rc = process.poll()
        return rc, output_lines

    def print(self, trace, debug=False):
        if self._debug or self._debug:
            print("{}: {}".format(sys.argv[0], trace))
    def terminate(self, err):
        if not self._continueOnError:
            exit(err)
    def getPid(self):
        pid = None

        for proc in psutil.process_iter():
            found = True
            for n in self._excludeProcs:
                if n in " ".join(proc.cmdline()) or n in proc.name():
                    found = False
                    break
            for n in self._args.name.split(","):
                if n not in " ".join(proc.cmdline()) and n not in proc.name():
                    found = False
                    break
            if found:
              pid = proc.pid
              print(proc.name() + " " + " ".join(proc.cmdline()))
              break
        return pid

    def getBytes(self):
        sent_bytes = 0
        received_bytes = 0
        if (self._args.adapter != ""):
            adapters = self._args.adapter.split(",")
            for a in adapters:
              cmd = "sudo ifconfig " + a
              rc, output = self.issueCmd(cmd)
              for line in output:
                if "TX packets" in line:
                    words = list(filter(None, line.split(" ")))
                    sent_bytes += int(words[4])
                if "RX packets" in line:
                    words = list(filter(None, line.split(" ")))
                    received_bytes += int(words[4])
        return sent_bytes, received_bytes

    def sample(self):
        retries = 0
        while True:
            pid = self.getPid()
            if pid == None:
                print("cannot find pid for {} retry {}\r".format(
                    self._args.name, retries), end="")
                if self._args.noRetry:
                    print("\r" + 80*" ")
                    exit(0)
                time.sleep(2)
                retries += 1
            else:
                print("\r" + 80*" ")
                break
        print("pid found: {}".format(pid))
        process = psutil.Process(pid)
        last_times = process.cpu_times()
        (last_tx_bytes, last_rx_bytes) = self.getBytes()
        with open(self._args.results, 'w') as results_fd:
            print("opening {}".format(self._args.results))
            header = "seconds,cputime,txbytes,rxbytes"
            print(header)
            if results_fd:
                results_fd.write(header + "\n")
            start_time = time.time()
            interval_time = 0
            sample_time = self._args.sample_interval

            while process.is_running():
                cur_sleep_time = sample_time - (interval_time % sample_time)
                #print("sleep_time is {} ".format(sleep_time))
                time.sleep(cur_sleep_time)
                times = process.cpu_times()
                usage = (times.user + times.system) - (last_times.user + last_times.system)
                (cur_tx_bytes, cur_rx_bytes) = self.getBytes()
                tx_bytes, rx_bytes = (cur_tx_bytes - last_tx_bytes, cur_rx_bytes - last_rx_bytes)
                interval_time = time.time() - start_time
                result = "{:.3f},{:.2f},{},{}".format(
                    interval_time, usage, tx_bytes, rx_bytes)
                print(result)
                if results_fd:
                    results_fd.write(result + "\n")
                last_times = times
                (last_tx_bytes, last_rx_bytes) = (cur_tx_bytes, cur_rx_bytes)

    def run(self):
        self.parseArgs()

        print("process: {}".format(self._args.name))
        while True:
            try:
              self.sample()
            except psutil.NoSuchProcess:
                print("process exited")
                if self._args.noRetry:
                    exit(0)
            """ except BaseException as err:
            print(f"Unexpected {err=}, {type(err)=}")
            exit(0)"""


if __name__ == "__main__":
    r = Sample()

    r.run()


