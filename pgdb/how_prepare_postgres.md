# 🛠️ Preparing PostgreSQL for Local AI Integration

## Generate Embeddings

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

## Create Index on the embedding Column
```bash
# Create index
sudo -u postgres psql -d testdb -Xc \
  "CREATE INDEX ON commit_logs USING hnsw (embedding vector_cosine_ops);"

# Drop index if needed
sudo -u postgres psql -d testdb -Xc \
  "DROP INDEX commit_logs_embedding_idx;"
```

----

## Final Working Query
```sql
SELECT local_chat('Optimise numeric multiplication for short inputs. – when, who, etc.');
```

## Additional Test Queries
```sql
-- Preview some stored embeddings:
select id, embedding from  commit_logs limit 5;

-- Similarity search using generated embedding vector:
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

-- Run a local AI model on a custom input:
SELECT ai_local_call(
    'Show me what i send to you',
    'Commit 1: checksum verification...',
    'llama3'
);

```