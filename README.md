# Tool for creating Telegram bots in Elixir

Fork of [elixir-telegram-bot-boilerplate](https://github.com/lubien/elixir-telegram-bot-boilerplate)

---

## Installation

First, add tg_bot to your `mix.exs` dependencies.

``` elixir
def deps do
  [{:tg_bot, "~> 0.1.0"}]
end
```

Second, add some settings to your `config.exs`

``` elixir
config :tg_bot,
  commands: YourBot.Commands

config :nadia,
  token: System.get_env("TELEGRAM_BOT_TOKEN")
```

- `:commands` - your bot commands module
- `:token` - your bot token

---

## Example of your bot commands module

``` elixir
defmodule NiceBot.Commands do
  use Telegram.Router
  use Telegram.Commander

  command ["hello", "hi"] do
    Logger.log(:info, "Command '/hello' or '/hi'")

    send_message("Hello World!")
  end

  command "question" do
    Logger.log(:info, "Command '/question'")

    {:ok, _} =
      send_message(
        "What's the best functional programming language?",
        reply_markup: %Model.InlineKeyboardMarkup{
          inline_keyboard: [
            [
              %{
                callback_data: "/choose rust",
                text: "Rust",
              },
              %{
                callback_data: "/choose elixir",
                text: "Elixir",
              }
            ],
            [
              %{
                callback_data: "/choose erlang",
                text: "Erlang",
              },
              %{
                callback_data: "/choose haskell",
                text: "Haskell",
              },
            ],
            [
              %{
                callback_data: "/typo-:p",
                text: "Other",
              },
            ]
          ]
        }
      )
  end

  callback_query_command "choose" do
    Logger.log(:info, "Callback Query Command '/choose'")

    case update.callback_query.data do
      "/choose rust" ->
        answer_callback_query(text: "Nope :3")
      "/choose elixir" ->
        answer_callback_query(text: "You are absolutely right")
      "/choose erlang" ->
        answer_callback_query(text: "¯\\_(ツ)_/¯")
      "/choose haskell" ->
        answer_callback_query(text: "Nope B)")
    end
  end

  command "argued" do
    Logger.log(:info, "Command '/argued'")

    [_command | args] = String.split(update.message.text, " ")
    send_message("Your arguments were: " <> Enum.join(args, " "))
  end

  message "123" do
    Logger.log(:info, "Message '123'")

    send_message("123")
  end

  # Fallbacks

  # Rescues any unmatched callback query.
  callback_query do
    Logger.log(:warn, "Did not match any callback query")

    answer_callback_query(text: "You are wrong D:")
  end

  # Rescues any unmatched message.
  message do
    Logger.log(:warn, "Did not match the message")

    send_message("Sorry, I couldn't understand you")
  end
end
```

__Note :__ If you don't write any fallback functions, it won't

lead to an error! Bot just won't answer your message.

