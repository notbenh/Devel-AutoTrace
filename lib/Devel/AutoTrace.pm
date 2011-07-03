package DB; 
sub DB {}   # Everyone else is doing it... 

package Devel::AutoTrace;
use strict;
use warnings;
use Sys::Hostname;
use autodie;
use Time::HiRes qw {time};
require Digest::MD5;

# ABSTRACT: A simple way to start to track a large spralling codebase for cruft. 

=head1 NAME 

Devel::AutoTrace - Currently a half baked idea on how to do automatic loging of a codebase such that you can know where the cruft is.

=head1 SYNOPSIS

  > perl -d:AutoTrace my_script.pl
  > cat /tmp/devel_autotrace.log 
  [43a3a8bf38dfabe838eeac5a9daa2180:1309665646.17477] ./my_script.pl : start
  [43a3a8bf38dfabe838eeac5a9daa2180:1309665647.40194] ./my_script.pl : end
  > cat /tmp/43a3a8bf38dfabe838eeac5a9daa2180.traceuse 
  ... 

=head1 DESCRIPTION

{{EXPLAIN WHATS GOING ON HERE}}

=head1 CONFIGURATION

Currently this is done via %ENV, this might change

=head2 AUTOTRACE_LOGROOT

Default is to write to '/tmp', setting $ENV{AUTOTRACE_LOGROOT} will override this. 
You are require to make sure that path exists.

=head2 AUTOTRACE_LOGFILE

Default is 'devel_autotrace.log', set $ENV{AUTOTRACE_LOGFILE} to change.

=head2 AUTOTRACE_UID

Default is to build a md5_hex from $0, time and a random number. 

=head1 LOG FORMAT

Current log format is: 
  [AUTOTRACE_UID:time_hires] $0 : $msg\n

Currently only 'start' and 'end' are tracked. 

=head1 STACK TRACE

Devel::TraceUse is used to build a stack trace that is saved to AUTOTRACE_LOGROOT/AUTOTRACE_UID.traceuse.

=cut

my $root = ${ENV}{AUTOTRACE_LOGROOT} || q{/tmp};
open(my $log, '>>', $ENV{AUTOTRACE_LOGFILE} || qq{$root/devel_autotrace.log} );
my $uid = $ENV{AUTOTRACE_UID} || Digest::MD5::md5_hex(hostname,$0,time,rand(1000));

sub ATLOG ($) { printf $log qq{[%s:%s] %s : %s\n}, $uid, time, $0, join( ' ',@_) }

sub import {
   #my $class = shift;
   ATLOG 'start';

   # TODO: this should be from the callers context
   require Devel::TraceUse;
   Devel::TraceUse->import(sprintf qw{output:%s/%s.traceuse}, $root, $uid);
}

END { ATLOG 'end' }

=head1 TODO

=over

=item * Only 'start' and 'end' are tracked.

=item * ATLOG is not exported... should it be?

=item * Devel::TraceUse is called from Devel::AutoTrace context thus the heading on the report is wrong.

=back

=cut

1;
