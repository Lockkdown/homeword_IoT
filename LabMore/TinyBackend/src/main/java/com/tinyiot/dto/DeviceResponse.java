package com.tinyiot.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeviceResponse {
    private Long id;
    private String deviceId;
    private String name;
    private String status;
    private boolean online;
    private boolean receivesGlobalMqtt;
    private Instant createdAt;
    private Instant lastSeen;
}
