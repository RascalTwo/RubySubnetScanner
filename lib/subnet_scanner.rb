require 'ipaddr'
require 'optparse'
require 'socket'
require 'net/ping'

def parse_command_line_arguments
	ip_address = nil
	subnet_mask = nil
	
	auto = false
	verbose = false
	
	OptionParser.new do |opts|
		opts.banner = 'Usage: subnet_scanner.rb [IP Address] [Subnet Mask]'
	
		opts.on('-i', '--ip-address ip_address', "IP Address") do |arg|
			ip_address = arg
		end
	
		opts.on('-s', '--subnet-mask subnet_mask', "Subnet Mask") do |arg|
			subnet_mask = arg
		end

		opts.on('-a', '--auto', "Automatically find IP Address and Subnet Mask") do
			auto = true
		end

		opts.on('-v', '--verbose', "Verbosely log the status") do
			verbose = true
		end
	end.parse!

	if auto
		return nil, nil, verbose
	end
	
	ip_address = ip_address ? ip_address : ARGV[0]
	subnet_mask = subnet_mask ? subnet_mask : ARGV[1]

	return ip_address, subnet_mask, verbose
end



def get_network_info
	Socket.getifaddrs.select do |socket|
		socket.name != 'lo' && socket.addr.ip? && socket.netmask.ip? && socket.addr.ipv4?
	end.compact[0]
end

def calculate_network_range(ip, mask)
	ip_range = IPAddr.new("#{ip}/#{mask}").to_range.map do |ip_object|
		ip_object.to_s
	end
end

def scan_range(ip_range, verbose)
	return ip_range.select do |ip_address|
		active = Net::Ping::External.new(ip_address).ping?
		if verbose
			puts "\t#{ip_address} #{active}"
		end
		active
	end
end

def write_to_file(active_ips)
	puts "Active", active_ips
	File.open('active_ips.txt', 'w') do |file|
		file.puts active_ips.join("\n")
	end
end
