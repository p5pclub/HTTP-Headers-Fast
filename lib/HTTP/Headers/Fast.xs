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
        HV *standard_case = get_hv(
            "HTTP::Headers::Fast::standard_case", 0
        );
        SV **cache_field;
        char *orig;
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
        cache_field = hv_fetch( MY_CXT.cache, field, strlen(field), 1 );
        if (!cache_field) {
            croak("Cannot create cache for fields");
        } else if ( SvOK(*cache_field) ) {
            RETVAL = SvPV_nolen(*cache_field);
            return;
        }

        /* make a copy to represent the original one */
        orig = (char *) malloc( strlen(field) );
        strcpy( orig, field );

        /* lc */
        for ( i = 0; i < strlen(field); i++ )
            field[i] = tolower( field[i] );

        /* uc first char after word boundary */
        SV **standard_case_val = hv_fetch(
            standard_case, field, strlen(field), 1
        );

        if (!standard_case_val)
            croak("hv_fetch() failed. This should not happen.");

        if ( !SvOK(*standard_case_val) ) {
            bool word_boundary = true;

            for (i = 0; i < strlen(orig); i++ ) {
                if ( !isalpha( orig[i] ) ) {
                    word_boundary = true;
                    continue;
                }

                if (word_boundary) {
                    orig[i] = toupper( orig[i] );
                    word_boundary = false;
                }
            }

            *standard_case_val = newSVpv( orig, strlen(orig) );
        }

        sv_setpv( *cache_field, field );

        RETVAL = field;
    OUTPUT: RETVAL
