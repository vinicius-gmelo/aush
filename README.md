# aush - autoupdate sh
Script que busca atualizações sempre que um shell script é executado, utilizando `git` e um arquivo de source. Funciona com shell scripts compatíveis com POSIX.
## Requerimentos
- `git`: este script utiliza `git clone` para atualização de shell scripts;
- `curl`: teste da url inserida pelo usuário na configuração deste script; 
- `chmod +x 'aush.sh'; cp 'aush.sh' 'aush_source.sh' "${HOME}/.local/bin/"; cd "${HOME}/.local/bin"; mv 'aush.sh' 'aush'` (utilizar o diretório de scripts do usuário - `"${HOME}/.bin"`, ou outro): `aush` deve constar nos comandos do shell do usuário para funcionar e 'aush_source.sh' deve estar disponível no mesmo diretório;
- O nome do script deve ser o mesmo do repositório e o script a ser atualizado deve estar no diretório raiz do repositório (ex.: 'meu_script.sh' deve constar na raiz do repositório 'meu_script' do usuário).
## Uso
A maneira mais simples de utilizar este script é clonar algum repositório e utilizar os comandos `aush config` e `aush [script]`. Com isso, sempre que o script for executado, `aush` buscará por atualizações. Para atualizar o próprio `aush`, utilize `aush update`.
