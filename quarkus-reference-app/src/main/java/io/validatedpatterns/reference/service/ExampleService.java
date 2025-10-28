package io.validatedpatterns.reference.service;

import io.validatedpatterns.reference.model.ExampleModel;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.*;

/**
 * Example service with business logic
 */
@ApplicationScoped
public class ExampleService {

    private final Map<String, ExampleModel> store = new HashMap<>();

    public ExampleService() {
        // Initialize with sample data
        store.put("1", new ExampleModel("1", "Example 1", "First example", "active"));
        store.put("2", new ExampleModel("2", "Example 2", "Second example", "active"));
    }

    /**
     * Get all examples
     */
    public List<ExampleModel> getAll() {
        return new ArrayList<>(store.values());
    }

    /**
     * Get example by ID
     */
    public ExampleModel getById(String id) {
        return store.get(id);
    }

    /**
     * Create new example
     */
    public ExampleModel create(ExampleModel example) {
        String id = UUID.randomUUID().toString();
        example.setId(id);
        example.setStatus("active");
        store.put(id, example);
        return example;
    }

    /**
     * Update example
     */
    public ExampleModel update(String id, ExampleModel example) {
        if (store.containsKey(id)) {
            example.setId(id);
            store.put(id, example);
            return example;
        }
        return null;
    }

    /**
     * Delete example
     */
    public boolean delete(String id) {
        return store.remove(id) != null;
    }
}
