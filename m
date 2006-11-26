From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 17:32:12 +0000
Subject: Re: [PATCH 3/6]: Fix calculation of t_ipi time of scheduled transmission
Message-Id: <39e6f6c70611260932j5cde0d98q5012817b3a335edb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
In-Reply-To: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/21/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Fix calculation of t_ipi time of scheduled transmission
>
> Problem:
> --------
>  Currently packet transmissions are not scheduled according to [RFC 3448, 4.6] and
>  will, in the worst case, be sent later than necessary. If scheduled transmission
>  requires using a delay, the current delay value is also larger as necessary.
>
> Solution:
> ---------
>  This patch fixes time and delay calculation for scheduling CCID 3 packets.
>
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
>
>
>
>     D e t a i l e d   D e r i v a t i o n   [not meant as commit message]

Gerrit,

       Why not use these valuable detailed derivations in the commit
messages? I'm very much in favour of having them in the git logs,
please let me know if you won't mind me doing that, no need to
resubmit, I'd just remove the [] part.

Thanks a lot,

- Arnaldo
