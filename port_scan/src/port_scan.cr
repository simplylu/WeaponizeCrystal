require "socket"

def port_scan(ip : String, min_port : Int32, max_port : Int32) : Array(Int32)
  ports = Array(Int32).new
  min_port.upto(max_port) { |port| 
    begin
      client = TCPSocket.new(ip, port, dns_timeout=1, connect_timeout=1)
      ports.push port
    rescue ex
      # Do nothing
    end
  }
  return ports
end

if ARGV.size == 2
  begin
    ip = ARGV[0]
    min_port = ARGV[1].split("-")[0].to_i
    max_port = ARGV[1].split("-")[1].to_i

    t_start = Time.monotonic
    open_ports = port_scan(ip, min_port, max_port)
    t_end = Time.monotonic

    total = t_end - t_start
    if total.milliseconds > 1000
      total = "#{total.seconds}.#{total.milliseconds}s"
    else
      total = "#{total.milliseconds}ms"
    end

    puts "Portscan for #{ip} has taken #{total}"
    puts "TCP Port #{min_port} to #{max_port} have been scanned"
    puts "Found #{(max_port-min_port)-open_ports.size} closed ports"
    puts "Found #{open_ports.size} open ports"
    open_ports.each do |port|
      puts "  - #{port}"
    end
  rescue ex
    puts "Error:   #{ex.message}"
    puts "Usage:   ./port_scan IP PORT_RANGE"
    puts "Example: ./port_scan 127.0.0.1 1-1000"
  end
else
  puts "Usage:   ./port_scan IP PORT_RANGE"
  puts "Example: ./port_scan 127.0.0.1 1-1000"
end
