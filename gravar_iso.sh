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

# Função para verificar se o disco está montado
verificar_disco_montado() {
    local disco="$1"
    if mount | grep -q "/dev/$disco"; then
        echo "O disco /dev/$disco está montado. Deseja desmontá-lo? (s/n)"
        read -r resposta
        if [[ "$resposta" == "s" ]]; then
            sudo umount "/dev/$disco" || { echo "Falha ao desmontar o disco."; exit 1; }
        else
            echo "Por favor, desmonte o disco antes de continuar."
            exit 1
        fi
    fi
}

# Função para gravar a ISO
gravar_iso() {
    local disco="$1"
    local caminho_iso="$2"
    echo "Gravando a ISO em /dev/$disco..."
    read -p "Tem certeza que deseja continuar? Isso irá sobrescrever dados no disco! (s/n): " confirm
    if [[ "$confirm" == "s" ]]; then
        sudo dd if="$caminho_iso" of="/dev/$disco" bs=4M status=progress
        echo "Gravação concluída."
    else
        echo "Operação cancelada."
    fi
}

# Função para limpar disco
limpar_disco() {
    local disco="$1"
    echo "Limpando o disco /dev/$disco..."
    read -p "Tem certeza que deseja limpar o disco? (s/n): " confirm
    if [[ "$confirm" == "s" ]]; then
        sudo dd if=/dev/zero of="/dev/$disco" bs=4M status=progress
        echo "Limpeza concluída."
    else
        echo "Operação cancelada."
    fi
}

# Função principal
main() {
    while true; do
        echo "Escolha uma opção:"
        echo "1) Gravar ISO"
        echo "2) Limpar disco"
        echo "3) Sair"
        read -p "Digite sua escolha: " opcao

        case $opcao in
            1)
                listar_disks
                local num_disks=$(lsblk -d -n -o NAME | wc -l)
                local disco_selecionado=$(selecionar_disco "$num_disks")
                local caminho_iso=$(obter_caminho_iso)
                local disco=$(lsblk -d -n -o NAME | sed -n "$((disco_selecionado + 1))p")
                verificar_disco_montado "$disco"
                gravar_iso "$disco" "$c
