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
public class RelayHistoryResponse {
    private Long id;
    private String command;
    private String source;
    private Instant timestamp;
}
