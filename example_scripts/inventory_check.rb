# example script to generate a report on the current state of HP SUM inventory checks

printf "%-20s %-26s %-26s %-26s\n", "Name", "Last chef-client run", "Last inventory", "Interval"
nodes.all do |n|
  if n['ohai_time'].nil?
    checkin = '---'
  else
    checkin = Time.at(n['ohai_time'])
  end
  if n['hpsum'].nil? || n['hpsum']['inventory'].nil?
    lastcheck = '---'
    interval = '---'
  else
    lastcheck = n['hpsum']['inventory']['lastcheck'] || '---'
    interval = n['hpsum']['inventory']['interval'] || '---'
  end
   printf "%-20s %-26s %-26s %-26s\n", n.name, checkin, lastcheck, interval
end
