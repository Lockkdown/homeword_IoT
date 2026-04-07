package com.tinyiot.controller;

import com.tinyiot.dto.PzemReadingResponse;
import com.tinyiot.dto.RelayHistoryResponse;
import com.tinyiot.service.TelemetryQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/devices/{deviceId}/telemetry")
@RequiredArgsConstructor
public class TelemetryController {

    private final TelemetryQueryService telemetryQueryService;

    @GetMapping("/pzem/latest")
    public ResponseEntity<PzemReadingResponse> latestPzem(@PathVariable Long deviceId) {
        PzemReadingResponse r = telemetryQueryService.latestPzem(deviceId);
        if (r == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(r);
    }

    @GetMapping("/pzem")
    public ResponseEntity<List<PzemReadingResponse>> listPzem(
            @PathVariable Long deviceId,
            @RequestParam(defaultValue = "50") int limit
    ) {
        return ResponseEntity.ok(telemetryQueryService.listPzem(deviceId, limit));
    }

    @GetMapping("/relay-history")
    public ResponseEntity<List<RelayHistoryResponse>> relayHistory(
            @PathVariable Long deviceId,
            @RequestParam(defaultValue = "50") int limit
    ) {
        return ResponseEntity.ok(telemetryQueryService.relayHistory(deviceId, limit));
    }
}
