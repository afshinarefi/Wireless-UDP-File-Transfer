#!/usr/bin/ruby

require './buffer'
require './logger'
require './fileReader'
require './encoder'
require './transmitter'

=begin
  
  This class is responsible for breaking a file into packets, add header and
  perform any necessary coding.

  Author:: Afshin Arefi (mailto:arefi@ualberta.ca)

=end

class TXHandler

  # This method initializes the default values.

  def initialize(setting,server)
    @setting=setting
    @buffer=Buffer.new(@setting)
    @server=server
  end

  def initializeWorkers
    @fileReader=FileReader.new(@setting,@buffer.getEditor(0))
    @totalPackets=@fileReader.totalPackets
    @fileSize=@fileReader.fileSize
    @encoder=Encoder.new(@setting,@totalPackets,self,@buffer.getEditor(1))
    @transmitter=Transmitter.new(@totalPackets,@dataPath,@buffer.getEditor(2))
  end

  def start
    fileReaderThread=Thread.new {@fileReader.start}
    encoderThread=Thread.new {@encoder.start}
    transmitterThread=Thread.new {@transmitter.start}
    fileReaderThread.join
    Logger.log :Info,"FileReader thread done!"
    encoderThread.join
    Logger.log :Info,"Encoder thread done!"
    transmitterThread.join
    Logger.log :Info,"Transmitter thread done!"
  end
  
  def initializeDataPath dataPathPort
    @dataPathPort=dataPathPort
    Logger.log :Info,"Creating a UDP stream to #{@setting.broadcastIP}:#{@dataPathPort}."
    @dataPath=UDPSocket.new
    @dataPath.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    @dataPath.connect @setting.broadcastIP,@dataPathPort
    Logger.log :Info,"Stream was created."
  end

  def closeDataPath    
    Logger.log :Info,"Closing the data path."
    @dataPath.close
  end

  def totalPackets
    @totalPackets
  end

  def fileSize
    @fileSize
  end

  def lossRate
    @server.lossRate
  end

end

__END__
