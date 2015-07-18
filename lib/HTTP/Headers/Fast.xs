#define PERL_NO_GET_CONTEXT     /* we want efficiency */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <string.h>

#define MY_CXT_KEY "HTTP::Headers::Fast::_guts" XS_VERSION

typedef struct {
    HV *cache;
    HV *standard_case;
    SV **translate;
} my_cxt_t;

START_MY_CXT;

MODULE = HTTP::Headers::Fast		PACKAGE = HTTP::Headers::Fast
PROTOTYPES: DISABLE

BOOT:
{
    MY_CXT_INIT;
    MY_CXT.cache         = newHV();
    MY_CXT.standard_case = get_hv( "HTTP::Headers::Fast::standard_case", 0 );
    MY_CXT.translate     = hv_fetch(
        gv_stashpvn( "HTTP::Headers::Fast", 19, 0 ),
        "TRANSLATE_UNDERSCORE",
        20,
        0
    );
}

char *
_standardize_field_name( char *field )
    PREINIT:
        int i;
        SV **cache_field;
        char *orig;
        int len;
        SV *TRANSLATE_UNDERSCORE;
        dMY_CXT;
    CODE:
        /* underscores to dashes */
        TRANSLATE_UNDERSCORE = GvSV( *MY_CXT.translate );

        if (!TRANSLATE_UNDERSCORE)
            croak("$TRANSLATE_UNDERSCORE variable does not exist");

        len = strlen(field);
        if ( SvOK(TRANSLATE_UNDERSCORE) && SvTRUE(TRANSLATE_UNDERSCORE) )
            for ( i = 0; i < len; i++ )
                if ( field[i] == '_' )
                    field[i] = '-';

        /* check the cache */
        cache_field = hv_fetch( MY_CXT.cache, field, len, 0 );
        if ( cache_field && SvOK(*cache_field) ) {
            XSRETURN_PV( SvPV_nolen(*cache_field) );
            return;
        }

        /* make a copy to represent the original one */
        orig = (char *) malloc(len);
        strcpy( orig, field );

        /* lc */
        for ( i = 0; i < len; i++ )
            field[i] = tolower( field[i] );

        /* uc first char after word boundary */
        SV **standard_case_val = hv_fetch(
            MY_CXT.standard_case, field, len, 1
        );

        if (!standard_case_val)
            croak("hv_fetch() failed. This should not happen.");

        if ( !SvOK(*standard_case_val) ) {
            bool word_boundary = true;

            for (i = 0; i < len; i++ ) {
                /* \w is basically A-Za-z0-9_ */
                /* grep isWORDCHAR handy.c */
                /* at least headers aren't in Unicode */
                if (
                     !isalpha( orig[i] )
                  && !isdigit( orig[i] )
                  && orig[i] != '_'
                ) {
                    word_boundary = true;
                    continue;
                }

                if (word_boundary) {
                    orig[i] = toupper( orig[i] );
                    word_boundary = false;
                }
            }

            *standard_case_val = newSVpv( orig, len );
        }

        hv_store( MY_CXT.cache, orig, len, newSVpv(field,len), 0 );
        RETVAL = field;
    OUTPUT: RETVAL
