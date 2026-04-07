package com.tinyiot.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tinyiot.model.Device;
import com.tinyiot.model.PzemReading;
import com.tinyiot.model.RelayHistory;
import com.tinyiot.repository.DeviceRepository;
import com.tinyiot.repository.PzemReadingRepository;
import com.tinyiot.repository.RelayHistoryRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Instant;

@Service
@Slf4j
public class MqttTelemetryService {

    public static final String T_RELAY_STATE = "tiny/relay/state";
    public static final String T_TELEMETRY = "tiny/telemetry";

    private final DeviceRepository deviceRepository;
    private final PzemReadingRepository pzemReadingRepository;
    private final RelayHistoryRepository relayHistoryRepository;
    private final TransactionTemplate tx;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public MqttTelemetryService(
            DeviceRepository deviceRepository,
            PzemReadingRepository pzemReadingRepository,
            RelayHistoryRepository relayHistoryRepository,
            PlatformTransactionManager transactionManager
    ) {
        this.deviceRepository = deviceRepository;
        this.pzemReadingRepository = pzemReadingRepository;
        this.relayHistoryRepository = relayHistoryRepository;
        this.tx = new TransactionTemplate(transactionManager);
    }

    public void handleIncoming(String topic, String payload) {
        if (topic == null) {
            return;
        }
        try {
            if (T_RELAY_STATE.equals(topic)) {
                tx.executeWithoutResult(status -> handleRelayState(payload));
            } else if (T_TELEMETRY.equals(topic)) {
                tx.executeWithoutResult(status -> handleTelemetry(payload));
            }
        } catch (Exception e) {
            log.warn("MQTT handle error topic={} msg={}", topic, e.getMessage());
        }
    }

    private void handleRelayState(String payload) {
        String cmd = payload != null ? payload.trim().toUpperCase() : "";
        if (!cmd.equals("ON") && !cmd.equals("OFF")) {
            return;
        }
        Device device = deviceRepository.findByReceivesGlobalMqttTrue().orElse(null);
        if (device == null) {
            log.debug("No active device for relay state MQTT");
            return;
        }
        device.setStatus(cmd);
        device.setOnline(true);
        device.setLastSeen(Instant.now());
        deviceRepository.save(device);

        RelayHistory rh = RelayHistory.builder()
                .device(device)
                .command(cmd)
                .source(RelayHistory.Source.MQTT)
                .build();
        relayHistoryRepository.save(rh);
    }

    private void handleTelemetry(String payload) {
        Device device = deviceRepository.findByReceivesGlobalMqttTrue().orElse(null);
        if (device == null) {
            return;
        }

        try {
            JsonNode json = objectMapper.readTree(payload);
            
            // Save PZEM Reading
            PzemReading reading = PzemReading.builder()
                    .device(device)
                    .voltage(json.has("voltage") ? json.get("voltage").asDouble() : 0.0)
                    .current(json.has("current") ? json.get("current").asDouble() : 0.0)
                    .power(json.has("power") ? json.get("power").asDouble() : 0.0)
                    .energy(json.has("energy") ? json.get("energy").asDouble() : 0.0)
                    .frequency(json.has("frequency") ? json.get("frequency").asDouble() : 0.0)
                    .powerFactor(json.has("power_factor") ? json.get("power_factor").asDouble() : 0.0)
                    .build();
            pzemReadingRepository.save(reading);

            // Update Device Status if included
            if (json.has("status")) {
                String cmd = json.get("status").asText().toUpperCase();
                if (cmd.equals("ON") || cmd.equals("OFF")) {
                    device.setStatus(cmd);
                }
            }

            device.setOnline(true);
            device.setLastSeen(Instant.now());
            deviceRepository.save(device);

        } catch (Exception e) {
            log.warn("Failed to parse telemetry JSON: {}", e.getMessage());
        }
    }
}
