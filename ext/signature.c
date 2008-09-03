#include "postgres.h"
#include "fmgr.h"
#include "funcapi.h"

PG_MODULE_MAGIC;

typedef struct
{
	int32		vl_len_; 
	uint32  len;
	uint8   data[1];
}	Signature;

#define MIN(X,Y) ((X) < (Y) ? (X) : (Y))
#define MAX(X,Y) ((X) > (Y) ? (X) : (Y))

#define IN_AGGR         (fcinfo->context && IsA(fcinfo->context, AggState))
#define AGGR_GROW_SIZE 8192

/*
 * fmgr interface macros
 */
#define DatumGetSignatureP(X)		     	((Signature *) PG_DETOAST_DATUM(X))
#define DatumGetSignaturePCopy(X)	   	((Signature *) PG_DETOAST_DATUM_COPY(X))
#define SignaturePGetDatum(X)			   	PointerGetDatum(X)
#define PG_GETARG_SIGNATURE_P(n)	   	DatumGetSignatureP(PG_GETARG_DATUM(n))
#define PG_GETARG_SIGNATURE_P_COPY(n) DatumGetSignaturePCopy(PG_GETARG_DATUM(n))
#define PG_RETURN_SIGNATURE_P(x)	   	return SignaturePGetDatum(x)

/* Header overhead *in addition to* VARHDRSZ */
#define SIGNATUREHDRSZ			sizeof(uint32)


Datum sig_in( PG_FUNCTION_ARGS );
Datum sig_out( PG_FUNCTION_ARGS );
Datum sig_resize( PG_FUNCTION_ARGS );
Datum sig_set( PG_FUNCTION_ARGS );
Datum sig_get( PG_FUNCTION_ARGS );
Datum sig_contains( PG_FUNCTION_ARGS );
Datum sig_length( PG_FUNCTION_ARGS );
Datum sig_count( PG_FUNCTION_ARGS );
Datum sig_min( PG_FUNCTION_ARGS );
Datum sig_and( PG_FUNCTION_ARGS );
Datum sig_or( PG_FUNCTION_ARGS );
Datum sig_xor( PG_FUNCTION_ARGS );
Datum sig_on( PG_FUNCTION_ARGS );

int COUNT_TABLE[] = {
  0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
  1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
  1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
  1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
  3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
  4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8,
};

PG_FUNCTION_INFO_V1( sig_in );

Datum
sig_in( PG_FUNCTION_ARGS )
{
	char *arg = PG_GETARG_CSTRING(0);
	int32 len,
	      bytes;
	Signature *result;
	
	char *sptr;
	uint8 *bptr;
	uint8 x;
	
	len = strlen(arg);
	bytes = (len + 7) / 8 + VARHDRSZ + SIGNATUREHDRSZ;

	result = (Signature *) palloc0(bytes);
	SET_VARSIZE(result, bytes);
	result->len = len;

	bptr = result->data;
	x = 0x80;
	for (sptr = arg; *sptr; sptr++) {
		if (*sptr == '1') {
			*bptr |= x;
		}
		x >>= 1;
		if (x == 0) {
			x = 0x80;
			bptr++;
		}
	}
	
	PG_RETURN_SIGNATURE_P(result);
}


PG_FUNCTION_INFO_V1( sig_out );

Datum
sig_out( PG_FUNCTION_ARGS )
{
	Signature	  *s = PG_GETARG_SIGNATURE_P(0);
	char 				*result;
	uint8       *bptr,
							x;
	char        *sptr;
	int32       len,
							i, j, k;
	
	len = s->len;
	result = (char *) palloc(len + 1);
	bptr = s->data;
	sptr = result;
	
	for (i = 0; i <= len - 8; i += 8, bptr++) {
		x = *bptr;
		for (j = 0; j < 8; j++) {
			*sptr++ = (x & 0x80) ? '1' : '0';
			x <<= 1;
		}
	}
	if (i < len) {
		x = *bptr;
		for (k = i; k < len; k++) {
				*sptr++ = (x & 0x80) ? '1' : '0';
				x <<= 1;
		}
	}
	*sptr = '\0';

	PG_RETURN_CSTRING(result);	
}


PG_FUNCTION_INFO_V1( sig_resize );

Datum
sig_resize( PG_FUNCTION_ARGS )
{
	Signature *sig,
		        *res;
	int32 sigbytes,
	      resbytes,
				reslen;
	
	sig = PG_GETARG_SIGNATURE_P(0);
	sigbytes = VARSIZE(sig) - VARHDRSZ - SIGNATUREHDRSZ;
	
	reslen = PG_GETARG_INT32(1);
	resbytes = (reslen + 7) / 8;
	
	res = (Signature *) palloc0( resbytes + VARHDRSZ + SIGNATUREHDRSZ );
	SET_VARSIZE(res, resbytes + VARHDRSZ + SIGNATUREHDRSZ);
	res->len = reslen;
	
	memcpy(res->data, sig->data, MIN(sigbytes, resbytes));
	
	PG_FREE_IF_COPY(sig, 0);
	
	PG_RETURN_SIGNATURE_P( res );
}


PG_FUNCTION_INFO_V1( sig_set );

Datum
sig_set( PG_FUNCTION_ARGS )
{
	Signature *sig,
		        *res;
	int32 sigbytes,
	      resbytes,
	      index,
	      bit,
	      byte_offset,
				bit_offset;
	uint8 c;
	
	sig = PG_GETARG_SIGNATURE_P(0);
	sigbytes = VARSIZE(sig) - VARHDRSZ - SIGNATUREHDRSZ;
	
	index = PG_GETARG_INT32(1);
	if (PG_NARGS() == 3) {
		bit = PG_GETARG_INT32(2);
	} else {
		bit = 1;
	}
  
  byte_offset = index / 8;
  bit_offset  = index % 8;
	
	if (byte_offset >= sigbytes) {
		resbytes = byte_offset + (IN_AGGR ? AGGR_GROW_SIZE : 1);
	} else {
		resbytes = sigbytes;
	}
	
	if (IN_AGGR && resbytes == sigbytes) {
		res = sig;
	} else {
		res = (Signature *) palloc0( resbytes + VARHDRSZ + SIGNATUREHDRSZ );
		SET_VARSIZE(res, resbytes + VARHDRSZ + SIGNATUREHDRSZ );	
		memcpy(res->data, sig->data, MIN(sigbytes, resbytes));
	}
	res->len = MAX(sig->len, index+1);
	
	c = res->data[byte_offset];
	if (bit) {
		c |= (0x80 >> bit_offset);
	} else {
		c &= ~(0x80 >> bit_offset);
	}
	res->data[byte_offset] = c;
	
	PG_FREE_IF_COPY(sig, 0);
	
	PG_RETURN_SIGNATURE_P( res );
}


PG_FUNCTION_INFO_V1( sig_get );

Datum
sig_get( PG_FUNCTION_ARGS )
{
	Signature *sig;
	int32 sigbytes,
	      index,
	      byte_offset,
				bit_offset,
				c,
				bit;
	
	sig = PG_GETARG_SIGNATURE_P(0);
	sigbytes = VARSIZE(sig) - VARHDRSZ - SIGNATUREHDRSZ;
	
	index = PG_GETARG_INT32(1);
	
	if (index > sig->len) {
		bit = 0;
	} else {
  		byte_offset = index / 8;
	  	bit_offset  = index % 8;
	
	  	c = sig->data[byte_offset];
	    if (c & (0x80 >> bit_offset)) {
	      bit = 1;
	    } else {
	      bit = 0;
	    }
	}
	
	PG_FREE_IF_COPY(sig, 0);
	
	PG_RETURN_INT32( bit );
}


PG_FUNCTION_INFO_V1( sig_contains );

Datum
sig_contains( PG_FUNCTION_ARGS )
{
	Signature *sig;
	int32 sigbytes,
	      index,
	      byte_offset,
				bit_offset,
				c,
				bit;
	
	sig = PG_GETARG_SIGNATURE_P(0);
	sigbytes = VARSIZE(sig) - VARHDRSZ - SIGNATUREHDRSZ;
	
	index = PG_GETARG_INT32(1);
	
	if (index > sig->len) {
		bit = 0;
	} else {
  		byte_offset = index / 8;
	  	bit_offset  = index % 8;
	
	  	c = sig->data[byte_offset];
	    if (c & (0x80 >> bit_offset)) {
	      bit = 1;
	    } else {
	      bit = 0;
	    }
	}
	
	PG_FREE_IF_COPY(sig, 0);
	
	PG_RETURN_BOOL( bit == 1 );
}


PG_FUNCTION_INFO_V1( sig_length );

Datum
sig_length( PG_FUNCTION_ARGS )
{	
  Signature *sig;
	int32 length;

	sig = PG_GETARG_SIGNATURE_P(0);
	length = sig->len;
	
	PG_FREE_IF_COPY( sig, 0 );

	PG_RETURN_INT32( length );
}


PG_FUNCTION_INFO_V1( sig_count );

Datum
sig_count( PG_FUNCTION_ARGS )
{	
  Signature *sig;
	int32 sigbytes,
	      count,
	      i;
	uint8 ch;
	
	sig = PG_GETARG_SIGNATURE_P(0);
	sigbytes = VARSIZE(sig) - VARHDRSZ - SIGNATUREHDRSZ;
	
	count = 0;
	for(i=0; i < sigbytes; i++) {
		ch = sig->data[i];
		count += COUNT_TABLE[ch];
	}
	
	PG_FREE_IF_COPY( sig, 0 );

	PG_RETURN_INT32( count );
}


PG_FUNCTION_INFO_V1( sig_min );

Datum
sig_min( PG_FUNCTION_ARGS )
{	
  Signature *sig;
	int32 sigbytes,
	      min,
				i;
	uint8 ch, x;
	
	sig = PG_GETARG_SIGNATURE_P(0);
	sigbytes = VARSIZE(sig) - VARHDRSZ - SIGNATUREHDRSZ;
	
	min = - 1;
	i = 0;
	while (i < sigbytes && min < 0) {
		ch = sig->data[i];
		if (ch > 0) {
			min = i * 8;
			x = 0x80;
			while ((ch & x) == 0) {
				x >>= 1;
				min++;
			}
		}
		i++;
	}
	
	PG_FREE_IF_COPY( sig, 0 );

	if (min < 0) {
		PG_RETURN_NULL();
	} else {
		PG_RETURN_INT32( min );
	}
}


PG_FUNCTION_INFO_V1( sig_and );

Datum
sig_and( PG_FUNCTION_ARGS )
{
	Signature *sig1, 
	          *sig2,
		        *res;
	int32 sig1bytes, 
	      sig2bytes,
		    resbytes,
				i;
	
	sig1 = PG_GETARG_SIGNATURE_P(0);
	sig1bytes = VARSIZE(sig1) - VARHDRSZ - SIGNATUREHDRSZ;
	
	sig2 = PG_GETARG_SIGNATURE_P(1);
	sig2bytes = VARSIZE(sig2) - VARHDRSZ - SIGNATUREHDRSZ;
	
	resbytes = MAX(sig1bytes, sig2bytes);
	
	if (IN_AGGR && resbytes == sig1bytes) {
		res = sig1;
	} else {
		res = (Signature *) palloc0( resbytes + VARHDRSZ + SIGNATUREHDRSZ );
		SET_VARSIZE(res, resbytes + VARHDRSZ + SIGNATUREHDRSZ );
	}
	res->len = MAX(sig1->len, sig2->len);
	
	for(i=0; i<resbytes; i++) {
		if (i < sig1bytes && i < sig2bytes) {
			res->data[i] = sig1->data[i] & sig2->data[i];
		}
	}
	
	PG_FREE_IF_COPY(sig1, 0);
	PG_FREE_IF_COPY(sig2, 1);
	
	PG_RETURN_SIGNATURE_P( res );
}


PG_FUNCTION_INFO_V1( sig_or );

Datum
sig_or( PG_FUNCTION_ARGS )
{
	Signature *sig1, 
	          *sig2,
		        *res;
	int32 sig1bytes, 
	      sig2bytes,
		    resbytes,
				i;
	
	sig1 = PG_GETARG_SIGNATURE_P(0);
	sig1bytes = VARSIZE(sig1) - VARHDRSZ - SIGNATUREHDRSZ;
	
	sig2 = PG_GETARG_SIGNATURE_P(1);
	sig2bytes = VARSIZE(sig2) - VARHDRSZ - SIGNATUREHDRSZ;
	
	resbytes = MAX(sig1bytes, sig2bytes);
	
	if (IN_AGGR && resbytes == sig1bytes) {
		res = sig1;
	} else {
		res = (Signature *) palloc0( resbytes + VARHDRSZ + SIGNATUREHDRSZ );
		SET_VARSIZE(res, resbytes + VARHDRSZ + SIGNATUREHDRSZ );
	}
	res->len = MAX(sig1->len, sig2->len);
	
	for(i=0; i<resbytes; i++) {
		if (i < sig1bytes && i < sig2bytes) {
			res->data[i] = sig1->data[i] | sig2->data[i];
		}
	}
	
	PG_FREE_IF_COPY(sig1, 0);
	PG_FREE_IF_COPY(sig2, 1);
	
	PG_RETURN_SIGNATURE_P( res );
}


PG_FUNCTION_INFO_V1( sig_xor );

Datum
sig_xor( PG_FUNCTION_ARGS )
{
	Signature *sig,
		        *res;
	int32 bytes,
	      bits,
				i;
	uint8	x;
	
	sig = PG_GETARG_SIGNATURE_P(0);
	bytes = VARSIZE(sig) - VARHDRSZ - SIGNATUREHDRSZ;
	bits = sig->len % 8;
	
	res = (Signature *) palloc0( bytes + VARHDRSZ + SIGNATUREHDRSZ );
	SET_VARSIZE(res, bytes + VARHDRSZ + SIGNATUREHDRSZ );
	res->len = sig->len;
	
	for(i=0; i<bytes; i++) {
		res->data[i] = ~(sig->data[i]);
	}
	
	if (bits > 0) {
		x = 0xFF >> bits;
		res->data[bytes-1] &= ~x;
	}
	
	PG_FREE_IF_COPY(sig, 0);
	
	PG_RETURN_SIGNATURE_P( res );
}
