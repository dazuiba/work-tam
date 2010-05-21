# LDAP must be initliazed in the first place
# A defect when ldap and ruby-oci comes together
# see http://dev.rubyonrails.org/ticket/6914
begin
  require 'ldap'
rescue LoadError
  p '========ladp is not installed!======'
end