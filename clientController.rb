#!/usr/bin/ruby


class ClientController

  attr_accessor :fileSize
  attr_accessor :totalPackets

  def initialize(setting)
    @setting=setting
  end

  def handshakeDataInfo dataPathPort
    @controlPath=TCPSocket.new(@setting.serverIP,@setting.controlPort)
    @controlPath.puts "STREAM,#{dataPathPort}"
    
    info=@controlPath.gets
    @fileSize=info.split(',')[0].to_i
    @totalPackets=info.split(',')[1].to_i
    Logger.log :Info,"File Info Received: #{info}"
    Logger.log :Info,"Total Packets: #{@totalPackets}"
  end

  def start client
    lastLoss=0
    lastTotal=0
    loop do
      currentLoss=client.loss
      currentTotal=client.total
      if (currentTotal-lastTotal)==0
        mergeCount=0
      else
        mergeCount=1.0/((currentLoss-lastLoss).to_f/(currentTotal-lastTotal).to_f)
        if mergeCount>@setting.windowSize
          mergeCount=@setting.windowSize+1
        end
      end
      @controlPath.puts "#{mergeCount}"
      lastLoss=currentLoss
      lastTotal=currentTotal
      sleep 0.1
    end
  end

end
