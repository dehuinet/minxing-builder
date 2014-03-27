require 'yaml'

root=ARGV.first
flavor_name=ARGV.last
if root.nil? then
	puts "need root path"
	return
end
flavors="#{root}/flavors/#{flavor_name}"
unless File.exist?(flavors) then
	puts "flavors :#{flavor_name}: not exist"
	return
end

system "cp -r  #{flavors}/*  #{root}/"

["zh-Hans.lproj","en.lproj"].each do|n|
	source_file="#{flavors}/config/#{n}/Strings.strings"
	dest_file="#{root}/EnterpriseMicroBlog/resources/config/#{n}/Strings.strings"
	puts source_file
	puts dest_file
	if File.exist source_file then
		dest_file_content=File.read dest_file
		File.read(source_file).split("\n").each do|k|
			if k=~/"(.+?)"(\s*)=(\s*)"(.+?)"/ then
				dest_file_content.gsub!(Regexp.new("^\""+$1+"\".+?\n"),k+"\n")
			end
		end
		File.open(dest_file, 'w') { |file| file.write(dest_file_content) }

	end

end

#modify PROVISIONING

config=YAML::load(File.read("#{root}/EnterpriseMicroBlog/resources/config/build.yaml"))
provision_key=config[:PROVISIONING]
provision_file="#{root}/EnterpriseMicroBlog/EnterpriseMicroBlog.xcodeproj/project.pbxproj"
provision_file_content=File.read(provision_file)
provision_file_content.gsub!(/PROVISIONING_PROFILE =.+?\n/,"PROVISIONING_PROFILE = \"#{provision_key}\";\n")
provision_file_content.gsub!(/"PROVISIONING_PROFILE\[.+?\n/,"\"PROVISIONING_PROFILE[sdk=iphoneos*]\" = \"#{provision_key}\";\n")
File.open(provision_file, 'w') { |file| file.write(provision_file_content) }