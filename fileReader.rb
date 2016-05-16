#!/usr/bin/ruby

class FileReader

  def initialize setting,editor
    @setting=setting
    fileAddress=@setting.sourceDir+@setting.fileName
    Logger.log :Info,"Openning file #{fileAddress} . . ."
    if !File.file? fileAddress
      Logger.log :Error,"File does not exist."
      raise "File does not exist."
    end
    @fileSize=File.size(fileAddress)
    @inputFile=File.open(fileAddress,'rb')
    @totalDataPackets=((@fileSize-1)/(@setting.chunkSize))+1
    @totalPackets=@totalDataPackets+(((@totalDataPackets-1)/(@setting.windowSize-@setting.codeCount))+1)*@setting.codeCount
    @editor=editor
    @sequenceNumber=0
  end

  def start
    Logger.log :Info,"Starting to buffer #{@fileSize} bytes."\
                     " In #{@totalPackets} packets."
    @editor.allocateWindow!
    while @sequenceNumber<@totalPackets
      if not @editor.isInWindow? @sequenceNumber
        @editor.releaseWindow
        @editor.allocateWindow!
      end
      if (@sequenceNumber % @setting.windowSize) >= (@setting.windowSize - @setting.codeCount)
        packet="C%08x" % [@sequenceNumber]
      else
        data=@inputFile.read @setting.chunkSize
        packet="D%08x%s" % [@sequenceNumber,data]
      end
      @editor.write @sequenceNumber,packet
      @sequenceNumber=(@sequenceNumber+1)
    end
    @editor.releaseWindow
  end

  def totalPackets
    @totalPackets
  end

  def fileSize
    @fileSize
  end

end
