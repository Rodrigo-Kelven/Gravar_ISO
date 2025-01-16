#!/bin/bash

# Função para listar discos
listar_disks() {
    echo "Discos disponíveis:"
    lsblk -d -n -o NAME,SIZE | awk '{print NR-1 ": /dev/" $1 " - " $2}'
}

# Função para selecionar disco
selecionar_disco() {
    local escolha
    while true; do
        read -p "Selecione o número do disco onde deseja gravar a ISO: " escolha
        if [[ "$escolha" =~ ^[0-9]+$ ]] && [ "$escolha" -ge 0 ] && [ "$escolha" -lt "$1" ]; then
            echo "$escolha"
            return
        else
            echo "Escolha inválida. Tente novamente."
        fi
    done
}

# Função para obter caminho da ISO
# Pensar em colocriar uma interface para isso
obter_caminho_iso() {
    local caminho
    while true; do
        read -p "Digite o caminho completo da imagem ISO: " caminho
        if [ -f "$caminho" ]; then
            echo "$caminho"
            return
        else
            echo "Caminho inválido. Verifique se a ISO existe e tente novamente."
        fi
    done
}

# Função para gravar a ISO
gravar_iso() {
    local disco="$1"
    local caminho_iso="$2"
    echo "Gravando a ISO em /dev/$disco..."
    sudo dd if="$caminho_iso" of="/dev/$disco" bs=4M status=progress
    echo "Gravação concluída."
}

# Função principal
main() {
    listar_disks
    local num_disks=$(lsblk -d -n -o NAME | wc -l)
    local disco_selecionado=$(selecionar_disco "$num_disks")
    local caminho_iso=$(obter_caminho_iso)
    gravar_iso "$(lsblk -d -n -o NAME | sed -n "$((disco_selecionado + 1))p")" "$caminho_iso"
}

# Executa a função principal
main
