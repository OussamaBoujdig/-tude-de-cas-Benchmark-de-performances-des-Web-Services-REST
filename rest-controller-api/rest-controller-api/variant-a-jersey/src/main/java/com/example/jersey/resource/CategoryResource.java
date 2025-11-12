package com.example.jersey.resource;

import com.example.common.dto.PageResponse;
import com.example.common.model.Category;
import com.example.common.model.Item;
import com.example.jersey.repository.CategoryRepository;
import com.example.jersey.repository.ItemRepository;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;

@Component
@Path("/categories")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CategoryResource {

    private static final int DEFAULT_PAGE = 0;
    private static final int DEFAULT_SIZE = 50;
    private static final int MAX_SIZE = 100;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ItemRepository itemRepository;

    @GET
    public Response getCategories(
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("size") @DefaultValue("50") int size) {
        
        size = Math.min(size, MAX_SIZE);
        Pageable pageable = PageRequest.of(page, size);
        Page<Category> categoryPage = categoryRepository.findAll(pageable);
        
        PageResponse<Category> response = new PageResponse<>(
            categoryPage.getContent(),
            categoryPage.getNumber(),
            categoryPage.getSize(),
            categoryPage.getTotalElements()
        );
        
        return Response.ok(response).build();
    }

    @GET
    @Path("/{id}")
    public Response getCategoryById(@PathParam("id") Long id) {
        return categoryRepository.findById(id)
            .map(category -> Response.ok(category).build())
            .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }

    @GET
    @Path("/{id}/items")
    public Response getItemsByCategory(
            @PathParam("id") Long id,
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("size") @DefaultValue("50") int size) {
        
        // Verify category exists
        if (!categoryRepository.existsById(id)) {
            return Response.status(Response.Status.NOT_FOUND).build();
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
        
        return Response.ok(response).build();
    }

    @POST
    public Response createCategory(Category category) {
        if (category.getName() == null || category.getName().trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity("{\"error\":\"Name is required\"}")
                .build();
        }
        
        Category saved = categoryRepository.save(category);
        return Response.status(Response.Status.CREATED).entity(saved).build();
    }

    @PUT
    @Path("/{id}")
    public Response updateCategory(@PathParam("id") Long id, Category category) {
        return categoryRepository.findById(id)
            .map(existing -> {
                existing.setName(category.getName());
                existing.setDescription(category.getDescription());
                Category updated = categoryRepository.save(existing);
                return Response.ok(updated).build();
            })
            .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }

    @DELETE
    @Path("/{id}")
    public Response deleteCategory(@PathParam("id") Long id) {
        if (!categoryRepository.existsById(id)) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        
        categoryRepository.deleteById(id);
        return Response.noContent().build();
    }
}
