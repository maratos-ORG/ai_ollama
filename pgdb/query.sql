
update commit_logs set hash = trim(hash)" -c "vacuum full analyze commit_logs;
select count(*) from commit_logs;

CREATE OR REPLACE FUNCTION local_get_embedding(
  content text,
  api_key text DEFAULT current_setting('openai.api_key', true)
) RETURNS vector(1024)
AS $$
  import requests
  import json

  response = requests.post(
    'http://192.168.0.16:11434/api/embeddings',
    headers={'Content-Type': 'application/json'},
    data=json.dumps({
      'model': 'mxbai-embed-large',
      'prompt': content.replace("\n", " ")
    })
  )

  if response.status_code >= 400:
    raise Exception(f"Failed. Code: {response.status_code}")

  return response.json()['embedding']
$$ LANGUAGE plpython3u;


SELECT local_get_embedding('Llamas are members of the camelid family');

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

