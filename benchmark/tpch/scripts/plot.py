#!/usr/bin/python3

import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import argparse
from argparse import RawTextHelpFormatter
import time
import subprocess
import sys
import os

class Convert:
    def __init__(self):
      self._args = None
      self.parseArgs()

    def parseArgs(self):
        parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                         description="Plot matplotlib charts of csv data.\n")
        parser.add_argument("--debug", "-D",
                            help="enable debug output")
        parser.add_argument("--show", "-s", default=False,
                            help="show chart")
        parser.add_argument("--file", "-i", required=True,
                            help="input file")
        self._args = parser.parse_args()

    def sumTransfers(row):
        return row['txbytes'] + row['rxbytes']
    def bytes_to_mb(row, column):
        return row[column] / (1024 * 1024)

    def create_chart(self, file_name):
        df = pd.read_csv(file_name)
        df['cumulative'] = df.apply(
            lambda row: Convert.sumTransfers(row), axis=1)
        df['txmb'] = df.apply(
            lambda row: Convert.bytes_to_mb(row, "txbytes"), axis=1)
        df['rxmb'] = df.apply(
            lambda row: Convert.bytes_to_mb(row, "rxbytes"), axis=1)

        plot_name = file_name.replace(".csv", "").replace("_", " ")
        fig, axs = plt.subplots(2)
        fig.suptitle(plot_name)

        time_label = "Time (seconds)"

        axs[0].title.set_text('CPU Utilization')
        cputime_line, = axs[0].plot(range(0, len(df.index)), df['cputime'])
        cputime_line.set_label('CPUs')

        axs[0].set(xlabel=time_label, ylabel='CPUs')
        axs[0].set_ylim([0, 16])
        axs[0].legend()
        axs[0].grid(which='major')

        axs[1].title.set_text('Network Bandwidth')
        axs[1].set_ylim([0, 128])

        tx_line, = axs[1].plot(range(0, len(df.index)), df['txmb'], color='orange')
        tx_line.set_label('TX')
        axs[1].set(xlabel=time_label, ylabel='MB/s')

        rx_line, = axs[1].plot(range(0, len(df.index)), df['rxmb'], color='black')
        rx_line.set_label('RX')
        axs[1].set(xlabel=time_label, ylabel='MB/s')
        axs[1].legend()
        axs[1].grid(which='major')

        # Give more space between plots for lower title and upper axis lable to be clear.
        plt.subplots_adjust(hspace=0.6)
        #axs[1].plot(range(0, len(df.index)), df['cumulative'])
        #axs[1].set(xlabel='time', ylabel='cumulative')
        output_file = file_name.replace(".csv", ".jpg")
        plt.savefig(output_file, format="jpg")
        if self._args.show:
            plt.show()

    def run(self):
        files = self._args.file.split(",")
        for f in files:
            self.create_chart(f)


if __name__ == "__main__":
    c = Convert()

    c.run()



