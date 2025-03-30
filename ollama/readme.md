# 🧠 Using Ollama and Jupyter

This guide shows how to run Ollama models locally and experiment with them using Jupyter Notebook.

---

## ✅ Install and Run Ollama Model

```bash
ollama run llama3 "Почему небо голубое?"
```

### Run Jupiter
```bash
docker run -p 9888:8888 -v "/Users/maratos/Documents/docker/jupyter":/home/jovyan/work jupyter/datascience-notebook
http://localhost:9888
```

### install ollama lib in Jupyter
Run the following command inside a cell 
!pip install ollama

### Run python code Jupyter
Take code from [ollama_text.py](ollama_text.py)