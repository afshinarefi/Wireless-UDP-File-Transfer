#!/usr/bin/ruby

require './logger'

class Editor

  def initialize buffer,step
    @buffer=buffer
    @step=step
  end
  
  def allocateWindow?
    @buffer.allocateWindow? @step
  end

  def allocateWindow
    @buffer.allocateWindow @step
  end

  def allocateWindow!
    @buffer.allocateWindow! @step
  end

  def releaseWindow?
    @buffer.releaseWindow? @step
  end

  def releaseWindow
    @buffer.releaseWindow @step
  end

  def isInWindow? sequenceNumber
    @buffer.isInWindow? @step,sequenceNumber
  end

  def isAfterWindow? sequenceNumber
    @buffer.isAfterWindow? @step,sequenceNumber
  end
  
  def isBeforeWindow? sequenceNumber
    @buffer.isBeforeWindow? @step,sequenceNumber
  end
  
  def read sequenceNumber
    return @buffer.editorRead @step,sequenceNumber
  end

  def write sequenceNumber, data
    @buffer.editorWrite @step,sequenceNumber,data
  end

  def step
    @step
  end
end
