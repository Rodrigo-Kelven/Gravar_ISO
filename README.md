
## Gravador de ISO

Script criado com o objetivo de facilitar a criação de pendrives/discos com imagens ISO.
De simples entendimeto, o script usará a biblioteca ***os*** para listar os discos e a biblioteca ***subprocess*** para executar o comando dd no Linux.

## Como Funciona o Script

- Listar Discos: A função listar_disks usa lsblk para listar todos os discos disponíveis no sistema, mostrando o nome e o tamanho de cada disco.
- Selecionar Disco: A função selecionar_disco permite que o usuário selecione um disco a partir da lista exibida. O script verifica se a entrada do usuário é válida.
- Obter Caminho da ISO: A função obter_caminho_iso solicita ao usuário que insira o caminho da imagem ISO. O script verifica se o caminho é válido e se o arquivo existe.
- Gravar a ISO: A função gravar_iso usa o comando dd para gravar a imagem ISO no disco selecionado. O comando é executado com sudo, então o usuário precisará fornecer a senha.
- Função Principal: A função main orquestra a execução do script, chamando as funções na ordem correta.

## Instalação

```bash
  git clone https://github.com/Rodrigo-Kelven/Gravar_ISO
  cd Gravar_ISO
  chmod +x gravar_iso.sh
  ./gravar_iso.sh
```
    
## Melhorias

- Criação de uma interface intuitiva
- Remoção/restauração e limpeza de discos
- Mais confiabilidade para não ter perca de desempenho

# Contribuições

Contribuições são bem-vindas! Se você tiver sugestões ou melhorias, sinta-se à vontade para abrir um issue ou enviar um pull request.


## Autores

- [@Rodrigo_Kelven](https://github.com/Rodrigo-Kelven)
