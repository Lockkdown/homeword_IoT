package com.truonghoangphuc.lab306.service.impl;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.truonghoangphuc.lab306.entity.Category;
import com.truonghoangphuc.lab306.repository.CategoryRepository;
import com.truonghoangphuc.lab306.service.CategoryService;

import lombok.AllArgsConstructor;
@Service
@AllArgsConstructor
public class CategoryServiceImpl implements CategoryService {
    private final CategoryRepository categoryRepository;

    @Override
    public Category createCategory(Category category) {
        return categoryRepository.save(category);
    }
    
    @Override
    public Category getCategoryById(Long categoryId) {
    Optional<Category> optionalCategory = categoryRepository.findById(categoryId);
        return optionalCategory.get();
    } 

    @Override
    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    @Override
    public Category updateCategory(Category category) {
        Category existingCategory = categoryRepository.findById(category.getId()).get();
        existingCategory.setTitle(category.getTitle());
        existingCategory.setDescription(category.getDescription());
        existingCategory.setPhoto(category.getPhoto());
        existingCategory.setProducts(category.getProducts());
        Category updatedCategory = categoryRepository.save(existingCategory);
        return updatedCategory;
    }

    @Override
    public void deleteCategory(Long categoryId) {
        categoryRepository.deleteById(categoryId);
    }
}
