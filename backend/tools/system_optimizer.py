import psutil
import os
import shutil

def optimize_system():
    """
    Safely optimizes Windows performance by clearing temporary files 
    and throttling high-CPU background tasks. 
    KEMO should call this when the user asks to boost performance.
    """
    results = []
    
    # --- STEP 1: Safe Temp File Cleanup ---
    freed_bytes = 0
    temp_dir = os.environ.get('TEMP') # Safely gets C:\Users\Manoj\AppData\Local\Temp
    
    if temp_dir and os.path.exists(temp_dir):
        for item in os.listdir(temp_dir):
            item_path = os.path.join(temp_dir, item)
            try:
                size = os.path.getsize(item_path)
                if os.path.isfile(item_path):
                    os.remove(item_path)
                elif os.path.isdir(item_path):
                    shutil.rmtree(item_path)
                freed_bytes += size
            except Exception:
                # File is currently in use by Windows, safely ignore it!
                pass 
                
    if freed_bytes > 0:
        mb_freed = round(freed_bytes / (1024 * 1024), 2)
        results.append(f"Cleared {mb_freed} MB of system junk.")
    else:
        results.append("Temp system files are already clean.")

    # --- STEP 2: CPU Priority Throttling ---
    optimized_procs = 0
    
    # We NEVER throttle these essential developer/system tools
    whitelist = ['explorer.exe', 'code.exe', 'dart.exe', 'python.exe', 'system', 'svchost.exe']
    
    # We need to call process_iter twice. The first time initializes the CPU % measurement.
    psutil.cpu_percent(interval=0.1) 
    
    for proc in psutil.process_iter(['pid', 'name', 'cpu_percent']):
        try:
            name = proc.info['name'].lower()
            cpu_usage = proc.info['cpu_percent']
            
            # If a background app is using more than 2% CPU and isn't whitelisted...
            if cpu_usage > 2.0 and name not in whitelist:
                # Tell Windows to deprioritize this app so active apps run faster!
                # psutil.BELOW_NORMAL_PRIORITY_CLASS is a Windows-specific command
                proc.nice(psutil.BELOW_NORMAL_PRIORITY_CLASS) 
                optimized_procs += 1
                
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess, AttributeError):
            # AccessDenied happens if we try to touch an Admin-level Windows process. We just ignore it.
            pass
            
    if optimized_procs > 0:
        results.append(f"Throttled CPU priority for {optimized_procs} background hogs.")
    else:
        results.append("Background CPU allocation is optimal.")

    # Return a clean summary for KEMO to read back to you!
    return " Optimization Complete: " + " | ".join(results)

