# encoding: UTF-8
require 'test/unit'
require 'vote_proxy'

class ProxyTest < Test::Unit::TestCase

  VOTE_RESULT = ["成功", "失败", "内容不匹配", "超时", "其他网络错误"]

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
    puts Proxy.freeProxy("http://free-proxy.cz/en/proxylist/main/2")
  end

  def test_popular
    puts Vote.queryPopuler.join("\n")
  end

  def test_fireProxy
    fireProxyArray = [
        "http://www.proxyfire.net/forum/showthread.php?t=67596",
        "http://www.proxyfire.net/forum/showthread.php?t=69056",
        "http://www.proxyfire.net/forum/showthread.php?t=69162",
        "http://www.proxyfire.net/forum/showthread.php?t=69163",
        "http://www.proxyfire.net/forum/showthread.php?t=69458",
        "http://www.proxyfire.net/forum/showthread.php?t=67597"
    ]

    threadGroup = ThreadGroup.new
    proxys=Array.new;
    fireProxyArray.each(){|url|
      threadGroup.add(Thread.new(url){|fireProxy|
        proxys+=Proxy.normalProxy(fireProxy)
      });
    }
    threadGroup.list.each() { |thread|
      thread.join
    }
    proxys=proxys.uniq;
    IO.write("../data/fire.txt", proxys.join("\n"))
  end



  def test_voteByProxyText
    proxys =Proxy::fileProxy("../data/proxy.txt")
    threadGroup = ThreadGroup.new
    succ=0
    failed=0
    proxys.each() { |proxy|
      ip = proxy.split(":").first;
      port = proxy.split(":").last;
      threadGroup.add(Thread.new(ip,port) {|proxyIp,proxyPort|
        begin
          puts "vote by #{proxyIp}:#{proxyPort}"
          res = Vote::voteByHttpProxy(1387, proxyIp, proxyPort)
          puts "vote result #{VOTE_RESULT[res]}"
          if res==0
            succ+=1
          else
            failed+=1
          end
        rescue Exception=>e
          puts e
        end
      })
    }
    threadGroup.list.each() { |thread|
      thread.join
    }

    puts "投票结果: 成功-#{succ}  失败-#{failed}"
  end

end