def get_command_line_argument
    if ARGV.empty?
        puts "Usage: ruby lookup.rb <domain>"
        exit
      end
      ARGV.first
    end
    
    domain = get_command_line_argument
    dns_raw = File.readlines("zone")
    dns_records = {}
    lookup_chain = []
    
    def parse_dns(rawfile)
        records = {}
        rawfile.reject { |line| line.empty? }.
          map { |line| line.split(",") }.
          reject { |record| record.length < 3 }.
          map { |record_array| record_array.map { |data_in_record| data_in_record.strip } }.
          each { |data| records[data[1]] = { :type => data[0], :value => data[2] } }
        records
    end   
    
    def resolve(dns_records, lookup_chain, domain)
        if !dns_records.keys.include? domain
          puts "record not found for #{domain}"
          lookup_chain
        elsif dns_records[domain][:type] == "A"
          lookup_chain.push(dns_records[domain][:value])
          lookup_chain
        elsif dns_records[domain][:type] == "CNAME"
          lookup_chain.push(dns_records[domain][:value])
          resolve(dns_records, lookup_chain, dns_records[domain][:value])
        end
      end
    
    dns_records = parse_dns(dns_raw)
    lookup_chain = [domain]
    lookup_chain = resolve(dns_records, lookup_chain, domain)
    puts lookup_chain.join(" => ")