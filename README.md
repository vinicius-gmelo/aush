# aush - autoupdate sh
Script que busca atualizações sempre que um shell script é executado, utilizando `git` e um arquivo de source. Funciona com shell scripts compatíveis com POSIX.
## Requerimentos
- `git`: este script utiliza `git clone` para atualização de shell scripts;
- `curl`: teste da url inserida pelo usuário na configuração deste script; 
- `chmod +x 'aush.sh'; cp 'aush.sh' "${HOME}/.local/bin/aush"` (ou `"${HOME}/.bin"`, ou o diretório de scripts do usuário): `aush` deve constar nos comandos do shell do usuário para funcionar;
- O nome do script deve ser o mesmo do repositório e o script deve estar no diretório raiz do repositório (ex.: 'meu_script.sh' deve constar na raiz do repositório 'meu_script' do usuário).
## Uso
A maneira mais simples de utilizar este script é clonar algum repositório e utilizar os comandos `aush config` e `aush [script]`. Com isso, sempre que o script for executado o `aush` buscará por atualizações para o script. Para atualizar o próprio `aush`, utilize `aush update`.
