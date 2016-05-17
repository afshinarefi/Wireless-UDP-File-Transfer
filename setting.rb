#!/usr/bin/ruby

=begin
  
  This class contains all the configuration values of the program.

  Author:: Afshin Arefi (mailto:arefi@ualberta.ca)

=end

class Setting

  attr_accessor :serverIP
  attr_accessor :broadcastIP
  attr_accessor :clientIP
  attr_accessor :controlPort
  attr_accessor :delay
  attr_accessor :chunkSize
  attr_accessor :bufferSize
  attr_accessor :fileName
  attr_accessor :sourceDir
  attr_accessor :destinationDir
  attr_accessor :windowSize
  attr_accessor :mergeCount
  attr_accessor :maxTries
  attr_accessor :senderEditorCount
  attr_accessor :receiverEditorCount
  attr_accessor :codeCount

  def initialize
    # The sender IP address.
    @serverIP='192.168.1.1'

    # The IP address to which the packets will be sent.
    @broadcastIP='192.168.1.255'

    # The client IP address who requests the transmission of the file.
    @clientIP='192.168.1.73'

    # The port on which the server listens for transmission requests.
    @controlPort=52005

    # The amount of time a thread will wait for another thread to do something
    # before checking again.
    @delay=0.00

    # The size of the data inserted into each packet before adding the header.
    @chunkSize=1<<10

    # The size of the buffers used in the system.
    @bufferSize=49

    @fileName='Video.ts'

    @sourceDir='Sample/'

    @destinationDir='Disk/'

    @windowSize=11

    @mergeCount=1

    @maxTries=3

    @senderEditorCount=3

    @receiverEditorCount=3

    @codeCount=1

  end
end

__END__
