require "acceptance_helper"


resource "数据源 FTP" do
  require 'net/ftp'

  Object.const_set("FtpController", ApplicationController)  

	Settings.ftp && Settings.ftp.each do |item|
		_info = item[1]
	
		"FtpController".constantize.class_eval do 
			# 获得body数据
			define_method "#{item[0].downcase.tr_s("::", "_")}" do 
				_info.each do |k, v|
		      local_variable_set "_#{k}", v
		    end
				# 使用def 会在 对应 ApplicationController 中寻找 _info
				_day = Time.zone.now.to_date.strftime('%Y%m%d')
		  #   today_string = to_date_string today # today.strftime('%Y%m%d')
		    # day_to_fetch = 1 #@day_to_fetch || 1
		  #   last_day_string = to_date_string(today - day_to_fetch)

		    # @last_report_time = Time.zone.parse(time_string) 
		    p "+===========  start connect  ==============="
		    # connect! unless @connection
		    _connection = Net::FTP.new
			  _connection.connect(_server, _port)
			  _connection.passive = _passive || false  ## ?
			  _connection.login(_user, _password)
		    p "+===========  connect success  ==============="
		    _connection.chdir _remote_dir.encode('gbk')
		    
		    file_arr = []
		    file_infos = []

		    file_arr = _connection.nlst(ftpfile_format( _day, _info))
		    # file_arr = 


		    # (0..day_to_fetch).each do |index|
		    #   file_arr.concat _connection.nlst(ftpfile_format(today-index, _info)) rescue []
		    # end
		    file_arr.each do |filename|
		      report_time_string = get_report_time_string(filename, _info)
		      filename = filename.encode! 'utf-8', 'gb2312', {:invalid => :replace}
		      file_infos << [report_time_string, filename]
		      #  文件名的时间, 转码后文件名
		    end
		    p "+===========   file_info after sort_by   ==============="
		    p file_infos = file_infos.sort_by { |k, v| k }
		    # _is_process = false
		    p "+===========  _filename ==============="
		    p _filename = file_infos.last[1]

		    _connection.getbinaryfile(_filename)
		    _file = File.open(_filename)

		    _contents = []
		    File.foreach(_file, encoding: _file_encoding) do |line|
		    	line = line.encode('utf-8', :invalid => :replace)
	        p line = line.strip
	         _contents += [line] unless line.blank?
	    	end
	    	File.delete(_file)
		    
		    # close!
		    _connection.close if _connection
			  _connection = nil

		    render :json => {contents: _contents}
		    _info.each do |k, v|
		      local_instance_variable "_#{k}"
		    end
		 	end

		 	# define_method "initialize" do 
		  #   _info.each do |k, v|
		  #     instance_variable_set "@#{k}", v
		  #   end
		  #   # @process_file_infos = []
		  #   # @process_result_info = { :start_time => Time.now.to_f }
		  # end

			define_method "get_report_time_string" do |filename, info|
				_encode = /split\((.*)\)\[(.*)\]/.match(info["get_report_time_string"])
		    report_time_string = filename.split(Regexp.new _encode[1][1..-2])[_encode[2].to_i]
		  end

		  define_method "ftpfile_format" do |day, info|
		    info["filename"].tr_s('#{date}', to_date_string(day))
		  end

			# define_method "connect!" do
			#   @connection = Net::FTP.new
			#   @connection.connect(@server, @port)
			#   @connection.passive = @passive || false
			#   @connection.login(@user, @password)
			# end

			# define_method "close!" do
			#   @connection.close if @connection
			#   @connection = nil
			# end

			define_method "to_date_string" do |datetime|
		    date_string = datetime.strftime('%Y%m%d')
		  end





	  end

		# 生成文档
		get item[0].downcase.tr_s("::", "_") do

			item[1].each {|key, value| parameter key , value unless key == "describe"  }

			_info["describe"] && _info["describe"]["period"] && parameter("获取周期", "#{_info["describe"]["period"]}")
			_info["describe"] && _info["describe"]["project"] && parameter("工程"," #{_info["describe"]["project"]}")
			_info["describe"] && _info["describe"]["remark"] && parameter("备注", "#{_info["describe"]["remark"]}")

			example _info["title"] do 
	    	do_request
	    	puts  response_body
				expect(status).to eq 200
	    end

		end

	end

end

