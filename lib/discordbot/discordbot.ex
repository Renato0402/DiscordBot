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
        msg.content == "comandos" -> Api.create_message(msg.channel_id, "Os comandos existentes no bot são: **!gameprice**, **...**")

        # Nada
        true -> :ignore

      end

    end

    defp gamePrice(msg) do

      # Quebrando em comando/parametros
      aux = String.split(msg.content, " ", parts: 2)

      game = Enum.fetch!(aux, 1)

      response = HTTPoison.get!("https://www.cheapshark.com/api/1.0/games?title=#{game}")

      {:ok ,values} = Poison.decode(response.body)

      preco = values[""]

      Api.create_message(msg.channel_id, "O menor preço de #{game} é #{values}")

    end

    def handle_event(_event) do
        :noop
    end

end
