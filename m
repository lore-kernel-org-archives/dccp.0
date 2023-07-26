From: Simon Horman <simon.horman@corigine.com>
Date: Wed, 26 Jul 2023 12:59:25 +0000
Subject: Re: [PATCH net] dccp: Allocate enough data in ccid_get_builtin_ccids()
Message-Id: <ZMEY9aPRSpiy+qie@corigine.com>
List-Id: <dccp.vger.kernel.org>
References: <35ed2523-49ee-4e2b-b50d-38508f74f93f@moroto.mountain>
In-Reply-To: <35ed2523-49ee-4e2b-b50d-38508f74f93f@moroto.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Jul 26, 2023 at 02:56:01PM +0200, Simon Horman wrote:
> On Wed, Jul 26, 2023 at 01:47:02PM +0300, Dan Carpenter wrote:
> > This is allocating the ARRAY_SIZE() instead of the number of bytes.  The
> > array size is 1 or 2 depending on the .config and it should allocate
> > 8 or 16 bytes instead.
> > 
> > Fixes: ddebc973c56b ("dccp: Lockless integration of CCID congestion-control plugins")
> > Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
> 
> Reviewed-by: Simon Horman <simon.horman@corigine.com>

Sorry, I was a bit hasty there.

> > --- a/net/dccp/ccid.c
> > +++ b/net/dccp/ccid.c
> > @@ -48,7 +48,8 @@ bool ccid_support_check(u8 const *ccid_array, u8 array_len)
> >   */
> >  int ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len)
> >  {
> > -       *ccid_array = kmalloc(ARRAY_SIZE(ccids), gfp_any());
> > +       *ccid_array = kmalloc_array(ARRAY_SIZE(ccids), sizeof(*ccid_array),
> > +                                   gfp_any());

The type of *ccid_array is u8.
But shouldn't this be something more like sizeof(struct ccid_operations)
or sizeof(ccids[0]) ?

> >         if (*ccid_array = NULL)
> >                 return -ENOBUFS;
