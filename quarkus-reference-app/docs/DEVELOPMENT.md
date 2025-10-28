# Development Guide

## Prerequisites

- Java 17+
- Maven 3.8+
- Git
- Docker or Podman (for container builds)
- OpenShift CLI (oc) or kubectl

## Project Setup

### Clone Repository
```bash
git clone https://github.com/validated-patterns/reference-app.git
cd reference-app
```

### Build Project
```bash
./mvnw clean package
```

### Run in Development Mode
```bash
./mvnw quarkus:dev
```

The application will start with hot reload enabled. Visit http://localhost:8080

## Development Workflow

### 1. Make Code Changes
Edit files in `src/main/java/io/validatedpatterns/reference/`

### 2. Hot Reload
Changes are automatically reloaded in dev mode. No restart needed!

### 3. Test Changes
```bash
# In another terminal
curl http://localhost:8080/api/example
```

### 4. Run Tests
```bash
./mvnw test
```

### 5. Build for Production
```bash
./mvnw clean package
```

## Project Structure

```
src/
├── main/
│   ├── java/io/validatedpatterns/reference/
│   │   ├── api/
│   │   │   ├── HealthResource.java
│   │   │   └── ExampleResource.java
│   │   ├── service/
│   │   │   └── ExampleService.java
│   │   └── model/
│   │       └── ExampleModel.java
│   ├── resources/
│   │   └── application.properties
│   └── docker/
│       └── Dockerfile.jvm
└── test/
    └── java/io/validatedpatterns/reference/
        └── (test files)
```

## Adding New Features

### Add New REST Endpoint

1. Create new resource class:
```java
@Path("/api/newfeature")
@Produces(MediaType.APPLICATION_JSON)
public class NewFeatureResource {
    @GET
    public Response getFeature() {
        return Response.ok("Feature data").build();
    }
}
```

2. Add service class if needed:
```java
@ApplicationScoped
public class NewFeatureService {
    public String getFeature() {
        return "Feature data";
    }
}
```

3. Test the endpoint:
```bash
curl http://localhost:8080/api/newfeature
```

### Add New Model

1. Create model class in `model/`:
```java
public class NewModel {
    private String id;
    private String name;
    // getters/setters
}
```

2. Use in resource:
```java
@POST
public Response create(NewModel model) {
    // Process model
    return Response.status(Response.Status.CREATED).entity(model).build();
}
```

### Add Database Support

1. Add dependency to pom.xml:
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-orm-panache</artifactId>
</dependency>
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-jdbc-postgresql</artifactId>
</dependency>
```

2. Configure in application.properties:
```properties
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=postgres
quarkus.datasource.password=password
quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/mydb
quarkus.hibernate-orm.database.generation=update
```

3. Create entity:
```java
@Entity
public class Item extends PanacheEntity {
    public String name;
    public String description;
}
```

## Testing

### Run All Tests
```bash
./mvnw test
```

### Run Specific Test
```bash
./mvnw test -Dtest=ExampleServiceTest
```

### Run with Coverage
```bash
./mvnw test jacoco:report
```

### Example Unit Test
```java
@QuarkusTest
public class ExampleServiceTest {
    @Inject
    ExampleService service;

    @Test
    public void testCreate() {
        ExampleModel model = new ExampleModel("1", "Test", "Test", "active");
        ExampleModel created = service.create(model);
        assertNotNull(created.getId());
    }
}
```

### Example Integration Test
```java
@QuarkusTest
public class ExampleResourceTest {
    @Test
    public void testGetAll() {
        given()
            .when().get("/api/example")
            .then()
            .statusCode(200);
    }
}
```

## Debugging

### Enable Debug Logging
```bash
export QUARKUS_LOG_LEVEL=DEBUG
./mvnw quarkus:dev
```

### Debug in IDE
1. Set breakpoints in IDE
2. Run: `./mvnw quarkus:dev`
3. IDE will connect to debug port (5005)

### View Configuration
In dev mode, visit: http://localhost:8080/q/dev/config-editor

## Building Container Images

### Build JVM Image
```bash
./mvnw clean package
podman build -f src/main/docker/Dockerfile.jvm -t reference-app:latest .
```

### Build Native Image
```bash
./mvnw package -Pnative
podman build -f src/main/docker/Dockerfile.native -t reference-app:native .
```

### Push to Registry
```bash
podman tag reference-app:latest quay.io/your-org/reference-app:latest
podman push quay.io/your-org/reference-app:latest
```

## Local Kubernetes Testing

### Deploy Locally
```bash
# Create namespace
oc new-project reference-app-dev

# Deploy
oc apply -k k8s/overlays/dev

# Check status
oc get pods -n reference-app-dev
oc logs -f deployment/dev-reference-app -n reference-app-dev
```

### Port Forward
```bash
oc port-forward svc/dev-reference-app 8080:8080 -n reference-app-dev
```

### Test Deployed App
```bash
curl http://localhost:8080/api/example
```

## Code Style

### Format Code
```bash
./mvnw spotless:apply
```

### Check Code Quality
```bash
./mvnw sonar:sonar
```

## Performance Testing

### Load Testing with Apache Bench
```bash
ab -n 1000 -c 10 http://localhost:8080/api/example
```

### Load Testing with wrk
```bash
wrk -t4 -c100 -d30s http://localhost:8080/api/example
```

## Profiling

### CPU Profiling
```bash
./mvnw quarkus:dev -Dquarkus.profile=dev
# Use JProfiler or YourKit
```

### Memory Profiling
```bash
./mvnw quarkus:dev -Xmx512m
# Monitor with jconsole
```

## Troubleshooting

### Port Already in Use
```bash
# Find process using port 8080
lsof -i :8080

# Kill process
kill -9 <PID>
```

### Build Failures
```bash
# Clean build
./mvnw clean package

# Check dependencies
./mvnw dependency:tree
```

### Test Failures
```bash
# Run with verbose output
./mvnw test -X

# Run single test
./mvnw test -Dtest=ExampleServiceTest#testCreate
```

## IDE Setup

### IntelliJ IDEA
1. Open project
2. Configure JDK 17+
3. Enable annotation processing
4. Run → Edit Configurations → Add "Maven"
5. Command: `quarkus:dev`

### VS Code
1. Install "Extension Pack for Java"
2. Install "Quarkus Tools"
3. Open terminal and run: `./mvnw quarkus:dev`

### Eclipse
1. Import as Maven project
2. Install "Quarkus Tools"
3. Right-click project → Run As → Maven build
4. Goals: `quarkus:dev`

## Git Workflow

### Create Feature Branch
```bash
git checkout -b feature/my-feature
```

### Commit Changes
```bash
git add .
git commit -m "feat: add new feature"
```

### Push and Create PR
```bash
git push origin feature/my-feature
```

## Resources

- [Quarkus Documentation](https://quarkus.io/guides/)
- [Quarkus Extensions](https://quarkus.io/extensions/)
- [RESTEasy Reactive](https://quarkus.io/guides/resteasy-reactive)
- [Testing Guide](https://quarkus.io/guides/getting-started-testing)
