class Ftp 
	require 'net/ftp'
	def self.aaa
		FileUtils.rm_r(Dir.glob("#{Rails.root}/doc/*"))
		Settings.ftp.each do |key, settings|
	  	Ftp.new("ftp", key, settings).create_docs
	  end
	  p "+===========   start copy to public ==============="
	  FileUtils.rm_r("#{Rails.root}/public/doc")
	  p FileUtils.cp_r("#{Rails.root}/doc", "#{Rails.root}/public/doc/", remove_destination: true)
	end
	def initialize resource="ftp", key, settings
		@resource = resource
    @item_name = key
    @settings = settings
    settings.each do |k, v|
      instance_variable_set "@#{k}", v
    end
    @local_dir = "#{Rails.root}/doc/api/#{resource}/" #{}"#{Rails.root}/doc/api/#{resource}/#{@title}/"
  end

	def get_return
		# 取昨天数据
		_day = Time.zone.now.to_date
    connect! unless @connection
    p "+===========   start remote_dir  ==============="
      ####!!!!  remote_dir_encode
   	p "+===========   success remote_dir  ==============="
   	p "+===========   success remote_dir  ==============="
   	p "#{ftpfile_format( _day)}"
    file_arr = []
    # until file_arr.any?
    	_day -= 1
    	p "============ ftpfile_format( _day)  ====="
    	p "#{ftpfile_format( _day)}"
    	p file_arr = @connection.nlst(ftpfile_format( _day)).last(30) 
    # end
    p "+===========   file_arr  ==============="
    p file_arr
    _content = []
    file_arr.each do |filename|
    	connect! unless @connection
    	FileUtils.makedirs(@local_dir) unless File.exist?(@local_dir)

    	local_file = File.join(@local_dir, filename)
    	@connection.getbinaryfile(filename, local_file)
			 p "+===========   start copy  ==============="
    	_content += [parse(local_file, filename)]
    	p "+===========   finish copy  ==============="
    # rescue
    # 	connect!
    # 	redo
    	close!
    end
    # close!
    _content
    p "+===========   _content  ==============="
    # 数组每一项 输出为1行
    p _content
 	end

 	def parse local_file, filename
 		# 链接 "<a link href=\"#{Settings.root_url}/doc/api/#{@resource}/#{filename}\">#{filename}</a>"
 		# 图片 "<img src="#{Settings.root_url}/doc/api/#{@resource}/#{filename}" />"
 		# 文件路径 "#{Rails.root}/public//doc/api/#{@resource}/#{filename}"
 		return ["<a link href=\"#{Settings.root_url}/doc/api/#{@resource}/#{filename}\">#{filename}</a>",
 						"<img src=\"#{Settings.root_url}/doc/api/#{@resource}/#{filename}\" />"] unless local_file.include?('.txt')	
 		_text = []
 		File.foreach(local_file, encoding: @file_encoding) do |line|
    	line = line.encode('utf-8', :invalid => :replace)
      line = line.strip
       _text += [line] unless line.blank?
  	end
  	_text
 	end

  def ftpfile_format day
    @filename.gsub('#{date}', Time.now.to_date.strftime('%Y%m%d'))
  end

	def connect!
		p "+===========  start connect  ==============="
	  @connection = Net::FTP.new
	  @connection.connect(@server, @port)
	  @connection.passive = @passive || false
	  @connection.login(@user, @password)
	  p "+===========  connect success  ==============="
	  @connection.chdir @remote_dir.encode('gbk')
	end

	def close!
	  @connection.close if @connection
	  @connection = nil
	  "+===========  close connect  ==============="
	end

	def create_docs
  	_content = get_return
  	## 翻译
  	_parameter_json = @settings.map do |key, value| 
  		{
  			# "require": true,
	      # "scope": "appointment",
	      "name": "#{key}",
	      "description": "#{value}"
  		}
  	end
  	_parameter_html = @settings.map {|key, value| 
	  	"<tr>
	  		<td><span class=\"name\">#{key}</span></td>
	      <td><span class=\"description\">#{value}</span></td>
	    </tr>"}.join
	  # _body_html = _content.map { |e|   }
	  _html_file = File.join @local_dir, "#{@title}.html"
		_html_file = File.new(_html_file, "w")
		_json_file = File.join @local_dir, "#{@title}.json"
		_json_file = File.new(_json_file, "w")
  	_json_file.write(
	  	{
			  "resource": "#{@resource}",
			  "route": "appointments",
			  "description": "#{@title}",
			  "explanation": "null",
			  "parameters": "#{_parameter_json}",
			  "requests": [
			    {
			      "response_body": _content,
			      "response_content_type": "application/json; charset=utf-8",
			    }
			  ]
			})
  	_json_file.close
  	_html_file.write("
		  		<!DOCTYPE html>
		<html>
		  <head>
		    <title>#{@resource}</title>
		    <meta charset=\"utf-8\">
		    <style>
		      
		body {
		  font-family: Helvetica,Arial,sans-serif;
		  font-size: 13px;
		  font-weight: normal;
		  line-height: 18px;
		  color: #404040;
		}

		.container {
		  width: 940px;
		  margin-left: auto;
		  margin-right: auto;
		  zoom: 1;
		}

		pre {
		  background-color: #f5f5f5;
		  display: block;
		  padding: 8.5px;
		  margin: 0 0 18px;
		  line-height: 18px;
		  font-size: 12px;
		  border: 1px solid #ccc;
		  border: 1px solid rgba(0, 0, 0, 0.15);
		  -webkit-border-radius: 3px;
		  -moz-border-radius: 3px;
		  border-radius: 3px;
		  white-space: pre;
		  white-space: pre-wrap;
		  word-wrap: break-word;
		}

		td.required .name:after {
		  float: right;
		  content: \"required\";
		  font-weight: normal;
		  color: #F08080;
		}

		a{
		  color: #0069d6;
		  text-decoration: none;
		  line-height: inherit;
		  font-weight: inherit;
		}

		h1, h2, h3, h4, h5, h6 {
		  font-weight: bold;
		  color: #404040;
		}

		h1 {
		  margin-bottom: 18px;
		  font-size: 30px;
		  line-height: 36px;
		}
		h2 {
		  font-size: 24px;
		  line-height: 36px;
		}
		h3{
		  font-size: 18px;
		  line-height: 36px;
		}
		h4 {
		  font-size: 16px;
		  line-height: 36px;
		}

		table{
		  width: 100%;
		  margin-bottom: 18px;
		  padding: 0;
		  border-collapse: separate;
		  font-size: 13px;
		  -webkit-border-radius: 4px;
		  -moz-border-radius: 4px;
		  border-radius: 4px;
		  border-spacing: 0;
		  border: 1px solid #ddd;
		}

		table th {
		  padding-top: 9px;
		  font-weight: bold;
		  vertical-align: middle;
		  border-bottom: 1px solid #ddd;
		}
		table th+th, table td+td {
		  border-left: 1px solid #ddd;
		}
		table th, table td {
		  padding: 10px 10px 9px;
		  line-height: 18px;
		  text-align: left;
		}

		    </style>
		  </head>
		  <body>
		    <div class=\"container\">
		      <h1>#{@resource}</h1>

		      <div class=\"article\">
		        <h2>#{@title}</h2>

		          <h3>Parameters</h3>
		          <table class=\"parameters table table-striped table-bordered table-condensed\">
		            <thead>
		              <tr>
		                <th>Name</th>
		                <th>Description</th>
		              </tr>
		            </thead>
		            <tbody>
		              #{_parameter_html}
		            </tbody>
		          </table>
		          <h3>Response</h3>
		             	<h4>Body</h4>
		              <pre class=\"response body\">#{_content.join('<br/>')}</pre>
		      </div>
		    </div>
		  </body>
		</html>"
				)
  	_html_file.close
  end

  
end

