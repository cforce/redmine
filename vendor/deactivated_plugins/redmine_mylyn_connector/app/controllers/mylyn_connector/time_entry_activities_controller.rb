require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::TimeEntryActivitiesController < MylynConnector::ApplicationController
  unloadable
  include MylynConnector::Rescue::ClassMethods
  include MylynConnector::Version::ClassMethods

  accept_api_auth :all
  
  skip_before_filter :verify_authenticity_token

  helper MylynConnector::MylynHelper

  def all
    @activities = TimeEntryActivity.shared.active

    respond_to do |format|
      format.xml {render :layout => false}
    end
  end

end
