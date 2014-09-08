require 'socket'
require 'usagewatch_ext'
require 'system/getifaddrs'

@interval = 2
units = 's'
loopTime = "#{@interval}#{units}"
graphHistorySize = 10

hostname = "localhost"
ipaddrs = ["127.0.0.1"]
details = Hash.new({ value: 0 })

cpuProc = Hash.new({ value: 0 })
memProc = Hash.new({ value: 0 })
lastcpuProc = Hash.new({ value: 0 })
lastmemProc = Hash.new({ value: 0 })

class GraphPoints

  def initialize( arraySize )
    @max = arraySize
    @pointsArray = Array.new(arraySize)
    @pointsArray.push( { :x => 0, :y => 0 })
  end

  def getLastX()
    point = @pointsArray.last
    return point[ :x ]
  end

  def getLastY()
    point = @pointsArray.last
    return point[ :y ]
  end

  def update( x, y )
    point = { :x => x, :y => y }
    if @pointsArray.count > @max
      @pointsArray.shift
    end
    @pointsArray.push( point )
  end

  def getPoints()
    return @pointsArray
  end

end

@stats = {
  :duGig => GraphPoints.new(graphHistorySize),
  :duPct => GraphPoints.new(graphHistorySize),
  :cpu => GraphPoints.new(graphHistorySize),
  :memPct => GraphPoints.new(graphHistorySize),
  :sysload => GraphPoints.new(graphHistorySize),
  :rxMb => GraphPoints.new(graphHistorySize),
  :txMb => GraphPoints.new(graphHistorySize)
}

def self.updateStats
  @stats.each do | stat, stuff |
    newX = stuff.getLastX + @interval
    newY = getNewStat( "#{stat}" )
    stuff.update( newX, newY )
  end
end

def self.bandrx( netiface )
  read1 =`netstat -ib | grep -e "#{netiface}" -m 1 | awk '{print $7}'`
  sleep 1
  read2=`netstat -ib | grep -e "#{netiface}" -m 1 | awk '{print $7}'`
  (((read2.to_f - read1.to_f)/1024)/1024).round(3)
end

def self.bandtx( netiface )
  send1=`netstat -ib | grep -e "#{netiface}" -m 1 | awk '{print $10}'`
  sleep 1
  send2=`netstat -ib | grep -e "#{netiface}" -m 1 | awk '{print $10}'`
  (((send2.to_f - send1.to_f)/1024)/1024).round(3)
end

def self.memPctUsed()
  top = `top -l1 | awk '/PhysMem/'`
  top = top.gsub(/[\.\,a-zA-Z:]/, "").split(" ").reverse
  final = ((top[3].to_f / (top[0].to_f + top[3].to_f)) * 100).round(2)
  return final
end

def self.getNewStat(statname)
  case statname
    when 'duGig'
      return Usagewatch.uw_diskused
    when 'duPct'
      return Usagewatch.uw_diskused_perc
    when 'cpu'
      return Usagewatch.uw_cpuused
    when 'memPct'
      return memPctUsed
    when 'sysload'
      return Usagewatch.uw_load
    when 'rxMb'
      return bandrx('en0')
    when 'txMb'
      return bandtx('en0')
  end
  puts "Default value returned"
  return 0
end

SCHEDULER.every loopTime, :first_in => 0 do |job|
  hostname = Socket.gethostname
  ipaddrs = System.get_all_ifaddrs

  details['name'] = {
    label: 'hostname',
    value: hostname
  }

  ipaddrs.each do | net |
    details[ net[ :interface ] ] = {
      label: net[ :interface ],
      value: net[ :inet_addr ]
    }
  end

  updateStats
  @stats.each do | stat, stuff |
    send_event( "#{stat}Graph", points: stuff.getPoints() )
  end

  dpct = (@stats[ :duPct ]).getLastY
  send_event('diskPercent', { value: dpct })

  mpct = (@stats[ :memPct ]).getLastY
  send_event('memPercent', { value: mpct })

  send_event('hostdetaildata', { items: details.values })

  lastcpuProc = cpuProc
  lastmemProc = memProc
  cpuProc = Hash.new({ value: 0})
  memProc = Hash.new({ value: 0})
  Usagewatch.uw_cputop.each do |cproc|
    cpuProc[cproc[0]] = {
      label: cproc[0],
      value: cproc[1]
    }
  end
  Usagewatch.uw_memtop.each do |mproc|
    memProc[mproc[0]] = {
      label: mproc[0],
      value: mproc[1]
    }
  end
  send_event('memProc', items: memProc.values )
  send_event('cpuProc', items: cpuProc.values )
end
