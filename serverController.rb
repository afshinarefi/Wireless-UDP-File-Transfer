#!/usr/bin/ruby

class ServerController

  attr_reader :mergeCount

  def initialize setting
    @setting=setting
    # Reserving Port CONTROL_PORT to wait for connections
    begin
      Logger.log :Info,"Trying to capture port #{@setting.controlPort}"
      @controlServer=TCPServer.open @setting.serverIP,@setting.controlPort
    rescue SystemCallError => ex
      Logger.log :Error,ex.message
      exit
    end
    Logger.log :Info,"Port #{@setting.controlPort} Allocated."
  end

  def acceptClient
    begin
      Logger.log :Info,"Waiting for clients to connect . . ."
      @client=@controlServer.accept
    rescue SystemExit,SignalException => ex
      raise
    rescue Exception => ex
      Logger.log :Error,ex.message
      retry
    end

    @clientInfo=Hash.new
    @clientInfo[:IP]=@client.peeraddr[3]
    @clientInfo[:PORT]=@client.peeraddr[1]

    Logger.log :Info,"Client #{@clientInfo[:IP]}:#{@clientInfo[:PORT]} made a connection."
  end

  def requestHandler
    for try in 1..@setting.maxTries do
      Logger.log :Info,"Waiting for clients request. (Try #{try}/#{@setting.maxTries})"
      command,@dataPathPort=@client.gets.split(',')
      @dataPathPort=@dataPathPort.to_i
      if command=='STREAM' and @dataPathPort.between?(1,(1<<16)-1)
	return @dataPathPort
      else
        Logger.log :Warning,"Invalid request."
      end
    end
    Logger.log :Warning,"Maximum tries reached. No valid request recieved."
    raise Exception
  end
 
  def sendInfo fileSize,totalPackets
    @client.puts "#{fileSize},#{totalPackets}"
  end

  def terminate
    @client.puts 'END'
  end

  def close
    Logger.log :Info,"Releasing the control port."
    @client.close
  end

  def start
    @mergeCount=(@setting.windowSize-@setting.codeCount)/@setting.codeCount
    while not @client.closed?
      info=@client.gets
      temp=info.to_f
      if temp==0
        mergeCount=@setting.windowSize-@setting.codeCount
      else  
        mergeCount=((@setting.windowSize-@setting.codeCount).to_f/temp.to_f).floor
      end
      if (mergeCount*@setting.codeCount)>(@setting.windowSize-@setting.codeCount)
        mergeCount=(@setting.windowSize-@setting.codeCount)/@setting.codeCount
      end
      @mergeCount=mergeCount
    end
  end

end
