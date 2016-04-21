#!/usr/bin/ruby

# This class analyzes the receiving buffer window by window after the
# Receiver class has filled the window with the received packets.
# It replaces the lost packets with dummy all zero packets, and tries to decode
# the coded packet if possible.

class Decoder

  attr_reader :loss
  attr_reader :total

### Initialize general variables
  def initialize setting,totalPackets,editor
    @setting=setting
    @editor=editor
    @totalPackets=totalPackets
    @dummyBody="\0"*@setting.chunkSize
    @headerSize=(((@setting.windowSize-1)/8)+1)
    @loss=0
    @total=0
    @recovered=0
    @totalCoded=0
  end

### Initialize variables for each window
  def initializeWindow
    @codeHeader=Array.new(((@setting.windowSize-1)/8)+1,0)
    @windowLoss=0
    @windowTotal=0
    @windowReceived=' '
    @windowRecovered=' '
    @windowCodedCount=0
  end

### The main process of going through packets and decoding them
  def start

    @editor.allocateWindow!
    
    initializeWindow

    # Going through all packets
    for @sequenceNumber in 0...@totalPackets

      if @editor.isAfterWindow? @sequenceNumber
        
        Logger.log :Info,"#{"% 5d" % [@sequenceNumber/@setting.windowSize-1]} ==> #{'.'*@windowLoss}#{' '*(@setting.windowSize-@windowLoss-1)} #{@windowReceived} #{@windowRecovered} | #{@windowCodedCount} | #{@loss} , #{@totalCoded} , #{@recovered}"
        
        @editor.releaseWindow
        @editor.allocateWindow!

        initializeWindow

      end

      # Reading packet number @sequenceNumber from buffer
      packet=@editor.read @sequenceNumber

      # Case we get a coded packet
      if packet!=nil and packet[0]=='C'
        @windowReceived='X'
        @totalCoded+=1
        begin
          # Checking if the received coded packet is decodable
          if decodable? packet
	          # Performing the decoding
            decode packet
            @windowRecovered='X'
            @recovered+=1
          end
        rescue Exception => ex
          Logger.log :Error,ex.message
        end

      # Case we get a data packet
      elsif packet!=nil
        @total+=1
        @windowTotal+=1

        # Record the receipt of this packet in the window
        index=@sequenceNumber % @setting.windowSize
        @codeHeader[index/8]|=1<<(index%8)

      # Case we miss a data packet 
      elsif (@sequenceNumber % @setting.windowSize) != (@setting.windowSize-1)
        @loss+=1
        @total+=1

        @windowTotal+=1
        @windowLoss+=1

        @editor.write(@sequenceNumber,("D%08x" % @sequenceNumber)+@dummyBody)

      # Case we miss a coded packet
      else
        @editor.write(@sequenceNumber,("C%08x" % @sequenceNumber))
      end

    end

    @editor.releaseWindow

    Logger.log :Info,"#{@loss} packets lossed of which #{@recovered} was recovered!"
  end

### 
  def decodable? packet
    @windowCodedCount=0
    header=packet[9...9+@headerSize].bytes.to_a
    count=0
    for index in 0...(@setting.windowSize-1)
      if (header[index/8]&(1<<(index%8)))!=0
        @windowCodedCount+=1
      end
      if (@codeHeader[index/8]&(1<<(index%8)))==0 and (header[index/8]&(1<<(index%8)))!=0
        count+=1
        @number=index
        #if count>1
        #  break
        #end
      end
    end
    if count==1
      return true
    end
    return false
  end

### 
  def decode packet
    data=packet[9+@headerSize..-1]
    header=packet[9...9+@headerSize].bytes.to_a
    @decodedPacket=data.bytes.to_a
    base=@sequenceNumber-@setting.windowSize+1
    for index in 0...(@setting.windowSize-1)
      if (@codeHeader[index/8]&(1<<(index%8)))!=0 and (header[index/8]&(1<<(index%8)))!=0
        i=0
        for byte in @editor.read(base+index)[9..-1].bytes
          @decodedPacket[i]^=byte
          i+=1
        end
      end
    end
    @editor.write(base+@number,(("D%08x" % (base+@number))+@decodedPacket.pack("C*")))
  end

end
