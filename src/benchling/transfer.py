import requests
import pandas as pd
import json
import sys
import argparse

base_url = "https://calicotest.benchling.com/api/v2"
headers = {
    "accept": "application/json",
    "Content-Type": "application/json",
}


def convert_to_cids(barcodes, token):
    cids = []
    query_str = ",".join(barcodes)
    url = f"{base_url}/containers:bulk-get?barcodes={query_str}"
    print(f"GET {url}")
    response = requests.get(url, auth=(token, ""))
    res_dict = json.loads(response.content)
    for c in res_dict["containers"]:
        cids.append(c["id"])
    print(f"status_code: {response.status_code}, response: {cids}")
    assert len(cids) == len(barcodes)
    return cids


def do_transfer(transfer_infos, token):
    transfers = []
    length = len(transfer_infos["Source ID"])
    for i in range(length):
        t = {
            "sourceContainerId": transfer_infos["Source ID"][i],
            "transferVolume": {
                "units": transfer_infos["Units"][i],
                "value": transfer_infos["Value"][i],
            },
            "destinationContainerId": transfer_infos["Dest ID"][i],
            "sourceConcentration": {},
        }
        transfers.append(t)

    data_dict = {"transfers": transfers}
    data = json.dumps(data_dict, indent=4)
    url = f"{base_url}/transfers"
    print(f"POST {url}")
    print(f"payload: {data}")
    response = requests.post(url, headers=headers, data=data, auth=(token, ""))
    print(
        f"status_code: {response.status_code}, response: {json.loads(response.content)}"
    )


def main():
    parser = argparse.ArgumentParser(description="Benchling liquid Transfer tool")
    parser.add_argument("-f", dest="csv_path", action="store", help="input csv file")
    parser.add_argument("-t", dest="token", action="store", help="Benchling API token")
    args = parser.parse_args()
    if args.csv_path is None or args.token is None:
        parser.print_help()
        sys.exit(-1)
    input_csv_path = args.csv_path
    token = args.token
    df = pd.read_csv(input_csv_path)
    source_barcodes = df.loc[:, "Source Barcode"].tolist()
    source_cids = convert_to_cids(source_barcodes, token)
    df["Dest Barcode"] = df.loc[:, "Dest Plate Barcode"] + ":" + df.loc[:, "Well"]
    dest_cids = convert_to_cids(df.loc[:, "Dest Barcode"].tolist(), token)
    df["Source ID"] = source_cids
    df["Dest ID"] = dest_cids
    transfer_infos = df.to_dict()
    do_transfer(transfer_infos, token)


if __name__ == "__main__":
    main()
