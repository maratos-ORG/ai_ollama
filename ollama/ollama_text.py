from ollama import Client

# Подключаемся к серверу
#run in host's cli 
#OLLAMA_HOST=0.0.0.0:11436 ollama serve
client = Client(host='http://192.168.0.16:11434')

# Отправляем запрос к модели
response = client.chat(model='llama3', messages=[
  {
    'role': 'user',
    'content': 'Why is the sky blue? Give short answer ',
  },
])

# Выводим полный ответ для проверки структуры
print("Full response:", response)

# Предполагаем, что ответ имеет структуру с ключами 'message' и 'content'
if 'message' in response and 'content' in response['message']:
    print("Content:", response['message']['content'])
else:
    print("Expected keys are missing in the response.")
