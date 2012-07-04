require File.join(File.dirname(__FILE__), 'exasol')
require 'spreadsheet'
require 'yaml'

config = YAML.load_file("config.yaml")
@login = config["config"]["login"]
@password = config["config"]["password"]

#Create result file
result_excel = Spreadsheet::Workbook.new
sheet1 = result_excel.create_worksheet
sheet1.name = 'Result'
sheet1.row(0).concat %w{TranasctionID AMS_SUBID SSI_HO_TIME SP_HO_TIME SP_HO_STATUS AMS_TOC_TIME AMS_TAR_TIME}

row_counter = 1

@connection = Exasol.new(@login, @password)
@connection.connect

Spreadsheet.open('result.xls') do |book|
  book.worksheet('Payout and Conversions Comparison between AMS and HasOffers application').each do |row|
    next if row[1] == "AMS_SUBID"
    subid = row[1].insert(8, '-').insert(13, '-').insert(18, '-').insert(23, '-')

    puts subid

    query_1 = "select toc.created_at, tar.created_at from ids.track_affiliate_responses as tar join ids.track_offer_clicks as toc on tar.subid = toc.subid where toc.affiliate_network_id = 52 and toc.created_at > '2012-06-01' and toc.subid = '#{subid}'"
    @connection.do_query(query_1)
    result_1 = @connection.print_result_array
    puts result_1

        excel_row = sheet1.row(row_counter)
        excel_row[0] = row[0]
        excel_row[1] = row[1]
        excel_row[2] = row[2]
        excel_row[3] = row[3]
        excel_row[4] = row[4]
        excel_row[5] = result_1[0][0]
        excel_row[6] = result_1[0][1]

      row_counter += 1

  end

end

@connection.disconnect
result_excel.write 'final_result.xls'
