# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Box definition
  config.vm.box = "bento/almalinux-10"
  config.vm.box_version = "202511.25.0"


  # Allows stable communication between Host and VM on a fixed IP.
  config.vm.network "private_network", ip: "192.168.56.82"

  # Allows connection via localhost:1883 if the private network fails.
  config.vm.network "forwarded_port", guest: 1883, host: 1883

  # Provisioning: Install and configure Mosquitto MQTT Broker
  config.vm.provision "shell", inline: <<-SHELL
    set -e # Exit on error

    # 1. Install Dependencies
    # Mosquitto is in the EPEL repository
    dnf install -y epel-release
    dnf install -y mosquitto

    # 2. Configure Firewall (Crucial for RHEL/AlmaLinux)
    # Allow traffic on standard MQTT port 1883
    if systemctl is-active --quiet firewalld; then
      echo "Configuring Firewalld..."
      firewall-cmd --permanent --zone=public --add-port=1883/tcp
      firewall-cmd --reload
    else
      echo "Firewalld not active, skipping."
    fi

    # 3. Configure Mosquitto
    # Listen on all interfaces and allow anonymous access for development
    mkdir -p /etc/mosquitto/conf.d
    cat <<EOF > /etc/mosquitto/conf.d/external.conf
listener 1883
allow_anonymous true
EOF

    # 4. Configure Mosquitto Main Config
    # Ensure external config files are included
    if ! grep -q "include_dir /etc/mosquitto/conf.d" /etc/mosquitto/mosquitto.conf; then
        echo "include_dir /etc/mosquitto/conf.d" >> /etc/mosquitto/mosquitto.conf
    fi

    # 5. Start Service
    systemctl enable --now mosquitto
  SHELL

  # VirtualBox specific configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048" # Optimized: 2GB is sufficient for a headless broker
    vb.cpus = 2
    vb.name = "devops-vm"
    vb.gui = true # Enable GUI to debug boot issues
    
    # Optimizations for Hyper-V (NEM) compatibility
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
  end

  # Increase boot timeout to handle slower execution under NEM
  config.vm.boot_timeout = 600
end
