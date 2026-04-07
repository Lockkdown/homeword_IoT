package com.tinyiot.repository;

import com.tinyiot.model.RelayHistory;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RelayHistoryRepository extends JpaRepository<RelayHistory, Long> {

    List<RelayHistory> findByDevice_IdOrderByTimestampDesc(Long deviceId, Pageable pageable);
}
