Ecco una proposta di testo per le tue slide, strutturata in modo conciso e pronta per essere utilizzata in aula.

### **Modulo 1: VirtualBox e Vagrant (75’)**

**Slide 1: Virtualizzazione vs Containerizzazione**
*   **Virtual Machine (VM):** Un sistema completo (BIOS, kernel, OS) emulato sopra un host fisico tramite un hypervisor.
*   **Container:** Isolamento a livello di processo; condividono il kernel dell'host, offrendo minore overhead e avvio quasi istantaneo.
*   **Isolamento:** Le VM offrono un isolamento hardware forte; i container si basano su *namespaces* e *cgroups* del kernel Linux.

**Slide 2: Gestione degli stati e Snapshot**
*   **Snapshot:** Backup "punto nel tempo" dello stato della VM (disco e memoria).
*   **Rollback:** Permette di ripristinare rapidamente il sistema a uno stato precedente in caso di errori durante i test.
*   **Versatilità:** Ideale per sperimentare nuovi software o patch senza compromettere l'ambiente host.

**Slide 3: Networking in VirtualBox**
*   **NAT (Network Address Translation):** La VM accede a internet tramite l'host; la VM non è raggiungibile dall'esterno.
*   **Host-only:** Rete privata tra host e VM; utile per isolare i servizi ma permettere la gestione locale.
*   **Bridged:** La VM appare come un nodo reale nella rete fisica, ottenendo un IP dallo stesso router dell'host.

**Slide 4: Vagrant Setup & Vagrantfile**
*   **Cos'è Vagrant:** Tool per definire e gestire ambienti virtuali tramite codice (*Infrastructure as Code*).
*   **Vagrantfile:** File di configurazione in Ruby che definisce la "box" (immagine OS) e le risorse della VM.
*   **Comandi base:** `vagrant init` (inizializza), `vagrant up` (avvia), `vagrant halt` (arresta), `vagrant destroy` (elimina).

**Slide 5: Esercitazione Pratica**

---

### **Modulo 2: Nozioni di Base Linux e CLI (60’)**

**Slide 6: Navigazione e Ricerca nel Filesystem**
*   **Comandi base:** `ls` elenca i file, `cd` cambia directory, e `pwd` mostra la posizione attuale nel sistema.
*   **Ricerca:** `find` individua file in base ad attributi (nome, data, permessi); `grep` filtra il testo per trovare pattern specifici.
*   **Pipes (|):** Collegano l'output di un comando all'input di un altro, permettendo di combinare più strumenti semplici in operazioni complesse.

**Slide 7: Visualizzazione e Gestione dell'Output**
*   **Lettura:** `less` permette di scorrere file lunghi una schermata alla volta; `head` e `tail` mostrano rispettivamente l'inizio e la fine di un file.
*   **Monitoraggio:** `tail -f` visualizza le nuove righe aggiunte a un file in tempo reale, fondamentale per i file di log.

**Slide 8: File Management e Permessi**
*   **Manipolazione:** `cp` per copiare, `mv` per spostare o rinominare, e `rm` per eliminare file o intere directory (`rm -r`).
*   **Accesso:** `chmod` modifica i permessi (lettura, scrittura, esecuzione); `chown` cambia il proprietario e il gruppo di un file o directory.

**Slide 9: Sincronizzazione e Archiviazione**
*   **Archivio:** `tar` raggruppa più file e directory in un unico file (es. `.tar.gz`) mantenendo la struttura originale.
*   **Efficienza:** `rsync` è lo strumento standard per la sincronizzazione; trasferisce solo le differenze tra i file, risparmiando tempo e banda.

**Slide 10: Gestione dei Processi e Sistema**
*   **Monitoraggio:** `ps` fornisce un'istantanea dei processi attivi; `top` o `htop` offrono una vista dinamica dell'uso di CPU e memoria.
*   **Servizi:** `systemctl` gestisce le unità di sistema e i daemon (servizi in background).

**Slide 11: Editor di Testo: vi/vim**
*   **Essenziali:** Editor modale presente su quasi ogni sistema Linux.
*   **Modalità:** Inizia in *Command mode*; premi `i` per passare alla *Insert mode*.
*   **Comandi:** `:w` salva, `:q` esce, `:wq` salva ed esce.

---

### **Modulo 3: Gestione Pacchetti e Servizi (20’)**

**Slide 12: Package Managers**
*   **RedHat/AlmaLinux:** Utilizzano `dnf` (alto livello) e `rpm` (basso livello) per la gestione dei pacchetti.
*   **Debian/Ubuntu:** Utilizzano `apt` e `dpkg`.
*   **Funzionamento:** I manager risolvono le dipendenze scaricando automaticamente le librerie necessarie dai repository remoti.

**Slide 13: Service Management (systemctl)**
*   `systemctl start/stop`: Avvia o arresta un servizio immediatamente.
*   `systemctl enable/disable`: Configura l'avvio automatico del servizio al boot del sistema.
*   `systemctl status`: Mostra se un servizio è attivo e visualizza gli errori recenti.

**Slide 15: Esercitazione Pratica**
*   **Task:** Installare il broker MQTT `mosquitto` e avviarlo come servizio.
*   **Comandi:** 
    1. `sudo dnf install mosquitto`
    2. `sudo systemctl enable --now mosquitto`
