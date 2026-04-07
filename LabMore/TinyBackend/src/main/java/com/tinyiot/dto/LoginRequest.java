package com.tinyiot.dto;

import lombok.Data;

@Data
public class LoginRequest {
    /** Username or email */
    private String username;
    private String password;
}
