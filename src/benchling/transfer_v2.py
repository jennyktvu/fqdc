import requests
import pandas as pd
import json
import sys
import argparse
import string

base_url = "https://calicotest.benchling.com/api/v2"
headers = {
    "accept": "application/json",
    "Content-Type": "application/json",
}

col_sc = "Source Container"
col_sw = "Source Well"
col_dcon = "Destination Container"
col_dcol = "Destination Column (124)"
col_vol = "Volume"

def get_barcode_cid_dict(barcodes, token):
    barcode_cid_dict = {}
    cids = []
    query_str = ",".join(barcodes)
    url = f"{base_url}/plates:bulk-get?barcodes={query_str}"
    print(f"GET {url}")
    response = requests.get(url, auth=(token, ""))
    res_dict = json.loads(response.content)
    # print(res_dict)
    for c in res_dict["plates"]:
        cids.append(c["id"])
    print(f"status_code: {response.status_code}, response: {cids}")
    # assert len(cids) == len(barcodes)
    for i in range(len(barcodes)):
        barcode_cid_dict[barcodes[i]] = cids[i]
    return barcode_cid_dict


def get_col_wells(col_idx):
    wells = []
    for c in list(string.ascii_uppercase)[:16]:
        wells.append(f"{c}{col_idx}")
    return wells

def gen_transfer_infos(sb, sw, db, dcol, vol):
    tis = []
    dwells = get_col_wells(dcol)
    for well in dwells:
        item = {
            "Source ID": sb,
            "Dest ID": f"{db}:{well}",
            "Units": "uL",
            "Value": vol
        }
        tis.append(item)
    return tis

def do_transfer(transfer_infos, token):
    transfers = []
    length = len(transfer_infos)
    for i in range(length):
        t = {
            "sourceContainerId": transfer_infos[i]["Source ID"],
            "transferVolume": {
                "units": transfer_infos[i]["Units"],
                "value": transfer_infos[i]["Value"]
            },
            "destinationContainerId": transfer_infos[i]["Dest ID"],
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
    source_barcodes = list(map( lambda x: x[:3] + '-' + x[3:], df.loc[:, col_sc].tolist()))
    dest_barcodes = list(map(lambda x: x[:4] + '-' + x[4:], df.loc[:, col_dcon].tolist()))
    src_barcode_cid_dict = get_barcode_cid_dict(source_barcodes, token)
    dest_barcode_cid_dict = get_barcode_cid_dict(dest_barcodes, token)
    df["sb"] = source_barcodes
    df["db"] = dest_barcodes
    # print(src_barcode_cid_dict)
    # print(dest_barcode_cid_dict)
    # print(df)

    for _, row in df.iterrows():
        transfer_infos = gen_transfer_infos(row["sb"],
                                            row[col_sw],
                                            row["db"],
                                            row[col_dcol],
                                            row[col_vol])
        # print(transfer_infos)
        do_transfer(transfer_infos, token)



if __name__ == "__main__":
    main()
