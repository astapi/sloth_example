use Mix.Config

config :sloth, slack_token: System.get_env("SLACK_TOKEN")

config :exredis,
  host: "127.0.0.1",
  port: 6379,
  password: "",
  db: 0,
  reconnect: :no_reconnect,
  max_queue: :infinity

