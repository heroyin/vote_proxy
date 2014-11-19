require "vote_proxy/version"
require "vote_proxy/vote"
require "vote_proxy/proxy"
require "vote_proxy/database"
require "vote_proxy/votethread"

module VoteProxy
  autoload :VoteThread,     'tor/votethread'
  autoload :Proxy, 'vote_proxy/proxy'
  autoload :VERSION,    'vote_proxy/version'
end
