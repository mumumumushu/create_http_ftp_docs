Rails.application.routes.draw do
  
  Settings.http && Settings.http.each do |item| 
  	get URI(item[1]["url"]).path, to: "http##{item[0].downcase.tr_s("::", "_")}" 
	end

  Settings.ftp && Settings.ftp.each do |item|
    get URI(item[0].downcase.tr_s("::", "_")), to: "ftp##{item[0].downcase.tr_s("::", "_")}"
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
