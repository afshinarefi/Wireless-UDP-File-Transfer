#!/usr/bin/ruby
# Drone

require 'socket'
require './encoder'
require './logger'
require './setting'
require './tXHandler'
require './serverController'

=begin
  
  This class is responsible for transmitting the packets to the clients
  requesting it.

  Author:: Afshin Arefi (mailto:arefi@ualberta.ca)

=end

class Server

  def initialize(setting)
    @setting=setting
    @tXHandler=nil
  end

  def uninitializeControlPath
    @controlServer.close
  end

 
  def clientHandler
    begin
      @tXHandler=TXHandler.new(@setting,self)
      @dataPathPort=@serverController.requestHandler
      @tXHandler.initializeDataPath @dataPathPort
      @tXHandler.initializeWorkers
      @serverController.sendInfo @tXHandler.fileSize,@tXHandler.totalPackets
      controlThread=Thread.new{@serverController.start}
      dataThread=Thread.new{@tXHandler.start}
      dataThread.join
      Logger.log :Info,"Transmission Complete."

      Logger.log :Info,"Sending terminating message to the client."
      @serverController.terminate 
      @tXHandler.closeDataPath
    rescue SystemExit,SignalException => ex
      Logger.log :Info,"Closing the control path."
      @serverController.close
      raise
    rescue Exception => ex
      Logger.log :Error,ex.message
    end

    Logger.log :Info,"Closing the control path."
    @serverController.close
  end

  def run
    @serverController=ServerController.new @setting
    loop do
      begin
        @serverController.acceptClient
        self.clientHandler
      rescue SystemExit, SignalException => ex
        Logger.log :Warning,"Server Stopped"
	break
      rescue Exception => ex
        Logger.log :Error,"Something unexpected happened and the server stopped:\n\t#{ex.message}"
      end
    end
    @serverController.close
    Logger.log :Info,"Done."
  end

  def mergeRatio
    @serverController.mergeRatio
  end

end

setting=Setting.new
server=Server.new(setting)
server.run
