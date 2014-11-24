# encoding: UTF-8
require 'vote_proxy'

help = "输入查询指令：
  0 - 导入proxy.txt
  1 - 开始用代理库投票
  2 - 停止用代理库刷票
  3 - 投票结果
  4 - 抓取www.cnproxy.net代理
  5 - 抓取proxy.com.ru代理
  6 - 抓取google-proxy代理
  7 - 抓取free-proxy 代理
  8 - 抓取cool-proxy 代理
"

@voteThread=VoteThread.new;
@proxyIp = "10.8.1.3"
@proxyPort = 3128

def fetchCoolProxys
  @voteThread.addProxy(Proxy.normalProxy("http://happy-proxy.com/fresh_proxies?key=81e4bc299af84e35"))
  for i in 1..11
    url="http://www.cool-proxy.net/proxies/http_proxy_list/page:#{i}/sort:score/direction:desc"
    proxys =Proxy.coolProxy(url, @proxyIp, @proxyPort)
    count=@voteThread.addProxy(proxys)
    puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"
  end
end

def fetchCnProxys
  for i in 1..10
    url="http://www.cnproxy.com/proxy#{i}.html"
    proxys =Proxy.cnproxy(url, @proxyIp, @proxyPort)
    count=@voteThread.addProxy(proxys)
    puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"
  end
  for i in 1..2
    url="http://www.cnproxy.com/proxyedu#{i}.html"
    proxys =Proxy.cnproxy(url, @proxyIp, @proxyPort)
    count=@voteThread.addProxy(proxys)
    puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"
  end

end

def fetchRuProxys
  for i in 1..12
    url="http://proxy.com.ru/list_#{i}.html"
    proxys =Proxy.ruproxy(url, @proxyIp, @proxyPort)
    count=@voteThread.addProxy(proxys)
    puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"
  end
end

def fetchGoogleProxys
  url="http://www.google-proxy.net/"
  proxys =Proxy.rubularProxy(url, @proxyIp, @proxyPort)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"
end

def fetchFreeProxys
  for i in 1..176
    Thread.new(i) { |index|
      url="http://free-proxy.cz/en/proxylist/main/#{index}"
      begin
        proxys =Proxy.freeProxy(url)
      rescue
        puts "#{url}抓取代理失败"
      end
      count=@voteThread.addProxy(proxys)
      puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"
    }
  end
end


def importFromFile
  proxys =Proxy::fileProxy("../data/proxy.txt")
  count=@voteThread.addProxy(proxys)
  puts "proxy.txt导入代理#{proxys.size}个,成功添加#{count}个"
end

puts help
while true
  cmd = gets.chomp
  begin
    case cmd.split(" ").first
      when "0"
        importFromFile
        next
      when "1"
        @voteThread.start(150)
        next
      when "2"
        @voteThread.stop
        next
      when "3"
        succ, failed=@voteThread.voteResult
        puts "投票结果: 成功-#{succ}  失败-#{failed}"
        next0
      when "4"
        fetchCnProxys
        next
      when "5"
        fetchRuProxys
        next
      when "6"
        fetchGoogleProxys
        next
      when "7"
        fetchFreeProxys
        next
      when "8"
        fetchCoolProxys
        next
      else
        puts "未知命令"
    end
  rescue
  end
  puts help
end