# Aush
Atualiza automaticamente um script a partir do Github sempre que o script é executado. Utiliza um link para a conta do usuário setado em `$HOME/.aush`. 
## Requerimentos
Clonar o repositório ou baixar o script, habilitando a execução com `chmod +x aush.sh`. Adicionar aos comandos do shell com `mv aush.sh aush; mv aush $HOME/.local/bin` (ou `$HOME/.bin`, ou o diretório de scripts do usuário). Inserir `. aush` antes de qualquer comando do script. O próprio `aush` também pode se incluir no script, com o comando `aush [script]`.
## Uso
```sh
$ aush [script] # adiciona o source do aush no script
$ aush set # seta a conta do Github de onde o aush buscará atualizações para os scripts
$ aush update # atualiza o aush```
$ aush help
```

