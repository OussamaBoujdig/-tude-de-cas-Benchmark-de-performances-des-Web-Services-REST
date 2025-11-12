package com.example.springdata.repository;

import com.example.common.model.Category;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;

@RepositoryRestResource(path = "categories", collectionResourceRel = "categories")
public interface CategoryRepository extends JpaRepository<Category, Long> {
    
    @Override
    @RestResource(exported = true)
    Page<Category> findAll(Pageable pageable);
    
    @Override
    @RestResource(exported = true)
    <S extends Category> S save(S entity);
    
    @Override
    @RestResource(exported = true)
    void deleteById(Long id);
}
