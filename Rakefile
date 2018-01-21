require 'rake'

# This is a good idea that holman@ had
#
# https://raw.github.com/holman/dotfiles/master/Rakefile
#
# I changed a few things, tho.  I checked in his and then added my changes.  For posterity.
#

task :update => [:pull, :setup] do
  # nop
end

task :pull do
  puts `git pull`
end

task :setup do
  scripts = Dir.glob('*/**/install.sh').sort
  scripts.each do |script|
    puts script
    puts `#{script}`
  end
end


desc "Hook our dotfiles into system-standard positions."
task :install do
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

task :default => 'install'
