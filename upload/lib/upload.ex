defmodule Upload do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Upload.Worker, [arg1, arg2, arg3])
      worker(__MODULE__, [], function: :run)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Upload.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def run do
    routes = [
      {"/", :cowboy_static, {:priv_file, :upload, "index.html"}},
      {"/upload", Handler, []},
      {"/files/[...]", :cowboy_static, {:priv_dir, :upload, "files"}}
    ]
    dispatch = :cowboy_router.compile([{:_, routes}])
    opts = [port: 3000]
    env = [dispatch: dispatch]
    {:ok, _pid} = :cowboy.start_http(:http, 100, opts, [env: env])
  end
end
