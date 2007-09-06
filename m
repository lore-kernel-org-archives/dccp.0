From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:52:24 +0000
Subject: Re: [PATCH 9/10]: Support for server holding timewait state
Message-Id: <5640c7e00709052152nf1f2544h91c7dc30f1b5a604@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Support for server holding timewait state
>
> This adds a socket option and signalling support for the case where the server
> holds timewait state on closing the connection, as described in RFC 4340, 8.3.
>
> Since holding timewait state at the server is the non-usual case, it is enabled
> via a socket option. Documentation for this socket option has been added.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

One comment below, but otherwise:
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -497,6 +497,12 @@ static int do_dccp_setsockopt(struct soc
>                                                      (struct dccp_so_feat __user *)
>                                                      optval);
>                 break;
> +       case DCCP_SOCKOPT_SERVER_TIMEWAIT:
> +               if (dp->dccps_role != DCCP_ROLE_SERVER)
> +                       err = -EOPNOTSUPP;
> +               else
> +                       dp->dccps_server_timewait = (val > 0);
> +               break;

When I did my faster restart I checked how Nagle for TCP was done (I
think it was that one I read) and copied the code for mine to be like
this:

		if (val)
			hcrx->ccid3hcrx_extensions |= TFRC_EXT_FASTER_RESTART;
		else
			hcrx->ccid3hcrx_extensions &= ~TFRC_EXT_FASTER_RESTART;

I think yours would be better like this or
                       dp->dccps_server_timewait = (val != 0);

Remember true is just non-zero and some languages actually make true -1.

Regards,

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
