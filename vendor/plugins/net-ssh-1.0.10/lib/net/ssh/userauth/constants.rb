#--
# =============================================================================
# Copyright (c) 2004,2005 Jamis Buck (jamis@37signals.com)
# All rights reserved.
#
# This source file is distributed as part of the Net::SSH Secure Shell Client
# library for Ruby. This file (and the library as a whole) may be used only as
# allowed by either the BSD license, or the Ruby license (or, by association
# with the Ruby license, the GPL). See the "doc" subdirectory of the Net::SSH
# distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# net-ssh website : http://net-ssh.rubyforge.org
# project website: http://rubyforge.org/projects/net-ssh
# =============================================================================
#++

module Net
  module SSH
    module UserAuth

      module Constants

        USERAUTH_REQUEST          = 50
        USERAUTH_FAILURE          = 51
        USERAUTH_SUCCESS          = 52
        USERAUTH_BANNER           = 53

        USERAUTH_PASSWD_CHANGEREQ = 60
        USERAUTH_PK_OK            = 60

      end

    end
  end
end
