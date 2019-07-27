defmodule Telegram.Router do
  @bot_name Telegram.get_bot_username()

  # Code injectors

  defmacro __using__(_opts) do
    quote do
      require Logger
      import Telegram.Router

      def match_message(message) do
        try do
          apply(__MODULE__, :do_match_message, [message])
        rescue
          err in FunctionClauseError ->
            Logger.log(
              :warn,
              """
              Errored when matching command. #{Poison.encode! err}
              Message was: #{Poison.encode! message}
              """
            )
        end
      end
    end
  end

  defp generate_message_matcher(message, handler) do
    quote do
      def do_match_message(%{
        message: %{
          text: unquote(message)
        }
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
      def do_match_message(%{
        message: %{
          text: unquote(message) <> " " <> _
        }
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
      def do_match_message(%{
        message: %{
          text: unquote(message) <> "@" <> unquote(@bot_name)
        }
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
      def do_match_message(%{
        message: %{
          text: unquote(message) <> "@" <> unquote(@bot_name) <> " " <> _
        }
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end
  defp generate_message_matcher(handler) do
    quote do
      def do_match_message(var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end


  defp generate_command_matcher(command, handler) do
    quote do
      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command)
        }
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> " " <> _
        }
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> "@" <> unquote(@bot_name)
        }
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> "@" <> unquote(@bot_name) <> " " <> _
        }
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  defp generate_inline_query_matcher(handler) do
    quote do
      def do_match_message(%{inline_query: inline_query} = var!(update))
        when not is_nil(inline_query) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  defp generate_inline_query_command_matcher(command, handler) do
    quote do
      def do_match_message(%{
        inline_query: %{query: "/" <> unquote(command)}
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
      def do_match_message(%{
        inline_query: %{query: "/" <> unquote(command) <> " " <> _}
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  defp generate_callback_query_matcher(handler) do
    quote do
      def do_match_message(%{callback_query: callback_query} = var!(update))
        when not is_nil(callback_query) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  defp generate_callback_query_command_matcher(command, handler) do
    quote do
      def do_match_message(%{
        callback_query: %{data: "/" <> unquote(command)}
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
      def do_match_message(%{
        callback_query: %{data: "/" <> unquote(command) <> " " <> _}
      } = var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  # Receiver Macros

  ## Message

  defmacro message(do: function) do
    generate_message_matcher(function)
  end
  defmacro message(message, do: function)
    when is_bitstring(message) do
    generate_message_matcher(message, function)
  end
  defmacro message(module, function) do
    generate_message_matcher({module, function})
  end
  defmacro message(message, module, function) do
    generate_message_matcher(message, {module, function})
  end

  ## Command

  defmacro command(commands, do: function)
    when is_list(commands) do
    Enum.map(
      commands,
      &generate_command_matcher(&1, function)
    )
  end
  defmacro command(command, do: function) do
    generate_command_matcher(command, function)
  end
  defmacro command(commands, module, function)
    when is_list(commands) do
    Enum.map(
      commands,
      &generate_command_matcher(&1, {module, function})
    )
  end
  defmacro command(command, module, function) do
    generate_command_matcher(command, {module, function})
  end

  ## Inline query

  defmacro inline_query(do: function) do
    generate_inline_query_matcher(function)
  end

  defmacro inline_query(module, function) do
    generate_inline_query_matcher({module, function})
  end

  defmacro inline_query_command(commands, do: function)
    when is_list(commands) do
    Enum.map(
      commands,
      &generate_inline_query_command_matcher(&1, function)
    )
  end
  defmacro inline_query_command(command, do: function) do
    generate_inline_query_command_matcher(command, function)
  end
  defmacro inline_query_command(commands, module, function)
    when is_list(commands) do
    Enum.map(
      commands,
      &generate_inline_query_command_matcher(&1, {module, function})
    )
  end
  defmacro inline_query_command(command, module, function) do
    generate_inline_query_command_matcher(command, {module, function})
  end

  ## Callback query

  defmacro callback_query(do: function) do
    generate_callback_query_matcher(function)
  end
  defmacro callback_query(module, function) do
    generate_callback_query_matcher({module, function})
  end

  defmacro callback_query_command(commands, do: function)
    when is_list(commands) do
    Enum.map(
      commands,
      &generate_callback_query_command_matcher(&1, function)
    )
  end
  defmacro callback_query_command(command, do: function) do
    generate_callback_query_command_matcher(command, function)
  end
  defmacro callback_query_command(commands, module, function)
    when is_list(commands) do
    Enum.map(
      commands,
      &generate_callback_query_command_matcher(&1, {module, function})
    )
  end
  defmacro callback_query_command(command, module, function) do
    generate_callback_query_command_matcher(command, {module, function})
  end

  # Helpers

  def handle_message({module, function}, update)
    when is_atom(function) and is_list(update) do
    Task.start(fn -> apply(module, function, [hd update]) end)
  end
  def handle_message({module, function}, update)
    when is_atom(function) do
    Task.start(fn -> apply(module, function, [update]) end)
  end
  def handle_message(function, _update)
    when is_function(function) do
    Task.start(fn -> function.() end)
  end
  def handle_message(_, _), do: nil
end
