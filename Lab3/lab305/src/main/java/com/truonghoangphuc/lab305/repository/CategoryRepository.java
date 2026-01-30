package com.truonghoangphuc.lab305.repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.truonghoangphuc.lab305.entity.Category;

public interface CategoryRepository extends JpaRepository< Category, Long> {
    boolean existsByParentId(Long parentId);
}
