#!/usr/bin/ruby

class FileWriter

  def initialize setting,totalPackets,fileSize,editor
    @setting=setting
    @totalPackets=totalPackets
    @fileSize=fileSize
    @outputFile=File.open(@setting.destinationDir+Time.now.to_s+"."+@setting.fileName,'wb')
    @editor=editor
    @sequenceNumber=0
    @totalSize=0
  end

  def start
    @editor.allocateWindow!
    while @sequenceNumber<@totalPackets
      if @editor.isAfterWindow? @sequenceNumber
        @editor.releaseWindow
        @editor.allocateWindow!
      end
      packet=@editor.read @sequenceNumber
      @editor.write @sequenceNumber,nil
      if packet!=nil and packet[0]=='D'
        if (@fileSize-@totalSize)<@setting.chunkSize
          @totalSize+=@outputFile.write(packet[9...(@fileSize-@totalSize+9)])
	else
          @totalSize+=@outputFile.write(packet[9..-1])
	end
      end
      @sequenceNumber+=1
    end
    @editor.releaseWindow
    @outputFile.close
  end

  def totalPackets
    @totalPackets
  end

end
