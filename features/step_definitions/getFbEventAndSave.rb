Given /I want facebook events for facebook page "(.*)"/ do |club_id| end

When /I get facebook events for facebook page "(.*)"/ do |url| 
      facebook_page_id = Event.facebookIDFromFacebookPageUrl(url)
      #"(.*)"/
      #"([^"]*)"/
      access_token = Event.class_variable_get("@@access_token")
      url = "https://graph.facebook.com/#{facebook_page_id}?access_token=#{CGI.escape(access_token)}"
      
      club = (Club.find_by_facebook_id(facebook_page_id) or Club.create!(facebook_id: facebook_page_id)) 
      next if facebook_page_id.blank?
    
      
      facebook_page =  File.open( File.join(File.expand_path(File.dirname(__FILE__)), "..", "support", "facebook_page_fake.json"), "r").read
      FakeWeb.register_uri(:get, url, :body => facebook_page)
      fql_url = "https://api.facebook.com/method/fql.query?access_token=#{CGI.escape(access_token)}&query=#{CGI.escape(Event.get_fql(facebook_page_id))}&format=JSON"
      berkeley_project_events =  File.open( File.join(File.expand_path(File.dirname(__FILE__)), "..", "support", "berkeley_project_events.json"), "r").read
      FakeWeb.register_uri(:get, fql_url, :body => berkeley_project_events)
      club.update_facebook_page_events false
end
      
  
Then /there should be (.*) events for Facebook page "(.*)"/ do |n, facebook_id|
    if facebook_id.strip.length == 0
      facebook_id = nil
    end
    assert Club.find_by_facebook_id!(facebook_id).events.count == n.to_i, "got #{Club.find_by_facebook_id!(facebook_id).events.count} events instead of #{n} events for club with facebook id #{facebook_id}"
end
