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

  def reportWindowLoss windowLoss
      @controlPath.puts "#{windowLoss}"
  end

end
