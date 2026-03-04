package com.truonghoangphuc.lab311.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.truonghoangphuc.lab311.model.Device;

public interface DeviceRepository extends JpaRepository<Device, Long> {
}
