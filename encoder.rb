#!/usr/bin/ruby

class Encoder

  def initialize setting,totalPackets,tXHandler,editor
    @setting=setting
    @editor=editor
    @sequenceNumber=0
    @totalPackets=totalPackets
    @tXHandler=tXHandler
  end

  def initializeWindow
    @cindex=0
    packets=(0...(@setting.windowSize-@setting.codeCount)).to_a
    @mergeList=[]
    for i in 0...@setting.codeCount
      res=packets.sample(@tXHandler.mergeCount)
      packets-=res
      @mergeList<<res
    end
    @codeHeader=Array.new(@setting.codeCount){Array.new(((@setting.windowSize-1)/8)+1,0)}
    @codedPacket=Array.new(@setting.codeCount){Array.new(@setting.chunkSize,0)}
  end

  def start
    @editor.allocateWindow!
    initializeWindow
    for @sequenceNumber in 0...@totalPackets
      if not @editor.isInWindow? @sequenceNumber
        @editor.releaseWindow
        @editor.allocateWindow!
        initializeWindow
      end
      packet=@editor.read @sequenceNumber
      if packet[0]=='C'
        @editor.write(@sequenceNumber,packet+@codeHeader[@cindex].pack("C*")+@codedPacket[@cindex].pack("C*"))
        @cindex+=1
      else
        self.encode(packet[9..-1],@sequenceNumber % @setting.windowSize)
      end
    end
    @editor.releaseWindow
  end

  def encode data, index
    for j in 0...@setting.codeCount
      if @mergeList[j].include? index
        @codeHeader[j][index/8]|=1<<(index%8)
        i=0
        for byte in data.bytes
          @codedPacket[j][i]^=byte
          i+=1
        end
      end
    end
  end

end
