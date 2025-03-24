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

wsl --install
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