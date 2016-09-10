defmodule PushHub.Aliyun do
  @behaviour PushHub.ServiceProvider
  use HTTPoison.Base

  @action "Push"

  def process_url(url) do
    "https://cloudpush.aliyuncs.com/?" <> url
  end

  @defaults %{"Target" => "all", 
    "TargetValue" => ["all"], 
    "Type" => 1, 
    "DeviceType" => 1,
    "StoreOffline" => true
  }

  @doc """
  error response example:
  """
  def send(title, content, options \\ @defaults) do
    if check_config do
      %{"Target" => target, 
        "TargetValue" => devices, 
        "Type" => type, 
        "DeviceType" => device_type,
        "StoreOffline" => offline
      } = Map.merge(@defaults, options)

      url = "&Title=#{encode(title)}&Body=#{encode(content)}&Type=#{type}&StoreOffline=#{offline}&DeviceType=#{device_type}" 
        <> with_devices(target, devices) <> with_nonce <> with_timestamp

      url = with_signature(basic_params <> url)

      response = get(url)

      case(response) do
        {:ok, %HTTPoison.Response{status_code: _code,
          headers: _headers,
          body: resp_body}} ->
            try do
              json = Poison.decode!(resp_body)
              case(json) do
                %{"ResponseId" => _responseId} -> {:ok, json}
                %{"Code" => _code, "Message" => _message} -> {:error, json}
              end
            rescue
              _e -> {:error, resp_body}
            end
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, "no api keys set in config"}
    end
  end

  defp get_access_key_id do
    Application.get_env(:push_hub, :access_key_id)
  end

  defp get_access_key_secret do
    Application.get_env(:push_hub, :access_key_secret)
  end

  defp get_appkey do
    Application.get_env(:push_hub, :appkey)
  end

  defp check_config do
    get_appkey && get_access_key_id && get_access_key_secret
  end

  defp encode(url) do
    url 
    |> URI.encode_www_form
  end

  defp hmac(url) do
    :crypto.hmac(:sha, get_access_key_secret <> "&", url)
    |> Base.encode64
  end

  defp with_devices(target, devices) do
    "&Target=#{target}&TargetValue=" <> Enum.join(devices, ",")
  end

  defp with_timestamp() do
    "&Timestamp=#{DateTime.to_iso8601(DateTime.utc_now)}"
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  defp with_nonce() do
    "&SignatureNonce=" <> random_string(8)
  end

  defp basic_params() do
    "Format=JSON&AccessKeyId=#{get_access_key_id}&Action=#{@action}&AppKey=#{get_appkey}&SignatureMethod=HMAC-SHA1&RegionId=cn-hangzhou&SignatureVersion=1.0&Version=2015-08-27"
  end

  defp with_signature(url) do
    url = url |> URI.decode_query
    |> URI.encode_query 
    |> String.replace("+", "%20")

    to_sign = "GET&" <> encode("/") <> "&" <> encode(url)

    signature = hmac(to_sign)

    url <> "&Signature=" <> encode(signature)
  end
end