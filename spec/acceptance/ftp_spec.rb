require "acceptance_helper"


resource "数据源 FTP" do
  require 'net/ftp'

  Object.const_set("FtpController", ApplicationController)  

	Settings.ftp && Settings.ftp.each do |item|
		_info = item[1]
	
		"FtpController".constantize.class_eval do 
			# 获得body数据
			define_method "#{item[0].downcase.tr_s("::", "_")}" do 
				# 使用def 会在 对应 ApplicationController 中寻找 _info
				today = Time.zone.now.to_date
		    today_string = to_date_string today # today.strftime('%Y%m%d')
		    day_to_fetch = @day_to_fetch || 1
		    last_day_string = to_date_string(today - day_to_fetch)

		    # @last_report_time = Time.zone.parse(time_string) 
		    p "+===========  start connect  ==============="
		    connect! unless @connection
		    p "+===========  connect success  ==============="
		    @connection.chdir @remote_dir.encode('gbk')
		    
		    file_arr = []
		    file_infos = []
		    (0..day_to_fetch).each do |index|
		      file_arr.concat @connection.nlst(ftpfile_format(today-index)) rescue []
		    end
		    file_arr.each do |filename|
		      report_time_string = get_report_time_string filename
		      filename = filename.encode! 'utf-8', 'gb2312', {:invalid => :replace}
		      file_infos << [report_time_string, filename]
		      #  文件名的时间, 转码后文件名
		    end
		    p "+===========  file_info   ==============="
		    p file_infos.last
		    file_infos = file_infos.sort_by { |k, v| k }
		    # @is_process = false
		    p "+===========  file_info after sort_by  ==============="
		    p _filename = file_infos.last[1]

		    @connection.getbinaryfile(_filename)
		    _file = File.open(_filename)

		    _contents = []
		    File.foreach(_file, encoding: @file_encoding) do |line|
		    	line = line.encode('utf-8', :invalid => :replace)
	        p line = line.strip
	         _contents += [line] unless line.blank?
	    	end
	    	File.delete(_file)
		    
		    close!
		    render :json => {contents: _contents}
		 	end

		 	define_method "initialize" do 
		    _info.each do |k, v|
		      instance_variable_set "@#{k}", v
		    end
		    @process_file_infos = []
		    # @process_result_info = { :start_time => Time.now.to_f }
		  end

			define_method "get_report_time_string" do |filename|
				_encode = /split\((.*)\)\[(.*)\]/.match(_info["get_report_time_string"])
		    report_time_string = filename.split(Regexp.new _encode[1][1..-2])[_encode[2].to_i]
		  end

		  # define_method "ftpfile_format" do |day|
		  #   _info["filename"].tr_s("#\{}", to_date_string(day))
		  # end

			define_method "connect!" do
			  @connection = Net::FTP.new
			  @connection.connect(@server, @port)
			  @connection.passive = @passive || false
			  @connection.login(@user, @password)
			end

			define_method "close!" do
			  @connection.close if @connection
			  @connection = nil
			end

			define_method "to_date_string" do |datetime|
		    date_string = datetime.strftime('%Y%m%d')
		  end

		  define_method "to_datetime_string" do |report_time|
		    report_time.strftime('%Y%m%d%H')
		  end

		 #  define_method "process" do
				
				
			# end
	  end

		# 生成文档
		get item[0].downcase.tr_s("::", "_") do

			item[1].each {|value, key| parameter value, key }

			# parameter "周期", "#{_info["describe"]["period"]}"
			# parameter "工程", "#{_info["describe"]["project"]}"
			# parameter "备注", "#{_info["describe"]["remark"]}"
			

			example _info["title"] do 
	    	do_request
	    	puts  response_body
				expect(status).to eq 200
	    end

		end

end

end


	# def initialize
	# 	_info = item[0]
 #    _info.each do |k, v|
 #      instance_variable_set "@#{k}", v
 #    end
 #    @process_file_infos = []
 #    # @process_result_info = { :start_time => Time.now.to_f }
 #  end

	# def get_report_time_string filename
 #    report_time_string = filename.send(_info["get_report_time_string"])
 #  end

 #  def ftpfile_format day
 #    _info["filename"].tr_s("\#\{\}", to_date_string(day))
 #  end

	# def connect!
	#   @connection = Net::FTP.new
	#   @connection.connect(@server, @port)
	#   @connection.passive = @passive || false
	#   @connection.login(@user, @password)
	# end

	# def close!
	#   @connection.close if @connection
	#   @connection = nil
	# end

	# def to_date_string datetime
 #    date_string = datetime.strftime('%Y%m%d')
 #  end

 #  def to_datetime_string report_time
 #    report_time.strftime('%Y%m%d%H')
 #  end

 #  def process
		
	# 	today = Time.zone.now.to_date
 #    today_string = to_date_string today # today.strftime('%Y%m%d')
 #    day_to_fetch = @day_to_fetch || 1
 #    last_day_string = to_date_string(today - day_to_fetch)

 #    @last_report_time = Time.zone.parse(time_string) 
 #    p "+===========  start connect  ==============="
 #    connect! unless @connection
 #    p "+===========  connect success  ==============="
 #    @connection.chdir @remote_dir
    
 #    file_arr = []
 #    file_infos = []
 #    (0..day_to_fetch).each do |index|
 #      file_arr.concat @connection.nlst(ftpfile_format(today-index)) rescue []
 #    end
 #    file_arr.each do |filename|
 #      report_time_string = get_report_time_string filename
 #      filename = filename.encode! 'utf-8', 'gb2312', {:invalid => :replace}
 #      file_infos << [report_time_string, filename]
 #      #  文件名的时间, 转码后文件名
 #    end
 #    p "+===========  file_info   ==============="
 #    p file_infos
 #    file_infos = file_infos.sort_by { |k, v| k }
 #    # @is_process = false
 #    p "+===========  file_info after sort_by  ==============="
 #    p file_infos
 #    close!
	# end




    # puts "files is :#{file_infos}"
    # exception = {}
    # file_infos.each do |report_time_string, filename|
      # @report_time = Time.zone.parse report_time_string
      # @report_time_string = report_time_string
      # if @report_time > @last_report_time && @report_time <= Time.zone.now
        # @is_process = true
        # puts "#{DateTime.now}: process #{@redis_key} report file:#{filename}"

        # FileUtils.makedirs(@local_dir) unless File.exist?(@local_dir)
        # file_local_dir = File.join @local_dir, to_date_string(@report_time)
        # FileUtils.makedirs(file_local_dir) unless File.exist?(file_local_dir)
        # local_file = File.join file_local_dir, filename
        # connect! unless @connection
        # @connection.chdir @remote_dir
        # filename = filename.encode('gbk')
        # begin
        #   Timeout.timeout(200) do
        #     # @connection.getbinaryfile(filename, local_file)  
            	###  复制远程 到 本地
        #     # @connection.delete(filename) if @file_delete
        #   end
        # rescue Exception => e
        #   exception[filename] = e
        #   close!
        #   next
        # end
        # close!
        # begin
        #    parse local_file  
        #   @process_file_infos << filename

        #   $redis.set @redis_last_report_time_key, report_time_string
        # rescue Redis::BaseConnectionError => error
        #   puts "#{error}, retrying in 1s"
        #   sleep 1
        #   retry
         

        # end
      # end

    # end

    # begin
    #   file_infos.clear
    #   @process_result_info["exception"] = exception.to_json
    #   @process_result_info["file_list"] = @process_file_infos.to_json

    #   after_process if respond_to?(:after_process, true)
      
    #   close!
    # rescue Redis::BaseConnectionError => error
    #   puts "#{error}, retrying in 1s"
    #   sleep 1
    #   retry
    # end
     # p "+===========  process_file_infos  ==============="
     # p @process_file_infos
  # end