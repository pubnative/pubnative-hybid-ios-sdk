#!/usr/bin/env ruby
# frozen_string_literal: true

# NGSDK namespace: keep only OMSDK Smaato integration in viewability.
# - Removes all OMSDK_Pubnativenet #if/#endif blocks (so Pubnative OMSDK is not compiled).
# - Replaces "if (HyBid) ... else if (Smaato) ..." with only the Smaato branch so viewability
#   always uses OMSDK_Smaato.
# - In main SDK file: sets default integration type to Smaato and setter to always use Smaato.
#
# Run from namespace.sh after content replacement (so class name may already be NGSDK).

BASE_DIR = File.expand_path(ARGV[0] || File.join(__dir__, '..', 'PubnativeLite'))
SDK_CLASS_PATTERN = /\[(HyBid|NGSDK)\s+getIntegrationType\]/

def viewability_file?(path)
  return false unless path.end_with?('.m')
  return true if path.include?('Viewability')
  return true if path.include?('OMIDAdSessionWrapper') || path.include?('OMIDVerificationScriptResourceWrapper')
  false
end

def main_sdk_file?(path)
  return false unless path.end_with?('.m')
  base = File.basename(path, '.m')
  base == 'HyBid' || base == 'NGSDK'
end

# Remove entire block from #if __has_include(<OMSDK_Pubnativenet/ to matching #endif
def remove_pubnative_blocks(content)
  content = content.force_encoding('UTF-8') unless content.encoding == Encoding::UTF_8
  content = content.encode(Encoding::UTF_8, invalid: :replace, undef: :replace) if content.encoding == Encoding::UTF_8 && !content.valid_encoding?
  out = []
  skip_until_endif = false
  content.each_line do |line|
    if line =~ /#if\s+__has_include\s*\(\s*<\s*OMSDK_Pubnativenet\//
      skip_until_endif = true
      next
    end
    if skip_until_endif
      skip_until_endif = false if line.strip == '#endif'
      next
    end
    # Also drop standalone Pubnativenet import blocks (single-line or short)
    next if line =~ /#import\s+<\s*OMSDK_Pubnativenet\//
    out << line
  end
  out.join
end

# After removing Pubnative blocks, the "if (HyBid)" branch is empty or only has #endif. So we have:
#   if ([X getIntegrationType] == SDKIntegrationTypeHyBid) {
#   } else if ([X getIntegrationType] == SDKIntegrationTypeSmaato) {
#     #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
#     ...
#     #endif
#   }
# So we need to remove "if (...) HyBid/NGSDK) { } else if (...) Smaato) { " and the trailing "}" and keep the middle.
# Step 2: only remove the "}" when it's NOT followed by another "}" (nested case has #endif \n }\n }\n;
# we must keep both braces so the inner "else if" and outer "if (self)" stay closed).
# Note: Script runs after namespace content replacement, so integration type is SDKIntegrationTypeNGSDK.
def keep_only_smaato_after_removal(content)
  sdk_class = content =~ /NGSDK\s+getIntegrationType/ ? 'NGSDK' : 'HyBid'
  # Step 1: Remove "if (...) HyBid/NGSDK) { } else if (...) Smaato) { " so Smaato #if...#endif is at top level.
  # Match both HyBid and NGSDK so it works before or after namespace replacement.
  open_pattern = /\s*if\s*\(\s*\[#{Regexp.escape(sdk_class)}\s+getIntegrationType\]\s*==\s*SDKIntegrationType(?:HyBid|NGSDK)\)\s*\{\s*\n\s*\}\s*else\s+if\s*\(\s*\[#{Regexp.escape(sdk_class)}\s+getIntegrationType\]\s*==\s*SDKIntegrationTypeSmaato\)\s*\{\s*\n/m
  content = content.gsub(open_pattern, "\n    ")
  # Step 2: Remove the single "}" that closed the Smaato block (always one per #endif in these blocks).
  # #endif may be on its own line or on the same line as code (e.g. "];        #endif").
  content.gsub(/(#endif)\s*\n\s*\}\s*\n/m, "\\1\n")
end

# Main SDK file: after namespace, class is NGSDK and constant is SDKIntegrationTypeNGSDK; match both.
def force_smaato_default_and_setter(content)
  content
    .gsub(/static\s+SDKIntegrationType\s+_sdkIntegrationType\s*=\s*SDKIntegrationType(?:HyBid|NGSDK)\s*;/, 'static SDKIntegrationType _sdkIntegrationType = SDKIntegrationTypeSmaato;')
    .gsub(
      /(\+\s*\(void\)\s*setIntegrationType:\s*\(SDKIntegrationType\)\s*integrationType\s*\{\s*)if\s*\(integrationType\s*==\s*0\)\s*\{\s*_sdkIntegrationType\s*=\s*SDKIntegrationType(?:HyBid|NGSDK);\s*\}\s*else\s*\{\s*_sdkIntegrationType\s*=\s*integrationType;\s*\}\s*\}/m,
      '\1_sdkIntegrationType = SDKIntegrationTypeSmaato; }'
    )
end

def process_file(path)
  content = begin
    File.read(path, encoding: 'UTF-8')
  rescue ArgumentError
    File.binread(path).force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace)
  end
  original = content.dup

  if main_sdk_file?(path)
    content = force_smaato_default_and_setter(content)
  end

  if viewability_file?(path)
    content = remove_pubnative_blocks(content)
    content = keep_only_smaato_after_removal(content)
  end

  return false if content == original
  File.write(path, content)
  true
end

# Find all .m files: Viewability (and OMID wrappers) + main SDK in Core/Public.
# Support both BASE_DIR = inner (PubnativeLite/PubnativeLite) and BASE_DIR = outer (PubnativeLite).
inner = File.join(BASE_DIR, 'PubnativeLite')
viewability_dirs = [File.join(BASE_DIR, 'Core', 'Viewability'), File.join(inner, 'Core', 'Viewability')]
public_dirs = [File.join(BASE_DIR, 'Core', 'Public'), File.join(inner, 'Core', 'Public')]
files = []
(viewability_dirs + public_dirs).each do |dir|
  next unless File.directory?(dir)
  Dir[File.join(dir, '**', '*.m')].each { |f| files << f }
end
files.uniq!

processed = 0
files.each do |path|
  next unless viewability_file?(path) || main_sdk_file?(path)
  if process_file(path)
    rel = path.start_with?(BASE_DIR) ? path.sub("#{BASE_DIR}/", '') : path
    puts "  Smaato-only: #{rel}"
    processed += 1
  end
end

puts "OMSDK Smaato-only: updated #{processed} file(s)." if processed > 0