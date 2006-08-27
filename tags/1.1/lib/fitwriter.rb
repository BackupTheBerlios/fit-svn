#!/usr/bin/env ruby
require 'pcap'
require 'pp'

class FitWriterUtil
	def self.dest(file)
		results=Hash.new
		cap=Pcap::Capture.open_offline(file)
		#process only the first packet
		cap.loop do |pkt|
			next if pkt.class.eql? Pcap::Packet
			results['host']=pkt.ip_dst
			if pkt.tcp?
				results['port']=pkt.tcp_dport
			elsif pkt.udp?
				results['port']=pkt.udp_dport
			end
		end
		results
	end
end

class FitHeadersWriter
	def self.headers(file,type)
	dest=FitWriterUtil.dest(file)
	headers=%{##Generated by the Fault injection Toolkit
#author: <grandmasterlogic@gmail.com> 
#

faults "include/std.faults"
faults "include/test.faults"

option 'host','#{dest['host']}'
option 'port','#{dest['port']}'
option 'session','#{type}'

}
	end
end

class FitAsciiWriter
	def self.injections(file)
		injections=[]
		dest=FitWriterUtil.dest(file)
		cap=Pcap::Capture.open_offline(file)
		cap.loop do |pkt|
			data=nil
			if pkt.tcp?
				port=pkt.tcp_dport
				unless pkt.tcp_data.nil?
					data=pkt.tcp_data		
				end
			elsif pkt.udp?
				port=pkt.udp_dport
				unless pkt.udp_data.nil?
					data=pkt.udp_data
				end
			end
			if pkt.ip_dst.eql? dest['host'] and port.eql? dest['port']
				unless data.nil?
					captures=""
					data.each do |capture| 
						captures+=capture+"\\n"
					end
					pieces=captures.split
					size=pieces.size
					size.times do |i|
						parts=pieces.dup
						if i == size - 1
							parts[i]="::FAULT::\\n"
						else
							parts[i]="::FAULT::"
						end
						injections << parts.join(' ')
					end
				end
			end
		end
		cap.close
		injections.uniq!
		results=""
		injections.each do |inject|
			results+="inject \"#{inject}\"\n"
		end
		results
	end
end

class FitBinWriter
	def self.recap(file)
		cap=Pcap::Capture.open_offline(file)
	end
	def self.injections(file)
		injects=[]
		dest=FitWriterUtil.dest(file)
		cap=recap(file)
		len=0
		cap.loop do |pkt|
			next if pkt.class.eql? Pcap::Packet
			len+=1 if pkt.ip_dst.eql? dest['host']
		end
		len.times do |i|
			cap=recap(file)
			count=0
			injections=[]
			injections << "\n#top of session\n"
			cap.loop do |pkt|
				if pkt.tcp?
					port=pkt.tcp_dport
					data=pkt.tcp_data
				elsif pkt.udp?
					port=pkt.udp_dport
					data=pkt.udp_data
				end
				unless data.nil?
					if pkt.ip_dst.eql? dest['host'] and port.eql? dest['port']
						if count == i
							injections << "binject #{data.size}\n"	
						else
							injections << "write \"#{data}\"\n"
						end		
						count+=1
					else
						injections << "read #{data.size}\n"
					end
				end
			end
			injections << "reconnect\n"
			injections << "#end of session\n"
			injects << injections if injections.grep(/binject/).size > 0	
		end
		cap.close
		injects.to_s
	end
end