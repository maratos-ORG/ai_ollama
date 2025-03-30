from ollama import Client

#run in host's cli 
#OLLAMA_HOST=0.0.0.0:11436 ollama serve
client = Client(host='http://192.168.0.16:11434')

# Send request to the model
response = client.chat(model='llama3', messages=[
  {
    'role': 'user',
    'content': 'Why is the sky blue? Give short answer ',
  },
])

# Print the full response to check its structure
print("Full response:", response)

# Assume the response has a structure with 'message' and 'content' keys
if 'message' in response and 'content' in response['message']:
    print("Content:", response['message']['content'])
else:
    print("Expected keys are missing in the response.")
