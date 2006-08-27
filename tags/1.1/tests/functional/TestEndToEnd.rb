#!/usr/bin/env ruby
$: << "../../lib"

require 'yaml'
require 'pp'
require 'test/unit'
require 'interpreter'
require 'gserver'
require 'webrick'
require 'singleton'
require 'fitwriter'

class TestEndToEnd < Test::Unit::TestCase

	class AsciiServer < GServer
		attr_accessor :log
		def initialize
			super(4064)
			@log=Array.new
		end
		def serve(client)
			@log.push client.gets
		end
	end

	class BinServer < GServer
		attr_accessor :log
		def initialize
			super(4063)
			@log=Array.new
		end
		def serve(client)
			log=Array.new
			stage_one=client.read 1
			log.push stage_one 
			client.write stage_one
			stage_two=client.read 2
			log.push stage_two
			pattern="DEFACED"
			client.write pattern
			log.push pattern
			stage_three=client.read pattern.size
			log.push stage_three
			@log.push log
		end
	end

	def setup
		@ascii_tcpdump="fixtures/test_end_ascii.tcpdump"
		@bin_tcpdump="fixtures/test_end_bin.tcpdump"
		@opts=Hash.new
		#@opts['verbose']=true
		@i=Interpreter.new(@opts)
	end

	def test_bin
		server=BinServer.new
		server.start
                script=FitHeadersWriter.headers(@bin_tcpdump,"single")
                script+=FitBinWriter.injections(@bin_tcpdump)
		@i.run(script)
		y=YAML.load(File.open("fixtures/test_end_bin.yaml"))
		#general size check
		assert_equal(3,server.log.size,"number of iterations differs from fixture")
		#[["\337", "BB", "DEFACED", "DEFACED"],
		assert_equal(1,server.log[0][0].size,"first iteration size mismatch")
		assert_equal("BB",server.log[0][1],"first iteration second match")
		assert_equal("DEFACED",server.log[0][2],"first iteration third match")
		assert_equal("DEFACED",server.log[0][3],"first iteration fourth match")
		# ["A", "\035\324", "DEFACED", "DEFACED"],
		assert_equal("A",server.log[1][0],"second iteration first match")
		assert_equal(2,server.log[1][1].size,"second iteration size mismatch")
		assert_equal("DEFACED",server.log[1][2],"second iteration third match")
		assert_equal("DEFACED",server.log[1][3],"second iteration fourth match")
		# ["A", "BB", "DEFACED", "\364f\210\220\254\273\207"]]
		assert_equal("A",server.log[2][0],"third iteration first match")
		assert_equal("BB",server.log[2][1],"third iteration second match")
		assert_equal("DEFACED",server.log[2][2],"third iteration third match")
		assert_equal(7,server.log[2][3].size,"third iteration size mismatch")
		server.stop
	end

	def test_ascii
		server=AsciiServer.new
		server.start
                script=FitHeadersWriter.headers(@ascii_tcpdump,"multi")
		nscript=""
		script.each_line do |line|
			nscript+=line unless line =~ /include/
		end
		nscript+="faults \"fixtures/test.faults\"\n"
		script=nscript
                script+=FitAsciiWriter.injections(@ascii_tcpdump)
		@i.run(script)
		y=YAML.load(File.open("fixtures/test_end_ascii.yaml"))
                assert_equal(y,server.log,"data does not match fixture")
		server.stop
	end
end
