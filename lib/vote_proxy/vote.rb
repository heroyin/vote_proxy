# encoding: UTF-8
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'uri'


class Vote

  # 利用HTTP代理投票，0 - 成功  1 - 失败 2 - 内容不匹配 3 - 超时 4 - 其他错误
  def self.voteByHttpProxy(id, proxyIP, proxyPort)
    begin
      uri = URI.parse('http://www.hnmsw.com/zhuanti/changeTP.php')
      Net::HTTP::Proxy(proxyIP, proxyPort).start(uri.host, uri.port) { |http|
        req = Net::HTTP::Post.new(uri.path)
        req.form_data = {"photoID" => id}
        response = http.request(req)
        body = response.body
        puts body
        if body.force_encoding("utf-8").include? "成功"
          return 0
        elsif body.force_encoding("utf-8").include? "每天只能投一次票"
          return 1
        else
          return 2
        end
      }
    rescue Errno::ETIMEDOUT => timeout
      return 3
    rescue Exception => e
      return 4
    end

  end

  def self.vote(id, proxyIP, proxyPort)
    uri = URI.parse('http://www.hnmsw.com/zhuanti/changeTP.php')
    proxy_class = Net::HTTP::Proxy(proxyIP, proxyPort)
    proxy_class.start(uri.host, uri.port) { |http|
      req = Net::HTTP::Post.new(uri.path)
      req.form_data = {"photoID" => id}
      response = http.request(req)
      body = response.body
      res =body.force_encoding("utf-8").include? "成功"
      return res, body
    }
  end

  def self.ip(proxyIP, proxyPort)
    uri = URI.parse('http://www.telize.com/ip')
    proxy_class = Net::HTTP::Proxy(proxyIP, proxyPort)
    proxy_class.start(uri.host, uri.port) { |http|
      response = http.get(uri.path)
      ip = response.body
      ip.delete!("\n")
      ip
    }
  end

  # 查询前五位
  def self.queryPopuler()
    url = 'http://www.hnmsw.com/zhuanti/index_sheyingphoto.php'
    @doc = Nokogiri::HTML(open(url))
    photoArray = Array.new
    for obj in @doc.xpath("//div[@id='KinSlideshow']/a")
      alt = obj.child.attribute("alt").value
      src = obj.attribute("href").value
      photo = Hash.new
      photo["id"] = src.scan(/[\d]+/)
      photo["name"] = alt.split(" ")[0]
      photo["number"] = alt.scan(/[\d]+/)
      photoArray.push(photo)
    end
    photoArray
  end

end