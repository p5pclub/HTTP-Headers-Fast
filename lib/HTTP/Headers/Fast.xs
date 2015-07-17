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
    CODE:
        /* underscores to dashes */
        for ( i = 0; i < strlen(field); i++ )
            if ( field[i] == '_' )
                field[i] = '-';

        RETVAL = field;
    OUTPUT: RETVAL
