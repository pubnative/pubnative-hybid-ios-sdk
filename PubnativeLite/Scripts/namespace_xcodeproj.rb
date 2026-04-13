require 'xcodeproj'

PROJECT_PATH = "PubnativeLite/HyBid.xcodeproj"
NAMESPACE = ARGV[0] || "NGSDK"
TARGET_NAME = "HyBid"

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
     real_path.to_s.include?("Info.plist") || real_path.to_s.include?(".xcframework") ||
     real_path.extname == ".tbd" || real_path.extname == ".framework" ||
     file.path.include?('Pods_')  # Skip Pod framework references
    next
  end

  old_path = file.path
  new_path = old_path.gsub(/HyBid/, NAMESPACE).gsub(/PNLite/, NAMESPACE).gsub(/hybid/, 'ngsdk')
  
  if old_path != new_path
    file.path = new_path
    puts "✅ Updated: #{old_path} → #{new_path}"
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
puts "✅ Xcode project updated successfully!"
