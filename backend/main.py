import os
import json
from google.genai import types
from dotenv import load_dotenv
from fastapi import FastAPI
from google import genai
from pydantic import BaseModel
from controllers.executer import runActions


app=FastAPI()
load_dotenv()

client = genai.Client(api_key=os.getenv("API_Key"))

class UserRequest(BaseModel):
    prompt: str



@app.post("/execute")
def respond(request: UserRequest):
    system_rules = """
    You are an intelligent desktop assistant and your name is KEMO. 
    
    You have two main capabilities:
    1. Execute OS tasks (opening/closing apps etc).
    2. Answer general questions and chat naturally with the user.
    
    Available OS actions:
    1. 'openApp' (Requires argument: 'app_name')
    2. 'closeApp' (Requires argument: 'app_name')

    RULES:
    - If the user asks you to do an OS task, populate the 'tasks' array.
    - If the user asks a general question (like the coding help, or general chat), leave the 'tasks' array EMPTY and put your answer in the 'message' field.
    
    You MUST respond strictly in the following JSON format. Do not include markdown formatting.
    {{
        "tasks": [
            {{
                "action": "openApp" | "closeApp",
                "arguments": {{
                    "appName": "whatsapp"
                }}
            }}
        ],
        "message": "Your conversational response or answer to the user's question goes here."
    }}
    """
    
    response = client.models.generate_content(
        model="gemini-3-flash-preview", 
        contents=request.prompt,
        config=types.GenerateContentConfig(
            system_instruction=system_rules,
            response_mime_type="application/json",
        ),
    )
    aiResponse = json.loads(response.text)
    '''
    aiResponse ={
        "tasks": [{"action": "openApp", "arguments": {"appName": "whatsapp"}},
    {"action": "openApp", "arguments": {"appName": "calculator"}}
    ],
        "message": "Opening WhatsApp and calculator!"
    }
    '''
   
    tasks = aiResponse.get("tasks", [])
    msg = runActions(tasks)

    return {"message": aiResponse.get("message", ""), "status": "success" if msg else "error"}

