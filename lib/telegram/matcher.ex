defmodule Telegram.Matcher do
  use GenServer

  # Server

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast(message, state) do
    commands_module = Application.get_env(:tg_bot, :commands)
    if Keyword.has_key?(commands_module.__info__(:functions), :do_match_message) do
      commands_module.match_message(message)
    end

    {:noreply, state}
  end

  # Client

  def match(message) do
    GenServer.cast(__MODULE__, message)
  end
end
