#!/usr/bin/env ruby

class Inject 
	attr_accessor :size, :string
	def initialize
		@size=@string=nil
	end
	def check_required_values
		raise "must supply size" if size == nil
		raise "must supply string" if size == nil
	end
	def fault
		check_required_values
		@string*@size
	end
	def faults
		check_required_values
		f=[]
		1.upto @size do |i|
			f.push @string*i	
		end
		f
	end
end
