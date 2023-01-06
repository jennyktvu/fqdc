# transfer.py

A script to read a input csv and run Benchling API to transfer liquid between containers

## Dependency Installation

- Run `pip install -r requirements.txt`

## Example input csv file

```
Source Barcode,Dest Barcode,Value,Units
TUBE-11756,384W-013:A1,50,uL
TUBE-11756,384W-013:A2,40,uL
```

## Usage

```
usage: transfer.py [-h] [-f CSV_PATH] [-t TOKEN]

Benchling liquid Transfer tool

optional arguments:
  -h, --help   show this help message and exit
  -f CSV_PATH  input csv file
  -t TOKEN     Benchling API token
```

