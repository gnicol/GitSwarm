require 'sshkey'

class SSHKeyHelper
  attr_reader :dir
  def initialize
    @dir = Dir.mktmpdir
    LOG.debug @dir
    @keys = SSHKey.generate

    @private_key = File.open(@dir+'/private.key', 'w+')
    @private_key.write @keys.private_key
    @private_key.close

    @public_key = File.open(@dir+'/public.key', 'w+')
    @public_key.write @keys.ssh_public_key
    @public_key.close
  end

  def private_key_path
    @private_key.path
  end

  def public_key_path
    @public_key.path
  end

  def delete
    FileUtils.remove_dir(@dir)
  end
end
