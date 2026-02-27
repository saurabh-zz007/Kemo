from controllers.appOpener import ACTIONS
def runActions(taskList: list):
    if not taskList:
        return "No task to execute. How can I assist you today?"
    for task in taskList:
        # Get the action name and arguments
        actionName = task.get("action")
        argsDict = task.get("arguments", {})
        #call the action
        if actionName in ACTIONS:
            result = ACTIONS[actionName](**argsDict)
            if result:
                return result
    return "No valid action found."