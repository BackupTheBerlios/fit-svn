#!/usr/bin/ruby
#Fit Interactive Interpreter

require "irb"

module IRB
	def IRB.setup(ap_path)
	    IRB.init_error
	    IRB.parse_opts
	    IRB.run_config
	    IRB.load_modules

	    unless @CONF[:PROMPT][@CONF[:PROMPT_MODE]]
	      IRB.fail(UndefinedPromptMode, @CONF[:PROMPT_MODE])
	    end
	end

	def IRB.startup(ap_path)
		self.init_config(ap_path)
		@CONF[:PROMPT]
		@CONF[:PROMPT][:FIT]={
			:PROMPT_I => "fit> ",
			:PROMPT_S => "fit: ",
			:PROMPT_C => "fit>> ",
			:RETURN => "<<\n\n"
		}
		@CONF[:PROMPT_MODE]=:FIT
	end
end

IRB.startup(__FILE__)
if __FILE__ == $0
  IRB.start(__FILE__)
else
  if /^-e$/ =~ $0
    IRB.start(__FILE__)
  else
    IRB.setup(__FILE__)
  end
end

