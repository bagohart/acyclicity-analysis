require 'singleton'

# DEBUG-levels:
$NO_LOGGING   = 0
$LOG_ANALYSIS = 1 #leave out copy and initialise calls
$LOG_ALL      = 2

#This class opens and closes files after every call of log()
class Logger
  include Singleton
  def open(filename)
    @filename = filename
    File.open(@filename, 'w') {|f| }
  end

  def log(text)
    File.open(@filename, 'a') {|f| f.puts text}
  end
end

