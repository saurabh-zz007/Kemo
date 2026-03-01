import subprocess

def setup_environment(package_id: str) -> str:
    """
    Visibly installs software, pauses so the user can read errors, 
    and verifies the installation afterward so the AI doesn't hallucinate success.
    """
    try:
        # --- STEP 1: THE PRE-CHECK ---
        print(package_id)
        check_cmd = ["winget", "install", "-e", "--id", package_id]
        check_result = subprocess.run(
            check_cmd, 
            capture_output=True, 
            text=True, 
            creationflags=subprocess.CREATE_NO_WINDOW
        )
        
        if check_result.returncode == 0:
            return f"SUCCESS: {package_id} is already installed on this system."

        # --- STEP 2: THE VISIBLE INSTALLATION ---
        # Notice the cmd /c and the & pause at the end. 
        # This FORCES the black terminal to stay open and say "Press any key to continue..."
        # We also added the agreement flags back so it doesn't instantly crash on new setups.
        install_cmd = f'start "KEMO Installer" /wait cmd /c "winget install --id {package_id} --exact --accept-package-agreements --accept-source-agreements & pause"'
        
        # This will pause Python until you physically close that black terminal window.
        subprocess.run(install_cmd, shell=True)

        # --- STEP 3: THE POST-CHECK (The Lie Detector) ---
        # Did Winget actually install it, or did it fail/get canceled?
        post_check_result = subprocess.run(
            check_cmd, 
            capture_output=True, 
            text=True, 
            creationflags=subprocess.CREATE_NO_WINDOW
        )
        
        if post_check_result.returncode == 0:
            return f"SUCCESS: I have successfully installed {package_id}."
        else:
            return f"FAILURE: I opened the installer for {package_id}, but it did not install successfully. Read the terminal window for errors."

    except Exception as e:
        return f"FAILURE: System error: {str(e)}"

def remove_environment(package_id: str) -> str:
    """Visibly uninstalls software with Post-Check verification."""
    try:
        uninstall_cmd = f'start "KEMO Uninstaller" /wait cmd /c "winget uninstall --id {package_id} & pause"'
        subprocess.run(uninstall_cmd, shell=True)
        
        # Verify it's actually gone
        check_cmd = ["winget", "list", "--id", package_id, "--exact"]
        post_check_result = subprocess.run(check_cmd, capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        
        if post_check_result.returncode != 0:
            return f"SUCCESS: Successfully uninstalled {package_id}."
        else:
            return f"FAILURE: The uninstaller ran, but {package_id} is still on the system."
            
    except Exception as e:
        return f"FAILURE: System error: {str(e)}"