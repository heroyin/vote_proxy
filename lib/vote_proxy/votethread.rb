# encoding: UTF-8
require "sqlite3"
require "vote_proxy/vote"


class VoteThread

  def initialize()
    @threadGroup = ThreadGroup.new
    @db = SQLite3::Database.new "../data/proxy.db"
    @semaphore = Mutex.new
    @terminate=false;
    buildTables
  end

  VOTE_RESULT = ["成功", "失败", "内容不匹配", "超时", "其他网络错误"]

  def start(max)
    @succ=0
    @failed=0
    @terminate=false;
    # 解锁所有IP
    @db.execute2("update proxy set lock=0")

    @threadGroup = ThreadGroup.new
    while @threadGroup.list.count<max
      @threadGroup.add(Thread.new() {
        while (!@terminate)
          proxy = lockProxy()
          if (proxy&&!proxy.empty?)
            p "vote by #{proxy[1]}:#{proxy[2]}"
            res = Vote::voteByHttpProxy(1387, proxy[1], proxy[2])
            puts "vote result #{VOTE_RESULT[res]}"
            time = Time.now.strftime("%F %T")
            case res
              when 0
                @succ+=1
                @db.execute "update proxy set stamp= '#{time}', result=#{res}, lock=0 where id=#{proxy[0]}"
              when 1
                @failed+=1
                @db.execute "update proxy set stamp= '#{time}', result=#{res}, lock=0 where id=#{proxy[0]}"
              when 2
                @failed+=1
                @db.execute "delete from proxy where id=#{proxy[0]}"
                puts "投票失败,删除IP地址#{proxy[1]}:#{proxy[2]}"
              when 3, 4
                retryCount=proxy[3].to_i
                retryCount+=1
                if (retryCount>2)
                  @db.execute "delete from proxy where id=#{proxy[0]}"
                  puts "多次重试失败,删除IP地址#{proxy[1]}:#{proxy[2]}"
                  @failed+=1
                else
                  @db.execute "update proxy set result=#{res}, lock=0, retry=#{retryCount} where id=#{proxy[0]}"
                  puts "第#{retryCount}次重试#{proxy[1]}:#{proxy[2]}"
                end
              else
                @db.execute "delete from proxy where id='#{proxy[0]}'"
                @failed+=1
            end
          else
            puts "没有新的IP了,睡觉10秒"
            sleep(10)
          end

        end
      });
    end
  end

  def stop
    @terminate=true
    @threadGroup.list.each() { |thread|
      thread.join
    }
  end

  def voteResult
    return @succ, @failed
  end

  def addProxy(proxys)
    count=0
    @db.transaction
    begin
      proxys.each() { |proxy|
        if !/[^\d\.:]/.match(proxy)
          ip = proxy.split(":").first;
          port = proxy.split(":").last;
          @db.query("select ip from proxy where ip=? and port=?", ip, port) do |rs|
            if (rs.next==nil)
              @db.execute2("insert into proxy (ip, port) values ('#{ip}', '#{port}')")
              count+=1
            end
          end
        end
      }
    rescue
      @db.rollback
    ensure
      @db.commit
    end
    count
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
          lock,
          retry
        );
    SQL

  end


  def lockProxy()
    @semaphore.synchronize {
      time = Time.now
      time = time - 24*60*60
      @db.query("select id,ip,port,retry from proxy where (stamp<'#{time.strftime("%F %T")}' or stamp isnull) and (lock=0 or lock isnull)  limit 1") do |rs|
        if (row = rs.next)
          @db.execute "update proxy set lock=1 where id='#{row[0]}'"
          return row
        end
      end
    }
  end

  def splitProxy(proxy)
    ip = proxy.split(":")[0]
    port = proxy.split(":")[1]
    port = port.delete("\n")
    return ip, port
  end

end
