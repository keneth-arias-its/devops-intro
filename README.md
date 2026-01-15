# DevOps Intro - Setup

Questo repository contiene i materiali e gli script di automazione per il corso DevOps. Incluso nel progetto c'è un laboratorio pratico con una VM **Vagrant** (Broker MQTT) e un **Agente di monitoraggio Python**.

## 1. Scaricare il Repository

Apri un terminale (PowerShell o Prompt dei comandi) ed esegui il seguente comando per clonare il repository:

```powershell
git clone https://github.com/keneth-arias-its/devops-intro.git
cd devops-intro
```

*Nota: se non hai ancora installato Git, puoi scaricare il [file ZIP](https://github.com/keneth-arias-its/devops-intro/archive/refs/heads/main.zip) da GitHub, estrarlo e avviare i comandi di installazione.*

## 2. Abilitare l'esecuzione degli script PowerShell

Per impostazione predefinita, Windows limita l'esecuzione degli script. È necessario dare l'autorizzazione per eseguire gli script di automazione di questo progetto. Esegui questo comando in PowerShell *come Amministratore*:

```powershell
set-executionpolicy -scope CurrentUser -executionPolicy Bypass -Force
```

## 3. Eseguire gli script di installazione

Gli script si trovano nella cartella `scripts/`. Devono essere eseguiti con **privilegi di Amministratore** nel seguente ordine:

### A. IDE e Strumenti di base
Installa VS Code, Git e Windows Terminal.
```powershell
.\scripts\ide.ps1
```

### B. Virtualizzazione e Sincronizzazione
Installa Oracle VirtualBox, Vagrant e Syncthing.
```powershell
.\scripts\virtualbox.ps1
```

### C. Docker Desktop
Installa Docker Desktop e configura i requisiti WSL2/Hyper-V.
```powershell
.\scripts\docker.ps1
```

## 4. Avvio ambiente Lab (Vagrant e monitoraggio)

Una volta configurato l'ambiente (passi 1-3), puoi avviare il sistema di monitoraggio distribuito:

### 1. Avvia la VM Vagrant
Questo comanda crea una macchina virtuale con il broker MQTT Mosquitto preinstallato e configurato.

```bash
vagrant up
```
*Nota: La VM avrà IP statico `192.168.56.82`.*

### 2. Avvia l'Agente di monitoraggio
Lo script Python raccoglie le metriche dal tuo PC (CPU, RAM, Disco, Rete) e le invia alla VM.

**Esecuzione con uv (Raccomandato):**
```bash
cd app
uv sync
uv run main.py
```

*Nota: `uv` gestirà automaticamente l'ambiente virtuale e le dipendenze.*

Vedi [app/README.md](app/README.md) per dettagli approfonditi sull'agente.

### 3. Monitoraggio (WSL e MQTT Explorer)
Dopo aver avviato VM e App, installa Ubuntu-24.04 su WSL e apri MQTT Explorer per visualizzare i dati in tempo reale.
Avvia da powershell come amministratore dal percorso `devops-intro>`:
```powershell
.\scripts\wsl.ps1
```
Se non parte automaticamente riesegui il comando.

Per connetterti con **MQTT Explorer**, usa questa configurazione:
| **Name**:  | **Validate Cert**: | **Encryption**: |
| :--- | :--- | :--- |
| DevOps Lab | Disattivato | Disattivato |
| **Protocol**: | **Host**: | **Port**: |
| mqtt:// | 192.168.56.82 | 1883 |
| **Username**: *(vuoto)* | **Password**: *(vuoto)* | |

## 5. Spegnimento (Shutdown)

Quando hai finito di lavorare, segui questi passaggi per spegnere tutto correttamente:

1.  **Arresta l'Agente Python**: Nel terminale dove sta girando lo script python, premi `Ctrl+C` (o `Cmd+C`).
2.  **Chiudi MQTT Explorer**: Semplicemente chiudi la finestra dell'applicazione.
3.  **Spegni la VM Vagrant**: Dal percorso `devops-intro>` esegui:
    ```bash
    vagrant halt
    ```
    *Questo spegnerà la macchina virtuale liberando le risorse del tuo PC.*

---

## Risoluzione dei problemi

- **Riavvio del sistema:** Alcuni script (specialmente Docker e VirtualBox) potrebbero richiedere un riavvio del sistema per completare l'installazione dei driver.
- **Diritti di Amministratore:** Fai sempre clic con il tasto destro sul menu e seleziona **"Esegui come amministratore"** prima di eseguire i file `.ps1`.
- **WinGet:** Questi script utilizzano Windows Package Manager (WinGet). Se WinGet non è presente, gli script proveranno a installarlo automaticamente.

## Licenza

Questo progetto è distribuito sotto licenza MIT - vedi il file [LICENSE](LICENSE) per i dettagli.