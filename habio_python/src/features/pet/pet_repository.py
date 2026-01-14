from src.services.http_client import client


def chat(message: str):
    return client.post('/pet/chat', json={'message': message})


def list_personalities():
    return client.get('/pet/personalities')


def set_personality(personality: str):
    return client.post('/pet/personality', json={'personality': personality})
