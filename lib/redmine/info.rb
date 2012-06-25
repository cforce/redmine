module Redmine
  module Info
    class << self
      def app_name; 'InfoMine' end
      def url; 'https://infomine.dsv-gruppe.de/' end
      def help_url; '/projects/systemhaus/wiki/Hilfe' end
      #def app_name; 'Redmine' end
      #def url; 'http://www.redmine.org/' end
      #def help_url; 'http://www.redmine.org/guide' end
      def versioned_name; "#{app_name} #{Redmine::VERSION}" end
    end
  end
end
