# TinyIoT Backend

## Docker (PostgreSQL + pgAdmin + Mosquitto)

```bash
cd LabMore/TinyBackend
docker compose up -d
```

- **PostgreSQL**: `localhost:5433`, DB `tinyiot`, user/pass `tinyiot` / `tinyiot123`
- **pgAdmin**: http://localhost:5050 — `admin@tinyiot.local` / `admin123` — thêm server: Host `postgres`, Port `5432`, user `tinyiot`, password `tinyiot123`
- **Mosquitto**: `localhost:1884` (MQTT), `localhost:9002` (WebSocket)

## Chạy Spring Boot

Cần JDK 17+ và Docker đã chạy.

```bash
mvn spring-boot:run
```

API: http://localhost:8080  

- `POST /api/auth/register` — `{ "username", "email", "password" }`
- `POST /api/auth/login` — `{ "username", "password" }` (username hoặc email)
- `GET/POST/DELETE /api/devices` — header `Authorization: Bearer <jwt>`

Firmware ESP32 dùng topic global `tiny/power/*`, `tiny/relay/state`; thiết bị vừa add (`receivesGlobalMqtt=true`) nhận telemetry.

## MQTT Broker

ESP32 kết nối **EMQX** (port 1883). Backend và Flutter cũng phải dùng cùng broker này.

- ESP32: `mqtt://192.168.1.58:1883` (sdkconfig)
- Backend: `tcp://localhost:1883` (application.yml)
- Flutter:
```bash
flutter run \
  --dart-define=API_BASE_URL=http://192.168.1.58:8080 \
  --dart-define=MQTT_HOST=192.168.1.58 \
  --dart-define=MQTT_PORT=1883
```

## Luồng đồng bộ bật/tắt

```
Flutter UI toggle → POST /api/devices/{id}/control
  → Backend publish tiny/relay/command → EMQX 1883
    → ESP32 nhận lệnh, toggle relay GPIO
      → ESP32 publish tiny/relay/state (ON/OFF)
        → Flutter MQTT listener cập nhật UI (2 chiều)
        → Backend lưu relay_history (source=MQTT)
```
