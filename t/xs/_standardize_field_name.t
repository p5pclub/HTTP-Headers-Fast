use strict;
use warnings;
use Test::More;

BEGIN { use_ok('HTTP::Headers::Fast') }

can_ok( HTTP::Headers::Fast::, '_standardize_field_name' );

{
    is(
        HTTP::Headers::Fast::_standardize_field_name('hello_world_'),
        'hello-world-',
        'All underscores are converted to dashes',
    );
}

done_testing;
