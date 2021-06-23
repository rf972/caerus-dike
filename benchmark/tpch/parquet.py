from __future__ import print_function

import argparse
import sys
import base64

import pyarrow as pa
import pandas as pd
import pyarrow.parquet as pq


def get_metadata(parquet_file):
    r = pq.ParquetFile(parquet_file)
    return r.metadata

def get_row_group_metadata(parquet_file, group):
    r = pq.ParquetFile(parquet_file)
    return r.metadata.row_group(group)

def get_row_group_col_metadata(parquet_file, group, col):
    r = pq.ParquetFile(parquet_file)
    return r.metadata.row_group(group).column(col)

def print_key_value_metadata(parquet_file):
    meta = pq.read_metadata(parquet_file)
    #print("\n{}\n".format(meta.metadata.keys()))
    for key in meta.metadata.keys():
      print("\n{}:\n   {}".format(key, meta.metadata[key]))
    
    #decoded_schema = base64.b64decode(meta.metadata[b"ARROW:schema"])
    #schema = pa.ipc.read_schema(pa.BufferReader(decoded_schema))
    #print(schema)

def get_schema(parquet_file):
    r = pq.ParquetFile(parquet_file)
    return r.schema


def get_data(pq_table, n, head=True):
    data = pq_table.to_pandas()
    if head:
        rows = data.head(n)
    else:
        rows = data.tail(n)
    return rows

def write_multiplied_table(pq_table, output_prefix):
    df = pq_table.to_pandas()
    add_multiplier = 1
    prev_df = df
    for i in range(0, add_multiplier):
        print("append {} ".format(i))
        new_df = prev_df.append(df)
        prev_df = new_df
    print("new_df rows {}".format(len(new_df.index)))
    new_table = pa.Table.from_pandas(new_df)
    pq.write_table(new_table, output_prefix + "ex_large.snappy.parquet", data_page_size=100*1024*1024*1024)

def write_table(pq_table, output_prefix):
    df = pq_table.to_pandas()
    rows = len(df.index)
    print("rows {}".format(rows))
    print("output file " + output_prefix)
    new_df = df[:int(7)]
    new_table = pa.Table.from_pandas(new_df)
    pq.write_table(new_table, output_prefix + ".parquet.snappy", data_page_size=1024*1024*1024)
    #pq.write_table(pq_table, output_prefix + "full.snappy.parquet", data_page_size=1024*1024*1024)

def query_table(pq_table, query):
    df = pq_table.to_pandas()
    rows = len(df.index)
    print("rows {}".format(rows))
    print("output: " + query)
    new_df = df[['l_quantity','l_extendedprice','l_discount','l_shipdate']]
    new_table = pa.Table.from_pandas(new_df)
    pq.write_table(new_table, "query" + ".parquet.snappy", data_page_size=1024*1024*1024)

def main(cmd_args=sys.argv, skip=False):
    """
    Main entry point with CLI arguments
    :param cmd_args: args passed from CLI
    :param skip: bool, whether to skip init_args call or not
    :return: string stdout
    """
    if not skip:
        cmd_args = init_args()

    pd.set_option('display.max_columns', None)
    pd.set_option('display.max_rows', None)

    pq_table = pq.read_table(cmd_args.file)
    if cmd_args.write:
        #write_multiplied_table(pq_table, cmd_args.write)
        write_table(pq_table, cmd_args.write)
    elif cmd_args.query:
        query_table(pq_table, cmd_args.query)
    elif cmd_args.head:
        print(get_data(pq_table, cmd_args.head))
    elif cmd_args.tail:
        print(get_data(pq_table, cmd_args.tail, head=False))
    elif cmd_args.count:
        print(len(pq_table.to_pandas().index))
    elif cmd_args.schema:
        print("\n # Schema \n", get_schema(cmd_args.file))
    else:
        file_md = get_metadata(cmd_args.file)
        print("\n # Metadata \n", file_md)
        for i in range(0, file_md.num_row_groups):
            rg_md = get_row_group_metadata(cmd_args.file, i)
            print("\n # Row Group {}\n".format(i), rg_md)
            for c in range(0, rg_md.num_columns):
                col_md = get_row_group_col_metadata(cmd_args.file, i, c)
                print("\n Column {}\n".format(c), col_md)
        print_key_value_metadata(cmd_args.file)

def init_args():
    parser = argparse.ArgumentParser(
        description="Command line (CLI) tool to inspect Apache Parquet files on the go",
        usage="usage: parq file [-s [SCHEMA] | --head [HEAD] | --tail [TAIL] | -c [COUNT]]"
    )

    group = parser.add_mutually_exclusive_group()

    group.add_argument("-s",
                       "--schema",
                       nargs="?",
                       type=bool,
                       const=True,
                       help="get schema information",
                       )

    group.add_argument("--head",
                       nargs="?",
                       type=int,
                       const=10,
                       help="get first N rows from file"
                       )

    group.add_argument("--tail",
                       nargs="?",
                       type=int,
                       const=10,
                       help="get last N rows from file"
                       )

    group.add_argument("-c",
                       "--count",
                       nargs="?",
                       type=bool,
                       const=True,
                       help="get total rows count",
                       )

    group.add_argument("-w", "--write", default="",
                       help="output file")

    group.add_argument("-q", "--query", default="",
                       help="run a query on a dataframe")

    parser.add_argument("file",
                        type=argparse.FileType('rb'),
                        help='Parquet file')

    cmd_args = parser.parse_args()

    return cmd_args


if __name__ == '__main__':
    args = init_args()
    main(args, skip=True)
