#!/usr/bin/env ruby

require 'socket'

class Fuzzer
	def initialize(opts)
		@opts=opts
		@s=nil
		connect
	end
	def connect
		@s.close unless @s.nil?
		@s=TCPSocket.new(@opts['host'],@opts['port'])
	end
	alias :reconnect :connect
	def multi
		connect if @opts['session'].eql? "multi"
	end
	def put(string)
		multi
		@s.puts string
	end
	def get
		multi
		@s.gets
	end
	def write(string)
		multi
		@s.send string,0
	end
	def read(bytes)
		multi
		@s.recvfrom bytes
	end
end
