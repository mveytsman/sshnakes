defmodule SSHnakes.SSH.NopAuth do
  @moduledoc """
  NOP out out the ssh_server_key_api behaviour since we accept all users
  """

  @behaviour :ssh_server_key_api

  def host_key(algorithm, props) do
    # delegate to the ssh file key api
    :ssh_file.host_key(algorithm, props)
  end

  # all are welcome!
  def is_auth_key(_key, _user, _options), do: true
  def is_valid_password(_username, _password, _peer, _state), do: true

end
