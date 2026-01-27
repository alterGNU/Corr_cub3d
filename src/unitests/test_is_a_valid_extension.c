// =[ INCLUDE ]=================================================================
#include "cub3d.h"        // is_a_valid_extension
#include <string.h>       // strcmp
#include <stdio.h>        // printf, fflush
#include <math.h>         // sqrtf
// =[ DEFINE ]==================================================================
#define LEN 90
#define f_name "is_a_valid_extension"
#define E "\033[0m"      // COLOR END
#define CR "\033[0;31m"   // COLOR RED
#define CV "\033[0;32m"   // COLOR GREEN
#define CM "\033[0;33m"   // COLOR BROWN
#define CY "\033[0;93m"   // COLOR YELLOW
#define CB "\033[0;36m"   // COLOR AZURE
#define CG "\033[0;37m"   // COLOR GREY
#define CT "\033[97;100m" // COLOR GREY
#define PASS " \033[37;42m ✓ \033[0m\n"
#define	FAIL " \033[30;41m ✗ \033[0m\n"
#define	S1 CT"="E
#define	S2 CB"*"E
#define	S3 "-"
#define TEST_IS_VALID 1
#define	TEST_IS_NOT_VALID 0
// =[ UTILS FUN ]===============================================================
// -[ PRINTNTIME ]--------------------------------------------------------------
int	printntime(char *str, int n)
{
	for (int i = 0 ; i < n; i++)
		printf("%s", str);
	return (n);
}
// -[ PRINT_TITLE ]-------------------------------------------------------------
void print_title(char *title)
{
	printf(S1""CT);
	int psf = printf("[ %s ]", title);
	printntime(S1, LEN - psf - 1);
	printf(E"\n");
}
// -[ PRINT_SUB_TITLE ]---------------------------------------------------------
void print_subtitle(char *subtitle)
{
	printf(S2""CB);
	int psf = printf("( %s )", subtitle);
	printntime(S2, LEN - psf - 1);
	printf(E"\n");
}
// -[ PRINT_SEP ]---------------------------------------------------------------
void print_sep(char *sep)
{
	int	i = -1;
	while (++i < LEN)
		printf("%s", sep);
	printf("\n\n");
}
// -[ COUNT_CHAR_IN_STR ]-------------------------------------------------------
int	count_char_in_str(char c, char *str)
{
	int	res;

	res = 0;
	while(*str)
	{
		if (*str == c)
			res++;
		str++;
	}
	return (res);
}

// =[ TESTS FUNCTIONS ]=========================================================
/**
 * Check if <res> == is_a_valid_extension(<filename>, <ext>)
 */
int	test(int res, char *filename, char *ext)
{
	int	ft;
	int	psf;

	ft = is_a_valid_extension(filename, ext);
	psf = printf("%s(",f_name);
	printf(CB);
	psf += printf("%s",filename);
	printf(E);
	psf += printf(", ");
	printf(CB);
	psf += printf("%s",ext);
	printf(E);
	psf += printf(")=%d <=> IS %s EXTENSION ? ", ft, res==0?"AN UN-VALID":"A VALID");
	if (res != ft)
	{
		printntime(".", LEN - 4 - psf), printf(FAIL);
		return (1);
	}
	else
	{
		printntime(".", LEN - 4 - psf), printf(PASS);
		return (0);
	}
}

int	main(int ac, char **av, char **ev)
{
	(void) ac;
	(void) av;
	(void) ev;
	int	nb_err = 0;

	print_title("A| NULL and EMPTY args combination");//------------------------------------
	nb_err += test(TEST_IS_NOT_VALID, NULL, NULL);
	nb_err += test(TEST_IS_NOT_VALID, "", NULL);
	nb_err += test(TEST_IS_NOT_VALID, NULL, "");
	nb_err += test(TEST_IS_NOT_VALID, "", "");
	nb_err += test(TEST_IS_NOT_VALID, "file.ext", NULL);
	nb_err += test(TEST_IS_NOT_VALID, NULL, "ext");
	print_sep(S1);

	print_title("B| WRONG filename");//-----------------------------------------------------
	nb_err += test(TEST_IS_NOT_VALID, "filenameext", "ext"); // toto as no dot == no extension
	nb_err += test(TEST_IS_NOT_VALID, "filenameext", ".ext");// toto as no dot == no extension
	nb_err += test(TEST_IS_NOT_VALID, ".ext", "ext");        // toto as no dot == no extension (hidden file)
	nb_err += test(TEST_IS_NOT_VALID, ".ext", ".ext");       // toto as no dot == no extension (hidden file)
	print_sep(S1);

	print_title("C| WRONG extension");//-----------------------------------------------------
	nb_err += test(TEST_IS_NOT_VALID, "filename.ext", "ex");// toto as no dot == no extension
	nb_err += test(TEST_IS_NOT_VALID, "filename.ext", ".ex");// toto as no dot == no extension
	nb_err += test(TEST_IS_NOT_VALID, "filename.ext", "extt");// toto as no dot == no extension
	nb_err += test(TEST_IS_NOT_VALID, "filename.ext", ".extt");// toto as no dot == no extension
	nb_err += test(TEST_IS_NOT_VALID, "filename.ext.md", "ext");// toto as no dot == no extension
	nb_err += test(TEST_IS_NOT_VALID, "filename.ext.md", ".ext");// toto as no dot == no extension
	print_sep(S1);

	print_title("D| GOOD extension");//------------------------------------------------------
	nb_err += test(TEST_IS_VALID, "filename.ext", "ext");// toto as no dot == no extension
	nb_err += test(TEST_IS_VALID, "filename.ext", ".ext");// toto as no dot == no extension
	nb_err += test(TEST_IS_VALID, "filename.ext.py", "py");// toto as no dot == no extension
	nb_err += test(TEST_IS_VALID, "filename.ext.py", ".py");// toto as no dot == no extension
	nb_err += test(TEST_IS_VALID, ".filename.ext.py", "py");// toto as no dot == no extension
	nb_err += test(TEST_IS_VALID, ".filename.ext.py", ".py");// toto as no dot == no extension
	print_sep(S1);

	return (nb_err);
}
