defmodule Telegram.Matcher do
  use GenServer

  require Protocol
  Protocol.derive(Jason.Encoder, Nadia.Model.InlineKeyboardMarkup)

  # Server

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast({:match, %{message: _message, edited_message: nil} = update}, state) do
    commands_module = Application.get_env(:tg_bot, :commands)
    if Keyword.has_key?(commands_module.__info__(:functions), :do_match_message) do
      commands_module.match_message(update)
    end

    {:noreply, state}
  end
  def handle_cast({:match, _update}, state), do: {:noreply, state}

  # Client

  def match(update) do
    GenServer.cast(__MODULE__, {:match, update})
  end
end
