#define PERL_NO_GET_CONTEXT     /* we want efficiency */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <string.h>

#define MY_CXT_KEY "HTTP::Headers::Fast::_guts" XS_VERSION

typedef struct {
    HV *cache;
} my_cxt_t;


START_MY_CXT;

MODULE = HTTP::Headers::Fast		PACKAGE = HTTP::Headers::Fast
PROTOTYPES: DISABLE

BOOT:
{
    MY_CXT_INIT;
    MY_CXT.cache = newHV();
}

char *
_standardize_field_name( char *field )
    PREINIT:
        int i;
        SV *TRANSLATE_UNDERSCORE = get_sv(
            "HTTP::Headers::Fast::TRANSLATE_UNDERSCORE", 0
        );
        dMY_CXT;
    CODE:
        /* underscores to dashes */
        if (!TRANSLATE_UNDERSCORE)
            croak("$TRANSLATE_UNDERSCORE variable does not exist");

        if ( SvOK(TRANSLATE_UNDERSCORE) && SvTRUE(TRANSLATE_UNDERSCORE) )
            for ( i = 0; i < strlen(field); i++ )
                if ( field[i] == '_' )
                    field[i] = '-';

        /* check the cache */
        SV **cache_field = hv_fetch( MY_CXT.cache, field, strlen(field), 1 );
        if (!cache_field) {
            warn("Cannot create cache for fields");
        } else if ( SvOK(*cache_field) ) {
            RETVAL = SvPV_nolen(*cache_field);
            return;
        }

        sv_setpv( *cache_field, field );

        RETVAL = field;
    OUTPUT: RETVAL
