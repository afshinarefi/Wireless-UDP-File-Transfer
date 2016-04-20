#!/usr/bin/ruby

require './buffer'
require './logger'
require './fileWriter'
require './decoder'
require './receiver'

=begin
  
  This class is responsible for breaking a file into packets, add header and
  perform any necessary coding.

  Author:: Afshin Arefi (mailto:arefi@ualberta.ca)

=end

class RXHandler

  # This method initializes the default values.

  def initialize(setting)
    @setting=setting
    @buffer=Buffer.new(@setting)
  end

  def initializeHandlers
    @receiver=Receiver.new(@totalPackets,@dataPath,@buffer.getEditor(0))
    @decoder=Decoder.new(@setting,@totalPackets,@buffer.getEditor(1))
    @fileWriter=FileWriter.new(@setting,@totalPackets,@fileSize,@buffer.getEditor(2))
  end

  def start
    receiverThread=Thread.new {@receiver.start}
    decoderThread=Thread.new {@decoder.start}
    fileWriterThread=Thread.new {@fileWriter.start}
    receiverThread.join
    decoderThread.join
    fileWriterThread.join
  end
  
  def initializeDataPath
    @dataPath=UDPSocket.new
    @dataPath.bind(@setting.broadcastIP,0)
    @dataPathPort=@dataPath.addr[1]
    Logger.log :Info,"Data path created on UDP port %d" % [@dataPathPort]
  end

  def dataPathPort
    @dataPathPort
  end

  def totalPackets= totalPackets
    @totalPackets=totalPackets
  end

  def fileSize
    @fileSize
  end

  def fileSize= fileSize
    @fileSize=fileSize
  end

  def loss
    @decoder.loss
  end

  def total
    @decoder.total
  end
end

__END__
