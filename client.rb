#!/usr/bin/ruby
# Car

require 'socket'
require './setting'
require './buffer'
require './logger'
require './rXHandler'
require './clientController'

=begin
  
  This class is responsible for creating a connection to the server, receiving
  the the data and writing them in a file.

  Author:: Afshin Arefi (mailto:arefi@ualberta.ca)

=end

class Client
  
  def initialize(setting)
    @setting=setting
  end

  def request
    
    @rXHandler=RXHandler.new @setting
    @rXHandler.initializeDataPath
    @clientController=ClientController.new @setting
    @clientController.handshakeDataInfo @rXHandler.dataPathPort
    @rXHandler.totalPackets=@clientController.totalPackets
    @rXHandler.fileSize=@clientController.fileSize
    @rXHandler.initializeHandlers
    controlThread=Thread.new {@clientController.start self}
    @rXHandler.start
  end

  def loss
    @rXHandler.loss
  end

  def total
    @rXHandler.total
  end

end

setting=Setting.new
client=Client.new(setting)
client.request
