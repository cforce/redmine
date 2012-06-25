require_dependency 'mailer'

module MailerSubscriptionPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        unless base.method_defined?(:news_comment_added)
            base.send(:include, NewsCommentAddedMethod)
        end
        base.class_eval do
            unloadable
            alias_method_chain :attachments_added, :subscribers
            alias_method_chain :issue_add, :subscribers
            alias_method_chain :issue_edit, :subscribers
            if File.exist?("#{RAILS_ROOT}/app/views/layouts/mailer.text.html.erb")
                alias_method_chain :render_multipart, :subscription
            end
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def attachments_added_with_subscribers(attachments)
            attachments_added_without_subscribers(attachments)

            notified_users = []
            container = attachments.first.container
            case container.class.name
            when 'Project'
                subscribers = ProjectSubscriber.find_all_by_project_id(container.id)
                notified_users = subscribers.select{ |subscriber| subscriber.subscribed_to?(:files) && subscriber.user.allowed_to?(:view_files, container) }
            when 'Version'
                subscribers = ProjectSubscriber.find_all_by_project_id(container.project.id)
                notified_users = subscribers.select{ |subscriber| subscriber.subscribed_to?(:files) && subscriber.user.allowed_to?(:view_files, container.project) }
            end
            unless notified_users.empty?
                recipients @recipients + notified_users.collect{ |subscriber| subscriber.user.mail }
            end
        end

        def issue_add_with_subscribers(issue)
            issue_add_without_subscribers(issue)

            subscribers = ProjectSubscriber.find_all_by_project_id(issue.project.id)
            notified_users = subscribers.select{ |subscriber| subscriber.subscribed_to?(:new_issues) && issue.visible?(subscriber.user) }.collect{ |subscriber| subscriber.user.mail }
            notified_users -= @recipients
            notified_users -= @cc
            recipients @recipients + notified_users
        end

        def issue_edit_with_subscribers(journal)
            issue_edit_without_subscribers(journal)

            status = journal.new_status
            if status && status.is_closed?
                issue = journal.journalized.reload
                subscribers = ProjectSubscriber.find_all_by_project_id(issue.project.id)
                notified_users = subscribers.select{ |subscriber| subscriber.subscribed_to?(:closed_issues) && issue.visible?(subscriber.user) }.collect{ |subscriber| subscriber.user.mail }
                notified_users -= @recipients
                notified_users -= @cc
                recipients @recipients + notified_users
            end
        end

        def version_closed(version)
            subscribers = ProjectSubscriber.find_all_by_project_id(version.project.id)
            notified = subscribers.select{ |subscriber| subscriber.subscribed_to?(:releases) && version.visible?(subscriber.user) }.collect{ |subscriber| subscriber.user.mail }

            wiki_url = nil
            if version.project.wiki && !version.wiki_page_title.blank?
                wiki = version.project.wiki.find_page(!version.wiki_page_title)
                if wiki
                    url_for(:controller => 'wiki', :action => 'show', :project_id => version.project, :id => Wiki.titleize(version.wiki_page_title))
                end
            end

            redmine_headers 'Project'    => version.project.identifier,
                            'Version'    => version.name,
                            'Version-Id' => version.id
            message_id version
            recipients notified
            subject "[#{version.project.name}] " + l(:mail_subject_version_closed, :version => version.name)
            body :version     => version,
                 :project_url => url_for(:controller => 'projects', :action => 'show', :id => version.project),
                 :version_url => url_for(:controller => 'versions', :action => 'show', :id => version),
                 :wiki_url    => wiki_url
            render_multipart('version_closed', body)
        end

        def repository_added(repository)
            subscribers = ProjectSubscriber.find_all_by_project_id(repository.project.id)
            notified = subscribers.select{ |subscriber| subscriber.subscribed_to?(:repository) && subscriber.user.allowed_to?(:view_changesets, changeset.project) }.collect{ |subscriber| subscriber.user.mail }

            redmine_headers 'Project'       => repository.project.identifier,
                            'SCM-Type'      => repository.type,
                            'Repository-Id' => repository.id
            recipients notified
            subject "[#{repository.project.name}]" + l(:mail_subject_repository_added)
            body :repository_url => url_for(:controller => 'repositories', :action => 'show', :id => repository.project)
            render_multipart('repository_added', body)
        end

        def changeset_added(changeset)
            subscribers = ProjectSubscriber.find_all_by_project_id(changeset.project.id)
            notified = subscribers.select{ |subscriber| subscriber.subscribed_to?(:repository) && subscriber.user.allowed_to?(:view_changesets, changeset.project) }.collect{ |subscriber| subscriber.user.mail }

            redmine_headers 'Project'     => changeset.project.identifier,
                            'Revision'    => changeset.identifier,
                            'Revision-Id' => changeset.id
            @author = changeset.user
            recipients notified
            title = "[#{changeset.project.name}] #{l(:label_revision)} #{changeset.format_identifier}"
            title << ": #{changeset.short_comments}" unless changeset.short_comments.blank?
            subject title
            body :changeset    => changeset,
                 :revision_url => url_for(:controller => 'repositories', :action => 'revision', :id => changeset.project, :rev => changeset.identifier),
                 :diff_url     => url_for(:controller => 'repositories', :action => 'diff', :id => changeset.project, :rev => changeset.identifier, :path => "")
            render_multipart('changeset_added', body)
        end

        def board_added(board)
            subscribers = ProjectSubscriber.find_all_by_project_id(board.project.id)
            notified = subscribers.select{ |subscriber| subscriber.subscribed_to?(:forums) && board.visible?(subscriber.user) }.collect{ |subscriber| subscriber.user.mail }

            redmine_headers 'Project'  => board.project.identifier,
                            'Board'    => board.name,
                            'Board-Id' => board.name
            recipients notified
            subject "[#{board.project.name}] #{board.name}"
            body :board     => board,
                 :board_url => url_for(:controller => 'boards', :action => 'show', :project_id => board.project, :id => board)
            render_multipart('board_added', body)
        end

        def render_multipart_with_subscription(method_name, body)
            if File.exist?(File.join(File.dirname(__FILE__), "../app/views/mailer/#{method_name}.html.erb"))

                # Copy of Mailer#render_multipart in Redmine 1.3.x
                if Setting.plain_text_mail?
                    content_type "text/plain"
                    body render(:file => "#{method_name}.text.erb", :body => body, :layout => 'mailer.text.plain.erb')
                else
                    content_type "multipart/alternative"
                    part :content_type => "text/plain",
                         :body => render(:file => "#{method_name}.text.erb", :body => body, :layout => 'mailer.text.plain.erb')
                    part :content_type => "text/html",
                         :body => render_message("#{method_name}.html.erb", body)
                end

            else
                render_multipart_without_subscription(method_name, body)
            end
        end

    end

    module NewsCommentAddedMethod

        # A copy of news_comment_added from Redmine 1.3.x
        def news_comment_added(comment)
            news = comment.commented
            redmine_headers 'Project' => news.project.identifier
            message_id comment
            recipients news.recipients
            subject "Re: [#{news.project.name}] #{l(:label_news)}: #{news.title}"
            body :news => news,
                 :comment => comment,
                 :news_url => url_for(:controller => 'news', :action => 'show', :id => news)
            render_multipart('news_comment_added', body)
        end

    end

end
