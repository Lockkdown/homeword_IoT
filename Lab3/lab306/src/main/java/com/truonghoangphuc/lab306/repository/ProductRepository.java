package com.truonghoangphuc.lab306.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.truonghoangphuc.lab306.entity.Product;
public interface ProductRepository extends JpaRepository<Product, Long> {
}
