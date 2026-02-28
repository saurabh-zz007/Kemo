from AppOpener import open as app_open, close as app_close

def open_app(app_name: str) -> str:
    """Attempts to open a Windows application and returns the result for the AI."""
    try:
        # throw_error=True forces it to crash if it can't find the app, 
        # which allows our except block to catch it and warn the AI!
        app_open(app_name, match_closest=True, throw_error=True)
        return f"SUCCESS: '{app_name}' was successfully launched on the desktop."
    except Exception as e:
        return f"FAILURE: Could not open '{app_name}'. The app might not be installed. Details: {str(e)}"

def close_app(app_name: str) -> str:
    """Attempts to close a Windows application and returns the result."""
    try:
        app_close(app_name, match_closest=True, throw_error=True)
        return f"SUCCESS: '{app_name}' was successfully closed."
    except Exception as e:
        return f"FAILURE: Could not close '{app_name}'. It might not be running. Details: {str(e)}"