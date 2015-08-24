module PerforceSwarm
  class FileAlreadyExists < RuntimeError
  end

  class LoginException < RuntimeError
  end

  class IdentityNotFound < LoginException
  end

  class IdentityAmbiguous < LoginException
  end

  class CredentialInvalid < LoginException
  end
end
