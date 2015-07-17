use strict;
use warnings;
use Test::More;

BEGIN { use_ok('HTTP::Headers::Fast') }

can_ok( HTTP::Headers::Fast::, '_standardize_field_name' );

{
    $HTTP::Headers::Fast::TRANSLATE_UNDERSCORE = 1;
    is(
        HTTP::Headers::Fast::_standardize_field_name('hello_world_'),
        'hello-world-',
        'All underscores are converted to dashes',
    );
}

{
    $HTTP::Headers::Fast::TRANSLATE_UNDERSCORE = 0;
    is(
        HTTP::Headers::Fast::_standardize_field_name('hello_world_'),
        'hello_world_',
        'Respect $TRANSLATE_UNDERCORE global',
    );
}

{
    $HTTP::Headers::Fast::TRANSLATE_UNDERSCORE = 0;
    is(
        HTTP::Headers::Fast::_standardize_field_name('hello_world_'),
        'hello_world_',
        'Test that caching works (as much as we can)',
    );
}

done_testing;
