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
public class PzemReadingResponse {
    private Long id;
    private Double voltage;
    private Double current;
    private Double power;
    private Double energy;
    private Double frequency;
    private Double powerFactor;
    private Instant timestamp;
}
