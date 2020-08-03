#!/usr/bin/ruby -w
require 'net/https'

SIZE = 49_999_900
OUT_FILE = 'output.rb'.freeze

WORDS = if File.readable?('wordlist') && File.file?('wordlist')
	puts ":: Reading locally stored wordlist"
	IO.read('wordlist')
else
	puts ":: Downloading and saving words to 'wordlist'"
	Net::HTTP.get(URI('https://raw.githubusercontent.com/Souravgoswami/wordlists/master/all_words'))
		.tap { |x|  IO.write('wordlist', x) }
end.lines.each { |x| x.tap(&:downcase!).tap(&:strip!) }.tap(&:uniq!).freeze

output, i = "time = Time.now\n", -1
concat = %<puts "Time taken: \#{Time.now - time}s\n">
size = SIZE - 1 - concat.bytesize

until output.bytesize >= size
	output << %<puts "#{WORDS[(i += 1) % WORDS.size]}"\n>
end

output.concat(concat)

bs = output.bytesize
bytes_count = if bs >= 10 ** 9
	"(#{bs.fdiv(10 ** 9).round(2)} GB) "
elsif bs >= 10 ** 6
	"(#{bs.fdiv(10 ** 6).round(2)} MB) "
elsif bs >= 10 ** 3
	"(#{bs.fdiv(10 ** 3).round(2)} KB) "
else
	""
end

puts ":: Writing #{bs.to_s.reverse.gsub(/\d{1,3}/).to_a.join(?,).reverse} bytes #{bytes_count}to #{OUT_FILE}"

IO.write(OUT_FILE, output)
puts "\e[38;2;255;80;80m:: Please don't execute such big file...\e[0m" if bs > 10 ** 7
