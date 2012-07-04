require File.join(File.dirname(__FILE__), 'requester')
require 'spreadsheet'
require 'yaml'
require 'yajl'

#Load HasOffers config details
@config = YAML.load_file("config.yaml")
@hasoffers_api_url = @config["config"]["api_url"]
@network_id = @config["config"]["network_id"]
@network_token = @config["config"]["network_token"]

#Create xls result file
@result = Spreadsheet::Workbook.new
@sheet1 = @result.create_worksheet
@sheet1.name = 'Payout and Conversions Comparison between AMS and HasOffers application'
@sheet1.row(0).concat %w{TranasctionID AMS_SUBID SSI_HO_TIME SP_HO_TIME SP_HO_STATUS}

row_counter = 1

#Read xls file with information from SP database about landing pages
Spreadsheet.open('ssi.xls') do |book|
  book.worksheet('Sheet1').each do |row|
    break if row[0].nil?
      next if row[0] == "transaction_id"
        response = Requester.make_request(
        @hasoffers_api_url,
        {
          "Format" => "json",
          "Service" => "HasOffers",
          "Version" => "2",
          "NetworkId" => "#{@network_id}",
          "NetworkToken" => "#{@network_token}",
          "Target" => "Report",
          "Method" => "getConversions",
          "fields[Stat.affiliate_info1]" => "Stat.affiliate_info1",
          "fields[Stat.date]" => "Stat.date",
          "fields[Stat.status]" => "Stat.status",
          "filters[Stat.ad_id][conditional]" => "EQUAL_TO",
          "filters[Stat.ad_id][values][0]" => row[0].to_i
        },
        :get
      )

      json = StringIO.new("#{response}")
      parser = Yajl::Parser.new
      hash = parser.parse(json)
      puts response
      subid = hash["response"]["data"]["data"][0]["Stat"]["affiliate_info1"]
      date = hash["response"]["data"]["data"][0]["Stat"]["date"]
      status = hash["response"]["data"]["data"][0]["Stat"]["status"]
      excel_row = @sheet1.row(row_counter)
      excel_row[0] = row[0]
      excel_row[1] = subid
      excel_row[2] = row[1]
      excel_row[3] = date
      excel_row[4] = status
      row_counter += 1
  end
end

@result.write 'result.xls'
