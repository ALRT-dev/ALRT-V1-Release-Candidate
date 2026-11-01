#!/usr/bin/env python3
"""Issue, list, or revoke single-use links for the one-time key drop.

  python3 issue_link.py                 # new link, valid 15 minutes, one view
  python3 issue_link.py --ttl 60 --note "for Claude, GDACS onboarding"
  python3 issue_link.py --list          # pending / consumed tokens
  python3 issue_link.py --revoke <id>   # kill a link before it is used

The link is only as secret as the channel you send it over. Send it in a
vault share or a direct message that auto-deletes, never in a shared chat.
Needs: boto3, credentials with dynamodb:PutItem/Scan/DeleteItem on the table
and cloudformation:DescribeStacks on the stack.
"""
import argparse
import datetime as dt
import os
import secrets
import sys
import time

import boto3
from botocore.exceptions import ClientError


def outputs(cfn, stack):
    try:
        s = cfn.describe_stacks(StackName=stack)["Stacks"][0]
    except ClientError as e:
        sys.exit(f"Cannot read stack {stack}: {e.response['Error']['Message']}")
    return {o["OutputKey"]: o["OutputValue"] for o in s.get("Outputs", [])}


def issue(ddb, table, url, ttl_min, note, issuer):
    rid = secrets.token_urlsafe(32)  # 256 bits, URL-safe
    now = int(time.time())
    exp = now + ttl_min * 60
    item = {
        "request_id": {"S": rid},
        "consumed": {"BOOL": False},
        "issued_at": {"N": str(now)},
        "expires_at": {"N": str(exp)},
        "issued_by": {"S": issuer},
    }
    if note:
        item["note"] = {"S": note}
    ddb.put_item(TableName=table, Item=item,
                 ConditionExpression="attribute_not_exists(request_id)")
    when = dt.datetime.fromtimestamp(exp, dt.timezone.utc).astimezone()
    print(f"Single-use link (expires {when:%Y-%m-%d %H:%M %Z}, one view):\n")
    print(f"  {url}?request_id={rid}\n")
    print(f"Revoke early with: python3 issue_link.py --revoke {rid}")


def list_tokens(ddb, table):
    now = int(time.time())
    items = ddb.scan(TableName=table).get("Items", [])
    if not items:
        print("No tokens on record.")
        return
    print(f"{'request_id (prefix)':<22}{'state':<10}{'expires':<22}{'consumer_ip':<16}note")
    for it in sorted(items, key=lambda i: int(i["issued_at"]["N"])):
        exp = int(it["expires_at"]["N"])
        if it["consumed"]["BOOL"]:
            state = "USED"
        elif exp <= now:
            state = "expired"
        else:
            state = "pending"
        when = dt.datetime.fromtimestamp(exp, dt.timezone.utc).astimezone()
        print(f"{it['request_id']['S'][:8] + '…':<22}{state:<10}{when:%Y-%m-%d %H:%M}      "
              f"{it.get('consumer_ip', {}).get('S', '-'):<16}{it.get('note', {}).get('S', '')}")


def revoke(ddb, table, rid):
    try:
        ddb.delete_item(TableName=table, Key={"request_id": {"S": rid}},
                        ConditionExpression="attribute_exists(request_id)")
    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            sys.exit("No such token.")
        raise
    print("Revoked.")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--stack", default=os.environ.get("STACK_NAME", "gdacs-key-drop"))
    p.add_argument("--region", default=os.environ.get("AWS_REGION", "ap-southeast-2"))
    p.add_argument("--ttl", type=int, default=15, help="minutes until the link expires (default 15, max 1440)")
    p.add_argument("--note", default="", help="who/what the link is for (stored with the token)")
    g = p.add_mutually_exclusive_group()
    g.add_argument("--list", action="store_true")
    g.add_argument("--revoke", metavar="REQUEST_ID")
    a = p.parse_args()
    if not 1 <= a.ttl <= 1440:
        sys.exit("--ttl must be between 1 and 1440 minutes")

    cfn = boto3.client("cloudformation", region_name=a.region)
    ddb = boto3.client("dynamodb", region_name=a.region)
    out = outputs(cfn, a.stack)
    table, url = out.get("TableName"), out.get("KeyUrl")
    if not table or not url:
        sys.exit(f"Stack {a.stack} is missing TableName/KeyUrl outputs; run deploy.sh")

    if a.list:
        list_tokens(ddb, table)
    elif a.revoke:
        revoke(ddb, table, a.revoke)
    else:
        issuer = boto3.client("sts", region_name=a.region).get_caller_identity()["Arn"]
        issue(ddb, table, url, a.ttl, a.note, issuer)


if __name__ == "__main__":
    main()
