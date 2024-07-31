# ai_ollama

## Provisiona the solition 
- cd pgdb
- vagrant up
- vagrant ssh 
- Implement command from pgdb/[how_prepare_postgres.md](pgdb/how_prepare_postgres.md)
- [run olamma](ollama/llama3.md) via docker 

## Usage
Result of provisionong will be the fellowing query  
```sql
select local_chat('Optimise numeric multiplication for short inputs. – when, who, etc.');
and olamma will provide the answer  
```
