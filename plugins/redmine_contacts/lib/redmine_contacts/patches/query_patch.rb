require_dependency 'query'

module RedmineContacts
  module Patches
    module QueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method_chain :available_filters, :contacts

          base.add_available_column(QueryColumn.new(:contacts))

        end
      end


      module InstanceMethods
        def sql_for_contacts_field(field, operator, value)
          compare = operator == '=' ? 'IN' : 'NOT IN'
          contacts_select = "SELECT contacts_issues.issue_id FROM contacts_issues
              WHERE contacts_issues.contact_id IN (#{value.join(',')})"

          "(#{Issue.table_name}.id #{compare} (#{contacts_select}))"    
        end  

        def sql_for_companies_field(field, operator, value) 
          compare = operator == '=' ? 'IN' : 'NOT IN'
          employes_select = "SELECT contacts_issues.issue_id FROM contacts_issues
              WHERE contacts_issues.contact_id IN
              ( SELECT c_1.id from #{Contact.table_name}
                LEFT OUTER JOIN #{Contact.table_name} AS c_1 ON c_1.company = #{Contact.table_name}.first_name
                WHERE #{Contact.table_name}.id IN (#{value.join(',')})
              )"
          companies_select = "SELECT contacts_issues.issue_id FROM contacts_issues
              WHERE contacts_issues.contact_id IN (#{value.join(',')})"

          "((#{Issue.table_name}.id #{compare} (#{employes_select}))
          OR (#{Issue.table_name}.id #{compare} (#{companies_select})))"
        end


        def available_filters_with_contacts
          # && !RedmineContacts.settings[:issues_filters] 
          if @available_filters.blank? && (@project.blank? || @project.module_enabled?(:contacts_module)) 
            select_fields = "#{Contact.table_name}.first_name, #{Contact.table_name}.last_name, #{Contact.table_name}.middle_name, #{Contact.table_name}.is_company, #{Contact.table_name}.id"
            available_filters_without_contacts.merge!({ 'contacts' => {
                :type => :list,
                :name => l(:field_contacts),
                :order  => 6,
                :values => (@project.blank? ? Contact.visible.order_by_name : @project.contacts).find(:all, :select => select_fields, :limit => 500).collect{ |t| [t.name, t.id.to_s] }.uniq
              }}) if !available_filters_without_contacts.key?("contacts") && (@project.blank? || User.current.allowed_to?(:view_contacts, @project))

            available_filters_without_contacts.merge!({ 'companies' => {
                :type   => :list,
                :name => l(:field_companies),
                :order  => 6,
                :values => (@project.blank? ? Contact.visible.order_by_name : @project.contacts).find(:all, :select => select_fields, :limit => 500, :conditions => {:is_company => true}).collect{ |t| [t.name, t.id.to_s] }.uniq
              }}) if !available_filters_without_contacts.key?("companies") && (@project.blank? || User.current.allowed_to?(:view_contacts, @project))
          else
            available_filters_without_contacts
          end
          @available_filters
        end
      end
    end
  end
end

unless Query.included_modules.include?(RedmineContacts::Patches::QueryPatch)
  Query.send(:include, RedmineContacts::Patches::QueryPatch)
end
