package com.truonghoangphuc.lab310.repository;
import com.truonghoangphuc.lab310.model.Device;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeviceRepository extends JpaRepository<Device, Long> {
}
