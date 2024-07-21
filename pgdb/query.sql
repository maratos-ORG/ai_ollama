
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