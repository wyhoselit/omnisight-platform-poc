---
type: Overview
title: RAG Pipeline Overview
description: High-level overview of the Retrieval-Augmented Generation (RAG) pipeline implementation, covering document ingestion, embedding generation, abstract vector storage (ChromaDB/PGVector), and LLM integration.
tags: [RAG, architecture, backend, AI, pgvector, chromadb]
resource: /backend/app/modules/llm/rag/
---
# RAG Pipeline Overview

The RAG (Retrieval-Augmented Generation) pipeline enhances the application's AI capabilities by allowing the LLM to access and reason over external knowledge sources. It is implemented in the `backend/app/modules/llm/rag/` and `backend/app/modules/ai/services/` directories.

## Architecture

The pipeline consists of the following main components, orchestrated by the `ingestion_service.py` and used by `llm_integrator.py`:

1.  **Document Ingestion** (`document_loader.py`, `text_splitter.py`): Loads documents (PDF, TXT) and splits them into overlapping chunks.
2.  **Embedding Generation** (`embedding_generator.py`): Uses a Sentence-Transformer model (`all-MiniLM-L6-v2` by default) to convert text chunks into vector embeddings.
3.  **Vector Store Abstraction** (`vector_store.py`): Abstract base class defining the contract for vector databases.
    - **ChromaDB Implementation** (`chroma_vector_store.py`): File-based storage for local development.
    - **PGVector Implementation** (`pgvector_store.py`): PostgreSQL-based storage for production, featuring HNSW indexes for high-performance similarity search.
    - **Factory** (`vector_store_factory.py`): Singleton factory providing the configured implementation via `VECTOR_STORE` environment variable.
4.  **Retrieval** (`retrieval_service.py`, `retriever.py`): Performs similarity search against the vector store to find relevant document chunks for a given query.
5.  **LLM Integration** (`llm_integrator.py`): Combines retrieved context with the user query and sends it to the LLM service for generation.
6.  **Experiment Tracking** (`mlflow_tracker.py`): Logs experiments, parameters, and metrics to MLflow for reproducibility.

## Data Flow

1.  Documents are loaded and split into chunks.
2.  Chunks are embedded and stored in the configured vector store (ChromaDB or PGVector) with metadata.
3.  User query is embedded and used to retrieve top-K similar chunks via similarity search.
4.  Retrieved chunks are formatted as context.
5.  Context + query is passed to the LLM via `llm_integrator.py` and `llm_service.py`.
6.  LLM generates a grounded response.
7.  (Optional) Pipeline steps and results are logged to MLflow.

## Key Files

| Component | File | Purpose |
|-----------|------|---------|
| Document Loading | `document_loader.py` | Load PDF/TXT files using LangChain loaders |
| Text Splitting | `text_splitter.py` | Split documents into overlapping chunks using `RecursiveCharacterTextSplitter` |
| Embeddings | `embedding_generator.py` | Generate vector embeddings using `sentence-transformers` |
| Vector Store Interface | `vector_store.py` | Abstract base class for vector store implementations |
| Vector Store Factory | `vector_store_factory.py` | Provides singleton instance of Chroma or PGVector store |
| Ingestion Orchestration | `ingestion_service.py` | Coordinates loading, splitting, embedding, and storing |
| Retrieval | `retrieval_service.py`, `retriever.py` | Query vector store for relevant context |
| LLM Integration | `llm_integrator.py` | Bridge between retrieval and LLM generation |

## Architecture Decisions

- [Vector Database Choice](/docs/architecture-decisions/0001-vector-database-choice.md) -> Explains the hybrid strategy of ChromaDB for dev and PGVector for production.
- [Module Boundaries](/docs/architecture-decisions/0002-module-boundaries.md) -> Defines the logical separation of AI services and RAG pipeline components.

## Related Pages

- [Document Ingestion](document_ingestion.md) -> details the loading and splitting process
- [Embedding Generation](embedding_generation.md) -> covers the embedding model and generation
- [Vector Store](vector_store.md) -> explains abstract interface and specific implementations (Chroma/PGVector)
- [Retrieval](retrieval.md) -> describes similarity search and context retrieval
- [LLM Integration](llm_integration.md) -> shows how retrieved context is used for generation
- [Experiment Tracking](experiment_tracking.md) -> covers MLflow logging