defmodule Discordbot.Consumer do

  use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do

      cond do

        # COMANDOS

        String.starts_with?(msg.content, "!gameprice ") -> gamePrice(msg)

        msg.content == "!gameprice" -> Api.create_message(msg.channel_id, "Use **!gameprice <nome do jogo>** para descobir o preço do jogo na Steam.")

        # Caso Geral
        String.starts_with?(msg.content, "!") -> Api.create_message(msg.channel_id, "Comando inválido, tente novamente.")

        # Listar comandos existentes
        msg.content == "!comandos" -> Api.create_message(msg.channel_id, "Os comandos existentes no bot são: **!gameprice**, **...**")

        # Nada
        true -> :ignore

      end

    end

    defp gamePrice(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      game = Enum.fetch!(aux, 1)

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
