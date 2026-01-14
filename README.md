# DevOps Intro - Setup

Questo repository contiene i materiali e gli script di automazione per il corso DevOps. Segui le istruzioni qui sotto per configurare il tuo ambiente locale su Windows.

## 1. Scaricare il Repository

Apri un terminale (PowerShell o Prompt dei comandi) ed esegui il seguente comando per clonare il repository:

```powershell
git clone https://github.com/keneth-arias-its/devops-intro.git
cd devops-intro
```

*Nota: se non hai ancora installato Git, puoi scaricare il file ZIP da GitHub ed estrarlo.*

## 2. Abilitare l'esecuzione degli script PowerShell

Per impostazione predefinita, Windows limita l'esecuzione degli script. È necessario dare l'autorizzazione per eseguire gli script di automazione di questo progetto. Esegui questo comando in PowerShell:

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

## 4. Avvio e Monitoraggio

Una volta configurato l'ambiente (passi 1-3), segui questi passaggi per avviare il sistema:

1. **Avvia la VM Vagrant:**
   ```bash
   vagrant up
   ```

2. **Avvia l'App di Telemetria:**
   Vedi [app/README.md](app/README.md) per i dettagli.

3. **Monitoraggio (WSL e MQTT Explorer):**
   Dopo aver avviato VM e App, configura WSL e apri MQTT Explorer per visualizzare i dati.
   ```powershell
   .\scripts\wsl.ps1
   ```

---

## Risoluzione dei problemi

- **Riavvio del sistema:** Alcuni script (specialmente Docker e VirtualBox) potrebbero richiedere un riavvio del sistema per completare l'installazione dei driver.
- **Diritti di Amministratore:** Fai sempre clic con il tasto destro sul tuo terminale e seleziona **"Esegui come amministratore"** prima di eseguire i file `.ps1`.
- **WinGet:** Questi script utilizzano Windows Package Manager (WinGet). Se WinGet non è presente, gli script proveranno a installarlo automaticamente.