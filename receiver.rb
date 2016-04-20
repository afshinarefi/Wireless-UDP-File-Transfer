#!/usr/bin/ruby

require './logger'
require 'timeout'

class Receiver

  def initialize totalPackets,dataPath,editor
    @editor=editor
    @dataPath=dataPath
    @totalPackets=totalPackets
    @sequenceNumber=0
  end


  def start
    packet=nil
    @editor.allocateWindow!
    @editor.allocateWindow!
    loop do
      begin
        timeout(0.1) do
          packet=@dataPath.recv((1<<12)-1)
        end
      rescue Timeout::Error
        if @editor.isAfterWindow?(@totalPackets-1)
          @editor.releaseWindow
          @editor.allocateWindow!
          retry
        else
          break
        end
      end
      @sequenceNumber=packet[1..8].hex
      if @editor.isAfterWindow? @sequenceNumber
        @editor.releaseWindow
        @editor.allocateWindow!
      end
      if @editor.isInWindow? @sequenceNumber
        @editor.write(@sequenceNumber,packet)
      end
    end
    @editor.releaseWindow
    @editor.releaseWindow
  end
end
