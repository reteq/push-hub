defmodule PushHub.ServiceProvider do
  use Behaviour

  @doc """
  interface for push service provider which can be set in config.exs
  """
  defcallback  send(String.t, String.t, String.t, Any) ::  {:ok, any} | {:error, any}
end