package File::Identify::Item;

use strict;
use warnings;
use feature qw'say';
use Carp;
use Data::Dumper;

my @items; # store for all items

# create new F::I::I object
sub new {
    my $class = shift;

    # bless early so we can call package methods
    my $self = bless {}, $class;
    $self->_init_regex();

    return $self;
}

# when called in list context returns an array of all items
# otherwise returns undef.
# accepts an optional list of items to check and store
sub item {
    my $self      = shift;
    my @new_items = @_;

    $self->_parse_item($_) for @new_items;

    wantarray
        ? return @items
    : return;
}

# adds items to @items
# checks if the item is a directory, parses item into pieces (path, name, extension (where applicable))
sub _parse_item {
    my $self     = shift;
    my $raw_item = shift;

    # remove any trailing slashes
    $raw_item =~ s/\/+\Z//;

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

    # check if this item has an extension
    my ($path,$name,$ext) = $raw_item =~ /$self->{_re}->{ext}/;

    if ($path && $name && $ext) {
        @$item{ qw(path name ext) } = ($path, $name, $ext);

        # set ext to lower case. original case is preservered in name
        $item->{ext} = lc $item->{ext};
    }
    else {
        # looks like an item without an extension
        ($path,$name) = $raw_item =~ /$self->{_re}->{noext}/;
        @$item{ qw(path name) } = ($path,$name);
    }
    
    push @items, $item;

    return;
}

# precompiles some regexes that will be used to parse items
sub _init_regex {
    my $self = shift;

    # for files or directories without extensions
    $self->{_re}->{noext} = qr/\A(.*)\/(.*)\Z/;
    # and files with extensions
    $self->{_re}->{ext}   = qr/\A(.*)\/(.*\.(.*?))\Z/;

    return;
}

1;
