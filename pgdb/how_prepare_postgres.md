## Generate embeddings
``` sql
with scope as (
 select hash
 from commit_logs
 where embedding is null
 order by id
 limit 25
), upd as (
 update commit_logs
 set embedding = local_get_embedding(
   content := format(
     'Date: %s. Hash: %s. Message: %s',
     created_at,
     hash,
     message
   )
 )
 where hash in (
   select hash
   from scope
 )
 returning *
)
select
 count(embedding) as cnt_vectorized,
 max(upd.id) as latest_upd_id,
 round(
   max(upd.id)::numeric * 100 /
     (select max(c.id) from commit_logs as c),
   2
 )::text || '%' as progress,
 1 / count(*) as err_when_done
from upd;
\watch .1
```


## CREATE index on the embedding coklumn
```bash
sudo -u postgres psql -d testdb -Xc "create index on commit_logs using hnsw (embedding vector_cosine_ops)"
sudo -u postgres psql -d testdb -Xc "drop index  commit_logs_embedding_idx"
```

----


## CRetae function for AI
```sql
CREATE OR REPLACE FUNCTION ai_local_call(
 question text,
 data_to_embed text,
 model text default 'llama3',
 token_limit int default 4096,
 api_key text default current_setting('opanai.api_key', true)
) RETURNS text
AS $$
import requests, json

prompt = """Be terse. Discuss only Postgres and its commits.
For commits, mention timestamp and hash. The most important as information use only CONTEXT that I provided to you
CONTEXT (git commits):
---
%s
---
QUESTION: %s
""" % (data_to_embed[:2000], question)

response = requests.post(
    'http://192.168.0.16:11434/api/generate',
    headers={'Content-Type': 'application/json'},
    data=json.dumps({
      'model': model,
      'prompt': prompt
    })
)

if response.status_code >= 400:
   raise Exception(f"Failed. Code: {response.status_code}. Response: {response.text}")

full_response = ""
for line in response.iter_lines():
    if line:
        part = json.loads(line)
        if 'response' in part:
            full_response += part['response']
        if part.get('done', False):
            break

return full_response
$$ LANGUAGE plpython3u;

create or replace function local_chat(
 in question text,
 in model text default 'llama3',
 out answer text
) as $$
 with q as materialized (
   select local_get_embedding(
     question
   ) as emb
 ), find_enries as (
   select
     format(
       e'Created: %s, hash: %s, message: %s, committer: %s\n',
       created_at,
       left(hash, 8),
       message,
       authors
     ) as entry
   from commit_logs
   where embedding <=> (select emb from q) < 0.8
   order by embedding <=> (select emb from q)
   limit 5 -- adjust if needed
 )
 select ai_local_call(
   question := question,
   data_to_embed := string_agg(entry, e'\n'),
   model := model
 )
 from find_enries;
$$ language sql;
```

### Final working query 
```sql
select local_chat('Optimise numeric multiplication for short inputs. – when, who, etc.');
```



## aditional query for test
```sql
select id, embedding from  commit_logs limit 5;

WITH generated_vector AS (
    SELECT local_get_embedding(content := 'commit with checksum that was create only 2024') AS q_vector
)
SELECT
    created_at,
    format(
        'https://gitlab.com/postgres/postgres/-/commit/%s',
        left(hash, 8)
    ),
    left(message, 150),
    authors,
    1 - (embedding <-> generated_vector.q_vector) as similarity
FROM commit_logs, generated_vector
ORDER BY embedding <-> generated_vector.q_vector
LIMIT 5;


SELECT ai_local_call(
    'Show me what i send to you',
    'Commit 1: checksum verification...',
    'llama3'
);

```