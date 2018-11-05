require 'aws-sdk'

module AthenaCsv; class Client

  attr_reader :config

  def initialize
    @config = {
      dbname: AthenaCsv.config.dbname,
      user: AthenaCsv.config.user,
      password: AthenaCsv.config.password,
      host: AthenaCsv.config.host,
      region: 'us-east-1',
      output_location: 's3://aws-athena-query-results-333957572119-us-east-1',
	  s3_encryption: 'SSE_S3'
    }
	@client = athenaClient
	@result = []
  end

  def run(sql)
    query_exec_id = execute(sql)
	puts 'Execution started with Id: ' + query_exec_id
	begin
		query_exec_state = status(query_exec_id)
		puts query_exec_state
		sleep(3)
	end while query_exec_state == 'RUNNING'
	puts 'Execution completed -- fetching result started' 
	begin
		result, next_token = result_set(query_exec_id, next_token)
		@result.push(*result)
	end while next_token != nil
	puts "Total rows fetched as Result: #{@result.length}"
	return @result	
  end

  private

  def athenaClient
    Aws::Athena::Client.new(
		region: @config[:region],
		access_key_id: @config[:user],
		secret_access_key: @config[:password]
	)
  end
  
  def execute(sql)
	@client.start_query_execution({
		query_string: sql,
		#client_request_token: "IdempotencyToken",
		query_execution_context: {
			database: @config[:dbname],
		},
		result_configuration: { 
			output_location: @config[:output_location],
			encryption_configuration: {
				encryption_option: @config[:s3_encryption]
			},
		},
	}).query_execution_id
  end
  
  def status(execution_id)
	@client.get_query_execution({
	  query_execution_id: execution_id,
	}).query_execution.status.state	
  end
  
  def result_set(execution_id, next_token=nil)
	response = @client.get_query_results({
		query_execution_id: execution_id,
		next_token: next_token,
		max_results: 1000,
	})
	return response.result_set.rows, response.next_token
  end
end; end