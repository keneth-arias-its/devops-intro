import psutil
import time

# --- HELPER FUNCTIONS ---

def safe_get(func, *args, **kwargs):
    """
    Safely executes a function.
    Returns the result if successful, or None if an error occurs.
    Used to prevent the app from crashing if a specific sensor is unavailable.
    """
    try:
        return func(*args, **kwargs)
    except Exception:
        return None

def to_dict(obj):
    """
    Helper to convert a psutil result (namedtuple) to a dictionary.
    Returns None if the object is None or empty.
    """
    if obj and hasattr(obj, '_asdict'):
        return obj._asdict()
    return None

# --- METRIC COLLECTION functions ---

def get_boot_time():
    """Returns the system boot timestamp (when the PC was passed turned on)."""
    return safe_get(psutil.boot_time)

def get_cpu_metrics():
    """Collects CPU Load, Frequency, and Context Switches."""
    return {
        # interval=1 means we block for 1 second to calculate usage.
        # This is handled in a separate thread in main.py.
        "load_percent": safe_get(psutil.cpu_percent, interval=1),
        
        # We use a lambda to call the function lazily inside safe_get
        "frequency": safe_get(lambda: to_dict(psutil.cpu_freq())),
        "stats": safe_get(lambda: to_dict(psutil.cpu_stats()))
    }

def get_memory_metrics():
    """Collects RAM (Virtual) and Swap memory usage."""
    return {
        "virtual": safe_get(lambda: to_dict(psutil.virtual_memory())),
        "swap": safe_get(lambda: to_dict(psutil.swap_memory()))
    }

def get_disk_metrics():
    """Collects Disk Usage (%) and I/O (Read/Write bytes)."""
    return {
        # Monitors usage of the root partition '/'
        "usage_percent": safe_get(lambda: psutil.disk_usage('/').percent),
        "io": safe_get(lambda: to_dict(psutil.disk_io_counters()))
    }

def get_network_metrics():
    """Collects Network I/O and Interface details."""
    net_if = {}
    
    # Get details for each interface (Speed, MTU, Status)
    raw_net_if = safe_get(psutil.net_if_stats)
    if raw_net_if:
        for name, stats in raw_net_if.items():
            net_if[name] = to_dict(stats)
                
    return {
        "io": safe_get(lambda: to_dict(psutil.net_io_counters())),
        "interfaces": net_if
    }

def get_power_metrics():
    """Collects Battery status (if available)."""
    battery = safe_get(psutil.sensors_battery)
    if battery:
        return {
            "battery_percent": battery.percent,
            "power_plugged": battery.power_plugged,
        }
    return None

def get_hardware_sensors():
    """Collects Temperature and Fan speeds (Linux/Hardware dependent)."""
    # Temperatures
    temps = {}
    raw_temps = safe_get(getattr(psutil, "sensors_temperatures", None))
    if raw_temps:
        for name, entries in raw_temps.items():
            temps[name] = [entry.current for entry in entries]

    # Fans
    fans = {}
    raw_fans = safe_get(getattr(psutil, "sensors_fans", None))
    if raw_fans:
        for name, entries in raw_fans.items():
            fans[name] = [entry.current for entry in entries]
    
    return {
        "temperatures": temps,
        "fans": fans
    }
