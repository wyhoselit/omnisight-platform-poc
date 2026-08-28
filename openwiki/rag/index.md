---
type: Documentation Index
title: "Rag"
description: "Files and subdirectories in Rag."
---

# Files

- [RAG Document Ingestion](document_ingestion.md) - Details the process of loading and splitting documents into manageable chunks for the Retrieval-Augmented Generation (RAG) pipeline.
- [RAG Embedding Generation](embedding_generation.md) - Explains how text chunks are converted into numerical vector embeddings for the Retrieval-Augmented Generation (RAG) pipeline.
- [RAG LLM Integration](llm_integration.md) - Details how Large Language Models (LLMs) are integrated into the RAG pipeline to generate context-aware responses.
- [RAG Pipeline Overview](overview.md) - High-level overview of the Retrieval-Augmented Generation (RAG) pipeline implementation, covering document ingestion, embedding generation, abstract vector storage (ChromaDB/PGVector), and LLM integration.
- [RAG Retrieval](retrieval.md) - Explains the retrieval mechanism for the RAG pipeline, including similarity search via abstract vector store interface (ChromaDB or PGVector) with cosine distance scoring.
- [RAG Vector Store](vector_store.md) - Describes the abstract vector store interface and its implementations (ChromaDB for dev, PGVector for prod) used for persisting and querying document embeddings in the RAG pipeline.
