require 'socket'
require 'usagewatch_ext'

hostname = "localhost"
ipaddrs = ["127.0.0.1"]
details = Hash.new({ value: 0 })
usw = Usagewatch
pointsHash = Hash.new({ value: 0 })

startArray = Array.new(10){ Hash.new({ y: 0, x: 0}) }

stats = Hash.new({
  duGig: startArray,
  duPct: startArray,
  cpu: startArray,
  memPct: startArray,
  sysload: startArray,
  rxMb: startArray,
  txMb: startArray
})

cpuProc = Hash.new({ value: 0 })
memProc = Hash.new({ value: 0 })
lastcpuProc = Hash.new({ value: 0 })
lastmemProc = Hash.new({ value: 0 })

def get_new_stat(statname)
  value = 0
  case statname
    when 'duGig'
      value = usw.uw_diskused
    when 'duPct'
      value = usw.uw_diskused_perc
    when 'cpu'
      value = usw.uw_cpuused
    when 'memPct'
      value = usw.uw_memused
    when 'sysload'
      value = usw.uw_load
    when 'rxMb'
      value = usw.uw_bandrx
    when 'txMb'
      value = usw.uw_bandtx
  end
  return value
end

SCHEDULER.every '2s', :first_in => 0 do |job|
  hostname = Socket.gethostname
  ipaddrs = Socket.ip_address_list
  details['name'] = {
    label: 'hostname',
    value: hostname
  }
  ipaddrs.each do |ip|
    ipstring = ip.ip_address
    details[ipstring] = {
      label: 'local ip',
      value: ipstring
    }
  end

  #graph-style data
  stats.each do | stat, stuff |
    stuff.shift
    stuff[:x] = stuff[:y]
    stuff[:y] = get_new_stat(stat)
    stuff << { x: stuff[:x], y: stuff[:y] }
    stats[stat] = stuff
    send_event( stat + "_graph", points: stuff )
  end

  send_event('hostdetaildata', { items: details.values })
  pointsHash.each do |stat|
    send_event( stat + "_gauge", value: pointsHash[stat] )
  end
  lastcpuProc = cpuProc
  lastmemProc = memProc
  cpuProc = Hash.new({ value: 0})
  memProc = Hash.new({ value: 0})
  usw.uw_cputop.each do |cproc|
    cpuProc[cproc[0]] = {
      label: cproc[0],
      value: cproc[1]
    }
  end
  usw.uw_memtop.each do |mproc|
    memProc[mproc[0]] = {
      label: mproc[0],
      value: mproc[1]
    }
  end
  send_event('memProc', items: memProc.values )
  send_event('cpuProc', items: cpuProc.values )
end
