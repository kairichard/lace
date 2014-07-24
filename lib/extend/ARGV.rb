#Copyright 2009-2014 Max Howell and other contributors.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions
#are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module LaceArgvExtension
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

  def verbose?
    flag? '--verbose' or !ENV['VERBOSE'].nil?
  end

  def debug?
    flag? '--debug'
  end

  def nohooks?
    flag? '--no-hooks'
  end

  def force?
    flag? '--force'
  end

  def interactive?
    flag? '--interactive'
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
