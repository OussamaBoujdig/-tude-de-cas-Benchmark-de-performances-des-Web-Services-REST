package com.example.springdata.controller;

import com.example.common.dto.PageResponse;
import com.example.common.model.Category;
import com.example.common.model.Item;
import com.example.springdata.repository.CategoryRepository;
import com.example.springdata.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/categories")
public class CategoryController {

    private static final int MAX_SIZE = 100;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ItemRepository itemRepository;

    @GetMapping
    public ResponseEntity<PageResponse<Category>> getCategories(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        
        size = Math.min(size, MAX_SIZE);
        Pageable pageable = PageRequest.of(page, size);
        Page<Category> categoryPage = categoryRepository.findAll(pageable);
        
        PageResponse<Category> response = new PageResponse<>(
            categoryPage.getContent(),
            categoryPage.getNumber(),
            categoryPage.getSize(),
            categoryPage.getTotalElements()
        );
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Category> getCategoryById(@PathVariable Long id) {
        return categoryRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/items")
    public ResponseEntity<PageResponse<Item>> getItemsByCategory(
            @PathVariable Long id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        
        if (!categoryRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        
        size = Math.min(size, MAX_SIZE);
        Pageable pageable = PageRequest.of(page, size);
        Page<Item> itemPage = itemRepository.findByCategoryId(id, pageable);
        
        PageResponse<Item> response = new PageResponse<>(
            itemPage.getContent(),
            itemPage.getNumber(),
            itemPage.getSize(),
            itemPage.getTotalElements()
        );
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<?> createCategory(@RequestBody Category category) {
        if (category.getName() == null || category.getName().trim().isEmpty()) {
            return ResponseEntity.badRequest()
                .body("{\"error\":\"Name is required\"}");
        }
        
        Category saved = categoryRepository.save(category);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Category> updateCategory(
            @PathVariable Long id,
            @RequestBody Category category) {
        
        return categoryRepository.findById(id)
            .map(existing -> {
                existing.setName(category.getName());
                existing.setDescription(category.getDescription());
                Category updated = categoryRepository.save(existing);
                return ResponseEntity.ok(updated);
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(@PathVariable Long id) {
        if (!categoryRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        
        categoryRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
