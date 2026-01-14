import psutil
import time
import json
import socket
import paho.mqtt.client as mqtt

# CONFIGURATION
# This IP matches the static IP defined in the Vagrantfile
BROKER_ADDRESS = "192.168.56.82" 
TOPIC = "laptop/telemetry"

hostname = socket.gethostname()
client = mqtt.Client(f"{hostname}_Node")
client.connect(BROKER_ADDRESS)

print(f"Publishing sensor data to {BROKER_ADDRESS}...")

while True:
    # 1. Read Laptop Sensors
    battery = psutil.sensors_battery()
    cpu_usage = psutil.cpu_percent(interval=1)
    ram_usage = psutil.virtual_memory().percent
    disk_usage = psutil.disk_usage('/').percent
    net_io = psutil.net_io_counters()

    # Hardware Sensors (Temperature & Fans)
    # Note: Support for these varies significantly by OS and Hardware (often empty on Windows)
    temps = {}
    if hasattr(psutil, "sensors_temperatures"):
        try:
            raw_temps = psutil.sensors_temperatures()
            for name, entries in raw_temps.items():
                temps[name] = [entry.current for entry in entries]
        except Exception:
            pass

    fans = {}
    if hasattr(psutil, "sensors_fans"):
        try:
            raw_fans = psutil.sensors_fans()
            for name, entries in raw_fans.items():
                fans[name] = [entry.current for entry in entries]
        except Exception:
            pass
    
    # 2. Format as JSON Payload
    payload = {
        "device": hostname,
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
    
    # 3. Publish to VirtualBox Broker
    client.publish(TOPIC, json.dumps(payload))
    print(f"Sent: {payload}")
    time.sleep(2)