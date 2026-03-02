package com.truonghoangphuc.lab310.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import com.truonghoangphuc.lab310.model.Device;

public interface DeviceRepository extends JpaRepository<Device, Long> {
}
