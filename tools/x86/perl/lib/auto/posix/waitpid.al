# NOTE: Derived from ..\..\lib\POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 763 "..\..\lib\POSIX.pm (autosplit into ..\..\lib\auto/POSIX/waitpid.al)"
sub waitpid {
    usage "waitpid(pid, options)" if @_ != 2;
    CORE::waitpid($_[0], $_[1]);
}

# end of POSIX::waitpid
1;
