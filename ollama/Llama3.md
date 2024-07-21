## Install
### Install Ollama:
https://hub.docker.com/r/ollama/ollama
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
docker exec -it ollama ollama run llama3
docker exec -it ollama ollama run mxbai-embed-large

----

##embedding
https://ollama.com/blog/embedding-models
```bash
curl http://192.168.0.16:11434/api/embeddings -d '{
  "model": "mxbai-embed-large",
  "prompt": "Llamas are members of the camelid family"
}'
```


