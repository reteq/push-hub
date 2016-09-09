defmodule PushHubTest do
  use ExUnit.Case
  doctest PushHub

  alias PushHub.Aliyun

  setup tags do
    if !tags[:noprovider] do
      Application.put_env(:push_hub, :provider, Aliyun)
    end

    if tags[:aliyun] do
      Application.put_env(:push_hub, :provider, Aliyun)

      Application.put_env(:push_hub, :appkey, "Your app key")
      Application.put_env(:push_hub, :access_key_id, "Your key id")
      Application.put_env(:push_hub, :access_key_secret, "Your key secret")
    end

    {:ok, pid} = PushHub.start_link
    on_exit fn -> 
      Application.delete_env(:push_hub, :provider) 
      Application.delete_env(:push_hub, :appkey) 
      Application.delete_env(:push_hub, :access_key_id) 
      Application.delete_env(:push_hub, :access_key_secret) 
    end
    {:ok, pid: pid}
  end

  @tag :aliyun
  test "the truth" do
    assert {:ok, _} = Aliyun.send(1, "hi", "cheq")
    assert 1 + 1 == 2
  end
end
