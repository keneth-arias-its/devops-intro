# App di Telemetria

Questo script legge i dati dei sensori del laptop (CPU, RAM, Batteria, ecc) e li pubblica sul broker MQTT Mosquitto in esecuzione sulla VM Vagrant. Utilizza l'hostname della macchina come identificatore del dispositivo.

## Prerequisiti

- [uv](https://github.com/astral-sh/uv) installato sulla macchina host.
- VM Vagrant in esecuzione (`vagrant up`).

## Utilizzo

1. Entra nella directory:
   ```bash
   cd app
   ```

2. Installa le dipendenze e sincronizza l'ambiente:
   ```bash
   uv sync
   ```

3. Esegui lo script:
   ```bash
   uv run main.py
   ```