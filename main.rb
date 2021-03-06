require 'utils'
require 'pathname'

module Cmds
  OUT = Pathname "out"

  def self.cmd_export(recipient)
    system "gpg", "--import", "pub.gpg" or raise "failed to import public key"

    dir = OUT.join Time.now.utc.strftime '%Y%m%dT%H%M%SZ'
    dir.mkdir

    log = Utils::Log.new
    export_obj = -> obj, args: [], suffix: "" do
      dest = dir.join("#{obj}#{suffix}.json")
      log.info "writing to #{dest.relative_path_from OUT}"
      dest.open 'w' do |f|
        IO.popen ["bw", "list", obj, *args], 'r' do |p|
          IO.copy_stream p, f
        end
        $?.success? or raise "bw list #{obj} failed"
      end
      system "gpg", "--recipient", recipient, "--always-trust",
        "--encrypt", dest.to_s \
        or raise "gpg --encrypt failed"
      dest.delete
    end

    objects.each do |obj|
      next if obj =~ /^org-/
      export_obj.(obj)
    end
    export_obj.("items", args: ["--trash"], suffix: "_trash")
  end

  def self.objects
    s = `bw list --help`
    $?.success? or raise "bw list failed"
    objs = s[/Objects:(.+?)\n\s*\n/m, 1]&.split \
      or raise "list of objects not found"
    objs.size >= 3 or raise "too few objects"
    objs.all? /^[a-z-]+$/ or raise "invalid objects"
    objs
  end
end

if $0 == __FILE__
  require 'metacli'
  MetaCLI.new(ARGV).run Cmds
end
