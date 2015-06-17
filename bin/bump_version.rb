#!/usr/bin/env ruby

require 'versionomy'

INFO_PLIST = ARGV[0]
current_version = `/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' #{INFO_PLIST}`.chomp!
next_version = Versionomy.parse(current_version.chomp).bump(:tiny)

# Bump version
STDERR.puts "bump version from #{current_version} to #{next_version}"

# Update version
STDERR.puts "Set version #{next_version}"
`/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString #{next_version}"  #{INFO_PLIST}`
`/usr/libexec/PlistBuddy -c "Set :CFBundleVersion #{next_version}"  #{INFO_PLIST}`

print next_version