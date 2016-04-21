#!/usr/bin/ruby

=begin
  
  This class can be used to log and report different events happening in the
  process of a running program. Different log levels can be defined so at any
  point only up to a certain importance of logs will be printed.

  Author:: Afshin Arefi (mailto:arefi@ualberta.ca)

=end

class Logger

  # Current levels to be printed.
  @@levels=[:Info,:Warning,:Error]

  # Makes sure only one thread will report at a time.
  @@semaphore = Mutex.new

  @@logFile = File.new("log.dat","a")

  # Will print a given message if the importance level is met.

  def self.log level,message
    if @@levels.include? level
      @@semaphore.synchronize do
        puts "[% 8s | #{Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")} ]  #{message}"% [level]
        @@logFile.puts "[% 8s | #{Time.now}]  #{message}"% [level]
	@@logFile.flush
      end
    end
  end

  # Public accessor for @@levels

  def self.Levels levels
    @@levels=levels
  end
end

__END__
