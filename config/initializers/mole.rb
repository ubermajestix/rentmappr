require 'mole'
::Mole.initialize( :moleable       => true, 
                   :application    => "rentmappr",
                   :perf_threshold => 2,
                   :log_file         => $stdout,
                      :log_level        => :debug,
                   :mole_config    => File.join( RAILS_ROOT, %w[config moles]) )
# 
# Mole.initialize( :moleable         => true,
#                  :application      => "rentmappr",
#                  :emole_from       => "MoleBeatch@rentmappr.com",
#                  :emole_recipients => ['tyler@collectiveintellect.com'],
#                  :mode             => :persistent,
#                  :log_file         => $stdout,
#                  :log_level        => :debug,
#                  :perf_threshold   => 2,
#                  :mole_config    =>  File.join( File.dirname(__FILE__), %w[config_mole.rb] ) )
 ::Mole.dump