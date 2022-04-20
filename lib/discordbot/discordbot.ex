
defmodule Discordbot.Consumer do

  use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do

      cond do

        # COMANDOS

        # API Dicionário

        String.starts_with?(msg.content, "!dicionario ") -> dicionario(msg)

        msg.content == "!dicionario" -> Api.create_message(msg.channel_id, "Use **!dicionario <palavra em português>** para descobir o significado da palavra desejada.")

        # API Covid-19

        String.starts_with?(msg.content, "!covid ") -> covidCases(msg)

        msg.content == "!covid" -> Api.create_message(msg.channel_id, "Use **!covid <nome do país em Ingles>** para descobir a situação da covid-19 no país escolhido.")

        # API Nba

        String.starts_with?(msg.content, "!nba ") -> nbaID(msg)

        msg.content == "!nba" -> Api.create_message(msg.channel_id, "Use **!nba <nome do jogador> <sobrenome do jogador>** para descobir seus stats na temporada atual.")

        # API Valorant

        String.starts_with?(msg.content, "!valorant ") -> valorant(msg)

        msg.content == "!valorant" -> Api.create_message(msg.channel_id, "Use **!valorant <nome do agente>** para descobir a descrição do agente no Valorant.")

        # API preço de jogos

        String.starts_with?(msg.content, "!gameprice ") -> gamePrice(msg)

        msg.content == "!gameprice" -> Api.create_message(msg.channel_id, "Use **!gameprice <nome do jogo>** para descobir o preço do jogo na Steam.")

        # API Rick and Morty Episode

        String.starts_with?(msg.content, "!rickmortyEP ") -> rickAndMortyEP(msg)

        msg.content == "!rickmortyEP" -> Api.create_message(msg.channel_id, "Use **!rickmortyEP <numero do episodio>** para saber o nome do episodio de Rick and Morty.")

        # API Rick and Morty Character

        String.starts_with?(msg.content, "!rickmortyCH ") -> rickAndMortyCH(msg)

        msg.content == "!rickmortyCH" -> Api.create_message(msg.channel_id, "Use **!rickmortyCH <nome do personagem>** para ver quem é personagem de Rick and Morty.")

        # API Frutas

        String.starts_with?(msg.content, "!fruits ") -> fruits(msg)

        msg.content == "!fruits" -> Api.create_message(msg.channel_id, "Use **!dicionario <palavra em português>** para descobir o significado da palavra desejada.")

        # API Brasileirão

        String.starts_with?(msg.content, "!brasileirao ") -> brasileirao(msg)

        msg.content == "!brasileirao" -> Api.create_message(msg.channel_id, "Use **!brasileirao <nome do time da serie A>** para ver o escudo do time desejado.")

        # Listar comandos existentes
        msg.content == "!comandos" -> Api.create_message(msg.channel_id, "Os comandos existentes no bot são: **!gameprice**, **...**")

        # Caso Geral
        String.starts_with?(msg.content, "!") -> Api.create_message(msg.channel_id, "Comando inválido, tente novamente.")

        # Nada
        true -> :ignore

      end

    end

    defp brasileirao(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      team = Enum.fetch!(aux,1)

      response = HTTPoison.get!("https://api-football-standings.azharimm.site/leagues/bra.1/standings?season=2022&sort=asc")

      {:ok ,values} = Poison.decode(response.body)

      data = values["data"]

      standings = data["standings"]

      achou = Enum.find_value(standings, fn std ->

         teamResponse = std["team"]

         if teamResponse["name"] == team do

            Enum.each(teamResponse["logos"], fn logo ->

              Api.create_message(msg.channel_id, "**#{team}**:")
              Api.create_message(msg.channel_id, logo["href"])

            end)

         end

        end)

      if achou == nil, do: Api.create_message(msg.channel_id, "Time não encontrado na API.")

    end

    defp fruits(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      fruit = Enum.fetch!(aux,1)

      response = HTTPoison.get!("https://www.fruityvice.com/api/fruit/#{fruit}")

      {:ok ,values} = Poison.decode(response.body)

      if Enum.count(values) > 1 do

        Api.create_message(msg.channel_id, "For 100 grams of **#{fruit}**:\n")

        nutritionValues = values["nutritions"]

        carbo = nutritionValues["carbohydrates"]

        protein = nutritionValues["protein"]

        fat = nutritionValues["fat"]

        calories = nutritionValues["calories"]

        sugar = nutritionValues["sugar"]

        Api.create_message(msg.channel_id, "Carbohydrates: #{carbo}\nProtein: #{protein}\nFat: #{fat}\nCalories: #{calories}\nSugar: #{sugar}")

      else

        Api.create_message(msg.channel_id, "Fruta não encontrada na API.")

      end

    end

    defp rickAndMortyEP(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      episode = Enum.fetch!(aux,1)

      response = HTTPoison.get!("https://rickandmortyapi.com/api/episode/#{episode}")

      {:ok ,values} = Poison.decode(response.body)

      if Enum.count(values) > 1 do

        episodeName = values["name"]

        Api.create_message(msg.channel_id, "**Episode #{episode}**: #{episodeName}")

      else

        Api.create_message(msg.channel_id, "Episodio não encontrado na API.")

      end

    end

    defp rickAndMortyCH(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      character = Enum.fetch!(aux,1)

      response = HTTPoison.get!("https://rickandmortyapi.com/api/character")

      {:ok ,values} = Poison.decode(response.body)

      results = values["results"]

      achou = Enum.find_value(results, fn x ->

        name = x["name"]

        if name == character do

          url = x["image"]

          Api.create_message(msg.channel_id, "**#{character}**: #{url}")

        end

      end)

      if achou == nil, do: Api.create_message(msg.channel_id, "Personagem não encontrado na API.")

    end

    defp dicionario(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      word = Enum.fetch!(aux,1)

      response = HTTPoison.get!("https://significado.herokuapp.com/v2/#{word}")

      {:ok ,values} = Poison.decode(response.body)

      Enum.each(values, fn x ->

        if is_map(x) do

          meanings = x["meanings"]

          Api.create_message(msg.channel_id, "Significado de **#{word}**:\n")

          Enum.each(meanings, fn meaning -> Api.create_message(msg.channel_id, "#{meaning}\n")end)

        else

          Api.create_message(msg.channel_id, "Palavra não encontrada na API.")

        end
      end)

    end

    defp covidCases(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      country = Enum.fetch!(aux,1)

      response = HTTPoison.get!("https://covid-api.mmediagroup.fr/v1/cases?country=#{country}")

      {:ok ,values} = Poison.decode(response.body)

      if Enum.count(values) < 199 do

        IO.puts(Enum.count(values))

        all = values["All"]

        cases = all["confirmed"]

        deaths = all["deaths"]

        Api.create_message(msg.channel_id, "**#{country}:**\nCasos confirmados: #{cases}\nMortes: #{deaths}")

      else

        Api.create_message(msg.channel_id, "País não encontrado na API.")

      end

    end

    defp nbaID(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ")

      if Enum.count(aux) > 2 do

        playerName = Enum.fetch!(aux,1)

        playerLastName = Enum.fetch!(aux,2)

        response = HTTPoison.get!("https://www.balldontlie.io/api/v1/players?search=#{playerName}%20#{playerLastName}&season=2021")

        {:ok ,values} = Poison.decode(response.body)

        achou = Enum.find_value(values["data"],
       fn x ->

        playerID = x["id"]

        nbaStats(msg, playerID)

        end
        )

        if achou == nil, do: Api.create_message(msg.channel_id, "Jogador não encontrado na API.")

      else

        Api.create_message(msg.channel_id, "Favor inserir nome e sobrenome do jogador desejado")

      end

    end

    defp nbaStats(msg, id) do

      response = HTTPoison.get!("https://www.balldontlie.io/api/v1/season_averages?season=2021&player_ids[]=#{id}")

      {:ok ,values} = Poison.decode(response.body)

      Enum.each(values["data"],
       fn x ->

        pontos = x["pts"]

        rebotes = x["reb"]

        ass = x["ast"]

        roubos = x["stl"]

        blocks = x["blk"]

        Api.create_message(msg.channel_id, "Estatisticas do jogador na Temporada 2021:\n\nPontos por jogo: **#{pontos}**\nRebotes por jogo: **#{rebotes}**\nAssistencias por jogo: **#{ass}**\nRoubos por jogo: **#{roubos}**\nBloqueios por jogo: **#{blocks}**")

        end
        )


    end

    defp valorant(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      agente = Enum.fetch!(aux,1)

      response = HTTPoison.get!("https://valorant-agents-maps-arsenal.p.rapidapi.com/agents/pt-br", [{"X-RapidAPI-Host", "valorant-agents-maps-arsenal.p.rapidapi.com"} , {"X-RapidAPI-Key", "51e1c6efeemshd72c905ddd7e1f8p17b9b9jsnfcb06362662e"}], params: [{"name", agente}])

      {:ok ,values} = Poison.decode(response.body)

      agentes = values["agents"]

      achou = Enum.find_value(agentes,
       fn x ->

        description = x["description"]

        Api.create_message(msg.channel_id, description)

        end
        )

        if achou == nil ,do: Api.create_message(msg.channel_id, "**Agente não encontrado pela API.**")

    end

    defp gamePrice(msg) do

      # Quebrando em comando/parametros

      aux = String.split(msg.content, " ", parts: 2)

      game = Enum.fetch!(aux,1)


      Api.create_message(msg.channel_id, "**Procurando o preço do jogo #{game} na Steam, um momento... **")

      response = HTTPoison.get!("http://api.steampowered.com/ISteamApps/GetAppList/v0002/?format=json")

      {:ok ,values} = Poison.decode(response.body)
      listOfApps = values["applist"]["apps"]

      achou = Enum.find_value(listOfApps,
       fn x ->
        if String.downcase(x["name"]) == String.downcase(game) do

              getPriceById(msg,x["name"] ,x["appid"])

         end
        end
        )


      if achou == nil ,do: Api.create_message(msg.channel_id, "**Jogo #{game} não encontrado**")
    end

  defp getPriceById(msg,name,id) do

    response = HTTPoison.get!("https://store.steampowered.com/api/appdetails?appids=#{id}&cc=pt-br")
    #IO.puts(response.body)
    {_ok,values} = Poison.decode(response.body)

    #Api.create_message(msg.channel_id, "")
    #%{data: v} =  values
    data = values[to_string(id)]["data"]
    price = data["price_overview"]["final_formatted"]
    Api.create_message(msg.channel_id, "O preço do **#{name} é #{price} na Steam.**")

  end

  def handle_event(_event) do
    :noop
  end

end
