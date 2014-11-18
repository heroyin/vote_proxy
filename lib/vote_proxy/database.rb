# encoding: UTF-8
require "sqlite3"

class Database

  def initialize(file)
    @semaphore = Mutex.new
    @file = file
    @db = SQLite3::Database.new file
    buildTables
  end

  def hasProxy(ip, port)
    @db.query("select ip from proxy where ip=? and port=?", ip, port) do |rs|
      if (row = rs.next)
        return true
      else
        return false
      end
    end
  end

  def addProxy(ip, port)
    if (hasProxy(ip, port))
      return false
    end

    @db.execute2("insert into proxy (ip, port)
             VALUES (?, ?)", "#{ip}", "#{port}")
    return true
  end

  def splitProxy(proxy)
    ip = proxy.split(":")[0]
    port = proxy.split(":")[1]
    port = port.delete("\n")
    return ip, port
  end

  def addProxyArray(proxyArray)
    @db.transaction
    begin
      for proxy in proxyArray
        ip, port=splitProxy(proxy)
        addProxy(ip, port)
      end
    rescue
      @db.rollback
    ensure
      @db.commit
    end
  end

  def removeProxy(ip, port)
    @db.execute "delete from proxy where ip='#{ip}' and port='#{port}'"
  end

  def queryProxys(limit, offset)
    proxys = Array.new
    time = Time.now
    time = time - 24*60*60
    @db.query("select id, ip,port from proxy where stamp>'#{time.strftime("%F %T")}' limit #{limit} offset #{offset}") do |rs|
      while (row = rs.next)
        proxys.push("#{row[1]}:#{row[2]}")
        # @db.execute "update proxy set lock='1' where id='#{row[0]}'"
      end
    end

  end

  def lockProxys(limit)
    proxys = Array.new
    @semaphore.synchronize {
      time = Time.now
      time = time - 24*60*60
      @db.query("select id, ip,port from proxy where stamp>'#{time.strftime("%F %T")}' and lock='0' limit #{limit} offset #{offset}") do |rs|
        while (row = rs.next)
          proxys.push("#{row[1]}:#{row[2]}")
          @db.execute "update proxy set lock='1' where id='#{row[0]}'"
        end
      end
    }
    proxys
  end

  def getFailed(ip, port)
    @db.query("select failed from proxy where ip=? and port=?", ip, port) do |rs|
      if (row = rs.next)
        return row[0]
      else
        return 0
      end
    end
  end

  def updateProxy(ip, port, res)
    time = Time.now.strftime("%F %T")
    @db.execute "update proxy set stamp= '#{time}', result='#{res}' where ip='#{ip}' and port='#{port}'"
  end

  protected

  def buildTables
    @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS proxy (
          id integer primary key autoincrement,
          ip,
          port,
          stamp,
          result,
          lock
        );
    SQL

  end


end
