defmodule Discordbot.Consumer do

  use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do

      cond do

        # COMANDOS

        # API Valorant

        msg.content == "!valorant" -> valorant(msg)

        #API Words

        String.starts_with?(msg.content, "!words ") -> wordsDefinition(msg)

        msg.content == "!words" -> Api.create_message(msg.channel_id, "Use **!words <palavra>** para descobir o significado da palavra.")

        #API tabela serie A

        msg.content == "!brasileirao" -> brasileirao(msg)

        # API preço de jogos

        String.starts_with?(msg.content, "!gameprice ") -> gamePrice(msg)

        msg.content == "!gameprice" -> Api.create_message(msg.channel_id, "Use **!gameprice <nome do jogo>** para descobir o preço do jogo na Steam.")

        # Listar comandos existentes
        msg.content == "!comandos" -> Api.create_message(msg.channel_id, "Os comandos existentes no bot são: **!gameprice**, **...**")

        # Caso Geral
        String.starts_with?(msg.content, "!") -> Api.create_message(msg.channel_id, "Comando inválido, tente novamente.")

        # Nada
        true -> :ignore

      end

    end

    defp valorant(msg) do

      response = HTTPoison.get!("https://valorant-agents-maps-arsenal.p.rapidapi.com/agents/pt-br", [{"X-RapidAPI-Host", "valorant-agents-maps-arsenal.p.rapidapi.com"} , {"X-RapidAPI-Key", "125e6ae7ebmsh36882299b848d27p150e1ajsnd54c607719e4"}])

      {:ok ,values} = Poison.decode(response.body)

      agentes = values["agents"]

      Enum.each(agentes,
       fn x ->

        Api.create_message(msg.channel_id, agentes["title"])

        end
        )

    end

    defp wordsDefinition(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      word = Enum.fetch!(aux,1)

      response = HTTPoison.get!("https://wordsapiv1.p.rapidapi.com/words/#{word}/definitions", [{"X-RapidAPI-Host", "wordsapiv1.p.rapidapi.com"} , {"X-RapidAPI-Key", "125e6ae7ebmsh36882299b848d27p150e1ajsnd54c607719e4"}])

      {:ok ,values} = Poison.decode(response.body)

      definition = values["definitions"]["definition"]

      Api.create_message(msg.channel_id, "Definition of #{word}: #{definition}")

      IO.puts(values)

    end

    defp brasileirao(msg) do

      apiKey = "Bearer test_f7f9ad174fbd9cc5fe15e00edc0efb"

      response = HTTPoison.get!("https://api.api-futebol.com.br/v1/campeonatos/10/fases/168", [{"Authorization", apiKey}])

      {:ok ,values} = Poison.decode(response.body)

      IO.puts(values)

    end

    defp gamePrice(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      game = Enum.fetch!(aux,1)

      response = HTTPoison.get!("http://api.steampowered.com/ISteamApps/GetAppList/v0002/?format=json")

      {:ok ,values} = Poison.decode(response.body)
      listOfApps = values["applist"]["apps"]
      Enum.each(listOfApps,
       fn x ->
        if String.downcase(x["name"]) == String.downcase(game) do
              IO.puts(x["appid"])
              getPriceById(msg,x["name"],x["appid"])
         end
        end
        )
    end

  defp getPriceById(msg,name,id) do

    response = HTTPoison.get!("https://store.steampowered.com/api/appdetails?appids=#{id}")
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
