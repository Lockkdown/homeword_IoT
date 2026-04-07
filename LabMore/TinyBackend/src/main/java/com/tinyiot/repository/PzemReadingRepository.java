package com.tinyiot.repository;

import com.tinyiot.model.PzemReading;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PzemReadingRepository extends JpaRepository<PzemReading, Long> {

    List<PzemReading> findByDevice_IdOrderByTimestampDesc(Long deviceId, Pageable pageable);

    Optional<PzemReading> findTopByDevice_IdOrderByTimestampDesc(Long deviceId);
}
