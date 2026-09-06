# AI & LLM Services — docs

AI & LLM Services — docs

This module exposes two services: `LLMService` and `VectorService`. No internal calls. No external calls. No execution flow. No dependencies.

`LLMService` — wraps an LLM. Does nothing in code. No method bodies. No config. No model loading.  
`VectorService` — declares `generate_embedding`, `store_embedding`, `search`. No implementation. No DB. No vector store. No embeddings generated.

Both are stubs. No-op interfaces. No side effects. No state.

→ skipped: actual LLM client, vector store, embedding engine  
→ add when: system needs real inference or retrieval

No diagram. Nothing to connect.