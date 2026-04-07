package com.tinyiot.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(
        name = "devices",
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "device_id"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Device {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Hardware id from firmware e.g. esp32_AABBCCDD */
    @Column(name = "device_id", nullable = false)
    private String deviceId;

    @Column(nullable = false)
    private String name;

    /** ON / OFF relay state */
    @Column(nullable = false)
    @Builder.Default
    private String status = "OFF";

    @Column(nullable = false)
    @Builder.Default
    private boolean online = false;

    /**
     * Only one device in the whole system should receive global MQTT topics
     * (firmware publishes to tiny/power/* without device id in topic).
     */
    @Column(nullable = false)
    @Builder.Default
    private boolean receivesGlobalMqtt = false;

    @Column(nullable = false)
    private Instant createdAt;

    private Instant lastSeen;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @PrePersist
    void prePersist() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
