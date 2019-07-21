defmodule Telegram do
  use Application

  def start(_type, _args) do
    bot_name = Telegram.get_bot_username()

    unless String.valid?(bot_name) do
      IO.warn(
        """
        Env not found Application.get_env(:telegram, :bot_name)
        This will give issues when generating commands
        """
      )
    end

    if bot_name == "" do
      IO.warn("An empty bot_name env will make '/anycommand@' valid")
    end

    import Supervisor.Spec, warn: false

    children = [
      worker(Telegram.Poller, []),
      worker(Telegram.Matcher, [])
    ]

    opts = [strategy: :one_for_one, name: Telegram.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_bot_username do
    if is_nil(Application.get_env(:nadia, :token)) do
      "bot_name"
    else
      HTTPoison.start()
      token = Application.get_env(:nadia, :token)
      response = HTTPoison.get!("https://api.telegram.org/bot#{token}/getMe")

      Poison.decode!(response.body)["result"]["username"]
    end
  end
end
