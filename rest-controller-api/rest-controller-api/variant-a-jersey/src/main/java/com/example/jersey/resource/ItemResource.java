package com.example.jersey.resource;

import com.example.common.dto.PageResponse;
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
@Path("/items")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ItemResource {

    private static final int DEFAULT_PAGE = 0;
    private static final int DEFAULT_SIZE = 50;
    private static final int MAX_SIZE = 100;

    @Autowired
    private ItemRepository itemRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @GET
    public Response getItems(
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("size") @DefaultValue("50") int size,
            @QueryParam("categoryId") Long categoryId) {
        
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
        
        return Response.ok(response).build();
    }

    @GET
    @Path("/{id}")
    public Response getItemById(@PathParam("id") Long id) {
        return itemRepository.findById(id)
            .map(item -> Response.ok(item).build())
            .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }

    @POST
    public Response createItem(Item item) {
        // Validate required fields
        if (item.getName() == null || item.getName().trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity("{\"error\":\"Name is required\"}")
                .build();
        }
        if (item.getPrice() == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity("{\"error\":\"Price is required\"}")
                .build();
        }
        if (item.getCategoryId() == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity("{\"error\":\"Category ID is required\"}")
                .build();
        }
        
        // Verify category exists
        if (!categoryRepository.existsById(item.getCategoryId())) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity("{\"error\":\"Category not found\"}")
                .build();
        }
        
        Item saved = itemRepository.save(item);
        return Response.status(Response.Status.CREATED).entity(saved).build();
    }

    @PUT
    @Path("/{id}")
    public Response updateItem(@PathParam("id") Long id, Item item) {
        return itemRepository.findById(id)
            .map(existing -> {
                existing.setName(item.getName());
                existing.setDescription(item.getDescription());
                existing.setPrice(item.getPrice());
                existing.setQuantity(item.getQuantity());
                
                if (item.getCategoryId() != null && 
                    !item.getCategoryId().equals(existing.getCategoryId())) {
                    if (!categoryRepository.existsById(item.getCategoryId())) {
                        return Response.status(Response.Status.BAD_REQUEST)
                            .entity("{\"error\":\"Category not found\"}")
                            .build();
                    }
                    existing.setCategoryId(item.getCategoryId());
                }
                
                Item updated = itemRepository.save(existing);
                return Response.ok(updated).build();
            })
            .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }

    @DELETE
    @Path("/{id}")
    public Response deleteItem(@PathParam("id") Long id) {
        if (!itemRepository.existsById(id)) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        
        itemRepository.deleteById(id);
        return Response.noContent().build();
    }
}
