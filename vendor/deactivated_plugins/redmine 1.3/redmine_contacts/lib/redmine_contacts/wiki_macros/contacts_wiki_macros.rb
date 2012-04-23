include ContactsHelper           
include NotesHelper

module RedmineContacts
  module WikiMacros
    
    
    Redmine::WikiFormatting::Macros.register do
      desc "Contact Description Macro" 
      macro :contact_plain do |obj, args|
        args, options = extract_macro_options(args, :parent)
        raise 'No or bad arguments.' if args.size != 1
        contact = Contact.visible.find(args.first)
        link_to_source(contact)
      end  

      desc "Contact avatar"
      macro :contact_avatar do |obj, args|
        args, options = extract_macro_options(args, :parent)
        raise 'No or bad arguments.' if args.size != 1
        contact = Contact.visible.find(args.first)
        link_to avatar_to(contact, :size => "32"),  contact_url(contact), :id => "avatar", :title => contact.name
      end  

      desc "Contact with avatar"
      macro :contact do |obj, args|
        args, options = extract_macro_options(args, :parent)
        raise 'No or bad arguments.' if args.size != 1
        contact = Contact.visible.find_by_id(args.first)
        link_to(avatar_to(contact, :size => "16"),  contact_url(contact), :id => "avatar") + ' ' + link_to_source(contact) if contact
      end  

      desc "Deal"
      macro :deal do |obj, args|
        args, options = extract_macro_options(args, :parent)
        raise 'No or bad arguments.' if args.size != 1
        deal = Deal.visible.find(args.first)                                 
        s = ''
        s << avatar_to(deal, :size => "16") + " "
        s << link_to(deal.full_name, polymorphic_url(deal)) + " "
  			s << content_tag('span', 
  			                 h(deal.status), 
  			                 :style => "background-color:#{deal.status.color_name};color:white;padding: 3px 4px;font-size: 10px;white-space: nowrap;margin-right: 4px;", :class => "deal-status") if deal.status
      end  

      desc "Thumbnails"
      macro :thumbnails do |obj, args|
        return "" if obj.blank?
        args, options = extract_macro_options(args, :parent)
        raise 'No or bad arguments.' if args.size > 1  
        
        size = ""
        size = args.first if args.any?
        options[:size] = size.blank? ? "100" : size  
        options[:class] = "thumbnail"

        s = '<style type="text/css"> 
        img.thumbnail {
          border: 1px solid #D7D7D7;
          padding: 4px; 
          margin: 4px;
          vertical-align: middle;   
          background: white;
        } 
        </style>'  
        
        s << thumbnails(obj, options) 
        content_tag(:p, s) if !s.blank?
        
      end  

    end  

  end
end
