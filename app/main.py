import asyncio
import json
import socket
import sys
from datetime import datetime
import paho.mqtt.client as mqtt
import sensors

# CONFIGURATION
BROKER_ADDRESS = "192.168.56.82"
TOPIC_BASE = "laptop/monitoring"
UPDATE_INTERVAL = 5 # seconds

class MonitoringAgent:
    def __init__(self, broker, topic_base, interval):
        self.broker = broker
        self.topic_base = topic_base
        self.interval = interval
        self.hostname = socket.gethostname()
        
        # State tracking for diff-based publishing
        self.last_sent_data = {}
        
        # MQTT Client Setup
        self.client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, f"{self.hostname}_Agent")
        self.client.on_connect = self._on_connect
        self.client.on_disconnect = self._on_disconnect

    def _on_connect(self, client, userdata, flags, reason_code, properties):
        if reason_code == 0:
            print(f"✅ Connected to Broker at {self.broker}")
        else:
            print(f"❌ Connection failed with code {reason_code}")

    def _on_disconnect(self, client, userdata, flags, reason_code, properties):
        print("⚠️ Disconnected from broker")

    async def connect(self):
        """Connects to the MQTT broker (blocking but fast)."""
        try:
            self.client.connect(self.broker)
            self.client.loop_start() # Run network loop in background thread
            return True
        except Exception as e:
            print(f"❌ Failed to connect: {e}")
            return False

    async def collect_metrics(self):
        """Collects metrics in parallel using a ThreadPool."""
        loop = asyncio.get_running_loop()
        
        # Helper to run blocking psutil calls in threads
        def run_sync(func):
            return loop.run_in_executor(None, func)

        # 1. Schedule all independent sensor tasks
        # These will run simultaneously in thread pool
        tasks = {
            "cpu": run_sync(sensors.get_cpu_metrics),
            "memory": run_sync(sensors.get_memory_metrics),
            "disk": run_sync(sensors.get_disk_metrics),
            "network": run_sync(sensors.get_network_metrics),
            "power": run_sync(sensors.get_power_metrics),
            "sensors": run_sync(sensors.get_hardware_sensors),
        }

        # 2. Add static/fast data
        boot_time = sensors.get_boot_time()
        timestamp = datetime.now().isoformat()

        # 3. Wait for all threads to finish
        results = await asyncio.gather(*tasks.values())
        data = dict(zip(tasks.keys(), results))

        # 4. Attach metadata
        data["device"] = self.hostname
        data["timestamp"] = timestamp
        data["boot_time"] = boot_time
        
        return data

    async def publish_changes(self, full_data):
        """Publishes only changed data to subtopics."""
        
        # Common metadata to include in every message
        common = {
            "device": full_payload["device"],
            "timestamp": full_payload["timestamp"],
            "boot_time": full_payload.get("boot_time")
        }
        
        categories = ["cpu", "memory", "disk", "network", "power", "sensors"]
        
        for category in categories:
            if category not in full_data:
                continue
                
            sensor_data = full_data[category]
            
            # Serialize to check for changes (stable sort)
            current_json = json.dumps(sensor_data, sort_keys=True)
            last_json = self.last_sent_data.get(category)
            
            if current_json != last_json:
                # Prepare payload: Data + Metadata
                payload = {**sensor_data, **common}
                payload_str = json.dumps(payload)
                
                topic = f"{self.topic_base}/{category}"
                self.client.publish(topic, payload_str)
                
                print(f"📤 Sent {category} update -> {topic} ({len(payload_str)} bytes)")
                
                # Update state
                self.last_sent_data[category] = current_json

    async def run(self):
        """Main Loop: Fixed-Rate Execution."""
        print(f"🚀 Starting Monitoring Agent for {self.hostname}...")
        
        if not await self.connect():
            return

        print("📡 Monitoring active. Press Ctrl+C to stop.")
        
        try:
            while True:
                start_time = asyncio.get_running_loop().time()
                
                # --- WORK PHASE ---
                try:
                    full_payload = await self.collect_metrics()
                    
                    # Fix: Pass full_payload to publish method, not assume global
                    # Need to fix variable scope in publish_changes first? 
                    # Actually I noticed a bug in my own code block above: 
                    # `common` uses `full_payload` which isn't defined in `publish_changes`.
                    # I will fix this inline during writing.
                    await self.publish_changes(full_payload)
                    
                except Exception as e:
                    print(f"⚠️ Error in loop: {e}")

                # --- SLEEP PHASE (Fixed Rate) ---
                # Calculate how much time the work took
                elapsed = asyncio.get_running_loop().time() - start_time
                
                # Sleep only the remaining time to maintain interval
                sleep_time = max(0, self.interval - elapsed)
                
                if sleep_time == 0:
                    print("⚠️ Warning: Collection took longer than interval!")
                
                await asyncio.sleep(sleep_time)
                
        except asyncio.CancelledError:
            print("\n🛑 Stopping...")
        finally:
            self.client.loop_stop()
            self.client.disconnect()


    # CORRECTED METHOD FOR WRITING TO FILE (Bugfix applied here)
    async def publish_changes(self, full_data):
        # Metadata
        common = {
            "device": full_data["device"],
            "timestamp": full_data["timestamp"],
            "boot_time": full_data.get("boot_time")
        }
        
        categories = ["cpu", "memory", "disk", "network", "power", "sensors"]
        
        for category in categories:
            if category not in full_data or full_data[category] is None:
                continue

            sensor_data = full_data[category]
            current_json = json.dumps(sensor_data, sort_keys=True)
            last_json = self.last_sent_data.get(category)
            
            if current_json != last_json:
                payload = {**sensor_data, **common}
                payload_str = json.dumps(payload)
                topic = f"{self.topic_base}/{category}"
                
                self.client.publish(topic, payload_str)
                print(f"📤 Sent {category} -> {topic}")
                
                self.last_sent_data[category] = current_json

if __name__ == "__main__":
    agent = MonitoringAgent(BROKER_ADDRESS, TOPIC_BASE, UPDATE_INTERVAL)
    
    try:
        asyncio.run(agent.run())
    except KeyboardInterrupt:
        pass
