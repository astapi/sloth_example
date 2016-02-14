defmodule SlackTodo do
  use Application

  def start(_type, _args) do
    SlackTodo.Supervisor.start_link
  end
end

defmodule SlackTodo.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    supervise [
      worker(Plugin.SlackTodo, []),
    ], strategy: :one_for_one
  end
end

defmodule Plugin.SlackTodo do
  use Sloth.Plugin
  use Timex

  plugin ~r/ping/, :ping

  plugin ~r/^add (.*)$/, :add_todo
  plugin ~r/^todo$/, :get_todo
  plugin ~r/^delete (\d+)$/, :delete_todo

  @todo "todo:"

  def ping(send_data, captures \\ []) do
    Sloth.Slacker.say(send_data["channel"], "pong")
  end

  def add_todo(send_data, captures \\ []) do
    {:ok, client} = redis_client

    time = Timex.Time.now(:secs)
    key = @todo <> send_data["channel"]
    client |> Exredis.query(["ZADD", key, time, List.first(captures)])

    close_redis(client)
  end

  def get_todo(send_data, captures \\ []) do
    {:ok, client} = redis_client

    key = @todo <> send_data["channel"]
    todo_list = client |> Exredis.query(["ZRANGE", key, 0, -1])

    resp = todo_list |> Enum.with_index(1) |> decorate_todo_list("")
    Sloth.Slacker.say(send_data["channel"], resp)

    close_redis(client)
  end

  def delete_todo(send_data, captures \\ []) do
    {:ok, client} = redis_client

    key = @todo <> send_data["channel"]
    index = String.to_integer(List.first(captures))
    todo = client |> Exredis.query(["ZRANGE", key, index - 1, index])
    client |> Exredis.query(["ZREM", key, List.first(todo)])

    close_redis(client)
  end

  defp decorate_todo_list([head | tail], resp) do
    {todo, no} = head 
    decorate_todo_list(tail, "#{resp}#{no}. #{todo}\n")
  end

  defp decorate_todo_list([], resp) do
    resp
  end

  defp redis_client do
    Exredis.start_link
  end

  defp close_redis(client) do
    Exredis.stop client
  end

end
