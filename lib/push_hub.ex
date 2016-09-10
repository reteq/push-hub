defmodule PushHub do
  use GenServer

  @name __MODULE__
  @default_timeout 20000
  @timeout Application.get_env(:push_hub, :timeout, @default_timeout)
  @error_no_provider "should set push service provider in your config file"

  @doc """
  Starts the type server.
  """
  @spec start_link :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  @spec start_link_raw :: GenServer.on_start
  def start_link_raw do
    GenServer.start_link(__MODULE__, [])
  end

  @doc """
  Send message to device.

  If failed, will response with reason
  """
  @spec send(title :: String.t, message :: String.t, server :: GenServer.on_start) :: {:ok, any} | {:error, any}
  def send(title, message, options \\ %{}, server \\ @name) do
    GenServer.call(server, {:send, title, message, options}, @timeout)
  end

  def init(_) do
    {:ok, {}}
  end

  def handle_call({:send, title, message, options}, _from, state) do
    case Application.get_env(:push_hub, :provider) do
      nil -> 
        {:reply, {:error, @error_no_provider}, state}
      provider -> 
        {:reply, provider.send(title, message, options), state}
    end
  end
end
