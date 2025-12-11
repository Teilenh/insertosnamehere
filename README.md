# 🎯 Projet : Image Fedora Atomic Sway personnalisée (Desktop AMD)

## 🧩 Objectif
Me basé sur l'**image Fedora Atomic Sway**, pour faire une image custom, prête a l'emploi ( pour moi ) et fonctionnel,
But : un environnement **performant, reproductible, et légèrement durci**, optimisé pour **le gaming**, tout en conservant la nature **immutable** d'une Fedora Atomic.

---

## 🧱 Structure du dépôt
Basé sur le **template uBlue**, avec les éléments principaux :
- `Containerfile` — définition de l’image custom, héritant de `fedora-atomic-sway`
- `build.sh` 

---

## ✅ État actuel

- [x] **Base :** Fedora Atomic Sway (officielle)
- [x] SELinux actif et configuré (set par défaut avec Fedora)

---

## 🚧 Étapes à venir

### 🧠 Optimisations système
- [ ] opti système, latence, network, scheduler 

---

### 🎮 Logiciels à intégrer
- [x] Steam
- [ ] Lutris
- [ ] Gamemode
- [ ] Gamescope (session gaming)
- [x] Discord, Firefox
- [ ] Protonplus ( Flatpak ) 
- [ ] Virt-manager / QEMU / libvirt / spice-vdagent (VM)
- [ ] Outils : neovim, git, **fastfetch**, btop, etc.

---

### 🖥️ Environnement Sway & UI
- [ ] Configuration Sway (keybinds, rules)
- [ ] Waybar : topbar + modules personnalisés
- [ ] Wlogout & rofi configurés ( a méditer pour rofi, j'envisage une autre option )
- [ ] Thème GTK/Qt global (pas encore choisi un théme particulier)
- [ ] Pack d’icônes : **Arashi**
- [ ] Wallpaper par défaut intégré

---

### 🧰 Automatisation & outils
- [ ] `build.sh` (optimisations et durcissement)
- [ ] `sway-setup.sh`

---

### 🔒 Hardening additionnel (léger)
- [ ] Vérification journald (rotation, taille, compression)
- [ ] Firewalld : zones et règles affinées
- [ ] Vérification XDG & désactivation autologin

---

## 📘 Notes finales
- Image de base : Fedora sway Atomic
- point clé : réactif et élégant,légère opti
