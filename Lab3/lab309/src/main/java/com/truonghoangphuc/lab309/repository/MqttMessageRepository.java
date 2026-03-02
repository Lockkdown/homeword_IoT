package com.truonghoangphuc.lab309.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.truonghoangphuc.lab309.entity.MqttMessage;

@Repository
public interface MqttMessageRepository extends JpaRepository<MqttMessage, Long> {
    List<MqttMessage> findAllByOrderByPublishedAtDesc();
}
