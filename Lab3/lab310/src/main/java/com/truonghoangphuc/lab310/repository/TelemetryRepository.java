package com.truonghoangphuc.lab310.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import com.truonghoangphuc.lab310.model.Telemetry;

import java.util.List;
public interface TelemetryRepository extends JpaRepository<Telemetry, Long> {
    List<Telemetry> findByDeviceId(Long deviceId);
}
