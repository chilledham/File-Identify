package File::Identify::Item;

use strict;
use warnings;
use feature qw'say';
use Carp;
use Data::Dumper;

my @items; # store for all items

sub new {
    return bless {}, shift;
}

sub item {
    my $self      = shift;
    my @new_items = @_;

    $self->_parse_item($_) for @new_items;

    wantarray
        ? return @items
    : return;
}

sub _parse_item {
    my $self     = shift;
    my $raw_item = shift;

    # remove any trailing slashes
    $raw_item =~ s/\/+\Z//;

    $self->_init_regex()
        unless $self->{_re};

    # item shell
    my $item = {
        is_dir => undef,
        path   => undef,
        name   => undef,
        ext    => undef,
        size   => undef,
    };

    # directory check
    if (-d $raw_item) {
        $item->{is_dir}++;

        # split into pieces
        my ($path,$name) = $raw_item =~ /$self->{_re}->{noext}/;
        @$item{qw(path name)} = ($path, $name);

        push @items, $item;
        return;
    }

    # set size
    $item->{size} = (stat $raw_item)[7];

    my ($path,$name,$ext) = $raw_item =~ /$self->{_re}->{ext}/;

    if ($path && $name && $ext) {
        @$item{ qw(path name ext) } = ($path, $name, $ext);

        # set ext to lower case. original case is preservered in name
        $item->{ext} = lc $item->{ext};
    }
    else {
        ($path,$name) = $raw_item =~ /$self->{_re}->{noext}/;
        @$item{ qw(path name) } = ($path,$name);
    }
    
    push @items, $item;

    return;
}

sub _init_regex {
    my $self = shift;

    # for files or directories without extensions
    $self->{_re}->{noext} = qr/\A(.*)\/(.*)\Z/;
    # and files with extensions
    $self->{_re}->{ext}   = qr/\A(.*)\/(.*\.(.*?))\Z/;

    return;
}

1;
