# Fondamenti DevOps
## Percorso Formativo

---

## Modulo 1: VM, Linux, Git (4h)

---

### Introduzione DevOps (30’)

- **Cos’è DevOps:** 
  - Cicli CI/CD
  - Infrastruttura come Codice (IaC)
  - Osservabilità
- **Panoramica Corso:**
  - Prerequisiti
  - Output progetto finale

---

### Git e GitHub (35’)

- **Comandi Base:**
  - `git init`, `clone`, `add`, `commit`
  - `branch`, `merge`, `rebase`, `bisect`
- **Workflow:**
  - Remote repositories, Pull Requests (PR)
- **Esercizio:**
  - Fork repo corso
  - Branch "feature/setup"
  - Pull Request

---

### VirtualBox e Vagrant (75’)

- **Concetti Chiave:**
  - VM vs Container
  - Snapshot
  - Reti: NAT, Host-only, Bridged
- **Setup:**
  - Import box Ubuntu
  - Vagrantfile minimal
- **Esercizio:**
  - VM con 2 NIC (NAT + Host-only)
  - Port forwarding 8080

---

### Nozioni di Base Linux e CLI (60’)

- **Navigazione:** `ls`, `cd`, `pwd`, `find`, `grep`, `less`, `head/tail`, pipe
- **File Management:** `cp`, `mv`, `rm`, `chmod/chown`, `tar`, `rsync`
- **Processi:** `ps`, `top/htop`, `systemctl`
- **Editor:** vi/vim basics
- **Esercizio:** Script bash verifica servizi e log

---

### Gestione Pacchetti e Servizi (20’)

- **Comandi:**
  - `apt update/upgrade/install`
  - `systemctl enable/start/status/logs`
- **Esercizio:**
  - Installare curl, git, python3-pip
