#!/usr/bin/env ruby

$: << "../../lib"

require 'yaml'
require 'pp'
require 'test/unit'
require 'fitwriter'

class TestFitWriter< Test::Unit::TestCase
	def setup
		@ascii_tcpdump="fixtures/test_ascii.tcpdump"
		@bin_tcpdump="fixtures/test_bin.tcpdump"
	end
	def test_headers
		headers=FitHeadersWriter.headers(@ascii_tcpdump,"single")
		check="single"
		assert_match(check,headers,"invalid ascii data generated")
		headers=FitHeadersWriter.headers(@ascii_tcpdump,"multi")
		check="multi"
		assert_match(check,headers,"invalid ascii data generated")
	end
	
	def test_ascii
		ascii=FitAsciiWriter.injections(@ascii_tcpdump)
		sz_inject=ascii.grep(/^inject/).size
		assert_equal(6,sz_inject,"not enough inject lines")
	end
	def test_binary
		binary=FitBinWriter.injections(@bin_tcpdump)
		sz_binject=binary.grep(/^binject/).size
		sz_reconnect=binary.grep(/^reconnect/).size
		assert_equal(3,sz_binject,"not enough binject lines")
		assert_equal(3,sz_reconnect,"not enough reconnect lines")
	end
end

