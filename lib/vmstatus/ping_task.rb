require 'socket'

class Vmstatus::PingTask
  def initialize(host, port)
    @host = host
    @port = port
  end

  def run
    connect_nonblocking
    true
  rescue => e
    false
  end

  private

  def connect_nonblocking
    sockaddr = Socket.sockaddr_in(@port, @host)

    socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    begin
      socket.connect_nonblock(sockaddr)
    rescue IO::WaitWritable
      if IO.select(nil, [socket], nil, 5)
        begin
          socket.connect_nonblock(sockaddr)
        rescue Errno::EISCONN
          # connected
        end
      else
        raise Errno::ETIMEDOUT.new
      end
    ensure
      socket.close
    end
  end
end
