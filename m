From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 19:38:31 +0000
Subject: Re: [PATCH 3/3]: Convert Reset code into socket error number
Message-Id: <5640c7e00710011238s51f7b00ej6c2934752826659d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709291744.53552@strip-the-willow>
In-Reply-To: <200709291744.53552@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On 9/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Convert Reset code into socket error number
>
> This adds support for converting the 11 currently defined Reset codes int=
o system
> error numbers, which are stored in sk_err for further interpretation.
>
> This makes the externally visible API behaviour similar to TCP, since a c=
lient
> connecting to a non-existing port will experience ECONNREFUSED.
>
>  * Code 0, Unspecified, is interpreted as non-error (0);
>  * Code 1, Closed (normal termination), also maps into 0;
>  * Code 2, Aborted, maps into "Connection reset by peer" (ECONNRESET);
>  * Code 3, No Connection and
>    Code 7, Connection Refused, map into "Connection refused" (ECONNREFUSE=
D);
>  * Code 4, Packet Error, maps into "No message of desired type" (ENOMSG);
>  * Code 5, Option Error, maps into "Illegal byte sequence" (EILSEQ);
>  * Code 6, Mandatory Error, maps into "Operation not supported on transpo=
rt endpoint" (EOPNOTSUPP);
>  * Code 8, Bad Service Code, maps into "Invalid request code" (EBADRQC);
>  * Code 9, Too Busy, maps into "Too many users" (EUSERS);
>  * Code 10, Bad Init Cookie, maps into "Invalid request descriptor" (EBAD=
R);
>  * Code 11, Aggression Penalty, maps into "Quota exceeded" (EDQUOT)
>    which makes sense in terms of using more than the `fair share' of band=
width.
>
> The patch was found to solve the problem reported by R=E9mi Denis-Courmon=
t - many thanks.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/input.c |   48 +++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 39 insertions(+), 9 deletions(-)
>
> --- a/net/dccp/input.c
> +++ b/net/dccp/input.c
> @@ -55,6 +55,42 @@ static void dccp_rcv_closereq(struct soc
>         dccp_send_close(sk, 0);
>  }
>
> +static u8 dccp_reset_code_convert(const u8 code)
> +{
> +       const u8 error_code[] =3D {
> +       [DCCP_RESET_CODE_CLOSED]             =3D 0,       /* normal termi=
nation */
> +       [DCCP_RESET_CODE_UNSPECIFIED]        =3D 0,       /* nothing know=
n */
> +       [DCCP_RESET_CODE_ABORTED]            =3D ECONNRESET,
> +
> +       [DCCP_RESET_CODE_NO_CONNECTION]      =3D ECONNREFUSED,
> +       [DCCP_RESET_CODE_CONNECTION_REFUSED] =3D ECONNREFUSED,
> +       [DCCP_RESET_CODE_TOO_BUSY]           =3D EUSERS,
> +       [DCCP_RESET_CODE_AGGRESSION_PENALTY] =3D EDQUOT,
> +
> +       [DCCP_RESET_CODE_PACKET_ERROR]       =3D ENOMSG,
> +       [DCCP_RESET_CODE_BAD_INIT_COOKIE]    =3D EBADR,
> +       [DCCP_RESET_CODE_BAD_SERVICE_CODE]   =3D EBADRQC,
> +       [DCCP_RESET_CODE_OPTION_ERROR]       =3D EILSEQ,
> +       [DCCP_RESET_CODE_MANDATORY_ERROR]    =3D EOPNOTSUPP,
> +       };
> +

This array is inside the function so is local.

> +       return code <=3D DCCP_RESET_CODE_AGGRESSION_PENALTY? error_code[c=
ode] : 0;

and then you basically don't use half of it.
> +}

So I presume the reason for doing this is that half the codes don't
apply to reset.

However this looks ugly as you're only using half the array. I suspect
that you want this for other purposes too (it would make sense too).
As such then the array should be shifted out of the local function
into the main part of the file.

Ian
