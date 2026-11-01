"""Exercises the Lambda embedded in template.yaml against mocked AWS (moto).

  pip install "moto[dynamodb,secretsmanager]" pyyaml boto3
  python3 -m pytest backend/infra/key-drop/tests -q
"""
import importlib.util
import json
import os
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import boto3
import pytest
from moto import mock_aws

TEMPLATE = Path(__file__).resolve().parents[1] / "template.yaml"
REGION = "ap-southeast-2"
TABLE = "gdacs_key_access"
SECRET = "safetyalrt/gdacs-prod/webhook-key"


def lambda_source() -> str:
    text = TEMPLATE.read_text()
    block = re.search(r"ZipFile: \|\n((?:          .*\n|\n)+)", text).group(1)
    return "\n".join(line[10:] for line in block.splitlines())


def placeholder_secret() -> str:
    return re.search(r"SecretString: '(.*)'", TEMPLATE.read_text()).group(1)


@pytest.fixture
def env(monkeypatch):
    monkeypatch.setenv("AWS_DEFAULT_REGION", REGION)
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")
    monkeypatch.setenv("TABLE_NAME", TABLE)
    monkeypatch.setenv("SECRET_ID", SECRET)
    with mock_aws():
        ddb = boto3.client("dynamodb", region_name=REGION)
        ddb.create_table(
            TableName=TABLE, BillingMode="PAY_PER_REQUEST",
            AttributeDefinitions=[{"AttributeName": "request_id", "AttributeType": "S"}],
            KeySchema=[{"AttributeName": "request_id", "KeyType": "HASH"}])
        sm = boto3.client("secretsmanager", region_name=REGION)
        sm.create_secret(Name=SECRET, SecretString=placeholder_secret())

        path = Path(__file__).parent / "_index_under_test.py"
        path.write_text(lambda_source())
        spec = importlib.util.spec_from_file_location("index_under_test", path)
        mod = importlib.util.module_from_spec(spec)
        sys.modules.pop("index_under_test", None)
        spec.loader.exec_module(mod)
        try:
            yield mod, ddb, sm
        finally:
            path.unlink(missing_ok=True)


def put_token(ddb, rid, ttl=900, consumed=False):
    ddb.put_item(TableName=TABLE, Item={
        "request_id": {"S": rid}, "consumed": {"BOOL": consumed},
        "issued_at": {"N": str(int(time.time()))},
        "expires_at": {"N": str(int(time.time()) + ttl)}})


def event(rid, ip="203.0.113.9"):
    return {"queryStringParameters": {"request_id": rid},
            "requestContext": {"http": {"sourceIp": ip}}}


RID = "A" * 43  # token_urlsafe(32) length


def test_placeholder_secret_is_not_released_and_token_survives(env):
    mod, ddb, _ = env
    put_token(ddb, RID)
    r = mod.handler(event(RID), None)
    assert r["statusCode"] == 409
    assert "REPLACE_ME" not in r["body"]
    item = ddb.get_item(TableName=TABLE, Key={"request_id": {"S": RID}})["Item"]
    assert item["consumed"]["BOOL"] is False  # still usable once populated


def test_valid_token_releases_key_exactly_once(env):
    mod, ddb, sm = env
    sm.put_secret_value(SecretId=SECRET, SecretString='{"X-Webhook-Api-Key":"wk_live_abc"}')
    put_token(ddb, RID)
    first = mod.handler(event(RID), None)
    assert first["statusCode"] == 200
    assert json.loads(first["body"]) == {"X-Webhook-Api-Key": "wk_live_abc"}
    assert first["headers"]["Cache-Control"] == "no-store"
    second = mod.handler(event(RID, ip="198.51.100.2"), None)
    assert second["statusCode"] == 410
    assert "wk_live_abc" not in second["body"]
    item = ddb.get_item(TableName=TABLE, Key={"request_id": {"S": RID}})["Item"]
    assert item["consumed"]["BOOL"] is True
    assert item["consumer_ip"]["S"] == "203.0.113.9"  # first caller recorded, not the replay


def test_expired_unknown_and_malformed_tokens_are_refused(env):
    mod, ddb, sm = env
    sm.put_secret_value(SecretId=SECRET, SecretString='{"X-Webhook-Api-Key":"wk_live_abc"}')
    put_token(ddb, "B" * 43, ttl=-5)
    assert mod.handler(event("B" * 43), None)["statusCode"] == 410
    assert mod.handler(event("C" * 43), None)["statusCode"] == 410  # never issued
    assert mod.handler(event("short"), None)["statusCode"] == 400
    assert mod.handler(event("x" * 43 + "'; DROP"), None)["statusCode"] == 400
    assert mod.handler({"queryStringParameters": None}, None)["statusCode"] == 400
    for r in [mod.handler(event("B" * 43), None)]:
        assert "wk_live_abc" not in r["body"]


def test_concurrent_callers_only_one_wins(env):
    mod, ddb, sm = env
    sm.put_secret_value(SecretId=SECRET, SecretString='{"X-Webhook-Api-Key":"wk_live_abc"}')
    put_token(ddb, RID)
    with ThreadPoolExecutor(max_workers=8) as ex:
        codes = sorted(r["statusCode"] for r in ex.map(lambda _: mod.handler(event(RID), None), range(8)))
    assert codes == [200] + [410] * 7


def test_plain_string_secret_is_wrapped(env):
    mod, ddb, sm = env
    sm.put_secret_value(SecretId=SECRET, SecretString="rawkey-not-json-0123456789")
    put_token(ddb, RID)
    r = mod.handler(event(RID), None)
    assert json.loads(r["body"]) == {"X-Webhook-Api-Key": "rawkey-not-json-0123456789"}
