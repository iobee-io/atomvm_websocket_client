# WebSocket client example

Connects to `wss://echo.websocket.org/` over TLS and echoes a message a second.

The TLS verification is as much the point as the echo: `verify => crt_bundle`
checks the server certificate against ESP-IDF's bundled roots, so replies mean
DNS, TCP, TLS against a real trust store, the WebSocket handshake, framing and
delivery into an Erlang process are all working.

## Build and run

Build an AtomVM image that includes the port:

```bash
cd AtomVM/src/platforms/esp32
idf.py -DEXTRA_COMPONENT_DIRS=/path/to/atomvm_websocket_client build
idf.py flash
```

`CONFIG_MBEDTLS_CERTIFICATE_BUNDLE` must be enabled in the AtomVM build for
`verify => crt_bundle`; it is on by default in ESP-IDF.

Then set up WiFi and flash this application:

```bash
cp src/config.erl-template src/config.erl
$EDITOR src/config.erl
rebar3 atomvm esp32_flash
```

## Expected output

```
Acquired IP address: {192,168,1,42} Netmask: {255,255,255,0} Gateway: {192,168,1,1}
Connecting to wss://echo.websocket.org/
Connected.
Sent: <<"hello 1">>
Received: <<"hello 1">>
Received: <<"hello 2">>
```
