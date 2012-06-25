# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{question_plugin}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Davis"]
  s.date = %q{2009-10-14}
  s.description = %q{This is a plugin for Redmine that will allow users to ask questions to each other in issue notes}
  s.email = %q{edavis@littlestreamsoftware.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "COPYRIGHT.txt",
     "CREDITS.txt",
     "GPL.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "app/controllers/questions_controller.rb",
     "app/models/journal_questions_observer.rb",
     "app/models/question.rb",
     "app/models/question_mailer.rb",
     "app/views/question_mailer/answered_question.erb",
     "app/views/question_mailer/answered_question.text.html.rhtml",
     "app/views/question_mailer/asked_question.erb",
     "app/views/question_mailer/asked_question.text.html.rhtml",
     "app/views/questions/autocomplete_for_user_login.html.erb",
     "config/locales/de.yml",
     "config/locales/en.yml",
     "init.rb",
     "lang/de.yml",
     "lang/en.yml",
     "lib/question_hooks_base.rb",
     "lib/question_issue_hooks.rb",
     "lib/question_issue_patch.rb",
     "lib/question_journal_hooks.rb",
     "lib/question_journal_patch.rb",
     "lib/question_layout_hooks.rb",
     "lib/question_queries_helper_patch.rb",
     "lib/question_query_patch.rb",
     "rails/init.rb"
  ]
  s.homepage = %q{https://projects.littlestreamsoftware.com/projects/TODO}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{question_plugin}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{This is a plugin for Redmine that will allow users to ask questions to each other in issue notes}
  s.test_files = [
    "spec/lib/question_issue_hooks_spec.rb",
     "spec/lib/question_issue_patch_spec.rb",
     "spec/lib/question_journal_hooks_spec.rb",
     "spec/lib/question_queries_helper_patch_spec.rb",
     "spec/spec_helper.rb",
     "spec/models/question_mailer_spec.rb",
     "spec/models/question_spec.rb",
     "spec/models/journal_questions_observer_spec.rb",
     "spec/controllers/questions_controller_spec.rb",
     "spec/sanity_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
