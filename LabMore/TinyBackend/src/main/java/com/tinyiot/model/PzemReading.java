package com.tinyiot.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(name = "pzem_readings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PzemReading {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "device_pk")
    private Device device;

    private Double voltage;
    private Double current;
    private Double power;
    private Double energy;
    private Double frequency;
    private Double powerFactor;

    @Column(nullable = false)
    private Instant timestamp;

    @PrePersist
    void prePersist() {
        if (timestamp == null) {
            timestamp = Instant.now();
        }
    }
}
