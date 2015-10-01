require 'sshkey'

class SSHKeyHelper
  attr_reader :dir
  def initialize
    @local_dir_path = Dir.mktmpdir
    LOG.debug @local_dir_path
    @keys = SSHKey.generate

    @private_key = File.open(@local_dir_path+'/private.key', 'w+')
    @private_key.write @keys.private_key
    @private_key.close

    @public_key = File.open(@local_dir_path+'/public.key', 'w+')
    @public_key.write @keys.ssh_public_key
    @public_key.close

    FileUtils.chmod 0600, @private_key
    FileUtils.chmod 0600, @public_key
  end

  def private_key_path
    @private_key.path
  end

  def public_key_path
    @public_key.path
  end

  def delete
    FileUtils.remove_dir(@local_dir_path)
  end
end
