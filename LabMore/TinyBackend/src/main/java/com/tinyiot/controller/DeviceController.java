package com.tinyiot.controller;

import com.tinyiot.dto.ControlRequest;
import com.tinyiot.dto.DeviceRequest;
import com.tinyiot.dto.DeviceResponse;
import com.tinyiot.service.DeviceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/devices")
@RequiredArgsConstructor
public class DeviceController {

    private final DeviceService deviceService;

    @GetMapping
    public ResponseEntity<List<DeviceResponse>> list() {
        return ResponseEntity.ok(deviceService.listMine());
    }

    @PostMapping
    public ResponseEntity<DeviceResponse> add(@RequestBody DeviceRequest request) {
        return ResponseEntity.ok(deviceService.addOrUpdate(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeviceResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(deviceService.get(id));
    }

    @GetMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> status(@PathVariable Long id) {
        DeviceResponse d = deviceService.get(id);
        return ResponseEntity.ok(Map.of(
                "status", d.getStatus(),
                "online", d.isOnline(),
                "receivesGlobalMqtt", d.isReceivesGlobalMqtt()
        ));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        deviceService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/control")
    public ResponseEntity<DeviceResponse> control(@PathVariable Long id, @RequestBody ControlRequest request) {
        return ResponseEntity.ok(deviceService.control(id, request));
    }
}
