#!/usr/bin/env ruby
#

chdir_cmd=%{cd src/third_party/pcap}
osx_cmd=%{mv extconf_ppc.rb extconf.rb; mv mkmf_ppc.rb mkmf.rb}
pcap_cmd=%{ruby extconf.rb;make;make install}
uname=`uname -p`.chomp!

if uname.eql? "powerpc"
	cmd="#{chdir_cmd};#{osx_cmd};#{pcap_cmd}"
else
	cmd="#{chdir_cmd};#{pcap_cmd}"
end
system cmd

