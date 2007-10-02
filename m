From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 02 Oct 2007 18:46:13 +0000
Subject: Re: [PATCH v2 3/3]: Convert Reset code into socket error number
Message-Id: <5640c7e00710021146p64273743m8b363faced134f7d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710021159.38439@strip-the-willow>
In-Reply-To: <200710021159.38439@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> ----------------------------> Patch v2 <-----------------------------------------------------------
> [DCCP]: Convert Reset code into socket error number
>
> This adds support for converting the 11 currently defined Reset codes into system
> error numbers, which are stored in sk_err for further interpretation.
>
> This makes the externally visible API behaviour similar to TCP, since a client
> connecting to a non-existing port will experience ECONNREFUSED.
>
>  * Code 0, Unspecified, is interpreted as non-error (0);
>  * Code 1, Closed (normal termination), also maps into 0;
>  * Code 2, Aborted, maps into "Connection reset by peer" (ECONNRESET);
>  * Code 3, No Connection and
>    Code 7, Connection Refused, map into "Connection refused" (ECONNREFUSED);
>  * Code 4, Packet Error, maps into "No message of desired type" (ENOMSG);
>  * Code 5, Option Error, maps into "Illegal byte sequence" (EILSEQ);
>  * Code 6, Mandatory Error, maps into "Operation not supported on transport endpoint" (EOPNOTSUPP);
>  * Code 8, Bad Service Code, maps into "Invalid request code" (EBADRQC);
>  * Code 9, Too Busy, maps into "Too many users" (EUSERS);
>  * Code 10, Bad Init Cookie, maps into "Invalid request descriptor" (EBADR);
>  * Code 11, Aggression Penalty, maps into "Quota exceeded" (EDQUOT)
>    which makes sense in terms of using more than the `fair share' of bandwidth.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
