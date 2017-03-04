#!/usr/bin/env ruby

require_relative '../lib/subnet_scanner.rb'

ip_address, subnet_mask, verbose = parse_command_line_arguments

if ip_address == nil || subnet_mask == nil
	interface = get_network_info

	ip_address = ip_address != nil ? ip_address : interface.addr.ip_address
	subnet_mask = subnet_mask != nil ? subnet_mask : interface.netmask.ip_address
end

range = calculate_network_range(ip_address, subnet_mask)
active_ips = scan_range(range, true)
write_to_file(active_ips)