HOST="192.168.99.100"
PORT = 8000
HTTPS = True

DYNAMIC_CLIENT_REGISTRATION_PORT_RANGE_MIN = 8001
DYNAMIC_CLIENT_REGISTRATION_PORT_RANGE_MAX = 8005

STATIC_CLIENT_REGISTRATION_PORT_RANGE_MIN = 8501
STATIC_CLIENT_REGISTRATION_PORT_RANGE_MAX = 8505

if HTTPS:
    BASE = "https://%s:%d/" % (HOST, PORT)
else:
    BASE = "http://%s:%d/" % (HOST, PORT)

# If BASE is https these has to be specified
SERVER_CERT = "certificates/server.crt"
SERVER_KEY = "certificates/server.key"
CA_BUNDLE = None

PORT_DATABASE_FILE = "./static_ports.db"

OPRP_SSL_MODULE = "sslconf"

OPRP_TEST_FLOW = "tflow"

CONFIG_MAX_NUMBER_OF_CHARS_ALLOWED = 10000

CLIENT = {
    # loose way
    'allow': {
        "issuer_mismatch": True,
        "no_https_issuer": True,
    },
}
