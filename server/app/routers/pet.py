from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Any
import os

from app.auth import get_current_user
from app.db import init_db

# Optional Groq client (used if GROQ_API_KEY is set in env)
try:
    from groq import Groq
    GROQ_KEY = os.getenv('GROQ_API_KEY')
    GROQ_MODEL = os.getenv('GROQ_MODEL', 'llama-3.3-70b-versatile')
    client_groq = Groq(api_key=GROQ_KEY) if GROQ_KEY else None
except Exception:
    client_groq = None

router = APIRouter()


class ChatRequest(BaseModel):
    message: str


class ChatResponse(BaseModel):
    reply: str
    personality: str


@router.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest, current_user=Depends(get_current_user)):
    init_db()
    p = getattr(current_user, 'pet_personality', 'alegre')
    msg = req.message.strip()

    # If Groq client is available, prefer it for richer replies
    if client_groq:
        try:
            system = (
                f"You are a friendly virtual pet named {getattr(current_user, 'pet_name', 'Tu mascota')}. "
                f"Personality: {p}. Reply concisely in Spanish and keep tone consistent with the personality. "
                "Return only the reply text, do not add metadata."
            )
            user_msg = f"User message: {msg}"
            completion = client_groq.chat.completions.create(
                model=GROQ_MODEL,
                messages=[{"role": "system", "content": system}, {"role": "user", "content": user_msg}],
                temperature=0.6,
            )
            res = completion.choices[0].message.content
            reply_text = res.strip() if isinstance(res, str) else str(res)
            return {"reply": reply_text, "personality": p}
        except Exception as e:
            # Log and fall back to local rule-based reply
            print(f"⚠️ Groq error: {e} — falling back to local response")

    # Fallback local rule-based replies (previous behavior)
    low = msg.lower()
    if p == 'alegre':
        reply = f"¡Qué bien! {getattr(current_user, 'pet_name', 'tu mascota')} está feliz. Vamos a intentar: {low}. Tú puedes hacerlo 🌟"
    elif p == 'tierno':
        reply = f"{getattr(current_user, 'pet_name', 'tu mascota')} te abraza virtualmente y dice: '{low}' es posible, paso a paso 💕"
    elif p == 'triste':
        reply = f"{getattr(current_user, 'pet_name', 'tu mascota')} está un poco triste hoy, pero te anima a intentarlo: {low}. Acompañado, todo es más fácil."
    elif p in {'enojon', 'enojón'}:
        reply = f"{getattr(current_user, 'pet_name', 'tu mascota')} gruñe pero te empuja: haz {low} ahora, ¡no lo pienses tanto! 💪"
    elif p in {'timido', 'timidez'}:
        reply = f"{getattr(current_user, 'pet_name', 'tu mascota')} murmura: si quieres, empecemos con algo pequeño como {low}."
    elif p == 'energetico':
        reply = f"{getattr(current_user, 'pet_name', 'tu mascota')} salta de emoción: ¡Sí! Haz {low} y ganarás energía! ⚡"
    else:
        reply = f"{getattr(current_user, 'pet_name', 'tu mascota')} responde: {low}"

    return {"reply": reply, "personality": p}


# Available personalities
@router.get("/personalities")
async def list_personalities():
    return [
        {"name": "alegre", "description": "Alegre y optimista"},
        {"name": "tierno", "description": "Cálido y afectuoso"},
        {"name": "triste", "description": "Más melancólico y comprensivo"},
        {"name": "enojon", "description": "Gruñón pero motivador"},
        {"name": "timido", "description": "Reservado, dulcemente tímido"},
        {"name": "energetico", "description": "Lleno de energía y entusiasmo"}
    ]


class SetPersonalityRequest(BaseModel):
    personality: str


@router.post("/personality")
async def set_personality(req: SetPersonalityRequest, current_user=Depends(get_current_user)):
    allowed = {"alegre", "tierno", "triste", "enojon", "timido", "energetico"}
    if req.personality not in allowed:
        raise HTTPException(status_code=400, detail="Invalid personality")
    current_user.pet_personality = req.personality
    current_user.save()
    return {"personality": req.personality}