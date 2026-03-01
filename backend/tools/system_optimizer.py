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
    
    freed_bytes = 0
    temp_dir = os.environ.get('TEMP') 
    
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
                pass 
                
    if freed_bytes > 0:
        mb_freed = round(freed_bytes / (1024 * 1024), 2)
        results.append(f"Cleared {mb_freed} MB of system junk.")
    else:
        results.append("Temp system files are already clean.")

    optimized_procs = 0
    
    whitelist = ['explorer.exe', 'code.exe', 'dart.exe', 'python.exe', 'system', 'svchost.exe']
    
  
    psutil.cpu_percent(interval=0.1) 
    
    for proc in psutil.process_iter(['pid', 'name', 'cpu_percent']):
        try:
            name = proc.info['name'].lower()
            cpu_usage = proc.info['cpu_percent']
            
            
            if cpu_usage > 2.0 and name not in whitelist:
                
                proc.nice(psutil.BELOW_NORMAL_PRIORITY_CLASS) 
                optimized_procs += 1
                
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess, AttributeError):
            
            pass
            
    if optimized_procs > 0:
        results.append(f"Throttled CPU priority for {optimized_procs} background hogs.")
    else:
        results.append("Background CPU allocation is optimal.")

    return " Optimization Complete: " + " | ".join(results)

