---
type: Concept
title: RAG Retrieval
description: Explains the retrieval mechanism for the RAG pipeline, including similarity search via abstract vector store interface (ChromaDB or PGVector) with cosine distance scoring.
tags: [RAG, retrieval, similarity search, cosine distance, chroma, pgvector, backend]
resource: /backend/app/modules/llm/rag/retriever.py
---
# RAG Retrieval

The Retrieval component is responsible for finding the most relevant document chunks from the [Vector Store](vector_store.md) given a user's query. This is the core "search" step in the RAG pipeline.

## Components

### Retriever Logic (`retriever.py`)

The `retriever.py` module contains the core logic for performing similarity searches.

*   **`generate_query_embedding(query: str)`**: Converts the user's query string into an embedding using the same `EmbeddingGenerator` used during document ingestion (ensuring embedding space consistency).
*   **`retrieve(query: str, n_results: int = 5)`**: The main retrieval function. It embeds the query and queries the [Vector Store](vector_store.md) for the top `n_results` similar chunks.
*   **`retrieve_with_embedding(query_embedding: list[float], n_results: int = 5)`**: An alternative that accepts a pre-computed embedding, useful if the embedding is generated elsewhere or for testing.

*   **Source File**: `backend/app/modules/llm/rag/retriever.py`

### Retrieval API (`retrieval_service.py`)

The `retrieval_service.py` module exposes a FastAPI endpoint for the retrieval functionality.

*   **Endpoint**: `POST /retrieve`
*   **Request Body**: `RetrievalRequest` (contains `query: str` and optional `n_results: int`).
*   **Response**: Returns the raw results from the vector store query, including `ids`, `documents` (text content), `metadatas`, and `distances`.

*   **Source File**: `backend/app/modules/llm/rag/retrieval_service.py`

## Similarity Search

The search uses **cosine distance** to measure similarity between embeddings. Results include a normalized score (0 to 1) where higher values indicate more similar documents.

For PGVector:
```sql
SELECT id, content, meta_data,
       1 - cosine_distance(embedding, :query_emb) as score
FROM documents
ORDER BY embedding <=> :query_emb
LIMIT :limit
```

## Workflow

1.  User query is received (via API or internal call).
2.  Query is embedded using `EmbeddingGenerator`.
3.  Query embedding is used to search the vector store (ChromaDB or PGVector) for nearest neighbors.
4.  Top-K matching document chunks (with text and metadata) are returned along with similarity scores.
5.  These chunks are formatted as context and passed to the [LLM Integration](llm_integration.md) to generate a grounded response.

## Configuration

*   **`n_results`**: Number of top results to return (defaults to 5).
*   **`filter_metadata`**: Optional metadata filter to narrow search scope.
*   **Vector Store**: Select via `VECTOR_STORE` environment variable (`chroma` or `pgvector`).

## Dependencies

*   [Embedding Generation](embedding_generation.md) - for query embedding
*   [Vector Store](vector_store.md) - for storage and search (ChromaDB or PGVector)