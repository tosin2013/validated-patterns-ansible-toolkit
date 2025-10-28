package io.validatedpatterns.reference.api;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.HashMap;
import java.util.Map;

/**
 * Health check endpoints for Kubernetes probes
 */
@Path("/health")
public class HealthResource {

    /**
     * Liveness probe - is the application running?
     */
    @GET
    @Path("/live")
    @Produces(MediaType.APPLICATION_JSON)
    public Response liveness() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("checks", new Object[]{});
        return Response.ok(response).build();
    }

    /**
     * Readiness probe - can the application serve traffic?
     */
    @GET
    @Path("/ready")
    @Produces(MediaType.APPLICATION_JSON)
    public Response readiness() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("checks", new Object[]{});
        return Response.ok(response).build();
    }
}
