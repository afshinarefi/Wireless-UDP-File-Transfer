#!/usr/bin/ruby

require './logger'

class Transmitter

  def initialize totalPackets,dataPath,editor
    @editor=editor
    @dataPath=dataPath
    @totalPackets=totalPackets
  end


  def start
    @editor.allocateWindow!
    for @sequenceNumber in 0...@totalPackets
      if not @editor.isInWindow? @sequenceNumber
        @editor.releaseWindow
        @editor.allocateWindow!
      end
      @dataPath.send(@editor.read(@sequenceNumber),0)
    end
    @editor.releaseWindow

  end

end
