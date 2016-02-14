defmodule SlackTodo.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_todo,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      mod: {SlackTodo, []},
      applications: [:logger, :slacker, :sloth, :exredis, :timex]
    ]
  end

  defp deps do
    [
      {:websocket_client, github: "jeremyong/websocket_client"},
      {:slacker,  "~> 0.0.1"},
      {:sloth, github: "tamai/sloth"},
      {:exredis, ">= 0.2.2"},
      {:timex, "~> 1.0.1"}
    ]
  end
end
