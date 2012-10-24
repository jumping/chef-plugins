#
# Author:: Phil Kates (<phil.kates@rackspace.com>)
# Copyright:: Copyright (c) 2012 Rackspace, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Knife plugin to allow updating from a file. The current knife from file blows
# away all the info and replaces it which kills all the automatic info...which
# is bad.

require 'chef/knife'

module RaxChef
  class NodeUpdateFromFile < Chef::Knife

    deps do
      require 'chef/node'
      require 'chef/json_compat'
      require 'chef/knife/core/object_loader'
    end

    banner "knife node update_from_file FILENAME"

    def loader
      @loader ||= Chef::Knife::Core::ObjectLoader.new(Chef::Node, ui)
    end

    def filename
      @filename ||= @name_args[0]
    end

    def run
      if filename.nil?
        show_usage
        ui.fatal("You must specify a filename")
        exit 1
      end

      file_data = loader.load_from('nodes', filename)
      begin
        current_node = Chef::Node.load(file_data.name)
      rescue Net::HTTPServerException => e
        if e.message =~ /404/
          puts "ERROR: Failed to update node #{file_data.name}. Node not found."
        else
          puts e.message
        end
        exit(1)
      end

      current_node.name( file_data.name )
      current_node.chef_environment( file_data.chef_environment )
      current_node.run_list( file_data.run_list )
      current_node.normal_attrs = file_data.normal_attrs

      current_node.save
      puts "Updated node[#{file_data.name}]"
    end

  end
end
