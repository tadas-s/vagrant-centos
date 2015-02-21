include rvm
rvm::system_user { vagrant: }

$postgresql = hiera_hash('postgresql', false)

if $postgresql and $postgresql['install'] {
  include postgresql::server
}