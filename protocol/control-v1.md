# Control Protocol v1

Phase 1 uses JSON messages over a local, unencrypted WebSocket connection.
The ESP32 listens on port `81`.

Default access-point URL:

```text
ws://192.168.4.1:81/
```

## Drive command

```json
{"v":1,"type":"drive","seq":42,"action":"forward","speed":180}
```

- `v`: protocol version, currently `1`
- `type`: `drive`
- `seq`: increasing client sequence number
- `action`: `forward`, `backward`, `left`, `right`, or `stop`
- `speed`: integer from `0` to `255`

The controller repeats a held direction every 250 ms. The ESP32 stops the
motors if no valid drive command arrives for 750 ms.

## Response

```json
{"v":1,"type":"ack","seq":42,"message":"forward","uptime_ms":12004}
```

`type` is `ack`, `status`, or `error`.
