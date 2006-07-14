#!/usr/bin/env ruby

require 'YAML'
require 'pp'
require 'inject'
require 'fuzzer'

class Interpreter 
	def initialize(options)
		@opts=options
		@tokens="::FAULT::"
		@token=/#{@tokens}/
		@faults=Hash.new
		faults "include/std.faults"
	end

	def init_fuzzer
		@fuzzer=Fuzzer.new(@opts) unless @opts['hostname'].nil? and @opts['port'].nil?
	end
	#language syntax
	def option(option,set)
		@opts[option]=set
		init_fuzzer
	end
	def pack(o,type)
		o.pack(type)
	end
	def unpack(o,type)
		o.unpack(type)
	end
	def faults(file)
		if File.exist? file
			y=YAML.load(File.open(file))
			@faults.merge! y
		end
	end
	def debug(string)
		puts string if @opts['verbose']
	end
	def reconnect
		@fuzzer.reconnect
	end
	def get
		@fuzzer.get
	end
	def put(string)
		@fuzzer.put(string)
	end
	def read(bytes)
		@fuzzer.read bytes
	end
	def write(input)
		@fuzzer.write input	
	end
	def binject(size,string=@tokens)
		f=File.open("/dev/urandom")
		fault_string=f.read(size)			
		write string.gsub(@token,fault_string)
		f.close
	end
	def inject(string)
		i=Inject.new
		if string =~ @token
			@faults.each_value do |fault|
				i.size=fault['size'].to_i
				i.string=fault['string']
				i.faults.each do |fault_string|
					fs=string.gsub(@token,fault_string)
					put fs
					puts "wrote string:\n#{fs}" if @opts['verbose']
				end	
			end
		else
			put string
			puts "wrote string:\n#{string}" if @opts['verbose']
		end
	end
	#end syntax 

	def run(script)
		eval script
	end
end

