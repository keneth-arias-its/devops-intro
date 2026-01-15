import json
import sensors

def run_test():
    print("🧪 TEST RUN: verifying app/sensors.py logic...\n")

    # 1. System Info
    print(f"Boot Time: {sensors.get_boot_time()}")

    # 2. Collect all metrics using the module functions
    results = {
        "cpu": sensors.get_cpu_metrics(),
        "memory": sensors.get_memory_metrics(),
        "disk": sensors.get_disk_metrics(),
        "network": sensors.get_network_metrics(),
        "power": sensors.get_power_metrics(),
        "sensors": sensors.get_hardware_sensors()
    }

    # 3. Print Results
    print(json.dumps(results, indent=4))
    
    print("\n✅ Test completed. If you see JSON above, the sensors module is working.")

if __name__ == "__main__":
    run_test()
