### Instalar WSL (Ubuntu) en windows

```bash
# Habilitar WSL y Virtual Machine Platform
# habilidtar la bios intel vitual 
# open features or activar 
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:Hyper-V /all /norestart
# bugs 
bcdedit /set hypervisorlaunchtype auto
# **Descarga el instalador del kernel WSL 2 desde el sitio oficial de Microsoft**:  
   [https://aka.ms/wsl2kernel](https://aka.ms/wsl2kernel)

2. **Ejecuta el instalador** descargado (`wsl_update_x64.msi`) y sigue los pasos. Esto instalará el kernel de Linux necesario para que WSL 2 funcione.
wsl --list --online
wsl --install
wsl --install -d Ubuntu-22.04

```

### Instalar Docker dentro de WSL (Ubuntu)

```bash

sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc
# add 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# continue 
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
# cierra la wsl-ubuntu 
docker --version
docker compose version

``` 
- ssh
```bash
# download vscode and install pluggins remote -wsl
ssh-keygen -t rsa -b 4096 -C "correo@gmail.com"
eval "$(ssh-agent -s)"
ssh-add yes
#add ssh a git keygen

eval "$(ssh-agent -s)"
ssh-add /home/oakdev/yes
git push -u origin main

``` 
- python
```bash
sudo apt update && sudo apt install python3-venv -y
python3 -m venv venv
source venv/bin/activate
```
---
Para que `apt` use tu proxy HTTP en el puerto 3128, debes indicarlo explícitamente en su configuración (independientemente de que hayas exportado ya variables de entorno). Te propongo dos métodos:

---

### 1. Definir el proxy en un fichero de configuración de APT

1. Crea (o edita) un archivo llamado, por ejemplo, `/etc/apt/apt.conf.d/01proxy` con permisos de root:
   ```bash
   sudo nano /etc/apt/apt.conf.d/01proxy
   ```
2. Dentro, añade estas líneas (sustituye `proxy` por el hostname o IP real de tu proxy):

   ```plain
   Acquire::http::Proxy  "http://proxy:3128/";
   Acquire::https::Proxy "http://proxy:3128/";
   Acquire::ftp::Proxy   "http://proxy:3128/";
   ```

   - Si tu proxy requiere autenticación, el formato es:
     ```
     Acquire::http::Proxy "http://usuario:contraseña@proxy:3128/";
     ```
3. Guarda y cierra el archivo. A partir de este momento, `sudo apt update` ya usará ese proxy.

---

### 2. Exportar variables de entorno (sesión actual o global)

Puedes exportar las variables en tu shell actual o hacerlas permanentes:

- **Sólo para la sesión actual**:
  ```bash
  export http_proxy="http://proxy:3128/"
  export https_proxy="http://proxy:3128/"
  ```
  Luego:
  ```bash
  sudo -E apt update
  ```

- **Para todos los usuarios / sesiones**  
  Añade las mismas líneas en `/etc/environment` (requiere reiniciar sesión) o en tu `~/.bashrc`:
  ```bash
  echo 'http_proxy="http://proxy:3128/"'   | sudo tee -a /etc/environment
  echo 'https_proxy="http://proxy:3128/"'  | sudo tee -a /etc/environment
  ```

---

### Verifica la conectividad

1. **Ping al proxy**  
   ```bash
   ping -c3 proxy
   ```
2. **Telnet al puerto 3128**  
   ```bash
   telnet proxy 3128
   ```
   Deberías ver cómo acepta conexiones.

Si tras estos cambios sigue sin funcionar, revisa:

- Que el DNS resuelva correctamente `proxy` (prueba con su IP).
- Que no haya reglas de firewall bloqueando el tráfico saliente.
- Que tu proxy permita HTTP(s) hacia `archive.ubuntu.com` y `security.ubuntu.com`.

Con esto `apt update && apt upgrade -y` debería completarse sin los errores de “Connection refused”.
