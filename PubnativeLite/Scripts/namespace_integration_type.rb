base_dir = File.expand_path(ARGV.fetch(0))
header_path = File.join(base_dir, 'Core', 'Public', 'NGSDK.h')
header = File.read(header_path)
declaration = %r{
  typedef\s+NS_ENUM\s*\(\s*NSInteger\s*,\s*SDKIntegrationType\s*\)\s*\{
  \s*SDKIntegrationTypeNGSDK\s*=\s*0\s*,
  \s*SDKIntegrationTypeSmaato\s*=\s*1\s*
  \}\s*;
}x
abort 'Unexpected SDKIntegrationType declaration in NGSDK.h' unless header.match?(declaration)

replacement = <<~OBJC.chomp
  typedef NS_ENUM(NSInteger, NGSDKSDKIntegrationType) {
      SDKIntegrationTypeNGSDK NS_SWIFT_NAME(NGSDK) = 0,
      SDKIntegrationTypeSmaato NS_SWIFT_NAME(smaato) = 1
  } NS_SWIFT_NAME(SDKIntegrationType);
  typedef NGSDKSDKIntegrationType SDKIntegrationType;
OBJC

Dir[File.join(base_dir, '**', '*.{h,m,mm}')].each do |path|
  next if path.split(File::SEPARATOR).any? { |part| part == 'Pods' || part.start_with?('OMSDK') }

  original = File.read(path)
  content = path == header_path ? original.sub(declaration, '__NGSDK_INTEGRATION_TYPE__') : original
  content = content.gsub(/\bSDKIntegrationType\b/, 'NGSDKSDKIntegrationType')
  content = content.sub('__NGSDK_INTEGRATION_TYPE__', replacement) if path == header_path
  File.write(path, content) unless content == original
end
