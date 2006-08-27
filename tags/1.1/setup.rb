#!/usr/bin/env ruby
#

chdir_cmd=%{cd src/third_party/pcap}
uname=`uname -p`.chomp!

if uname.eql? "powerpc"
	pcap_cmd=%{ruby extconf_ppc.rb;make;make install}
else
	pcap_cmd=%{ruby extconf.rb;make;make install}
end
cmd="#{chdir_cmd};#{pcap_cmd}"
system cmd

