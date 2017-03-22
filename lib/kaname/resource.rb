require 'yaml'

module Kaname
  class Resource
    class << self
      def yaml(filename = 'keystone.yml')
        if File.exists?(filename)
          @_yaml = YAML.load_file(filename)
          expand_all_tenants
        else
          nil
        end
      end

      private

      def expand_all_tenants
        list_tenants = Kaname::Adapter::ReadOnly.new.list_tenants

        @_yaml.each do |username, config|
          next unless config['all_tenants']
          tenants = list_tenants.map{|tenant| [tenant.name, config['all_tenants']]}
          config['tenants'] = Hash[*tenants.flatten].merge(config['tenants'] || {})
          config.delete('all_tenants')
        end
      end
    end
  end
end
