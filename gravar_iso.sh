#!/bin/bash

# Função para listar discos disponíveis (exclui dispositivos "loop" e somente discos reais)
listar_disks() {
    echo "Discos disponíveis:"
    # lsblk lista dispositivos tipo disk, exclui loop, com tamanho, marcação removível (RM) e modelo
    lsblk -d -n -o NAME,SIZE,RM,MODEL | grep -v 'loop' | grep -v '^$' | awk '{print NR-1 ": /dev/" $1 " - " $2 " - Removível: " $3 " - Modelo: " substr($0, index($0,$4))}'
}

# Função para selecionar disco, validar escolha contra número total de discos listados
selecionar_disco() {
    local max_index=$1
    local escolha
    while true; do
        read -rp "Selecione o número do disco onde deseja gravar a ISO: " escolha
        if [[ "$escolha" =~ ^[0-9]+$ ]] && [ "$escolha" -ge 0 ] && [ "$escolha" -lt "$max_index" ]; then
            echo "$escolha"
            return
        else
            echo "Escolha inválida. Tente novamente."
        fi
    done
}

# Função para obter arquivo ISO válido
obter_caminho_iso() {
    local caminho
    while true; do
        read -rp "Digite o caminho completo para a imagem ISO: " caminho
        if [[ -f "$caminho" && ("$caminho" == *.iso || "$caminho" == *.img) ]]; then
            echo "$caminho"
            return
        else
            echo "Arquivo inválido ou não encontrado. Certifique-se de fornecer um caminho para um arquivo .iso válido."
        fi
    done
}

# Função para verificar se o disco está montado e desmontar se o usuário aceitar
verificar_disco_montado() {
    local disco="$1"
    # Verifica se alguma partição deste disco está montada
    if mount | grep -q "^/dev/$disco"; then
        echo "O disco /dev/$disco está montado. Deseja desmontar todas as suas partições? (s/n)"
        read -r resposta
        if [[ "$resposta" =~ ^[sS]$ ]]; then
            # Desmonta todas as partições relacionadas ao disco
            for part in $(lsblk -ln -o NAME "/dev/$disco" | tail -n +2); do
                sudo umount "/dev/$part" 2>/dev/null && echo "Desmontado /dev/$part"
            done
        else
            echo "Por favor, desmonte o disco manualmente antes de continuar."
            exit 1
        fi
    fi
}

# Função para gravar ISO no disco selecionado
gravar_iso() {
    local disco="$1"
    local caminho_iso="$2"
    echo "Gravando a ISO em /dev/$disco..."
    read -rp "Tem certeza que deseja continuar? Isso irá sobrescrever todos os dados no disco /dev/$disco! (s/n): " confirm
    if [[ "$confirm" =~ ^[sS]$ ]]; then
        # Usa dd com bs=4M e status=progress para desempenho e feedback
        sudo dd if="$caminho_iso" of="/dev/$disco" bs=4M status=progress conv=fdatasync
        if [ $? -eq 0 ]; then
            echo "Gravação concluída com sucesso."
        else
            echo "Erro durante a gravação da ISO."
        fi
    else
        echo "Operação cancelada."
    fi
}

# Função principal
main() {
    while true; do
        echo
        echo "Escolha uma opção:"
        echo "1) Gravar ISO em pendrive"
        echo "2) Sair"
        read -rp "Digite sua escolha: " opcao

        case $opcao in
            1)
                # Lista discos (apenas removíveis e não removíveis, exceto loop devices)
                # Primeiro obtém todos os discos
                mapfile -t discos < <(lsblk -d -n -o NAME | grep -v 'loop')

                # Se não encontrou discos, aborta
                if [ "${#discos[@]}" -eq 0 ]; then
                    echo "Nenhum disco encontrado."
                    exit 1
                fi

                listar_disks
                local num_disks=${#discos[@]}

                local escolha=$(selecionar_disco "$num_disks")
                local disco="${discos[$escolha]}"

                verificar_disco_montado "$disco"
                local iso_path=$(obter_caminho_iso)

                gravar_iso "$disco" "$iso_path"
                ;;
            2)
                echo "Saindo."
                exit 0
                ;;
            *)
                echo "Opção inválida. Tente novamente."
                ;;
        esac
    done
}

main
