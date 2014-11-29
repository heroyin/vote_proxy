require 'test/unit'
require 'vote_proxy'

class ProxyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_freeProxy
    # puts Proxy.proxz("http://www.proxz.com/proxylists.xml")
    puts "xroxy"
    puts Proxy.normalProxy("http://www.proxyfire.net/forum/showthread.php?t=67597&page=2")
  end

  def test_popular
    puts Vote.queryPopuler
  end

  def test_voteByProxyText
    proxys =Proxy::fileProxy("../data/proxy.txt")
    threadGroup = ThreadGroup.new
    proxys.each() { |proxy|
      ip = proxy.split(":").first;
      port = proxy.split(":").last;
      threadGroup.add(Thread.new(ip,port) {|ip,port|
        res = Vote::voteByHttpProxy(1387, ip, port)
        puts "vote result #{VOTE_RESULT[res]}"
      })
    }
    threadGroup.list.each() { |thread|
      thread.join
    }
  end

end