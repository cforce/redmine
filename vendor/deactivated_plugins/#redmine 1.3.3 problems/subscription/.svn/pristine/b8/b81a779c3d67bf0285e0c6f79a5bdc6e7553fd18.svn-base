class SubscriptionsController < ApplicationController
    before_filter :find_project
    before_filter :find_project_subscriber
    before_filter :authorize

    def subscription
        unless @subscriber
            resources = [ :news, :releases, :files ]
            case params[:resource]
            when 'wiki'
                resources << :wiki_pages
            when 'issues'
                resources << :new_issues
                resources << :closed_issues
            when 'boards'
                resources << :forums
            end

            @subscriber = ProjectSubscriber.new(:project       => @project,
                                                :user          => User.current,
                                                :subscribed_to => resources)
        end

        respond_to do |format|
            format.html do
                redirect_to(:controller => 'projects', :action => 'show', :id => @project)
            end
            format.js do
                render(:update) do |page|
                    @count = ProjectSubscriber.count(:conditions => { :project_id => @project })
                    if User.current.logged?
                        page.replace_html('subscribe', :partial => 'subscribe/form')
                    else
                        page.replace_html('subscribe', :partial => 'subscribe/register')
                    end
                end
            end
        end
    end

    def subscribe
        if User.current.logged? && request.post?
            @message = nil
            if @subscriber
                if params[:subscribed_to] && !params[:subscribed_to].empty?
                    @subscriber.update_attribute(:subscribed_to, params[:subscribed_to])
                    @message = l(:notice_successful_update)
                else
                    @subscriber.destroy
                    @message = l(:notice_successful_unsubscribe)
                end
            else
                if params[:subscribed_to] && !params[:subscribed_to].empty?
                    @subscriber = ProjectSubscriber.new(:project       => @project,
                                                        :user          => User.current,
                                                        :subscribed_to => params[:subscribed_to])
                    @subscriber.save
                    @message = l(:notice_successful_subscribe)
                else
                    @message = l(:notice_not_subscribed)
                end
            end

            respond_to do |format|
                format.html do
                    flash[:notice] = @message
                    redirect_to(:controller => 'projects', :action => 'show', :id => @project)
                end
                format.js do
                    render(:update) do |page|
                        page.replace_html('subscribe', :partial => 'subscribe/form')
                        page.visual_effect(:fade, 'subscribe-message', :delay => 1.0)
                    end
                end
            end
        else
            respond_to do |format|
                format.html { redirect_to(:controller => 'projects', :action => 'show', :id => @project) }
                format.js do
                    render(:update) do |page|
                        page.redirect_to(:controller => 'projects', :action => 'show', :id => @project)
                    end
                end
            end
        end
    end

    def unsubscribe
        if @subscriber
            @subscriber.destroy
            flash[:notice] = l(:notice_successful_unsubscribe)
        end
        redirect_to(:controller => 'my', :action => 'account')
    end

private

    def find_project_subscriber
        if User.current.logged?
            @subscriber = ProjectSubscriber.find_by_project_id_and_user_id(@project.id, User.current.id)
        end
    end

end
