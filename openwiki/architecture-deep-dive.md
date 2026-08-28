# Architecture Deep Dive

## System Architecture & Design Overview

This document provides a comprehensive analysis of the **Omnisight Platform PoC** system architecture, focusing on architecture planning, maintenance, integration, and operational excellence. The architecture follows a modular monolith pattern with clear boundaries, combining Vue.js 3 frontend with FastAPI backend, designed for scalability and maintainability.

## Project Structure Overview

### Frontend Architecture
- **Framework**: Vue.js 3 with Composition API
- **State Management**: Pinia stores for reactive state
- **Routing**: Vue Router for client-side navigation
- **Build Tool**: Vite with TypeScript support
- **UI Library**: Vuetify 3 for Material Design components
- **Testing**: Vitest with Happy DOM for unit tests

### Backend Architecture
- **Framework**: FastAPI for async HTTP APIs
- **Architecture Pattern**: Modular monolith with clear boundaries
- **Database**: PostgreSQL with pgvector extension for vector storage
- **API Versioning**: Multi-version support (v1, v2)
- **Observability**: OpenTelemetry + Prometheus + Grafana

## Key Architectural Components

### 1. Modular Monolith Design
The backend follows a strict modular pattern:

```
backend/app/
├── api/              # API routing and versioning
│   ├── v1/           # API v1 endpoints
│   └── v2/           # API v2 endpoints
├── modules/          # Feature modules (one per domain)
│   ├── admin/        # Admin functionality
│   ├── ai/           # AI/Large Language Model integration
│   ├── core/         # Core functionality (config, database, security)
│   ├── dashboard/    # Dashboard API
│   ├── system/       # System health and configuration
│   └── user/         # User management and authentication
└── core/             # Legacy core module references
```

### 2. API Design & Management
The system employs a sophisticated API design with the following principles:

#### Version Control
- **v1**: Comprehensive set of endpoints including health, auth, admin, dashboard, users, and AI
- **v2**: Streamlined subset focusing on core functionality
- **Fallback**: V1 serves as fallback for V2 unsupported endpoints

#### API Endpoints Structure
| Method | Path | Handler | Purpose |
|--------|------|---------|---------|
| GET | /health | Health Check | System readiness and liveness |
| POST | /login | Authentication | User session establishment |
| GET | /me | Current User | Authenticated user details |
| PUT | /me | Update User | Profile modification |
| GET | /api/v1/users | User List | Paginated user retrieval |
| POST | /api/v1/users | Create User | New user registration |

#### API Design Principles
1. **RESTful Design**: HTTP methods map to operations
2. **Versioned APIs**: Independent evolution of API versions
3. **Dependency Injection**: FastAPI dependencies for auth, database sessions
4. **Error Handling**: Standardized error responses with detailed messages

### 3. Data Management & Persistence

#### Database Architecture
- **Primary Database**: PostgreSQL with pgvector extension
- **Vector Storage**: Hybrid approach for development vs production
  - **Development**: ChromaDB (file-based, zero infrastructure)
  - **Production**: PGVector (ACID compliant, existing PostgreSQL investment)

#### Database Schema Optimization
Key optimizations implemented:

1. **Eager Loading**: Eliminate N+1 query problems through `joinedload()`
2. **JSONB Indexing**: GIN indexes for efficient JSON path queries
3. **Vector Similarity**: HNSW indexes for sub-linear ANN search
4. **Connection Pooling**: SQLAlchemy routing with write/read separation

#### Database Performance Examples

##### N+1 Query Optimization
```python
# Unoptimized: N+1 queries
db.query(User).all()  # 1 query
for user in users:   # N additional queries
    role_names = [role.name for role in user.roles]

# Optimized: Eager loading
users = db.query(User).options(joinedload(User.roles)).all()
# Single JOIN query
```

##### JSONB Query Optimization
```sql
-- Database index creation
CREATE INDEX idx_system_settings_jsonb_gin ON system_settings USING gin (settings);
```

### 4. AI & RAG Pipeline Architecture

#### Core Components
1. **Document Processing**: LangChain loaders for PDF/TXT extraction
2. **Text Splitting**: RecursiveCharacterTextSplitter with overlap
3. **Embedding Generation**: SentenceTransformer (all-MiniLM-L6-v2)
4. **Vector Storage**: Abstract interface with ChromaDB/PGVector implementations
5. **Retrieval Service**: Similarity search with metadata filtering
6. **LLM Integration**: Context retrieval and response generation

#### Architecture Decision
The system uses a **hybrid vector database strategy**:

**Development**: ChromaDB (simpler, faster iteration)
**Production**: PGVector (ACID compliance, existing infrastructure)

This decision balances development speed with production reliability, ensuring smooth transition from development to production while minimizing migration complexity.

### 5. Observability & Performance Management

#### Monitoring Stack
- **Metrics**: Prometheus + OpenTelemetry (latency, throughput, errors)
- **Tracing**: Tempo + OpenTelemetry (distributed request tracing)
- **Logging**: Loki + OpenTelemetry (structured logging with context)
- **Alerting**: Prometheus alerts + Alertmanager + Grafana

#### Service Level Objectives (SLOs)
| SLO | Target | Alert |
|-----|--------|-------|
| Availability | > 99.9% uptime | ServiceDown |
| Latency | P95 < 200ms | HighBackendLatency |
| Error Rate | < 5% | HighErrorRate |
| Frontend | P95 < 500ms render | HighFrontendLatency |

#### Performance Optimization
Implemented systematic query optimization across the stack:

1. **Database Optimization**: Eager loading, JSONB indexing, connection pooling
2. **Vector Search**: HNSW indexes for sub-linear ANN complexity
3. **API Design**: Versioning and efficient routing to reduce overhead
4. **Frontend Performance**: Component optimization and caching strategies

### 6. DevOps & Deployment

#### Deployment Strategy
- **Local Development**: Docker Compose for environment parity
- **Production**: Kubernetes (GKE) with Helm charts
- **CI/CD**: Automated testing and deployment pipelines

#### Docker Architecture
```yaml
services:
  backend:
    build: backend/
    ports: [8000:8000]
    environment:
      - DATABASE_URL=postgresql://...
    volumes:
      - ./backend/app:/app
  
  frontend:
    build: frontend/
    ports: [5173:5173]
    environment:
      - VITE_API_URL=http://localhost:8000
    depends_on:
      - backend
```

### 7. Development Workflow & Quality Assurance

#### Development Practices
1. **Modular Structure**: Each domain has dedicated folder with api/, services/, tests/
2. **Test-Driven Development**: Comprehensive unit and integration tests
3. **Type Safety**: Full TypeScript support with strict typing
4. **Code Quality**: ESLint, Prettier, TypeScript strict mode

#### Quality Assurance
- **Testing Levels**: Unit, integration, E2E tests across all layers
- **Code Coverage**: Automated metrics with CI/CD integration
- **Performance Monitoring**: Real-time metrics with SLO-based alerting
- **Security**: Authentication, authorization, input validation

## Key Decision Log

### Architecture Decision 1: Modular Monolith vs Microservices
**Decision**: Modular monolith for development speed and operational simplicity
- **Trade-offs**: Database becomes single point of failure, horizontal scaling limitations
- **Future-proof**: Clear module boundaries enable easier microservice transition

### Architecture Decision 2: Hybrid Vector Database Strategy
**Decision**: ChromaDB for dev, PGVector for production
- **Trade-offs**: Development environment differs from production
- **Benefits**: Fast iteration, ACID compliance, existing infrastructure leverage

### Architecture Decision 3: Database-Centric Scalability
**Decision**: Read replicas and connection pooling for database optimization
- **Trade-offs**: Database becomes bottleneck, requires sophisticated routing
- **Benefits**: Query-heavy workloads (RAG retrieval) offloaded effectively

## Integration Points & Dependencies

The system maintains clear integration patterns:

### Cross-Module Dependencies
- **Auth Module**: Provides dependency functions (`get_current_user`, `get_admin_user`)
- **Core Module**: Shared utilities (database, security, config)
- **Service Layer**: Business logic separated from API layer

### External Dependencies
- **LLM Providers**: OpenAI, Anthropic, local inference endpoints
- **Observability**: OpenTelemetry exporters, Prometheus exporters
- **Authentication**: JWT tokens with rate limiting middleware

## Technology Stack Summary

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | Vue.js 3, Vite, TypeScript, Vuetify | User interface |
| Backend | FastAPI, Python, SQLAlchemy | API services |
| Database | PostgreSQL, pgvector extension | Data persistence |
| Vector DB | ChromaDB (dev), PGVector (prod) | Semantic search |
| Observability | OpenTelemetry, Prometheus, Grafana | Monitoring |
| Containerization | Docker, Docker Compose, Kubernetes | Deployment |
| Testing | Vitest, Cypress, Pytest | Quality assurance |
| Workflow | OpenSpec | Change management |

## Conclusion

The Omnisight Platform PoC implements a robust, scalable architecture that balances development speed with production reliability. Key strengths include:

1. **Clear Architecture**: Modular monolith with explicit boundaries
2. **Performance Optimization**: Systematic query and performance improvements
3. **Observability**: Comprehensive monitoring with SLO-based alerting
4. **Developer Experience**: Fast iteration with Docker-based development
5. **Future Scalability**: Design patterns enable easy evolution to microservices

This architecture supports the platform's core mission of providing intelligent document retrieval and analysis while maintaining operational excellence and developer productivity.