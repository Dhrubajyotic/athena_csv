require 'csv'

module AthenaCsv; class Output;

  attr_reader :query, :file_path

  def initialize(query, file_path)
    @query = query
    @file_path = file_path
  end

  def query_results
    @query_result_rows ||= Client.new.run(query)
  end

  def values(row)
	row.data.map {|cell| cell.var_char_value}
  end

  def generate_csv
    CSV.open(file_path, "wb") do |csv|
      query_results.each do |row|
        csv << values(row)
      end
    end
  end

end; end
