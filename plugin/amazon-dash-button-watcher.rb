# -*- coding: utf-8 -*-

Plugin.create(:amazon_dash_button_observer) do

  IO.popen('ip l').map{|line|
    /\A\d+:\s*(\w+):/.match(line)
  }.select{|matched|
    matched
  }.each{|matched|
    Plugin.call(:amazon_dash_button_observer_start, matched[1].freeze)
  }

  last_pushed = Hash.new{|h, k| h[k] = 0}

  # 一秒以内に二回以上押された場合、無視する
  filter_amazon_dash_button_pushed do |interface, mac|
    now = Time.now.to_i
    Plugin.filter_cancel! if last_pushed[mac] >= now
    last_pushed[mac] = now + 1
    [interface, mac]
  end

  on_amazon_dash_button_pushed do |interface, mac|
    warn "#{interface}\tAmazon Dash Button #{mac} was pushed."
  end

  on_amazon_dash_button_observer_start do |interface|
    observer = Thread.new do
      Thread.pass
      observer.abort_on_exception = true
      IO.popen("tcpdump -i #{interface} -e", 'r').lazy.select{|line|
        line.include?('Broadcast, ethertype ARP')
      }.map{|line|
        /(?:[\da-f]{2}:){5}[\da-f]{2}/.match(line)
      }.select{|matched|
        matched
      }.map{|matched|
        matched[0]
      }.each{|mac_addr|
        Plugin.call(:amazon_dash_button_pushed, interface, mac_addr.freeze)
      }
    end
  end
end
