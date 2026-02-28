import json
import os
from google import genai  # NEW: The modern Google SDK
from dotenv import load_dotenv

# Import your isolated tools
from tools.app_manager import open_app, close_app
from tools.system_monitor import get_system_status
from tools.system_optimizer import optimize_system

load_dotenv() 

# --- THE COMMAND REGISTRY (O(1) Tool Lookup) ---
TOOL_REGISTRY = {
    "openApp": open_app,
    "closeApp": close_app,
    "getSystemStatus": get_system_status,
    "optimizeSystem": optimize_system
}

# NEW: Initialize the modern SDK Client
# It will automatically look for 'GEMINI_API_KEY' in your environment/.env file!
client = genai.Client(api_key=os.getenv('GEMINI_API_KEY'))
MODEL_ID = 'gemini-2.5-flash'

def execute_kemo_command(user_prompt: str) -> dict:
    """The master ReAct loop for KEMO."""
    
    # ---------------------------------------------------------
    # PASS 1: THE PLANNER
    # ---------------------------------------------------------
    planner_prompt = f"""
    You are the system brain of KEMO, an AI desktop assistant.
    The user asked: "{user_prompt}"
    
    Determine if you need to take physical action on the PC. 
    Available actions:
    - "openApp" (requires argument: 'app_name')
    - "closeApp" (requires argument: 'app_name')
    - "getSystemStatus" (no arguments)
    - "optimizeSystem" (no arguments)
    
    Respond ONLY with a valid JSON array of tasks. Do not include markdown formatting.
    Example: [{{"action": "openApp", "arguments": {{"app_name": "notepad"}}}}]
    If no actions are needed (just a conversation), output an empty array: []
    """
    
    try:
        # NEW: The updated generation syntax
        planner_response = client.models.generate_content(
            model=MODEL_ID, 
            contents=planner_prompt
        )
        raw_text = planner_response.text.strip().removeprefix('```json').removesuffix('```').strip()
        ai_planned_tasks = json.loads(raw_text)
    except Exception as e:
        print(f"Planner Error: {e}")
        ai_planned_tasks = []

    # ---------------------------------------------------------
    # THE EXECUTION
    # ---------------------------------------------------------
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

    # ---------------------------------------------------------
    # PASS 2: THE REPORTER
    # ---------------------------------------------------------
    if not ai_planned_tasks:
        reporter_prompt = f"You are KEMO. The user said: '{user_prompt}'. Give a brief, helpful, and conversational reply."
    else:
        reporter_prompt = f"""
        You are KEMO, an AI desktop assistant. 
        User asked: "{user_prompt}"
        You executed background tasks and got these raw system logs: {execution_logs}
        
        Write a short, natural, conversational response to tell the user what you just did based on the logs. 
        Do not read the raw logs to them, summarize it cleanly.
        """
        
    try:
        # NEW: The updated generation syntax
        reporter_response = client.models.generate_content(
            model=MODEL_ID, 
            contents=reporter_prompt
        )
        final_message = reporter_response.text
    except Exception as e:
        print(f"Reporter Error: {e}")
        final_message = "I encountered an error while trying to formulate my response."

    # ---------------------------------------------------------
    # THE DELIVERY
    # ---------------------------------------------------------
    return {
        "tasks": ai_planned_tasks,
        "message": final_message,
        "status": "success" if not "FAILED" in str(execution_logs) else "partial_error"
    }