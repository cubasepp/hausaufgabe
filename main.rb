require 'optparse'
require './api'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: main.rb [options] <API-Key> <voucher_id> <id>
                 <first_name> <last_name>'

  opts.on('-o', '--overview', 'List all cards') do |v|
    options[:overview] = true
  end
  opts.on('-t', '--transactions', 'List all cards with transactions') do |v|
    options[:transactions] = true
  end
  opts.on('-u', '--update', 'Update user first last name. ') do |v|
    options[:update] = true
  end
end.parse!

exit(1) if ARGV.empty?

puts "Start with API-Key #{ARGV[0]}"
data = GivveApiAccess.new(ARGV[0])

if options[:overview]
  puts "Get all cards"
  data.get_vouchers().each do |voucher|
    info =  data.get_vouchers(voucher['id'])
    puts "Cardnumber: " + info['number'] + \
         " Name: " + voucher['owner']['name'] + \
         " Balance: " + info['balance']['cents'].to_s + \
                        info['balance']['currency']

    if options[:transactions]
      transactions = data.get_vouchers_transactions(voucher['id'])
      puts "Found #{transactions.length} transactions" if transactions.length > 0
      transactions.each do |transaction|
        puts "\t Description" + transaction['description']
        puts "\t\t Amount: " + transaction['amount']['cents'].to_s + \
             transaction['amount']['currency']
      end
    end
  end
end
if options[:update]
  exit(1) if ARGV.length != 5
  puts data.update_customer(ARGV[1], ARGV[2], ARGV[3], ARGV[4])
end
