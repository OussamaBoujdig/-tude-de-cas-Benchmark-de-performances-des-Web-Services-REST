package com.example.springdata.controller;

import com.example.common.dto.PageResponse;
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
@RequestMapping("/items")
public class ItemController {

    private static final int MAX_SIZE = 100;

    @Autowired
    private ItemRepository itemRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @GetMapping
    public ResponseEntity<PageResponse<Item>> getItems(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(required = false) Long categoryId) {
        
        size = Math.min(size, MAX_SIZE);
        Pageable pageable = PageRequest.of(page, size);
        
        Page<Item> itemPage;
        if (categoryId != null) {
            itemPage = itemRepository.findByCategoryId(categoryId, pageable);
        } else {
            itemPage = itemRepository.findAll(pageable);
        }
        
        PageResponse<Item> response = new PageResponse<>(
            itemPage.getContent(),
            itemPage.getNumber(),
            itemPage.getSize(),
            itemPage.getTotalElements()
        );
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Item> getItemById(@PathVariable Long id) {
        return itemRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<?> createItem(@RequestBody Item item) {
        if (item.getName() == null || item.getName().trim().isEmpty()) {
            return ResponseEntity.badRequest()
                .body("{\"error\":\"Name is required\"}");
        }
        if (item.getPrice() == null) {
            return ResponseEntity.badRequest()
                .body("{\"error\":\"Price is required\"}");
        }
        if (item.getCategoryId() == null) {
            return ResponseEntity.badRequest()
                .body("{\"error\":\"Category ID is required\"}");
        }
        
        if (!categoryRepository.existsById(item.getCategoryId())) {
            return ResponseEntity.badRequest()
                .body("{\"error\":\"Category not found\"}");
        }
        
        Item saved = itemRepository.save(item);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateItem(
            @PathVariable Long id,
            @RequestBody Item item) {
        
        return itemRepository.findById(id)
            .map(existing -> {
                existing.setName(item.getName());
                existing.setDescription(item.getDescription());
                existing.setPrice(item.getPrice());
                existing.setQuantity(item.getQuantity());
                
                if (item.getCategoryId() != null && 
                    !item.getCategoryId().equals(existing.getCategoryId())) {
                    if (!categoryRepository.existsById(item.getCategoryId())) {
                        return ResponseEntity.badRequest()
                            .body("{\"error\":\"Category not found\"}");
                    }
                    existing.setCategoryId(item.getCategoryId());
                }
                
                Item updated = itemRepository.save(existing);
                return ResponseEntity.ok(updated);
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        if (!itemRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        
        itemRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
