# Pokédex com Ruby e Sinatra

Uma Pokédex completa e interativa desenvolvida com Ruby e Sinatra, consumindo a [PokéAPI](https://pokeapi.co/).

![Pokédex Ruby](https://user-images.githubusercontent.com/Augusto240/pokedex-ruby/main/screenshots/pokedex.png)

## ✨ Funcionalidades

- Visualização de uma lista paginada de Pokémon
- Página de detalhes para cada Pokémon com estatísticas, habilidades e descrição
- Navegação entre Pokémon (anterior e próximo)
- Busca em tempo real por nome com sugestões de autocompletar
- Sistema de favoritos com persistência de dados
- Visualização da cadeia evolutiva dos Pokémon
- Modo escuro/claro com persistência de preferência
- Design responsivo e interface amigável

## 🛠️ Tecnologias Utilizadas

- **Backend:** Ruby, Sinatra, ActiveRecord
- **Frontend:** HTML, ERB (Embedded Ruby), CSS, JavaScript
- **Comunicação API:** HTTParty
- **Banco de Dados:** SQLite3
- **Servidor:** Puma
- **Containerização:** Docker

## 🚀 Como Executar Localmente

### Método 1: Diretamente

1. Clone o repositório: `git clone https://github.com/Augusto240/pokedex-ruby`
2. Navegue para a pasta do projeto: `cd pokedex-ruby`
3. Instale as dependências: `bundle install`
4. Inicie o servidor: `bundle exec ruby app.rb`
5. Abra o seu navegador e acesse `http://localhost:5000`

### Método 2: Usando Docker

1. Clone o repositório: `git clone https://github.com/Augusto240/pokedex-ruby`
2. Navegue para a pasta do projeto: `cd pokedex-ruby`
3. Execute o Docker Compose: `docker-compose up`
4. Abra o seu navegador e acesse `http://localhost:5000`

## 🌟 Recursos

### Página Inicial
A página inicial exibe uma lista paginada de Pokémon com busca em tempo real. Você pode favoritar Pokémon diretamente nesta página.

### Página de Detalhes
Exibe informações detalhadas sobre um Pokémon específico, incluindo:
- Estatísticas de base
- Habilidades
- Tipo(s)
- Dimensões (altura/peso)
- Cadeia evolutiva com navegação

### Sistema de Favoritos
Permite que você marque Pokémon como favoritos. Os favoritos são armazenados em um banco de dados SQLite para persistência.

### Tema Claro/Escuro
Alterne entre os temas claro e escuro com um clique. Sua preferência será lembrada em visitas futuras.

## 🚧 Implementações Futuras

- Testes automatizados com RSpec
- Sistema de equipes Pokémon (com até 6 Pokémon)
- Comparação entre Pokémon
- Recomendações baseadas em tipos
- Filtros avançados


## 👨‍💻 Autor

Desenvolvido por [Augusto240](https://github.com/Augusto240).

---

Feito com ❤️ e Ruby.