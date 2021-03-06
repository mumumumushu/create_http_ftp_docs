require "acceptance_helper"

resource "数据源 HTTP" do
  require 'uri'
	require 'net/http'
	require 'net/https'
  Object.const_set("HttpController", ApplicationController)  

	Settings.http && Settings.http.each do |item|
		_info = item[1]
	
		"HttpController".constantize.class_eval do 
			# 获得body数据
			define_method "#{item[0].downcase.tr_s("::", "_")}" do 
				# 使用def 会在 对应 ApplicationController 中寻找 _info
				p URI::encode(_info["url"])
				p '-----'
			p 	url = URI(URI::parse(URI::encode(_info["url"])))
			p URI::encode(_info["url"])
				http = Net::HTTP.new(url.host, url.port)
				request = Net::HTTP::Get.new(url)
				# _info["params"].each{ |e| let(e[0].to_sym) { e[1]["value"] } } if _info["params"]

				_info["header"].each{ |e| request[e[0]] = e[1]} if _info["header"]
 
				response = http.request(request)
				render :json => response.read_body.force_encoding("utf-8")[0,2].eql?("{\"")  ? response.read_body.force_encoding('utf-8') : { message: "为爬取数据"}
		 	end
	  end

		# 生成文档
		get _info["url"] do
			_info["header"].each{ |key, value| header key, value} if _info["header"] 
			parameter "周期", "#{_info["describe"]["period"]}"
			parameter "工程", "#{_info["describe"]["project"]}"
			parameter "备注", "#{_info["describe"]["remark"]}"
			_info["params"].each{ |e| parameter e[0].to_sym, "#{e[1]}"  } if _info["params"]

			example _info["title"] do 
	    	do_request
	    	puts  response_body
				expect(status).to eq 200
	    end

		end
	end
end


