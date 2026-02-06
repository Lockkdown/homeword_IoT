package com.truonghoangphuc.lab310.repository;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.truonghoangphuc.lab310.model.Telemetry;
public interface TelemetryRepository extends JpaRepository<Telemetry, Long> {
    List<Telemetry> findByDeviceId(Long deviceId);
}