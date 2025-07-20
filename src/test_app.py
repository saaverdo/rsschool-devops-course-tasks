import sys
import pytest
from appy import app, db
from app.models import Record
# sys.path.append("..")

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
        yield client
        with app.app_context():
            db.drop_all()

def test_index(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b'Hello,Stranger!' in response.data

def test_display(client):
    # Add a record first
    with app.app_context():
        record = Record(hostname='pytesthost', remote_ip='127.0.0.1', date='2025-07-19 12:00')
        db.session.add(record)
        db.session.commit()
    response = client.get('/display')
    assert response.status_code == 200
    assert b'pytesthost' in response.data
    assert b'127.0.0.1' in response.data

def test_healthcheck(client):
    response = client.get('/healthcheck')
    assert response.status_code == 200
    assert b'ok' in response.data