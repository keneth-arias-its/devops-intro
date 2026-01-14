import psutil
import time
import json

# MOCK CONFIGURATION FOR TESTING
TOPIC = "laptop/telemetry"

print(f"TEST RUN: Reading sensors and printing JSON payload (MQTT Disabled)...")

# 1. Read Laptop Sensors
battery = psutil.sensors_battery()
cpu_usage = psutil.cpu_percent(interval=1)
ram_usage = psutil.virtual_memory().percent
disk_usage = psutil.disk_usage('/').percent
net_io = psutil.net_io_counters()

# Hardware Sensors (Temperature & Fans)
temps = {}
if hasattr(psutil, "sensors_temperatures"):
    try:
        raw_temps = psutil.sensors_temperatures()
        for name, entries in raw_temps.items():
            temps[name] = [entry.current for entry in entries]
    except Exception as e:
        temps["error"] = str(e)

fans = {}
if hasattr(psutil, "sensors_fans"):
    try:
        raw_fans = psutil.sensors_fans()
        for name, entries in raw_fans.items():
            fans[name] = [entry.current for entry in entries]
    except Exception as e:
        fans["error"] = str(e)

# 2. Format as JSON Payload
payload = {
    "device": "Student_Laptop_01_TEST",
    "battery_percent": battery.percent if battery else 100,
    "power_plugged": battery.power_plugged if battery else True,
    "cpu_load": cpu_usage,
    "ram_load": ram_usage,
    "disk_usage": disk_usage,
    "net_bytes_sent": net_io.bytes_sent,
    "net_bytes_recv": net_io.bytes_recv,
    "temperatures": temps,
    "fans": fans
}

# 3. Print to Console
print("\n--- GENERATED PAYLOAD ---")
print(json.dumps(payload, indent=4))
print("-------------------------\\n")
print("Test completed successfully.")
