package com.truonghoangphuc.lab304.repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.truonghoangphuc.lab304.entity.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {
}