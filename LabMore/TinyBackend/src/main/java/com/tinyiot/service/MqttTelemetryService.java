package com.tinyiot.service;

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
    public static final String T_V = "tiny/power/voltage";
    public static final String T_A = "tiny/power/current";
    public static final String T_W = "tiny/power/watts";
    public static final String T_E = "tiny/power/energy";
    public static final String T_F = "tiny/power/frequency";
    public static final String T_PF = "tiny/power/pf";

    private final DeviceRepository deviceRepository;
    private final PzemReadingRepository pzemReadingRepository;
    private final RelayHistoryRepository relayHistoryRepository;
    private final TransactionTemplate tx;

    private final Object partialLock = new Object();
    private final PzemPartial partial = new PzemPartial();

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
            } else if (topic.startsWith("tiny/power/")) {
                tx.executeWithoutResult(status -> handlePowerTopic(topic, payload));
            }
        } catch (Exception e) {
            log.warn("MQTT handle error topic={} msg={}", topic, e.getMessage());
        }
    }

    @Scheduled(fixedDelay = 3000)
    public void scheduledFlushPartial() {
        synchronized (partialLock) {
            if (!partial.hasAny()) {
                return;
            }
            if (partial.isComplete() || partial.isStale(3000)) {
                tx.executeWithoutResult(status -> flushPartialLocked());
            }
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

    private void handlePowerTopic(String topic, String payload) {
        Device device = deviceRepository.findByReceivesGlobalMqttTrue().orElse(null);
        if (device == null) {
            return;
        }
        double v = parseDouble(payload);
        if (Double.isNaN(v)) {
            return;
        }
        synchronized (partialLock) {
            switch (topic) {
                case T_V -> partial.voltage = v;
                case T_A -> partial.current = v;
                case T_W -> partial.power = v;
                case T_E -> partial.energy = v;
                case T_F -> partial.frequency = v;
                case T_PF -> partial.powerFactor = v;
                default -> {
                    return;
                }
            }
            partial.touch();
        }

        device.setOnline(true);
        device.setLastSeen(Instant.now());
        deviceRepository.save(device);

        boolean complete;
        synchronized (partialLock) {
            complete = partial.isComplete();
        }
        if (complete) {
            tx.executeWithoutResult(status -> {
                synchronized (partialLock) {
                    flushPartialLocked();
                }
            });
        }
    }

    private void flushPartialLocked() {
        if (!partial.hasAny()) {
            return;
        }
        Device device = deviceRepository.findByReceivesGlobalMqttTrue().orElse(null);
        if (device == null) {
            partial.reset();
            return;
        }
        PzemReading reading = PzemReading.builder()
                .device(device)
                .voltage(partial.voltage)
                .current(partial.current)
                .power(partial.power)
                .energy(partial.energy)
                .frequency(partial.frequency)
                .powerFactor(partial.powerFactor)
                .build();
        pzemReadingRepository.save(reading);
        partial.reset();
    }

    private static double parseDouble(String payload) {
        try {
            return Double.parseDouble(payload != null ? payload.trim() : "NaN");
        } catch (Exception e) {
            return Double.NaN;
        }
    }

    private static final class PzemPartial {
        Double voltage;
        Double current;
        Double power;
        Double energy;
        Double frequency;
        Double powerFactor;
        long lastUpdateMs = 0L;

        void touch() {
            lastUpdateMs = System.currentTimeMillis();
        }

        void reset() {
            voltage = null;
            current = null;
            power = null;
            energy = null;
            frequency = null;
            powerFactor = null;
            lastUpdateMs = 0L;
        }

        boolean hasAny() {
            return voltage != null || current != null || power != null
                    || energy != null || frequency != null || powerFactor != null;
        }

        boolean isComplete() {
            return voltage != null && current != null && power != null
                    && energy != null && frequency != null && powerFactor != null;
        }

        boolean isStale(long maxAgeMs) {
            return lastUpdateMs > 0 && (System.currentTimeMillis() - lastUpdateMs) > maxAgeMs;
        }
    }
}
