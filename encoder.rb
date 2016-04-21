#!/usr/bin/ruby

class Encoder

  def initialize setting,totalPackets,tXHandler,editor
    @setting=setting
    @codeHeader=Array.new(((@setting.windowSize-1)/8)+1,0)
    @codedPacket=Array.new(@setting.chunkSize,0)
    @editor=editor
    @sequenceNumber=0
    @totalPackets=totalPackets
    @tXHandler=tXHandler
    @mergeList=[]
  end

  def start
    @editor.allocateWindow!
    @mergeList=(0...(@setting.windowSize-1)).to_a.sample(@tXHandler.mergeCount)
    for @sequenceNumber in 0...@totalPackets
      if not @editor.isInWindow? @sequenceNumber
        @editor.releaseWindow
        @editor.allocateWindow!
        @mergeList=(0...(@setting.windowSize-1)).to_a.sample(@tXHandler.mergeCount)
      end
      packet=@editor.read @sequenceNumber
      if packet[0]=='C'
        @editor.write(@sequenceNumber,packet+@codeHeader.pack("C*")+@codedPacket.pack("C*"))
        @codeHeader=Array.new(((@setting.windowSize-1)/8)+1,0)
        @codedPacket=Array.new(@setting.chunkSize,0)
      else
        self.encode(packet[9..-1],@sequenceNumber % @setting.windowSize)
      end
    end
    @editor.releaseWindow
  end

  def encode data, index
    if @mergeList.include? index
      @codeHeader[index/8]|=1<<(index%8)
      i=0
      for byte in data.bytes
        @codedPacket[i]^=byte
        i+=1
      end
    end
  end

end
