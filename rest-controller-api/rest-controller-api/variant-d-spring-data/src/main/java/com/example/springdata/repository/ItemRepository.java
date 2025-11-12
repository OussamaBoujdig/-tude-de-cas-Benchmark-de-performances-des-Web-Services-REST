package com.example.springdata.repository;

import com.example.common.model.Item;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;
import org.springframework.web.bind.annotation.RequestParam;

@RepositoryRestResource(path = "items", collectionResourceRel = "items")
public interface ItemRepository extends JpaRepository<Item, Long> {
    
    @Override
    @RestResource(exported = true)
    Page<Item> findAll(Pageable pageable);
    
    @RestResource(path = "search/by-category", rel = "by-category")
    Page<Item> findByCategoryId(@RequestParam("categoryId") Long categoryId, Pageable pageable);
    
    @Override
    @RestResource(exported = true)
    <S extends Item> S save(S entity);
    
    @Override
    @RestResource(exported = true)
    void deleteById(Long id);
}
