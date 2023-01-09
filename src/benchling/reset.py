'''
It's a handy script to reset test container's volulme
'''
import requests
import json
import argparse
import sys

BASE_URL = "https://calicotest.benchling.com/api/v2"

HEADERS = {
    "accept": "application/json",
    "Content-Type": "application/json",
}

def set_vol(cid,  value, units, token):
    payload = {
        "quantity": {
            "units": units,
            "value": value
        }
    }

    data = json.dumps(payload, indent=4)
    url = f"{BASE_URL}/containers/{cid}"
    print(f"POST {url}")
    print(f"payload: {data}")
    response = requests.patch(url, headers=HEADERS, data=data, auth=(token, ""))
    print(
        f"status_code: {response.status_code}, response: {json.loads(response.content)}"
    )

def main():
    parser = argparse.ArgumentParser(description="Benchling liquid reset tool")
    parser.add_argument("-t", dest="token", action="store", help="Benchling API token")
    args = parser.parse_args()
    if args.token is None:
        parser.print_help()
        sys.exit(-1)
    token = args.token
    # reset desc containers
    set_vol("con_vnIRujNJ", 0, "uL", token)
    set_vol("con_WoQmGkgI", 0, "uL", token)
    # reset source containers
    set_vol("con_n4Lnt2G2", 5000, "uL", token)

if __name__ == "__main__":
    main()
