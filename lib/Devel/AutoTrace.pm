package Devel::AutoTrace;
use strict;
use warnings;
use Sys::Hostname;
use autodie;
use Time::HiRes qw {time};
require Digest::MD5;

# ABSTRACT: A simple way to start to track a large spralling codebase for cruft. 

open(my $log, '>>', $ENV{AUTOTRACE_LOGFILE} || '/tmp/devel_autotrace.log' );
my $uid = Digest::MD5::md5_hex(hostname,$0,time,rand(1000));

sub ALOG ($) { printf $log qq{[%s:%s] %s : %s\n}, $uid, time, $0, join( ' ',@_) }

sub import {
   my $class = shift;
   ALOG 'start';
}

END { ALOG 'end' }


1;
