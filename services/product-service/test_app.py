import os
os.environ['AWS_XRAY_SDK_ENABLED'] = 'false'

import pytest  # noqa: E402
from app import app  # noqa: E402


@pytest.fixture
def client():
    with app.test_client() as client:
        yield client


def test_health(client):
    rv = client.get('/health')
    assert rv.status_code == 200
    assert b"healthy" in rv.data
