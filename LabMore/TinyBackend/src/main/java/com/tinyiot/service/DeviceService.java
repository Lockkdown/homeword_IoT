package com.tinyiot.service;

import com.tinyiot.dto.ControlRequest;
import com.tinyiot.dto.DeviceRequest;
import com.tinyiot.dto.DeviceResponse;
import com.tinyiot.model.Device;
import com.tinyiot.model.RelayHistory;
import com.tinyiot.model.User;
import com.tinyiot.repository.DeviceRepository;
import com.tinyiot.repository.RelayHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DeviceService {

    private final DeviceRepository deviceRepository;
    private final RelayHistoryRepository relayHistoryRepository;
    private final CurrentUserService currentUserService;
    private final MqttOutboundService mqttOutboundService;

    @Transactional(readOnly = true)
    public List<DeviceResponse> listMine() {
        User user = currentUserService.requireCurrentUser();
        return deviceRepository.findByUserOrderByCreatedAtDesc(user).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public DeviceResponse addOrUpdate(DeviceRequest req) {
        User user = currentUserService.requireCurrentUser();
        if (req.getDeviceId() == null || req.getDeviceId().isBlank()) {
            throw new IllegalArgumentException("deviceId is required");
        }
        if (req.getName() == null || req.getName().isBlank()) {
            throw new IllegalArgumentException("name is required");
        }

        deviceRepository.clearGlobalMqttReceivers();

        Device device = deviceRepository.findByUserAndDeviceId(user, req.getDeviceId())
                .orElse(null);
        if (device == null) {
            device = Device.builder()
                    .user(user)
                    .deviceId(req.getDeviceId().trim())
                    .name(req.getName().trim())
                    .build();
        } else {
            device.setName(req.getName().trim());
        }
        device.setReceivesGlobalMqtt(true);
        device.setOnline(true);
        device.setLastSeen(Instant.now());
        deviceRepository.save(device);
        return toResponse(device);
    }

    @Transactional
    public void delete(Long id) {
        User user = currentUserService.requireCurrentUser();
        Device device = deviceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Device not found"));
        if (!device.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Forbidden");
        }
        deviceRepository.delete(device);
    }

    @Transactional(readOnly = true)
    public DeviceResponse get(Long id) {
        User user = currentUserService.requireCurrentUser();
        Device device = deviceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Device not found"));
        if (!device.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Forbidden");
        }
        return toResponse(device);
    }

    @Transactional
    public DeviceResponse control(Long id, ControlRequest req) {
        User user = currentUserService.requireCurrentUser();
        Device device = deviceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Device not found"));
        if (!device.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Forbidden");
        }
        String cmd = req.getCommand();
        if (cmd == null || (!cmd.equalsIgnoreCase("ON") && !cmd.equalsIgnoreCase("OFF"))) {
            throw new IllegalArgumentException("command must be ON or OFF");
        }
        cmd = cmd.toUpperCase();

        mqttOutboundService.publishRelayCommand(cmd);
        mqttOutboundService.publishLedCommand(cmd);

        device.setStatus(cmd);
        device.setLastSeen(Instant.now());
        deviceRepository.save(device);

        RelayHistory rh = RelayHistory.builder()
                .device(device)
                .command(cmd)
                .source(RelayHistory.Source.API)
                .build();
        relayHistoryRepository.save(rh);

        return toResponse(device);
    }

    private DeviceResponse toResponse(Device d) {
        return DeviceResponse.builder()
                .id(d.getId())
                .deviceId(d.getDeviceId())
                .name(d.getName())
                .status(d.getStatus())
                .online(d.isOnline())
                .receivesGlobalMqtt(d.isReceivesGlobalMqtt())
                .createdAt(d.getCreatedAt())
                .lastSeen(d.getLastSeen())
                .build();
    }
}
