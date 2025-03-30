# 🧠 ai_ollama

🧪 **Sandbox for experimenting with [Ollama](https://ollama.com/)** — a local LLM (Large Language Model) runner, integrated with PostgreSQL.

---

## ⚙️ Provision the solition 
```bash
- cd pgdb
- vagrant up
- vagrant ssh 
```
After running vagrant up, a VM is created with:
	•	Ubuntu 20.04 (ubuntu/focal64)
	•	PostgreSQL 16 installed and configured to accept remote connections (host: 6432)
	•	Installed extensions:
	•	pgvector — for vector similarity search
	•	plpython3u — to run Python-based functions inside PostgreSQL

Inside the VM:
	•	A database testdb is created and marat user is created with superuser access
	•	A commit_logs table is created with an embedding column of type vector(1024)
	•	Commits from postgres/postgres GitLab [repo](https://gitlab.com/postgres/postgres.git) are loaded into the table
	•	Initial SQL logic from [query.sql](query.sql) is applied

Inside the VM:
- Follow the steps in [pgdb/how_prepare_postgres.md](pgdb/how_prepare_postgres.md)
- Then run Ollama [via Docker](ollama/llama3.md)

## 🧪 Usage Example
Once provisioned, you can run SQL queries like:
```sql
select local_chat('Optimise numeric multiplication for short inputs. – when, who, etc.');
and olamma will provide the answer  
```
And Ollama will generate an answer using a local model.

## 📂 Structure
- pgdb/ – Vagrant environment with PostgreSQL setup
- ollama/ – Docker-related instructions for Ollama