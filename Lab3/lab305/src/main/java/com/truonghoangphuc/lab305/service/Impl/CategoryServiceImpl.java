package com.truonghoangphuc.lab305.service.Impl;

import java.util.List;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.truonghoangphuc.lab305.entity.Category;
import com.truonghoangphuc.lab305.repository.CategoryRepository;
import com.truonghoangphuc.lab305.service.CategoryService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class CategoryServiceImpl implements CategoryService {
    
    private final CategoryRepository categoryRepository;
    
    @Override
    public Category createCategory(Category category) {
        if (category.getParentId() != null) {
            if (category.getCategoryId() != null && category.getParentId().equals(category.getCategoryId())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "parent_id must not equal categoryId");
            }

            if (!categoryRepository.existsById(category.getParentId())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "parent_id does not exist");
            }
        }
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
        Category existingCategory = categoryRepository.findById(category.getCategoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));

        if (category.getParentId() != null) {
            if (category.getParentId().equals(existingCategory.getCategoryId())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "parent_id must not equal categoryId");
            }

            if (!categoryRepository.existsById(category.getParentId())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "parent_id does not exist");
            }
        }

        existingCategory.setName(category.getName());
        existingCategory.setDescription(category.getDescription());
        existingCategory.setParentId(category.getParentId());
        Category updatedCategory = categoryRepository.save(existingCategory);
        return updatedCategory;
    }

    @Override
    public void deleteCategory(Long categoryId) {
        if (!categoryRepository.existsById(categoryId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found");
        }

        if (categoryRepository.existsByParentId(categoryId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Cannot delete category because it has sub-categories");
        }

        categoryRepository.deleteById(categoryId);
    }
}
