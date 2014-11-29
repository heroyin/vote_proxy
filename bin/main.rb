# encoding: UTF-8
require 'vote_proxy'

help = "输入查询指令：
  0 - 导入proxy.txt
  1 - 开始用代理库投票
  2 - 可用IP数量
  3 - 投票结果
  4 - 抓取www.cnproxy.net代理
  5 - 抓取proxy.com.ru代理
  6 - 抓取google-proxy代理
  7 - 抓取proxynova 代理
  8 - 抓取cool-proxy 代理
  9 - 抓取normal-proxy 代理
  a - 获取排名
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

  url="http://www.us-proxy.org/"
  proxys =Proxy.rubularProxy(url, @proxyIp, @proxyPort)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://free-proxy-list.net/uk-proxy.html"
  proxys =Proxy.rubularProxy(url, @proxyIp, @proxyPort)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://free-proxy-list.net/anonymous-proxy.html"
  proxys =Proxy.rubularProxy(url, @proxyIp, @proxyPort)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url=" http://www.sslproxies.org/"
  proxys =Proxy.rubularProxy(url, @proxyIp, @proxyPort)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"


end

def fetchproxynova
  url="http://www.proxynova.com/proxy-server-list/"
  proxys =Proxy.proxynova(url)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://www.proxz.com/proxylists.xml"
  proxys =Proxy.proxz(url)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://www.xroxy.com/proxyrss.xml"
  proxys =Proxy.xroxy(url)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"
end

def fetchnormalproxy
  url="http://proxydb.org/http-proxy-list/"
  proxys =Proxy.normalProxyWithProxy(url,  @proxyIp, @proxyPort)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://www.proxyfire.net/forum/showthread.php?t=67597"
  proxys =Proxy.normalProxy(url)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://www.proxyfire.net/forum/showthread.php?t=67597&page=2"
  proxys =Proxy.normalProxy(url)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://www.proxyfire.net/forum/showthread.php?t=67597&page=3"
  proxys =Proxy.normalProxy(url)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://www.proxyfire.net/forum/showthread.php?t=67597&page=4"
  proxys =Proxy.normalProxy(url)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

  url="http://www.proxyfire.net/forum/showthread.php?t=67597&page=5"
  proxys =Proxy.normalProxy(url)
  count=@voteThread.addProxy(proxys)
  puts "#{url}抓取代理#{proxys.size}个,成功添加#{count}个"

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
        puts "可用IP数量#{@voteThread.availableCount}"
        next
      when "3"
        succ, failed=@voteThread.voteResult
        puts "投票结果: 成功-#{succ}  失败-#{failed}"
        next
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
        fetchproxynova
        next
      when "8"
        fetchCoolProxys
        next
      when "9"
        fetchnormalproxy
        next
      when "a"
        puts Vote.queryPopuler
        next
      else
        puts "未知命令"
    end
  rescue
  end
  puts help
end