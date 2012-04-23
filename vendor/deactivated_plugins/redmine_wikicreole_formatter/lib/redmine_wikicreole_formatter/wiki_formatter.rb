# require 'rdiscount'
require 'wikicreole'

module RedmineWikicreoleFormatter
    class WikiFormatter
        def initialize(text)
            @text = text.gsub("\r\n", "\n") + "\n" #.gsub("\[\[ *([^\[\]]+?) *\| *([^\[\]]+?) *\]\]", 
                                                   #     "[[\1|\2]]")
        end

        def to_html(&block)
            @macros_runner = block
            
            macros_re = "(([\w]+)(\(([^\}]*)\))?)"
            
            # Redmine macros parse through WikiCreole plugin syntax, ie:
            #       <<child_pages Home, parent=1>>
            WikiCreole.creole_plugin {|s|
                begin
                    macro, args = s.split(' ', 2)
                    args = (args || '').split(',').each(&:strip)
                    @macros_runner.call(macro, args)
                rescue => e
                    "<div class=\"flash error\">Error executing the <strong>#{macro}</strong> macro (#{e})</div>"
                end || s
            }
            
            WikiCreole.creole_parse(@text)
        rescue => e
            return("<pre>problem parsing wiki text: #{e.message}\n"+
                    "original text: \n"+
                    @text+
                    "</pre>")
        end
    end
end

