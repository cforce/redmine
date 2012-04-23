# Redmine Local Avatars plugin
#
# Copyright (C) 2010  Andrew Chaika, Luca Pireddu
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


require_dependency 'my_controller'
require 'local_avatars'

module LocalAvatarsPlugin
	module MyControllerPatch
    def self.included(base) # :nodoc:    
      base.class_eval do      
				unloadable
				helper :attachments
				include AttachmentsHelper 
			end
      base.send(:include, InstanceMethods)     
		end

		module InstanceMethods
			include LocalAvatars

			def avatar
				@user = User.current
				render :partial => 'users/avatar', :layout => true
			end

			def save_avatar
				@user = User.current
puts("MyControllerPatch#save_avatar")
				begin
					save_or_delete # see the LocalAvatars module
					puts("out of save_or_delete")
					redirect_to :action => 'account', :id => @user
				rescue
					puts("in catch block")
					flash[:error] = @possible_error
					redirect_to :action => 'avatar'
				end
			end
		end # InstanceMethods
  end
end
MyController.send(:include, LocalAvatarsPlugin::MyControllerPatch)
