# AI & LLM Services — app

AI & LLM Services — app

Purpose:  
Serve LLM completions, generate embeddings, and manage RAG workflows. Offloads heavy tasks to async workers. Enforces auth, rate limits, cost tracking.  

Key components:  

1. API Endpoints (`/api/v1/ai/`)  
   - `/chat` — sync/stream LLM chat (GPT, Claude, local)  
   - `/rag_chat` — RAG: retrieve docs → augment prompt → stream LLM  
   - `/embeddings` — generate vector embeddings (SentenceTransformer)  

2. Services  
   - `LLMService` — routes requests to providers (OpenAI, Anthropic, Local)  
   - `VectorService` — wraps embedding model + vector store (Chroma/PGVector)  
   - `VectorStore` — abstract DB interface (Chroma, PGVector impls)  
   - `LLMProvider` — ABC for provider adapters (mocked, not production-ready)  

3. Workers (Dramatiq)  
   - `generate_embedding` — single text → vector  
   - `generate_batch_embeddings` — batch text → vectors  
   - `generate_llm_completion` — single LLM call  
   - `generate_batch_llm_completions` — batch LLM calls  
   - `health_check_all` — verify LLM + vector store health  

4. Middleware  
   - `CostTrackingMiddleware` — logs AI endpoint usage (stub)  
   - `RateLimitingMiddleware` — 60 req/min per user (in-memory, not shared)  

5. Factory & Config  
   - `get_vector_store()` — singleton: picks Chroma or PGVector from `settings.VECTOR_STORE`  
   - `ModelRegistry` — SQL table for tracking deployed models (unused in code)  

Flow:  
```mermaid
graph LR
A[Client] --> B[/api/v1/ai/chat]
B --> C[LLMService.generate]
C --> D[get_provider]
D --> E[OpenAIProvider]
E --> F[OpenAI API]
B --> G[RateLimitingMiddleware]
B --> H[CostTrackingMiddleware]
B --> I[get_current_user]
A --> J[/api/v1/ai/rag_chat]
J --> K[retrieve(query)]
K --> L[get_vector_store()]
L --> M[Chroma/PGVector.search]
M --> N[Return docs]
J --> O[LLMService.generate_with_rag]
O --> P[Format context + prompt]
P --> C
A --> Q[/api/v1/ai/embeddings]
Q --> R[VectorService.generate_embedding]
R --> S[SentenceTransformer.encode]
Q --> T[Dramatiq: generate_embedding] -- async --
```

Connections:  
- `retrieve()` from `llm/rag/retriever.py` → `get_vector_store()` → `ChromaVectorStore.search()`  
- `ingestion_service.py` → `add_documents()` → vector store  
- `chat.py` → `get_llm_service()` → registers mock providers (replace with env keys)  

Critical gaps:  
- Mock providers only. No real API keys.  
- Rate limiter is in-memory. Not cluster-safe.  
- Cost tracking is print(). No DB or billing.  
- `ModelRegistry` defined but never used.  

Fix:  
Replace mock keys with `os.getenv("OPENAI_API_KEY")`.  
Use Redis for rate limiting.  
Log token usage to DB.  

Skipped:  
- Async DB sessions in `VectorService` (uses sync `SentenceTransformer`) → ponytail: switch to `sentence-transformers` async fork if latency critical.  
- Caching embeddings → ponytail: add Redis cache if same texts re-embedded.  
- Model versioning → ponytail: wire `ModelRegistry` to `LLMService` if multi-version routing needed.  

No tests for workers. Add `test_dramatiq_actors.py` if reliability matters.