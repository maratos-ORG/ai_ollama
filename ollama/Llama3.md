## 🧱 Install Ollama (via Docker)

📦 Docker Hub: [ollama/ollama](https://hub.docker.com/r/ollama/ollama)

```bash
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
docker exec -it ollama ollama run llama3
docker exec -it ollama ollama run mxbai-embed-large
```

----

## 🧠 Embedding API Example
Blog post: [Embedding Models with Ollama](https://ollama.com/blog/embedding-models)
```bash
curl http://192.168.0.16:11434/api/embeddings -d '{
  "model": "mxbai-embed-large",
  "prompt": "Llamas are members of the camelid family"
}'
```
This will return an embedding vector for the given prompt using the mxbai-embed-large model.

