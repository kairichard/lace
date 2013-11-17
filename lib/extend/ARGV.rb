module KoonArgvExtension
  def named
    @named ||= reject{|arg| arg[0..0] == '-'}
  end

  def options_only
    select {|arg| arg[0..0] == '-'}
  end

  # self documenting perhaps?
  def include? arg
    @n=index arg
  end
  def next
    at @n+1 or raise UsageError
  end

  def value arg
    arg = find {|o| o =~ /--#{arg}=(.+)/}
    $1 if arg
  end

  def force?
    flag? '--force'
  end

  def verbose?
    flag? '--verbose' or !ENV['VERBOSE'].nil?
  end

  def debug?
    flag? '--debug' 
  end

  def quieter?
    flag? '--quieter'
  end

  def interactive?
    flag? '--interactive'
  end

  def dry_run?
    include?('--dry-run') || switch?('n')
  end

  def ignore_deps?
    include? '--ignore-dependencies'
  end

  def flag? flag
    options_only.any? do |arg|
      arg == flag || arg[1..1] != '-' && arg.include?(flag[2..2])
    end
  end

  # eg. `foo -ns -i --bar` has three switches, n, s and i
  def switch? switch_character
    return false if switch_character.length > 1
    options_only.any? do |arg|
      arg[1..1] != '-' && arg.include?(switch_character)
    end
  end

  private

  def downcased_unique_named
    # Only lowercase names, not paths or URLs
    @downcased_unique_named ||= named.map do |arg|
      arg.include?("/") ? arg : arg.downcase
    end.uniq
  end
end
