package io.validatedpatterns.reference.api;

import io.validatedpatterns.reference.model.ExampleModel;
import io.validatedpatterns.reference.service.ExampleService;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

/**
 * Example REST API endpoints
 */
@Path("/api/example")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ExampleResource {

    @Inject
    ExampleService exampleService;

    /**
     * Get all examples
     */
    @GET
    public Response getAll() {
        List<ExampleModel> examples = exampleService.getAll();
        return Response.ok(examples).build();
    }

    /**
     * Get example by ID
     */
    @GET
    @Path("/{id}")
    public Response getById(@PathParam("id") String id) {
        ExampleModel example = exampleService.getById(id);
        if (example != null) {
            return Response.ok(example).build();
        }
        return Response.status(Response.Status.NOT_FOUND).build();
    }

    /**
     * Create new example
     */
    @POST
    public Response create(ExampleModel example) {
        ExampleModel created = exampleService.create(example);
        return Response.status(Response.Status.CREATED).entity(created).build();
    }

    /**
     * Update example
     */
    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") String id, ExampleModel example) {
        ExampleModel updated = exampleService.update(id, example);
        if (updated != null) {
            return Response.ok(updated).build();
        }
        return Response.status(Response.Status.NOT_FOUND).build();
    }

    /**
     * Delete example
     */
    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") String id) {
        boolean deleted = exampleService.delete(id);
        if (deleted) {
            return Response.noContent().build();
        }
        return Response.status(Response.Status.NOT_FOUND).build();
    }
}
