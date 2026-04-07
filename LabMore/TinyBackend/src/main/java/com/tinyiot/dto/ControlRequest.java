package com.tinyiot.dto;

import lombok.Data;

@Data
public class ControlRequest {
    /** ON or OFF */
    private String command;
}
