package com.truonghoangphuc.lab306.repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.truonghoangphuc.lab306.entity.Category;
public interface CategoryRepository extends JpaRepository<Category, Long> {
}

