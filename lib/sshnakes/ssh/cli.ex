require IEx
defmodule SSHnakes.SSH.Cli do
  require Logger
  @behaviour :ssh_daemon_channel

  ### API ###
  def send_data(pid, data) do
    send(pid, {:send_data, data})
  end

  ### Callbacks ###

  #### init ####

  def init([]) do
    {:ok, %{channel: nil,
            cm: nil,
            pty: %{term: nil, width: nil, height: nil, pixwidth: nil, pixheight: nil, modes: nil},
            shell: false,
            client_pid: nil
           }}
  end


  #### handle_ssh_msg ####
  def handle_ssh_msg({:ssh_cm, connection_handler,
                      {:data, channel_id, type, data}},
    state) do
    Logger.debug("DATA #{data}")
    SSHnakes.Client.send_data(state.client_pid, data)
    {:ok, state}
  end

  def handle_ssh_msg({:ssh_cm, connection_handler,
                      {:pty, channel_id, want_reply?,
                       {term, width, height, pixwidth, pixheight, modes} = pty}},
    state) do
    :ssh_connection.reply_request(connection_handler, want_reply?, :success, channel_id)
    {:ok, %{state | pty: %{term: term, width: width, height: height, pixwidth: pixwidth, pixheight: pixheight, modes: modes}}}
  end

  def handle_ssh_msg({:ssh_cm, connection_handler,
                      {:env, channel_id, want_reply?, var, value}},
    state) do
    :ssh_connection.reply_request(connection_handler, want_reply?, :failure, channel_id)
    Logger.debug "ENV #{var} = #{value}"
    {:ok, state}
  end

  def handle_ssh_msg({:ssh_cm, connection_handler,
                      {:window_change, channel_id, width, height, pixwidth, pixheight}},
    state) do
    Logger.debug "WINDOW CHANGE"
    SSHnakes.Client.resize(state.client_pid, width, height)
    {:ok, %{state | pty: %{state.pty | width: width, height: height, pixwidth: pixwidth, pixheight: pixheight}}}

  end

  def handle_ssh_msg({:ssh_cm, connection_handler,
                      {:shell, channel_id, want_reply?}},
    state) do
    :ssh_connection.reply_request(connection_handler, want_reply?, :success, channel_id)
    Logger.debug "SHELL"
    {:ok, pid} = SSHnakes.Client.start_link([self(), state.pty.width, state.pty.height])
    {:ok, %{state | client_pid: pid, shell: true}}
  end

  def handle_ssh_msg({:ssh_cm, connection_handler,
                      {:exec, channel_id, want_reply?, cmd}},
    state) do
    :ssh_connection.reply_request(connection_handler, want_reply?, :success, channel_id)
    Logger.debug "EXEC #{cmd}"
    {:ok, state}
  end

  def handle_ssh_msg({:ssh_cm, _connection_handler,
                      {:eof, _channel_id}},
    state) do
    Logger.debug "EOF"
    {:ok, state}
  end

  def handle_ssh_msg({:ssh_cm, _connection_handler,
                      {:signal, _channel_id, signal}},
    state) do
    Logger.debug "SIGNAL #{signal}"
    {:ok, state}
  end

  def handle_ssh_msg({:ssh_cm, _connection_handler,
                      {:exit_signal, channel_id, signal, err, lang}},
    state) do
    Logger.debug "EXIT SIGNAL #{signal} #{err} #{lang}"
    {:stop, channel_id, state}
  end

  def handle_ssh_msg({:ssh_cm, _connection_handler,
                      {:exit_STATUS, channel_id, status}},
    state) do
    Logger.debug "EXIT STATUS #{status}"
    {:stop, channel_id, state}
  end


  def handle_ssh_msg({x,y,z}, state) do

    IEx.pry
  end


  #### handle_msg ####

  def handle_msg({:ssh_channel_up, channel_id, connection_handler}, state) do
    {:ok, %{state | channel: channel_id, cm: connection_handler}}
  end

  def handle_msg({:EXIT, client_pid, reason}, %{client_pid: client_pid} = state) do
    {:stop, state.channel, state}
  end

  ### commands we expect from the client ###
  def handle_msg({:send_data, data}, state) do
    :ssh_connection.send(state.cm, state.channel, data)
    {:ok, state}
  end

  ### catch all for what we haven't seen ###
  def handle_msg(msg, term) do
    IEx.pry
  end


  #### terminate ####

  def terminate(reason, state) do
    :ok
  end
end
