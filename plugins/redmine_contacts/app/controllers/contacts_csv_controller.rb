class ContactsCsvController < ApplicationController
  unloadable
 
  before_filter :find_project_by_project_id, :authorize

  def show
  end
  
  def load   
    import_tags = params[:add_tag_list]
    tags_filter = {}
    tags_filter = {:set_filter => 1, 
                   :fields => [:tags], 
                   :values => {:tags => ActsAsTaggableOn::TagList.from(import_tags)},
                   :operators => {:tags => '='}} unless import_tags.blank?

    row_num = 0
    csv = FCSV.parse(params[:csv_file].read, :headers => true, :encoding => params[:encoding], :col_sep => params[:col_sep]) do |row|
      row_num += 1
      contact = Contact.new
      contact.first_name = row['First Name']
      contact.middle_name = row['Middle Name']
      contact.last_name = row['Last Name']
      contact.company = row['Company']
      contact.is_company = row['Is company'] == '1'
      contact.job_title = row['Job title']
      contact.phone = row['Phone']
      contact.email = row['Email']
      contact.address = row['Address']
      contact.website = row['Website']
      contact.skype_name = row['Skype']
      contact.background = row['Background']
      contact.birthday = row['Birthday'].to_date unless row['Birthday'].blank?
      contact.tag_list = [row['Tags'], import_tags].join(',')
      
      contact.custom_field_values.each do |custom_field_value| 
        custom_field_value.value = custom_field_value.custom_field.cast_value(row[custom_field_value.custom_field.name]).to_s
      end

      contact.projects << @project

      contact.save!
    end


    respond_to do |format|
      format.html{  redirect_to tags_filter.merge(:controller => 'contacts', 
                                                  :action => 'index',
                                                  :project_id => @project)
                                }
    end
  rescue Exception => e
    flash[:error] = "#{e.message} in row ##{row_num}"
    respond_to do |format|
      format.html{  redirect_to :back }
    end
  end    


end
