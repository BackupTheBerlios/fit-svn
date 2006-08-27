#!/usr/bin/env ruby

$: << "../../lib"

require 'yaml'
require 'pp'
require 'test/unit'
require 'interpreter'
require 'gserver'
require 'singleton'

class TestInterpreter < Test::Unit::TestCase

	@@last_port=nil

	class EchoServer < GServer
		attr_accessor :log
		def initialize(port)
			super(port)
			@log=Array.new
		end
		def serve(client)
			input=client.gets
			@log.push input
			client.puts input
		end
	end

	def random(r)
	    return @@last_port+1 unless @@last_port.nil?
	    sleep 1
	    srand Time.now.to_i
	    r.first + rand(r.last - r.first + (r.exclude_end? ? 0 : 1))
	end

	def setup
		@@last_port=@port=random(4000..6000)
		@opts=Hash.new
		@script=%{
faults  "fixtures/test.faults"
option	'host','localhost'
option	'port','#{@port}'
option 'session','multi'
		}

		@server=EchoServer.new(@port)
		@server.start
		sleep 2 

		@i=Interpreter.new(@opts)
	end

	def teardown 
		@server.stop
		sleep 1 
	end

	def test_inject
		y=YAML.load(File.open("fixtures/test_inject.yaml"))
		@script+=%{
inject "GET /"
inject "GET /::FAULT::"
}
		@i.run(@script)
		assert_equal(y,@server.log,"data does not match fixture")
	end

	def test_put
		y=YAML.load(File.open("fixtures/test_put.yaml"))
		@script+=%{
put "GET /test_put"
put ""
}
		@i.run(@script)
		assert_equal(y,@server.log,"data does not match fixture")
	end

	def test_binject
		y=YAML.load(File.open("fixtures/test_binject.yaml"))
		@script+=%{
binject 20,"GET /::FAULT::"
put ""
}
		@i.run(@script)
		assert_equal(25,@server.log[1].size, "expected string to be 25 in length got back #{@server.log[1].size}")
	end

	def test_write
		y=YAML.load(File.open("fixtures/test_write.yaml"))
		@script+=%{
write "GET /test_write"
put ""
}
		@i.run(@script)
		assert_equal(y,@server.log,"data does not match fixture")
	end
	
end

