require 'xcodeproj'

PROJECT_PATH = File.expand_path("../HyBid.xcodeproj", __dir__)
NAMESPACE = ARGV[0] || "NGSDK"
BASE_FOLDER = "PubnativeLite"
TARGET_NAME = "HyBid"
NEW_MODULE_NAME = NAMESPACE

puts "🔧 Using NAMESPACE: #{NAMESPACE}"
puts "📂 Opening Xcode project..."

project = Xcodeproj::Project.open(PROJECT_PATH)

# Update file references in Xcode project
puts "🔄 Updating file references..."
project.files.each do |file|
  next unless file.path
  next unless file.real_path  # Ensure real_path exists

  real_path = Pathname.new(file.real_path)

  # Skip excluded directories & file types (allow .js so hybidscaling.js → ngsdkscaling.js path is updated)
  if real_path.to_s.match?(/\/(Pods|OMSDK|PubnativeLiteDemo|PubnativeLiteTests|SmaatoApplovin|SmaatoSDK|SmaatoUnifiedBidding)\//) ||
     real_path.extname == ".xcconfig" || real_path.extname == ".xcprivacy" ||
     real_path.to_s.include?("Info.plist") || real_path.to_s.include?(".xcframework") || real_path.extname == ".tbd" || real_path.extname == ".framework"
    puts "⚠️ Skipped (Excluded File or Directory): #{real_path}"
    next
  end

  # ** Ensure the path is relative to "PubnativeLite" without duplicating it **
  relative_path = file.path.sub(/^.*?#{BASE_FOLDER}\//, "#{BASE_FOLDER}/")

  # ** Generate new file path applying the same renaming rules as namespace.sh **
  file_name = File.basename(relative_path)
  new_file_name = file_name
    .gsub("HyBid", NAMESPACE)
    .gsub("PNLite", NAMESPACE)
    .gsub("hybid", NAMESPACE.downcase)

  if file_name != new_file_name
    new_file_path = File.join(File.dirname(relative_path), new_file_name)

    # ** Remove unnecessary "./" if present **
    new_file_path.gsub!(/^\.\//, "")

    # ** Ensure the final path does not contain duplicate "PubnativeLite" **
    new_file_path.gsub!(/#{BASE_FOLDER}\/#{BASE_FOLDER}/, BASE_FOLDER)

    # ** Update file reference in `.xcodeproj` (path + name if explicitly set) **
    puts "🔄 Renaming #{file.path} → #{new_file_path}"
    file.path = new_file_path
    file.name = new_file_name if file.name
  end
end

# Update build settings for SDK target only (PRODUCT_NAME, PRODUCT_MODULE_NAME, PRODUCT_BUNDLE_IDENTIFIER)
# So dSYM Info.plist and binaries get net.nextgen.NGSDK. Demo and Tests targets are left unchanged.
# When building NGSDK: drop OMSDK_Pubnativenet link and use only OMSDK_Smaato (framework search path + frameworks).
puts "🛠 Updating build settings (SDK target only)..."
BUNDLE_ID_SDK = "net.nextgen.#{NAMESPACE}"

project.targets.each do |target|
  next unless target.name == TARGET_NAME

  target.build_configurations.each do |config|
    config.build_settings["PRODUCT_MODULE_NAME"] = NAMESPACE
    config.build_settings["PRODUCT_NAME"] = NAMESPACE
    config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = BUNDLE_ID_SDK

    # NGSDK uses only OMSDK_Smaato; point framework search at Smaato and drop Pubnativenet from link.
    paths = config.build_settings["FRAMEWORK_SEARCH_PATHS"]
    if paths.is_a?(Array)
      config.build_settings["FRAMEWORK_SEARCH_PATHS"] = paths.map do |p|
        p.to_s.include?("OMSDK-1.6.3") ? p.to_s.gsub("OMSDK-1.6.3", "OMSDK-Smaato-1.6.3") : p
      end
    end
  end

  # Remove OMSDK_Pubnativenet from SDK target link (so output xcframework has no OMSDK_Pubnativenet dependency)
  phase = target.frameworks_build_phase
  to_remove = phase.files.select { |bf| bf.file_ref && bf.file_ref.path.to_s.include?("OMSDK_Pubnativenet") }
  to_remove.each do |bf|
    phase.remove_build_file(bf)
    puts "✅ Removed OMSDK_Pubnativenet from SDK target link (NGSDK uses OMSDK_Smaato only)"
  end
end

project.save
puts "🚀 Xcode project successfully updated with new module and product name!"

# Fix Imports in Objective-C Headers **
puts "🔄 Fixing Import Statements..."
Dir.glob("#{BASE_FOLDER}/PubnativeLite/**/*.{h,m,mm}").each do |file|
  text = File.read(file)

  # Fix old imports
  text.gsub!(
    /#if __has_include\(<HyBid\/HyBid-Swift.h>\)/,
    "#if __has_include(<#{NAMESPACE}/#{NAMESPACE}-Swift.h>)"
  )
  text.gsub!(
    /#import "HyBid-Swift.h"/,
    "#import \"#{NAMESPACE}-Swift.h\""
  )

  File.write(file, text)
end

puts "✅ Namespace update completed! Reopen Xcode and build the project."
