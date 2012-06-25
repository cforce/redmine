require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::TrackersController < MylynConnector::ApplicationController
  unloadable
  include MylynConnector::Rescue::ClassMethods

  accept_api_auth :all
  
  skip_before_filter :verify_authenticity_token

  helper MylynConnector::MylynHelper

  def all
    @trackers = Tracker.find(:all)

    respond_to do |format|
      format.xml {render :layout => false}
    end
  end
end
