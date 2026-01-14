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
  - Import box bento/almalinux-10
  - Vagrantfile minimal
- **Esercizio:**
  - Port forwarding 8080
  - Ip statico 192.168.56.82

---

### Nozioni di Base Linux e CLI (60’)

- **Navigazione:** `ls`, `cd`, `pwd`, `find`, `grep`, `less`, `head/tail`, pipe
- **File Management:** `cp`, `mv`, `rm`, `chmod/chown`, `tar`, `rsync`
- **Processi:** `ps`, `top/htop`, `systemctl`
- **Editor:** vi/vim basics

---

### Gestione Pacchetti e Servizi (20’)

- **Package Managers:**
  - RedHat/AlmaLinux: `dnf`, `rpm`
  - Debian/Ubuntu: `apt`
- **Service Management:**
  - `systemctl enable/start/status/logs`
- **Esercizio:**
  - Installare mosquitto via dnf
