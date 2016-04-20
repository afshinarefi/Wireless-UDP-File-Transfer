#!/usr/bin/ruby

require './editor'

=begin
  
  This class is the implementation of a thread safe buffer with one producer
  and one consumer.

  Author:: Afshin Arefi (mailto:arefi@ualberta.ca)

=end

class Buffer
  
  # This method initializes the buffer with default values.

  def initialize setting
    @setting=setting
    @buffer=Array.new(@setting.bufferSize,nil)
    self.resetPointers
    self.createEditors
  end

  def resetPointers
    @startPointer=Array.new(@setting.senderEditorCount,0)
    @endPointer=Array.new(@setting.senderEditorCount,0)
  end

  def isInWindow? step,sequenceNumber
    if sequenceNumber>=@startPointer[step] and
       sequenceNumber<@endPointer[step]
      return true
    end
    return false
  end

  def isAfterWindow? step,sequenceNumber
    if sequenceNumber>=@endPointer[step]
      return true
    end
    return false
  end

  def isBeforeWindow? step,sequenceNumber
    if sequenceNumber<@startPointer[step]
      return true
    end
    return false
  end

  def createEditors
    @editors=[]
    for step in 0...@setting.senderEditorCount
      @editors << Editor.new(self,step)
    end
  end

  def getEditor step
    return @editors[step]
  end

  def next step
    return (step-1+@setting.senderEditorCount) % @setting.senderEditorCount
  end

  def outerDistance step
    if step==0
      return @startPointer[self.next(step)]-@endPointer[step]+@setting.bufferSize
    end
    return @startPointer[self.next(step)]-@endPointer[step]
  end
  
  def innerDistance step
    return @endPointer[step]-@startPointer[step]
  end

  def allocateWindow? step
    if step==2
    end
    if self.outerDistance(step)>=@setting.windowSize
      return true
    end
    return false
  end

  def allocateWindow step
    if self.allocateWindow? step
      @endPointer[step]=@endPointer[step]+@setting.windowSize
      return true
    end
    return false
  end

  def allocateWindow! step
    while not self.allocateWindow? step
      sleep @setting.delay
    end
    self.allocateWindow step
  end

  def releaseWindow? step
    if self.innerDistance(step)>=@setting.windowSize
      return true
    end
    return false
  end

  def releaseWindow step
    if self.releaseWindow? step
      @startPointer[step]=@startPointer[step]+@setting.windowSize
      return true
    end
    return false
  end

  def read index
    return @buffer[index % @setting.bufferSize]
  end

  def editorRead step,index
    if self.isInWindow? step,index
      return self.read index
    end
    Logger.log :Info,"Invalid read."
    raise "Invalid Read Access by Editor %d" % step
  end

  def write index, data
    @buffer[index % @setting.bufferSize]=data
  end

  def editorWrite step,index,data
    if self.isInWindow? step,index
      self.write index,data
    else
      raise "Invalid Write Access by Editor %d" % step
    end
  end
end

__END__
