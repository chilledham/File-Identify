package File::Identify;

use 5.010;
use strict;
use warnings;
use Carp;
use Data::Dumper;

use lib '/Users/collin/scripts/git/File-Identify/lib';
use File::Identify::Item;

our $VERSION = '0.01';

my @dirs; # will contain list of directories to search
my @exts; # will contain list of file extensions to search for, case insensitive

# create a new F::I object. Accepts a list of directories to peruse
sub new {
    my $class = shift;

    my $self =
        bless { _items => File::Identify::Item->new() }, $class;

    # check and store any directories passed to `new'
    $self->directory(@_);

    return $self;
}

# when called with a list, stores each item (if the item is a valid directory)
# when called in list context returns all stored directories
sub directory {
    my $self     = shift;
    my @new_dirs = @_;

    my $store_dir = sub {
        my $dir = shift @_;

        -e $dir && -d $dir
            ? push @dirs, $dir
        : carp "$dir is not a valid directory, ignoring";
    };

    $store_dir->($_) for @new_dirs;

    wantarray
        ? return @dirs
    : return;
}

# not supported XXX
sub extension {
    my $self     = shift;
    my @new_exts = @_;

    my $store_ext = sub {
        push @exts, shift @_;
    };

    $store_ext->($_) for @new_exts;

    wantarray
        ? return @exts
    : return;
}

sub scan {
    my $self = shift;

    # do nothing unless some directories have been set
    return unless scalar @dirs;

    $self->_rscan($_) for @dirs;

    return;
}

# send to F::I::Item
sub item {
    my $self = shift;
    return $self->{_items}->item(@_);
}

# same as above. sometimes it feels more natural to request your `items' over just `item'
sub items {
    my $self = shift;
    return $self->{_items}->item(@_);
}

# this should be the only place that sends items to F::I::Item
sub _rscan {
    my $self = shift;
    my $file = shift;

    $file =~ s/\/+\Z//g;

    if (-d $file) {
        # store directory
        $self->item($file);

        # open directory & check contents
        opendir DIR, $file
            or croak "Could not open $file: $!\n";
        
        my @files = map { "$file/$_" } grep { ! /\A\.{1,2}\Z/ } readdir DIR;
        closedir DIR;

        $self->_rscan($_) for @files;
    }
    else {
        $self->item($file);
    }

    return;
}

1;
