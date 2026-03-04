package com.truonghoangphuc.lab311.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.truonghoangphuc.lab311.model.Telemetry;

import java.util.List;

public interface TelemetryRepository extends JpaRepository<Telemetry, Long> {
    List<Telemetry> findByDeviceId(Long deviceId);
}
