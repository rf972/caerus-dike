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
import datetime
from xmlrpc.server import SimpleXMLRPCServer
from xmlrpc.server import SimpleXMLRPCRequestHandler
from threading import Thread
import atexit
import signal

class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2',)


class SamplerService:
    def start_sample(self):
        return "starting sample of: "

    class currentTime:
        @staticmethod
        def getCurrentTime():
            return datetime.datetime.now()

class Sample:
    def __init__(self):
      self._args = None
      self._continueOnError = False
      self._debug = False
      self._excludeProcs = ["sample_server.py"]
      atexit.register(self.cleanup)
      self._procs = []

    def cleanup(self):
        for p in self._procs:
            print("killing subproc: {}".format(p))
            os.kill(p, signal.SIGTERM)
            os.kill(p, signal.SIGKILL)

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

    def getPid(self, name):
        pid = None

        for proc in psutil.process_iter():
            found = True
            for n in self._excludeProcs:
                if n in " ".join(proc.cmdline()) or n in proc.name():
                    found = False
                    break
            for n in name.split(","):
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

    def get_results_file(self, test_name):
        filename = test_name + '.csv'
        retry = 0
        while(os.path.exists(filename)):
            retry += 1
            filename = test_name + '_{}.csv'.format(retry)
        filename

    def sample(self, name="", test_name="", retry_limit = 0):
        retries = 0
        if name == "":
            name = self._args.name
            print("using default name {}".format(name))
        if test_name == "":
            test_name = self._args.results
        while retry_limit == 0 or retries < retry_limit:
            pid = self.getPid(name)
            if pid == None:
                print("cannot find pid for {} retry {}/{}\r".format(
                    name, retries, retry_limit), end="")
                if self._args.noRetry:
                    print("\r" + 80*" ")
                    exit(0)
                time.sleep(2)
                retries += 1
            else:
                print("\r" + 80*" ")
                break
        if pid == None:
            print("process {} not found after retries".format(name))
            return
        print("pid found: {}".format(pid))
        process = psutil.Process(pid)
        last_times = process.cpu_times()
        (last_tx_bytes, last_rx_bytes) = self.getBytes()

        results_file = self.get_results_file(test_name)
        with open(results_file, 'w') as results_fd:
            print("opening {}".format(test_name))
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

    def start_server(self):
        with SimpleXMLRPCServer(("10.124.48.87", 8000)) as server:
            server.register_instance(self, allow_dotted_names=True)
            server.register_multicall_functions()
            print('Serving XML-RPC on localhost port 8000')
            try:
                server.serve_forever()
            except KeyboardInterrupt:
                print("\nKeyboard interrupt received, exiting.")
                sys.exit(0)

    def run(self):
        self.parseArgs()
        self.start_server()

    def start_sample(self, name, test_name):
        print("process: [{}] [{}]".format(name, test_name))
        try:
            newpid = os.fork()
            if newpid == 0:
                self.sample(name, test_name, retry_limit=10)
                return
            else:
                self._procs.append(newpid)
                pids = (os.getpid(), newpid)
                print("parent: %d, child: %d\n" % pids)
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


