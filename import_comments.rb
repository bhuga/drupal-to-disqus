#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__),'disqus/lib')
require 'disqus'
require 'disqus/api'

require 'rubygems'
require 'sequel'

opts = YAML.load_file 'db.yml'

Disqus::defaults[:api_key] = opts[:api_key]

forums = Disqus::Api.get_forum_list
forum = forums['message'].find do |forum| forum['shortname'] = 'bhuga' end

puts "I'm using this forum: #{forum.inspect}"

forum_key = (Disqus::Api.get_forum_api_key :forum_id => forum["id"])['message']

#puts forum_key.inspect

db = Sequel.connect opts

#db[:comments].each do | comment | puts comment[:thread] end
comment_threads = {}
comments = []
db[:comments].each do |comment|
  comment_threads["#{comment[:nid]}-#{comment[:thread]}"] = comment
  comments << comment
end

# make sure that comments without parents are first, so that we always create
# parentless comments first.  Otherwise, we might create children before their
# parents.
comments.sort! do | a, b |
  a[:thread].length <=> b[:thread].length
end

puts "I have #{comments.size} comments to post (of #{db[:comments].count})"

threads = {}
posted = 0
comments.each do | comment |
  if comment[:thread] =~ /\./
    parent_thread = comment[:thread][0..-5] + "/"
    comment[:parent] = comment_threads["#{comment[:nid]}-#{parent_thread}"]
    #puts "I has a parent! it's #{comment[:parent].inspect}\n\n"
  end
  comment[:created_at] = Time.at(comment[:timestamp]).strftime('%Y-%m-%dT%H:%M')
 
  if threads[comment[:nid]].nil? 
    thread_response = Disqus::Api.thread_by_identifier :forum_api_key => forum_key,
                                          :title => comment[:thread],
                                          :identifier => "node/#{comment[:nid]}"
    #puts "fetched a new thread.  response was #{thread_response.inspect}"
    thread_id = thread_response['message']['thread']
    threads[comment[:nid]] = thread_id
  end

  thread = threads[comment[:nid]]
  #puts "attempting to post #{comment.inspect}...\n\n"

  post = Disqus::Api.create_post :forum_api_key => forum_key,
                        :thread_id => thread['id'],
                        :message => comment[:comment],
                        :author_name => comment[:name].length > 0 ? comment[:name] : 'Anonymous',
                        :author_email => comment[:mail].length,
                        :parent_post => comment[:parent] ? comment[:parent][:disqus_id] : nil,
                        :created_at => comment[:created_at],
                        :author_url => comment[:homepage],
                        :ip_address => comment[:hostname]

  if post['succeeded'] 
    puts "added a post successfully: #{post['message']['id']}"
    posted += 1
  else
    puts "FAILED to add a post: #{post.inspect}"
  end
  comment[:disqus_id] = post['message']['id']

end
puts "Posted #{posted} comments!  Enjoy disqus!"
