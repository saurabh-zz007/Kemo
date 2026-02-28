from fastapi import FastAPI
from pydantic import BaseModel
from controllers.executer import execute_kemo_command

app = FastAPI()

class UserRequest(BaseModel):
    prompt: str

@app.post("/execute")
async def execute_endpoint(request: UserRequest):
    # Pass the prompt directly to our isolated ReAct Agent
    response_payload = execute_kemo_command(request.prompt)
    
    return response_payload