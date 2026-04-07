package com.tinyiot.repository;

import com.tinyiot.model.Device;
import com.tinyiot.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface DeviceRepository extends JpaRepository<Device, Long> {

    List<Device> findByUserOrderByCreatedAtDesc(User user);

    Optional<Device> findByUserAndDeviceId(User user, String deviceId);

    Optional<Device> findByReceivesGlobalMqttTrue();

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE Device d SET d.receivesGlobalMqtt = false WHERE d.receivesGlobalMqtt = true")
    void clearGlobalMqttReceivers();

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE Device d SET d.receivesGlobalMqtt = false WHERE d.user.id = :userId")
    void clearGlobalMqttReceiversForUser(@Param("userId") Long userId);
}
