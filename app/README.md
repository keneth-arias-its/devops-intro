# App di monitoraggio

Questo script legge i dati dei sensori del laptop (CPU, RAM, Batteria, Disco, Rete) e li pubblica sul broker MQTT sulla VM Vagrant. Utilizza l'hostname della macchina come identificatore del dispositivo.

## Novità
Il codice è stato modularizzato e reso più robusto:
*   **`main.py`**: Gestisce la connessione MQTT.
*   **`sensors.py`**: Gestisce l'acquisizione dei dati in modo sicuro (`psutil`).

## Prerequisiti

- [uv](https://github.com/astral-sh/uv) installato sulla macchina host (raccomandato).
- VM Vagrant in esecuzione (`vagrant up`).

## Installazione e Utilizzo

1. Entra nella directory:
   ```bash
   cd app
   ```

2. Installa le dipendenze e sincronizza l'ambiente:
   ```bash
   uv sync
   ```
   *Oppure con pip:* `pip install .`

3. Esegui lo script:
   ```bash
   uv run main.py
   ```
   *Oppure con python:* `python main.py`

## Dettagli Tecnici

### Dipendenze
Il progetto richiede:
*   `psutil >= 6.0.0`
*   `paho-mqtt >= 2.0.0`

### Configurazione
L'indirizzo del broker è configurato staticamente per puntare alla VM Vagrant:
*   **Broker**: `192.168.56.82` (Porta 1883)
*   **Topic**: `laptop/monitoring`