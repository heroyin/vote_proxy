# encoding: UTF-8
require 'uri'
require "base64"

class Proxy

  def self.cnproxy(url, proxyIP, proxyPort)
    uri = URI.parse(url)

    proxy_class = Net::HTTP::Proxy(proxyIP, proxyPort)
    proxy_class.start(uri.host, uri.port) {|http|
      response = http.get(uri.path)
      body= response.body

      # v="3";m="4";a="2";l="9";q="0";b="5";i="7";w="6";r="8";c="1"

      portHash=Hash.new
      body.scan(/[a-z]\=.\d\"/){|w|
        w= w.gsub(/\"/, "").gsub(/\\/, "")
        portHash[w.split("=")[0]]=w.split("=")[1]
      }

      ips=Array.new
      body.scan(/[\d]+\.[\d]+\.[\d]+\.[\d]+[\w\<\>\=\/\"\s\.]+\([\\\"\:\+\w]+\)/){|ip|
        ip = ip.gsub(/([\d]+\.[\d]+\.[\d]+\.[\d]+)[\w\<\>\"\\\:\=\.\/\(\s]+([\+a-z]+)\)/, '\1:\2')
        ip= ip.gsub(/[\+]/, "").gsub(/[a-z]/, portHash)
        # ip = ip.gsub(/[\+]/, "").gsub(/q/, "0").gsub(/c/, "1").gsub(/a/, "2").gsub(/v/, "3").gsub(/m/, "4").gsub(/b/, "5").gsub(/w/, "6").gsub(/i/, "7").gsub(/r/, "8").gsub(/l/, "9")
        ips.push(ip)
      }
      ips
    }
  end

  def self.ruproxy(url, proxyIP, proxyPort)
    uri = URI.parse(url)
    proxy_class = Net::HTTP::Proxy(proxyIP, proxyPort)
    proxy_class.start(uri.host, uri.port) {|http|
      response = http.get(uri.path)
      body= response.body

      # <tr><b><td>1</td><td>41.231.53.40</td><td>3128</td>
      ips=Array.new
      body.scan(/<\/td><td>[\d]+\.[\d]+\.[\d]+\.[\d]+<\/td><td>[\d]+/){|ip|
        ip = ip.gsub(/([\d]+\.[\d]+\.[\d]+\.[\d]+)<\/td><td>([\d]+)/, '\1:\2')
        # ip = ip.gsub(/[\+]/, "").gsub(/q/, "0").gsub(/c/, "1").gsub(/a/, "2").gsub(/v/, "3").gsub(/m/, "4").gsub(/b/, "5").gsub(/w/, "6").gsub(/i/, "7").gsub(/r/, "8").gsub(/l/, "9")
        ip=ip.delete("</td><td>")
        ips.push(ip)
      }
      ips
    }
  end

  def self.coolProxy(url, proxyIp, proxyPort)
    uri = URI.parse(url)
    proxy_class = Net::HTTP::Proxy(proxyIp, proxyPort)
    proxy_class.start(uri.host, uri.port) {|http|
      response = http.get(uri.path)
      body= response.body
      # <tr><b><td>1</td><td>41.231.53.40</td><td>3128</td>
      ips=Array.new
      body.scan(/decode\(str_rot13\(\"([\w=\/]+)"\)\)\)<\/script><\/td>[\s]+<td>([\d]+)/){|ip|
        host= ip[0].gsub(/[a-zA-Z]/){|s|
          ord = s.ord
          if(s.downcase.ord>="n".ord)
            ord+=-13
          else
            ord+=13
          end
          ord.chr
        }
        host=Base64.decode64(host)
        port=ip[1]
        ips.push("#{host}:#{port}")
      }
      ips
    }
  end

  def self.rubularProxy(url, proxyIp, proxyPort)
    uri = URI.parse(url)
    proxy_class = Net::HTTP::Proxy(proxyIp, proxyPort)
    proxy_class.start(uri.host, uri.port) {|http|
      response = http.get(uri.path)
      body= response.body
      ips=Array.new
      body.scan(/<tr><td>[\d]+.[\d]+.[\d]+.[\d]+<\/td><td>[\d]+<\/td>/){|ip|
        match=/([\d]+\.[\d]+\.[\d]+\.[\d]+)<\/td><td>([\d]+)/.match(ip)
        ips.push("#{match[1]}:#{match[2]}")
      }
      ips
    }
  end

  def self.freeProxy(url)
    response = Net::HTTP.get_response(URI.parse(url))
    body= response.body
    proxys=Array.new
    body.scan(/<\/div> [\d.]+<\/td>[\s]+<td><span class="fport">[\d]+<\/span>/){|ip|
      match=/([\d]+.[\d]+.[\d]+.[\d]+)<\/td>[\s]+<td><span class="fport">([\d]+)/.match(ip)
      proxy=match[1]+":"+match[2]
      proxys.push(proxy)
    }
    proxys
  end


  def self.normalProxy(url)
    response = Net::HTTP.get_response(URI.parse(url))
    body= response.body
       proxys=Array.new
      body.scan(/[\d]+\.[\d]+\.[\d]+\.[\d]+:[\d]+/){|proxy|
        proxys.push(proxy)
      }
      proxys
  end

  # 测试代理，0 - 成功  1 - 失败 2 - 超时 3 - 其他错误
  def self.testProxy(proxyIp, proxyPort)
    uri = URI.parse('http://www.telize.com/geoip')
    begin
      proxy_class = Net::HTTP::Proxy(proxyIp, proxyPort, nil, nil)
      proxy_class.start(uri.host, uri.port) {|http|
        response = http.get(uri.path)
        body = response.body
        if body.force_encoding("utf-8").include?"longitude"
          return 0
        else
          return 1
        end
      }
    rescue Errno::ETIMEDOUT=>timeout
        p timeout
        return 2
    rescue Exception=>e
        p e
        return 3
    end
  end

  def self.fileProxy(file)
    contentsArray=[]  # start with an empty array
    f = File.open(file)
    f.each_line {|line|
      contentsArray.push line.delete("\n")
    }
    contentsArray
  end

end