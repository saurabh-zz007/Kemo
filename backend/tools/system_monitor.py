
import psutil

def get_system_status():
    """Returns a snapshot of the current PC performance for KEMO to read."""
    cpu_usage = psutil.cpu_percent(interval=1)
    ram_info = psutil.virtual_memory()
    disk_info = psutil.disk_usage('/')
    
    battery = psutil.sensors_battery()
    battery_status = f"{battery.percent}%" if battery else "Desktop (No Battery)"
    

    return (
        f"System Status: CPU is at {cpu_usage}%, "
        f"RAM is at {ram_info.percent}% ({round(ram_info.used / (1024**3), 2)} GB used), "
        f"Disk is at {disk_info.percent}%, Battery is {battery_status}."
    )
