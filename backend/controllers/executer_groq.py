import json
import os
from openai import OpenAI          # DeepSeek client (OpenAI-compatible)
from groq import Groq              # Llama client
from dotenv import load_dotenv

from tools.app_manager import open_app, close_app
from tools.system_monitor import get_system_status
from tools.system_optimizer import optimize_system
from tools.env_setup import setup_environment, remove_environment

load_dotenv()

# --- TOOL REGISTRY (unchanged) ---
TOOL_REGISTRY = {
    "openApp": open_app,
    "closeApp": close_app,
    "getSystemStatus": get_system_status,
    "optimizeSystem": optimize_system,
    "setupEnvironment": setup_environment,
    "removeEnvironment": remove_environment
}

# --- DeepSeek Client (Planner) ---
deepseek_client = OpenAI(
    api_key=os.getenv('DEEPSEEK_API_KEY'),   # or 'API_KEY' if you kept that name
    base_url="https://api.deepseek.com"
)
DEEPSEEK_MODEL = 'deepseek-chat'

# --- Groq Client (Reporter) ---
groq_client = Groq(
    api_key=os.getenv('GROQ_API_KEY')
)
LLAMA_MODEL = 'llama-3.1-8b-instant'   # You can also use 'llama-3.1-70b-versatile'

def execute_kemo_command(user_prompt: str) -> dict:
    """
    Planner: DeepSeek (no tool access) – decides what tasks to run.
    Executor: runs the tools.
    Reporter: Llama 3.1 – generates a friendly summary (no tools).
    """

    # ---------------------------------------------------------
    # PASS 1: DEEPSEEK PLANNER (JSON mode)
    # ---------------------------------------------------------
    planner_prompt = f"""
    You are the system brain of KEMO, an AI desktop assistant.
    The user asked: "{user_prompt}"
    
    Determine if you need to take physical action on the PC or if it's just a general chat.
    
    Available actions:
    - "openApp" (requires argument: 'app_name')
    - "closeApp" (requires argument: 'app_name')
    - "getSystemStatus" (no arguments)
    - "optimizeSystem" (no arguments)
    - "setupEnvironment" (requires argument: 'package_id')
    - "removeEnvironment" (requires argument: 'package_id')
    
    CRITICAL: For setupEnvironment AND removeEnvironment, use the OFFICIAL Windows Winget ID.
    
    Respond ONLY with a valid JSON object containing a "tasks" array.
    Example: {{"tasks": [{{"action": "setupEnvironment", "arguments": {{"package_id": "Microsoft.VisualStudio.2022.BuildTools"}}}}]}}
    If no actions are needed, output an empty array: {{"tasks": []}}
    """

    try:
        planner_response = deepseek_client.chat.completions.create(
            model=DEEPSEEK_MODEL,
            messages=[
                {"role": "system", "content": "You are a helpful assistant designed to output JSON."},
                {"role": "user", "content": planner_prompt}
            ],
            response_format={"type": "json_object"},  # DeepSeek supports JSON mode
            temperature=0.0
        )
        ai_planned_tasks = []
        if planner_response.choices[0].message.content is not None:
            raw_text = planner_response.choices[0].message.content.strip()
            parsed_json = json.loads(raw_text)
            ai_planned_tasks = parsed_json.get("tasks", [])


    except Exception as e:
        print(f"Planner Error: {e}")
        ai_planned_tasks = []

    # EXECUTION 
    execution_logs = []

    for task in ai_planned_tasks:
        action_name = task.get("action")
        args = task.get("arguments", {})

        func = TOOL_REGISTRY.get(action_name)

        if func:
            try:
                result = func(**args)
                execution_logs.append(f"Action '{action_name}' Result: {result}")
            except Exception as e:
                execution_logs.append(f"Action '{action_name}' FAILED: {str(e)}")
        else:
            execution_logs.append(f"Action '{action_name}' FAILED: Tool not found in registry.")

    # PASS 2: LLAMA 3.1 REPORTER 
    if not ai_planned_tasks:
        reporter_prompt = f"The user said: '{user_prompt}'. Give a brief, helpful, and conversational reply."
    else:
        reporter_prompt = f"""
        User asked: "{user_prompt}"
        You executed background tasks and got these raw system logs: {execution_logs}
        
        Write a short, natural, conversational response to tell the user what you just did based on the logs. 
        Do not read the raw logs to them - summarize it cleanly.
        """

    try:
        reporter_response = groq_client.chat.completions.create(
            model=LLAMA_MODEL,
            messages=[
                {"role": "system", "content": "You are KEMO, a highly capable and friendly AI desktop assistant. Your work is to take the output from the background tasks and present it to the user in a friendly manner."},
                {"role": "user", "content": reporter_prompt}
            ],
            temperature=0.7
        )
        final_message = reporter_response.choices[0].message.content
    except Exception as e:
        print(f"Reporter Error: {e}")
        final_message = "I hit a snag while trying to formulate my response, but the background tasks were processed."

    # DELIVERY
    return {
        "tasks": ai_planned_tasks,
        "message": final_message,
        "status": "success" if "FAILED" not in str(execution_logs) else "partial_error"
    }