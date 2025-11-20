require 'rake'
require 'open3'
require 'fileutils'

def interactive_terminal?
  @interactive_terminal ||= STDERR.tty? && ENV.fetch('TERM', 'dumb') != 'dumb'
end

def progress_output(message, final: false)
  if interactive_terminal?
    STDERR.print "\r\033[K#{message}"
    STDERR.print "\n" if final
    STDERR.flush
  end
end

# This is a good idea that holman@ had
#
# https://raw.github.com/holman/dotfiles/master/Rakefile
#
# I changed a few things, tho.  I checked in his and then added my changes.  For posterity.
#

task :update => [:pull, :brewup, :link, :ensure_localrc, :install, :shellcheck] do
  # nop
end

task :brewup do
  system "brew cleanup --quiet"
  system "brew update --quiet"
  system "brew upgrade --quiet"
  system "brew autoremove --quiet"
  system "brew cleanup --quiet"
end

task :pull do
  system "git pull --ff-only --quiet"
end

desc "Calls any install.sh scripts"
task :install do
  scripts = Dir.glob('./*/install.sh').sort
  puts "Running install scripts..." unless interactive_terminal?
  scripts.each do |script|
    progress_output("Running #{script}")
    success = system(script)
    unless success
      progress_output("", final: true) if interactive_terminal?
      abort("Install script failed: #{script}")
    end
  end
  if interactive_terminal?
    progress_output("Completed install scripts (#{scripts.length})", final: true)
  else
    puts "Completed install scripts (#{scripts.length})"
  end
end

SHELLCHECK_EXTENSIONS = %w[.sh .bash .ksh .mksh].freeze
SHELLCHECK_SHEBANG = /\A#!.*\b(bash|sh|dash|ksh)\b/.freeze
SHELLCHECK_SKIP_PATTERN = /zsh/i.freeze
SHELLCHECK_LIST_FLAGS = %w[--ls --list].freeze

def shellcheck_ignored?(path)
  dir = File.dirname(path)
  loop do
    shellcheckignore_file = File.join(dir, '.shellcheckignore')
    if File.exist?(shellcheckignore_file)
      ignore_patterns = File.readlines(shellcheckignore_file).map(&:strip).reject { |line| line.empty? || line.start_with?('#') }
      relative_path = path.sub("#{dir}/", '')
      return true if ignore_patterns.any? { |pattern| relative_path.start_with?(pattern) }
    end
    break if dir == '.'
    dir = File.dirname(dir)
  end
  false
end

def shellcheck_shell_script?(path)
  return false unless File.file?(path)
  return false if path.match?(SHELLCHECK_SKIP_PATTERN)
  return true if SHELLCHECK_EXTENSIONS.include?(File.extname(path))
  first_line = File.open(path, &:readline)
  first_line.match?(SHELLCHECK_SHEBANG)
rescue EOFError, Errno::EISDIR, Errno::ENOENT, ArgumentError
  false
end

def shellcheck_targets
  tracked_files = `git ls-files`.split("\n").map { |path| "./#{path}" }
  tracked_files.select do |path|
    shellcheck_shell_script?(path) && !shellcheck_ignored?(path)
  end.sort
end

def shellcheck_list_requested?
  return true if SHELLCHECK_LIST_FLAGS.any? { |flag| ARGV.include?(flag) }
  ENV['LS'] == '1' || ENV['LIST'] == '1'
end

desc "Run shellcheck on all shell scripts to prevent regressions"
task :shellcheck do
  list_only = shellcheck_list_requested?

  progress_output("Scanning for shell scripts...") unless list_only
  puts(list_only ? "Listing shellcheck targets..." : "Running shellcheck...") unless interactive_terminal?

  shell_scripts = shellcheck_targets

  if shell_scripts.empty?
    if interactive_terminal?
      progress_output("No shell scripts found", final: true)
    else
      puts "No shell scripts found"
    end
    next
  end

  if list_only
    puts shell_scripts.join("\n")
    puts "Total shell scripts: #{shell_scripts.length}"
    next
  end

  errors_found = false

  shell_scripts.each do |script|
    progress_output("shellcheck #{script}") if interactive_terminal?
    stdout, stderr, status = Open3.capture3("shellcheck", script)
    unless status.success?
      progress_output("", final: true) if interactive_terminal?
      puts stdout unless stdout.empty?
      warn stderr unless stderr.empty?
      errors_found = true
    end
  end

  if errors_found
    if interactive_terminal?
      progress_output("Shellcheck found issues.", final: true)
    else
      puts "Shellcheck found issues."
    end
    exit 1
  else
    if interactive_terminal?
      progress_output("Shellcheck complete (#{shell_scripts.length} files)", final: true)
    else
      puts "Shellcheck complete (#{shell_scripts.length} files)"
    end
  end
end


desc "Ensure ~/.localrc exists with correct permissions and helpful comment"
task :ensure_localrc do
  localrc_path = File.expand_path('~/.localrc')
  comment_header = <<~COMMENT
    # ~/.localrc
    # Local shell configuration - not checked into git
    # This file is automatically sourced after all dotfiles configs.
    # Use this file to set secret environment variables, machine-specific settings, etc.
    #
    # Example:
    #   export API_KEY="your-secret-api-key"
    #   export DATABASE_PASSWORD="your-secret-password"
    #
  COMMENT

  if File.exist?(localrc_path)
    # File exists, just ensure permissions are correct
    File.chmod(0o600, localrc_path)
    progress_output("Ensured ~/.localrc permissions") if interactive_terminal?
  else
    # File doesn't exist, create it with helpful comment
    File.write(localrc_path, comment_header)
    File.chmod(0o600, localrc_path)
    if interactive_terminal?
      progress_output("Created ~/.localrc with helpful comment", final: true)
    else
      puts "Created ~/.localrc with helpful comment"
    end
  end
end

desc "Hook our dotfiles into system-standard positions."
task :link do
  linkables = Dir.glob('*/**{.symlink}')

  skip_all = false
  overwrite_all = false
  backup_all = false

  linkables.each do |linkable|
    overwrite = false
    backup = false

    file = linkable.split('/').last.split('.symlink').last
    target = "#{ENV["HOME"]}/.#{file}"

    if File.exists?(target) || File.symlink?(target)
      link_dest = "#{`pwd`.chomp}/#{linkable}" # probably rubyish way to do this
      already_done = File.symlink?(target) and File.readlink(target) == link_dest
      if already_done
        next
      end
      unless skip_all || overwrite_all || backup_all || already_done
        puts "File already exists: #{target}"
        puts ""
        puts `ls -l "#{target}"`
        puts ""
        puts "what do you want to do?"
        puts "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all, [q]uit"
        puts ""
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        when /q|Q/ then exit 0
        when 's' then next
        end
      end
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      `mv "$HOME/.#{file}" "$HOME/.#{file}.backup"` if backup || backup_all
    end
    `ln -s "$PWD/#{linkable}" "#{target}"`
  end
end

task :uninstall do

  Dir.glob('**/*.symlink').each do |linkable|

    file = linkable.split('/').last.split('.symlink').last
    target = "#{ENV["HOME"]}/.#{file}"

    # Remove all symlinks created during installation
    if File.symlink?(target)
      FileUtils.rm(target)
    end

    # Replace any backups made during installation
    if File.exists?("#{ENV["HOME"]}/.#{file}.backup")
      `mv "$HOME/.#{file}.backup" "$HOME/.#{file}"`
    end

  end
end

task :default => 'update'
