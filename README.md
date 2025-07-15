# Pokédex com Ruby e Sinatra

Uma Pokédex completa e interativa desenvolvida com Ruby e Sinatra, consumindo a [PokéAPI](https://pokeapi.co/).

## ✨ Funcionalidades

- **Exploração de Pokémon**
  - Visualização de uma lista paginada de Pokémon
  - Página de detalhes para cada Pokémon com estatísticas, habilidades e descrição
  - Navegação entre Pokémon (anterior e próximo)
  - Visualização da cadeia evolutiva dos Pokémon
  
- **Busca e Filtros**
  - Busca em tempo real por nome com sugestões de autocompletar
  - Filtros por tipo de Pokémon
  - Filtragem por favoritos
  
- **Recursos Avançados**
  - Sistema de favoritos com persistência de dados
  - Comparador de Pokémon (estatísticas, tipos, características)
  - Recomendador de equipes baseado em tipos e complementaridades
  - Sugestão de Pokémon com base no clima atual de sua localização
  - Mini-jogo "Quem é esse Pokémon?" para testar seus conhecimentos

- **Gerenciamento de Equipes**
  - Criação e gerenciamento de equipes de Pokémon
  - Até 6 Pokémon por equipe
  - Possibilidade de dar apelidos aos Pokémon
  
- **Interface Personalizável**
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

### Configuração Inicial

1. Clone o repositório: `git clone https://github.com/Augusto240/pokedex-ruby`
2. Navegue para a pasta do projeto: `cd pokedex-ruby`

#### Configurando a API de Clima (Opcional)
Para usar a funcionalidade de Pokémon baseado no clima atual:
1. Copie o arquivo de configuração: `cp config/secrets.yml.example config/secrets.yml`
2. Obtenha uma chave gratuita em [OpenWeatherMap](https://openweathermap.org/api)
3. Adicione sua chave no arquivo `config/secrets.yml`

### Método 1: Diretamente

1. Instale as dependências: `bundle install`
2. Inicie o servidor: `bundle exec ruby app.rb`
3. Abra o seu navegador e acesse `http://localhost:5000`

### Método 2: Usando Docker

1. Execute o Docker Compose: `docker-compose up`
2. Abra o seu navegador e acesse `http://localhost:5000`

## 🌟 Recursos em Destaque

### Página Inicial
A página inicial exibe uma lista paginada de Pokémon com busca em tempo real e filtros por tipo. Você pode favoritar Pokémon diretamente nesta página e ver um Pokémon recomendado com base no seu clima local.

### Página de Detalhes
Exibe informações detalhadas sobre um Pokémon específico, incluindo:
- Estatísticas de base
- Habilidades
- Tipo(s)
- Dimensões (altura/peso)
- Cadeia evolutiva com navegação
- Acesso ao recomendador de equipes e comparador

### Sistema de Favoritos
Permite que você marque Pokémon como favoritos. Os favoritos são armazenados em um banco de dados SQLite para persistência e podem ser visualizados em uma página dedicada.

### Comparador de Pokémon
Compare estatísticas, tipos e características entre dois Pokémon diferentes. Visualize lado a lado qual Pokémon tem vantagem em cada atributo.

### Recomendador de Equipes
Receba sugestões inteligentes de equipes equilibradas com base em um Pokémon escolhido, considerando vantagens de tipo e cobertura estratégica.

### Pokémon do Clima
Descubra qual Pokémon é mais adequado para o clima atual em sua localização. O tipo do Pokémon sugerido é alinhado com as condições meteorológicas atuais.

### Mini-jogo "Quem é esse Pokémon?"
Teste seus conhecimentos identificando Pokémon apenas por suas silhuetas. Um desafio divertido para os verdadeiros mestres Pokémon!

### Gerenciamento de Equipes
Crie, edite e gerencie equipes com até 6 Pokémon. Dê apelidos aos seus Pokémon e organize-os como quiser.

### Tema Claro/Escuro
Alterne entre os temas claro e escuro com um clique. Sua preferência será lembrada em visitas futuras.

## 🚧 Implementações Futuras

- Testes automatizados com RSpec
- Mais mini-jogos e desafios
- Visualização de movimentos e ataques
- Informações de itens e berries
- Integração com outras APIs Pokémon
- Sistema de autenticação de usuários

## 👨‍💻 Autor

Desenvolvido por [Augusto240](https://github.com/Augusto240).

---

Feito com ❤️ e Ruby.