# scrumDashboard - Add scrum functionality to any Redmine installation
# Copyright (C) 2009 BrokenTeam
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

class AddVisualizationFields < ActiveRecord::Migration
  def self.up
    add_column :dashboards, :issue_width, :float, :default => 65
    add_column :dashboards, :line_height, :integer, :default => 75
    add_column :dashboards, :col_max_width, :float, :default => 20 
  end

  def self.down
    remove_column( :dashboards, :issue_width )
    remove_column( :dashboards, :line_height )
    remove_column( :dashboards, :col_max_width )
  end
end
