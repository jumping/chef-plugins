#
# Author:: Jay Faulkner (<jason.faulkner@rackspace.com>)
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

module RaxChef
  class NodeShowExclude < Chef::Knife

    deps do
      require 'chef/knife'
      require 'chef/node'
      require 'chef/json_compat'
    end

    include Chef::Knife::Core::NodeFormattingOptions

    def format_for_repo(data)
      if config[:exclude_attribute]
        Array(config[:exclude_attribute]).each do |exclude|
          data.delete(exclude)
        end
      end
      if config[:inject_attribute]
        Array(config[:inject_attribute]).each do |inject|
          raise ArgumentError, "Attribute already exists. Cannot inject." if data["#{inject.split('=')[0]}"]
          data["#{inject.split('=')[0]}"] = inject.split('=')[1]
        end
      end
      data
    end

    banner "knife node show exclude NODE (options)"

    @attrs_to_not_show = []
    @attrs_to_inject = []
    option :exclude_attribute,
      :short => "-A [ATTR]",
      :long => "--exclude-attribute [ATTR]",
      :proc => lambda {|val| @attrs_to_not_show << val},
      :description => "Exclude one or more attributes"

    option :inject_attribute,
      :short        => "-I [ATTR]",
      :long         => "--inject_attribute [ATTR]",
      :proc => lambda {|val| @attrs_to_inject << val},
      :description  => "Inject an attribute. Format should be \"key=value\""

    def run
      ui.use_presenter Chef::Knife::Core::NodePresenter
      @node_name = @name_args[0]

      if @node_name.nil?
        show_usage
        ui.fatal("You must specify a node name")
        exit 1
      end

      node = Chef::Node.load(@node_name)
      output(format_for_repo(node))
    end
  end
end

