package com.truonghoangphuc.lab311.controller;

import com.truonghoangphuc.lab311.model.Device;
import com.truonghoangphuc.lab311.repository.DeviceRepository;
import com.truonghoangphuc.lab311.service.MqttPublisherService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/devices")
public class DeviceController {
    @Autowired
    private DeviceRepository deviceRepository;
    @Autowired
    private MqttPublisherService mqttPublisherService;
    @Autowired
    private MqttPahoMessageDrivenChannelAdapter mqttAdapter;

    @GetMapping
    public List<Device> getAllDevices() {
        return deviceRepository.findAll();
    }

    @PostMapping
    public Device createDevice(@RequestBody Device device) {
        mqttAdapter.addTopic(device.getTopic(), 1);
        return deviceRepository.save(device);
    }

    @PostMapping("/{id}/control")
    public String controlDevice(@PathVariable Long id, @RequestBody String payload) {
        Device device = deviceRepository.findById(id).orElse(null);
        if (device != null) {
            mqttPublisherService.publish(device.getTopic(), payload);
            return "Published to " + device.getTopic();
        }
        return "Device not found";
    }
}
