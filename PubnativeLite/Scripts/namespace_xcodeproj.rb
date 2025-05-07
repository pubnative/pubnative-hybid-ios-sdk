require 'xcodeproj'
require 'pathname'

PROJECT_PATH = "PubnativeLite/HyBid.xcodeproj"
NAMESPACE = "Smaato"
BASE_FOLDER = "PubnativeLite"
TARGET_NAME = "HyBid"
NEW_MODULE_NAME = "#{NAMESPACE}_#{TARGET_NAME}"

puts "📂 Opening Xcode project..."
project = Xcodeproj::Project.open(PROJECT_PATH)

puts "🔄 Updating file references in Xcode project..."
project.files.each do |file|
  next unless file.path # Skip files without a path
  next unless file.real_path # Ensure `real_path` exists

  real_path = Pathname.new(file.real_path)

  # Skip excluded directories & file types
  if real_path.to_s.match?(/\/(Pods|OMSDK|PubnativeLiteDemo|PubnativeLiteTests|SmaatoApplovin|SmaatoSDK|SmaatoUnifiedBidding)\//) ||
     real_path.extname == ".xcconfig" || real_path.extname == ".xcprivacy" ||
     real_path.to_s.include?("Info.plist") || real_path.to_s.include?(".xcframework") || real_path.extname == ".js" || real_path.extname == ".tbd" || real_path.extname == ".framework"
    puts "⚠️ Skipped (Excluded File or Directory): #{real_path}"
    next
  end

  # 🚨 Skip `.swift` files to prevent incorrect renaming
  if real_path.extname == ".swift"
    puts "⚠️ Skipped (Swift File): #{real_path}"
    next
  end

  # ** Ensure the path is relative to "PubnativeLite" without duplicating it **
  relative_path = file.path.sub(/^.*?#{BASE_FOLDER}\//, "#{BASE_FOLDER}/")

  # ** Generate new file path with the correct prefix **
  file_name = File.basename(relative_path)
  
  # Only rename if the file doesn't already have the namespace prefix
  unless file_name.start_with?("#{NAMESPACE}_")
    new_file_name = "#{NAMESPACE}_#{file_name}"
    new_file_path = File.join(File.dirname(relative_path), new_file_name)

    # ** Remove unnecessary "./" if present **
    new_file_path.gsub!(/^\.\//, "")

    # ** Ensure the final path does not contain duplicate "PubnativeLite" **
    new_file_path.gsub!(/#{BASE_FOLDER}\/#{BASE_FOLDER}/, BASE_FOLDER)

    # ** Update file reference in `.xcodeproj` **
    puts "🔄 Renaming #{file.path} → #{new_file_path}"
    file.path = new_file_path
  end
end

# Update Build Settings (Product Name, Module Name, Swift Header) **
puts "🛠 Updating Build Settings for target '#{TARGET_NAME}'..."
project.targets.each do |target|
  next unless target.name == TARGET_NAME

  target.build_configurations.each do |config|
    config.build_settings["PRODUCT_MODULE_NAME"] = NEW_MODULE_NAME
    config.build_settings["PRODUCT_NAME"] = NEW_MODULE_NAME
  end
end

# Save changes to `.xcodeproj` **
project.save
puts "🚀 Xcode project successfully updated with new module and product name!"

# Fix Imports in Objective-C Headers **
puts "🔄 Fixing Import Statements..."
Dir.glob("#{BASE_FOLDER}/**/*.{h,m,mm}").each do |file|
  text = File.read(file)

  # Fix old imports
  text.gsub!(
    /#if __has_include\(<HyBid\/HyBid-Swift.h>\)/,
    "#if __has_include(<Smaato_HyBid/Smaato_HyBid-Swift.h>)"
  )
  text.gsub!(
    /#import "HyBid-Swift.h"/,
    '#import "Smaato_HyBid-Swift.h"'
  )

  File.write(file, text)
end

puts "✅ Namespace update completed! Reopen Xcode and build the project."

