package com.truonghoangphuc.lab311.controller;

import com.truonghoangphuc.lab311.model.Telemetry;
import com.truonghoangphuc.lab311.repository.TelemetryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/telemetry")
public class TelemetryController {
    @Autowired
    private TelemetryRepository telemetryRepository;

    @GetMapping("/{deviceId}")
    public List<Telemetry> getByDevice(@PathVariable Long deviceId) {
        return telemetryRepository.findByDeviceId(deviceId);
    }
}
