from __future__ import annotations

import argparse
from pathlib import Path

from .bronze import csv_to_bronze
from .download import download


def main(argv: list[str] | None = None) -> None:
    p = argparse.ArgumentParser(prog="dvf")
    sub = p.add_subparsers(dest="cmd", required=True)

    d = sub.add_parser("download", help="download a department-year CSV from data.gouv.fr")
    d.add_argument("--year", type=int, required=True)
    d.add_argument("--department", required=True, help="e.g. 34, 2A, 971")
    d.add_argument("--dest", type=Path, default=Path("data/raw"))

    b = sub.add_parser("bronze", help="convert a raw CSV(.gz) to partitioned Parquet")
    b.add_argument("--input", type=Path, required=True)
    b.add_argument("--out", type=Path, default=Path("data/bronze"))
    b.add_argument("--year", type=int, required=True)
    b.add_argument("--department", required=True)

    args = p.parse_args(argv)
    if args.cmd == "download":
        print(download(args.year, args.department, args.dest))
    else:
        print(csv_to_bronze(args.input, args.out, args.year, args.department))


if __name__ == "__main__":
    main()
