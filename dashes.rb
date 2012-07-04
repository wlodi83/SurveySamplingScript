#!/usr/bin/ruby
a = []
count = 0
File.readlines('transaction_id.txt').each do |l|
 a.push(l.match(/(\d)*$/)[0] + "\n")
 puts a
 count += 1
end
puts count
File.open('subids_with_dashes.txt','w') do |f|
f.write a.join('')
end
