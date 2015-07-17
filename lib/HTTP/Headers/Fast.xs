#define PERL_NO_GET_CONTEXT     /* we want efficiency */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <string.h>


MODULE = HTTP::Headers::Fast		PACKAGE = HTTP::Headers::Fast
PROTOTYPES: DISABLE

char *
_standardize_field_name( char *field )
    PREINIT:
        int i;
        SV *TRANSLATE_UNDERSCORE = get_sv(
            "HTTP::Headers::Fast::TRANSLATE_UNDERSCORE", 0
        );
    CODE:
        /* underscores to dashes */
        if (!TRANSLATE_UNDERSCORE)
            croak("$TRANSLATE_UNDERSCORE variable does not exist");

        if ( SvOK(TRANSLATE_UNDERSCORE) && SvTRUE(TRANSLATE_UNDERSCORE) )
            for ( i = 0; i < strlen(field); i++ )
                if ( field[i] == '_' )
                    field[i] = '-';

        RETVAL = field;
    OUTPUT: RETVAL
