---
type: Concept
title: RAG Vector Store
description: Describes the abstract vector store interface and its implementations (ChromaDB for dev, PGVector for prod) used for persisting and querying document embeddings in the RAG pipeline.
tags: [RAG, vector store, ChromaDB, PGVector, backend, HNSW]
resource: /backend/app/modules/ai/services/vector_store.py
---
# RAG Vector Store

The Vector Store is the persistence layer for the RAG pipeline, responsible for storing document embeddings along with their associated text and metadata, and enabling efficient similarity search.

## Abstraction Layer

The system uses an abstract base class `VectorStore` to support multiple backends. This allows for a zero-infrastructure local development environment (ChromaDB) and a robust, production-ready environment (PGVector).

- **Interface**: `backend/app/modules/ai/services/vector_store.py`
- **Factory**: `backend/app/modules/ai/services/vector_store_factory.py` (singleton pattern)

## Implementations

### ChromaDB (Local Development)
- **Source**: `backend/app/modules/ai/services/chroma_vector_store.py`
- **Engine**: File-based `chromadb.PersistentClient` (defaults to `./chroma_db`).
- **Characteristics**: Fast, zero setup, ideal for local testing and iteration.

### PGVector (Production)
- **Source**: `backend/app/modules/ai/services/pgvector_store.py`
- **Engine**: PostgreSQL with the `pgvector` extension.
- **Indexing**: Uses **HNSW (Hierarchical Navigable Small World)** indexes for fast approximate nearest neighbor (ANN) search.
- **Optimization**: Tunable `m` and `ef_construction` parameters via environment variables (`PGVECTOR_HNSW_M`, `PGVECTOR_HNSW_EF_CONSTRUCTION`).
- **Schema**: Maps to the `Document` SQLAlchemy model in `backend/app/modules/llm/rag/models.py`.

## Core Methods

All implementations must provide:

- **`add_documents(documents: list[dict])`**: Persists document text and embeddings.
- **`search(query_embedding: list[float], limit: int = 10)`**: Performs similarity search (cosine distance) and returns `SearchResult` objects.
- **`delete(ids: list[str])`**: Removes documents by ID.
- **`health_check()`**: Verifies database connectivity.

## Usage in RAG Pipeline

1.  After [Embedding Generation](embedding_generation.md), the [Ingestion Service](document_ingestion.md) calls `add_documents` to persist embedded chunks.
2.  During a user query, the [Retrieval](retrieval.md) service calls `search` via the factory-provided instance to find relevant context.

## Configuration

Select the implementation via environment:
```env
VECTOR_STORE=pgvector  # or 'chroma'
DATABASE_URL=postgresql+asyncpg://user:pass@host:port/dbname
```