# Aush
Busca atualizações sempre que um script é executado, utilizando o [GH Cli](https://cli.github.com/). Caso o script esteja desatualizado, atualiza o script. Funciona com shell scripts compatíveis com POSIX.
## Requerimentos
- [GH Cli](https://cli.github.com/): o usuário deve estar logado no [GH CLI](https://cli.github.com/) (`gh auth login`); 
- `chmod +x aush.sh; mv aush.sh aush; mv aush $HOME/.local/bin` (ou `$HOME/.bin`, ou o diretório de scripts do usuário): `aush` deve constar nos comandos do shell do usuário para funcionar;
- O nome do script deve ser o mesmo do repositório e o script deve estar no diretório raiz do repositório (ex.: 'meu_script.sh' deve constar na raiz do repositório 'meu_script' do usuário).
## Uso
A maneira mais simples de utilizar este script é clonar algum repositório e utilizar o comando `aush [script]`. Com isso, o script passará a sempre buscar atualizações em seu respectivo repositório. Para atualizar o próprio `aush`, utilize `aush update`.
