package com.tinyiot.service;

import com.tinyiot.dto.PzemReadingResponse;
import com.tinyiot.dto.RelayHistoryResponse;
import com.tinyiot.model.Device;
import com.tinyiot.model.PzemReading;
import com.tinyiot.model.RelayHistory;
import com.tinyiot.model.User;
import com.tinyiot.repository.DeviceRepository;
import com.tinyiot.repository.PzemReadingRepository;
import com.tinyiot.repository.RelayHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TelemetryQueryService {

    private final DeviceRepository deviceRepository;
    private final PzemReadingRepository pzemReadingRepository;
    private final RelayHistoryRepository relayHistoryRepository;
    private final CurrentUserService currentUserService;

    @Transactional(readOnly = true)
    public List<PzemReadingResponse> listPzem(Long devicePk, int limit) {
        Device device = requireOwnedDevice(devicePk);
        return pzemReadingRepository.findByDevice_IdOrderByTimestampDesc(
                        device.getId(),
                        PageRequest.of(0, Math.min(Math.max(limit, 1), 200))
                ).stream()
                .map(this::toPzem)
                .toList();
    }

    @Transactional(readOnly = true)
    public PzemReadingResponse latestPzem(Long devicePk) {
        Device device = requireOwnedDevice(devicePk);
        return pzemReadingRepository.findTopByDevice_IdOrderByTimestampDesc(device.getId())
                .map(this::toPzem)
                .orElse(null);
    }

    @Transactional(readOnly = true)
    public List<RelayHistoryResponse> relayHistory(Long devicePk, int limit) {
        Device device = requireOwnedDevice(devicePk);
        return relayHistoryRepository.findByDevice_IdOrderByTimestampDesc(
                        device.getId(),
                        PageRequest.of(0, Math.min(Math.max(limit, 1), 200))
                ).stream()
                .map(this::toRelay)
                .toList();
    }

    private Device requireOwnedDevice(Long devicePk) {
        User user = currentUserService.requireCurrentUser();
        Device device = deviceRepository.findById(devicePk)
                .orElseThrow(() -> new IllegalArgumentException("Device not found"));
        if (!device.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Forbidden");
        }
        return device;
    }

    private PzemReadingResponse toPzem(PzemReading r) {
        return PzemReadingResponse.builder()
                .id(r.getId())
                .voltage(r.getVoltage())
                .current(r.getCurrent())
                .power(r.getPower())
                .energy(r.getEnergy())
                .frequency(r.getFrequency())
                .powerFactor(r.getPowerFactor())
                .timestamp(r.getTimestamp())
                .build();
    }

    private RelayHistoryResponse toRelay(RelayHistory r) {
        return RelayHistoryResponse.builder()
                .id(r.getId())
                .command(r.getCommand())
                .source(r.getSource().name())
                .timestamp(r.getTimestamp())
                .build();
    }
}
