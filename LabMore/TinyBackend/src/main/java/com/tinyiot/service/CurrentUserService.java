package com.tinyiot.service;

import com.tinyiot.model.User;
import com.tinyiot.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CurrentUserService {

    private final UserRepository userRepository;

    public User requireCurrentUser() {
        String name = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByUsername(name)
                .orElseThrow(() -> new IllegalStateException("User not found: " + name));
    }
}
