require "awesome_print"
AwesomePrint.irb!

require "irb/ext/save-history"
IRB.conf[:SAVE_HISTORY] = 2000
IRB.conf[:HISTORY_FILE] = ".irb-history"
