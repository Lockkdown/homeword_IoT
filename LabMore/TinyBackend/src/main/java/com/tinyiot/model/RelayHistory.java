package com.tinyiot.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(name = "relay_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RelayHistory {

    public enum Source {
        MQTT,
        API
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "device_pk")
    private Device device;

    /** ON or OFF */
    @Column(name = "relay_command", nullable = false)
    private String command;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Source source;

    @Column(nullable = false)
    private Instant timestamp;

    @PrePersist
    void prePersist() {
        if (timestamp == null) {
            timestamp = Instant.now();
        }
    }
}
